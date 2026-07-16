---
title: Procesador de pagos
parent: Operaciones
nav_order: 3
render_with_liquid: false
lang: es
---

# Procesador de pagos

## Última actualización

16 de julio de 2026

The Pool utiliza Stripe como procesador de pagos, con Cloudflare Worker como límite canónico de pago, aporte, webhook y liquidación. El sitio público puede recopilar la intención del carrito, pero Worker reconstruye la forma del dinero, crea sesiones Stripe, mantiene los aportes y luego cobra los métodos de pago guardados solo cuando una campaña de todo o nada tiene éxito.

Este documento describe la implementación actual desde la configuración hasta la integración. La conciliación instantánea específica del pago y las puertas requeridas antes de que se reanude la liquidación después de la recuperación se documentan en [BACKUP_RESTORE.md](/es/docs/operations/backup-restore/). También incorpora prácticas relevantes de ingeniería fintech del [Manual de ingeniería fintech](https://w.pitula.me/fintech-engineering-handbook/) de Voytek Pitula como guía operativa para The Pool.

## Modelo actual

The Pool no es una billetera de valor almacenado, un libro de mercado ni un sistema de saldo similar a un banco. Es un sistema de aportaciones de crowdfunding:

- Los patrocinadores guardan una tarjeta a través de Stripe Checkout en modo `setup`.
- Worker almacena registros de aporte en Cloudflare KV después de que Stripe confirma la sesión de configuración.
- Las tarjetas no se cargan en el momento del aporte.
- Después de la fecha límite de la campaña, las campañas financiadas se liquidan mediante la creación de Stripe PaymentIntents fuera de sesión con los métodos de pago guardados.
- Un pago de varias campañas se distribuye en un registro de aporte de alcance de campaña por campaña después de la confirmación.
- El envío, los impuestos y propina de plataforma se cobran en dólares, pero no todos cuentan para el progreso de la financiación de la campaña.

Stripe posee datos de tarjetas y campos de pago sensibles a PCI. The Pool posee la intención de aporte, la contabilidad de campañas, los correos electrónicos, los informes del panel y la orquestación de acuerdos.

## Principios de ingeniería

El código de pago debe optimizarse para lograr una corrección aburrida sobre la inteligencia.

### Sin dinero inventado

Los valores monetarios en tiempo de ejecución que ingresan al almacenamiento de aportes, informes, correos electrónicos y solicitudes Stripe se representan como centavos enteros. Los autores de campañas y los archivos de configuración pueden usar dólares o tarifas por usabilidad, pero los registros Worker y las llamadas al procesador deben usar centavos en el límite.

Reglas para un nuevo código de pago:

- No almacene los montos prometidos como flotaciones.
- Empareja cada cantidad con su significado: `subtotal`, `tax`, `shipping`, `tipAmount`, `amount`.
- Mantenga explícitos los supuestos monetarios. El despliegue actual está orientado al USD; no introduzca silenciosamente campos multidivisa.
- Redondee solo en límites controlados y luego almacene el valor del centavo redondeado.
- El progreso de la campaña utiliza el subtotal de la campaña, no el importe total cobrado.

### Ningún estado perdido

El Worker debe poder explicar qué sucedió con un aporte incluso cuando una devolución de llamada externa se retrasa, se duplica o se vuelve a intentar.

Superficies del estado actual:

- `pledge:{orderId}` almacena el registro de aporte y `history`.
- `campaign-pledges:{slug}` indexa los ID de pedidos para informes, liquidaciones, reposiciones y lecturas de paneles.
- `stats:{slug}` y `tier-inventory:{slug}` son proyecciones reconstruibles.
- `stripe-event:{event.id}` evita el procesamiento de webhooks duplicados.
- `processor-event:v1:*` conserva la evidencia de solicitud/webhook redactada de Stripe durante 400 días.
- `checkout-intent:{orderId}` almacena el manifiesto de pago utilizado para conservar los pagos empaquetados.
- `settlement-job:{slug}` realiza un seguimiento del progreso de la liquidación por lotes.
- `settlement-group:v1:{slug}:*` registra el estado de precarga duradera para un grupo determinista de carga de campaña/patrocinador.
- `reconciliation-break:v1:{slug}:*` registra diferencias explícitas abiertas o resueltas entre la verdad del aporte, el trabajo de liquidación y Stripe.
- Los resúmenes de observabilidad del rendimiento y webhooks se encuentran en `PLEDGES` KV para que los revise el operador.

El sistema actual no mantiene un libro de doble entrada. Si The Pool posteriormente mantiene saldos, divide pagos, admite reembolsos o maneja movimientos de dinero entre múltiples partes, agregue un verdadero libro de contabilidad de solo anexos con saldos derivados en lugar de extender las proyecciones de aportes a la verdad contable.

### Sin confianza ciega

El navegador, la orden de entrega del webhook Stripe y el éxito de la API externa se tratan como entradas que no son de confianza.

Controles actuales:

- `/checkout-intent/start` reconstruye totales a partir de artículos de carrito propios, definiciones de campaña, reglas de envío, resultados del proveedor de impuestos y límites de propinas configurados.
- Los tokens de intención de pago están firmados por HMAC y son de corta duración.
- La reserva y liquidación de nivel limitado se serializan a través de Durable Objects.
- Las firmas del webhook Stripe se verifican en el cuerpo de la solicitud sin formato.
- Las llamadas Stripe utilizan claves de idempotencia donde la ejecución repetida podría crear un movimiento de dinero duplicado.
- La API Stripe solicita fijar `2026-02-25.clover` hasta que una actualización probada intencional cambie la constante del cliente compartido.
- La liquidación utiliza claves de idempotencia deterministas por grupo de carga de campaña/patrocinador.
- Las respuestas de pago confidenciales son `private, no-store`.
- Las rutas POST de pago y pago requieren el origen del sitio confiable.

## Configuración

Utilice el asistente de configuración de repositorio raíz siempre que sea posible:

```bash
npm run setup:deploy -- --mode=local
npm run setup:deploy -- --mode=production --dry-run
```

El asistente sincroniza la configuración pública en Worker, crea o reutiliza espacios de nombres KV, verifica las CLI del proveedor cuando es posible y escribe secretos solo después de la confirmación.

### Enlaces Worker necesarios

Los entornos de producción y desarrollo Worker necesitan:

- `PLEDGES` KV espacio de nombres
- `RATELIMIT` KV espacio de nombres
- Encuadernación `CHECKOUT_INTENTS` Durable Object
- Encuadernación `TIER_INVENTORY_COORDINATOR` Durable Object
- Encuadernación `SETTLEMENT_COORDINATOR` Durable Object

`VOTES` no es específico de pago, pero la mayoría de las implementaciones completas también lo configuran.

### Configuración pública

Estos valores no son secretos y se encuentran en `_config.yml`, luego se reflejan en `worker/wrangler.toml` a través de `npm run sync:worker-config`:

- `platform.site_url` -> `SITE_BASE`
- `platform.worker_url` -> `WORKER_BASE`
- `platform.timezone` -> `PLATFORM_TIMEZONE`
- `checkout.stripe_publishable_key` -> `STRIPE_PUBLISHABLE_KEY`
- `pricing.sales_tax_rate` -> `SALES_TAX_RATE`
- `pricing.default_tip_percent` -> `DEFAULT_PLATFORM_TIP_PERCENT`
- `pricing.max_tip_percent` -> `MAX_PLATFORM_TIP_PERCENT`
- `tax.*` -> `TAX_*`
- `shipping.*` -> `SHIPPING_*` y `USPS_*`

Las claves publicables de Stripe son visibles para el navegador y pueden almacenarse en config o Worker vars. Las claves secretas y los secretos de webhooks no se deben almacenar en `_config.yml`.

### Secretos requeridos

Los secretos del desarrollo local viven en `worker/.dev.vars` ignorados. Los secretos de producción pertenecen a los secretos Cloudflare Worker:

```bash
wrangler secret put STRIPE_SECRET_KEY_LIVE
wrangler secret put STRIPE_SECRET_KEY_TEST
wrangler secret put STRIPE_WEBHOOK_SECRET_LIVE
wrangler secret put STRIPE_WEBHOOK_SECRET_TEST
wrangler secret put CHECKOUT_INTENT_SECRET
wrangler secret put MAGIC_LINK_SECRET
wrangler secret put ADMIN_SECRET
wrangler secret put ADMIN_SESSION_SECRET
wrangler secret put RESEND_API_KEY
```

Secretos de alcance recomendados:

```bash
wrangler secret put ADMIN_SETTLEMENT_SECRET
wrangler secret put ABANDONED_CART_TOKEN_SECRET
wrangler secret put TURNSTILE_SECRET_KEY
```

Secretos de proveedor opcionales:

```bash
wrangler secret put USPS_CLIENT_SECRET
wrangler secret put ZIP_TAX_API_KEY
```

Cuando un flujo de trabajo de acciones GitHub llama a la liquidación u otras rutas protegidas, agregue también el secreto de alcance coincidente a los secretos del repositorio GitHub. Los secretos del repositorio GitHub no se convierten automáticamente en secretos de tiempo de ejecución de Worker.

### Stripe Webhooks

Cree puntos finales de webhook Stripe para el modo de prueba y en vivo.

Punto final de producción:

```text
https://worker.example.com/webhooks/stripe
```

Eventos:

- `checkout.session.completed`
- `payment_intent.payment_failed`

Copie cada secreto de firma de endpoint en el secreto Worker correspondiente:

- `STRIPE_WEBHOOK_SECRET_TEST`
- `STRIPE_WEBHOOK_SECRET_LIVE`

Para trabajo local, prefiera:

```bash
./scripts/dev.sh --podman
```

Esa ruta puede ejecutar el oyente Stripe, reenviar eventos a `127.0.0.1:8787/webhooks/stripe` y escribir el valor `whsec_...` del oyente en `worker/.dev.vars`.

## Integración de pago

### 1. Carro del navegador

El sitio estático posee la interfaz de usuario del carrito y almacena la estructura del carrito. Puede recopilar selecciones de contactos, envíos, facturación, propinas y carritos, pero no decide los totales finales.

El navegador llama:

```text
POST /checkout-intent/start
```

Los campos importantes incluyen:

- `campaignSlug`
- `items`
- `email`
- `tipPercent`
- `shippingAddress`
- `billingAddress`
- `shippingOption`
- `abandonedCartConsent`

### 2. Canonicalización Worker

El Worker reconstruye el pedido a partir de entradas confiables:

- definiciones de niveles de campaña
- complementos de campaña y complementos de plataforma
- artículos de soporte y cantidades personalizadas
- estado de campaña y puertas de umbral
- disponibilidad de nivel limitado
- ajustes preestablecidos de envío y USPS/política alternativa
- resultado del proveedor de impuestos
- límites de punta configurados

El manifiesto de pago resultante almacena valores de centavos y un hash del carrito canónico. Para un inventario limitado, Worker reserva niveles escasos a través del Durable Object por campaña antes de crear la sesión Stripe.

### 3. Sesión de configuración de Stripe

El Worker crea una sesión de pago Stripe en modo `setup`. La ruta normal devuelve un arranque de pago en el sitio personalizado:

```json
{
  "checkoutUiMode": "custom",
  "sessionId": "cs_test_...",
  "clientSecret": "cs_test_..._secret_...",
  "publishableKey": "pk_test_...",
  "orderId": "pool-intent-..."
}
```

Si el pago personalizado no está disponible porque falta la clave publicable, Worker recurre a una URL de pago Stripe alojada en lugar de fallarle al soporte.

Los metadatos de la sesión Stripe incluyen un contexto de orden e integridad como:

- `orderId`
- `campaignSlug`
- `checkoutProvider`
- `checkoutNonce`
- `checkoutCartHash`
- `amountCents`
- `tipPercent`
- `hasPhysical`
- `preferredLang`

### 4. Finalización y webhook

Stripe envía `checkout.session.completed`. El Worker:

1. Lee el cuerpo de la solicitud sin formato.
2. Verifica la firma Stripe con el secreto del webhook correcto.
3. Comprueba la idempotencia de `stripe-event:{event.id}`.
4. Recupera los detalles de la sesión Stripe, SetupIntent, cliente y método de pago según sea necesario.
5. Carga el manifiesto de pago guardado.
6. Vuelve a calcular el hash de pago y valida el manifiesto.
7. Persiste un registro `pledge:{orderId}` por campaña.
8. Actualiza índices y proyecciones de campaña.
9. Confirma reservas de nivel limitado.
10. Envía un correo electrónico de confirmación al colaborador a través de Resend.
11. Elimina o marca el estado de pago/recordatorio transitorio.
12. Marca el evento Stripe procesado solo después de que la persistencia sea exitosa.

Esto hace que los webhooks duplicados sean seguros y que los fallos transitorios se puedan volver a intentar.

El sidecar de pago personalizado también tiene una ruta de recuperación protegida:

```text
POST /checkout-intent/complete
```

Esa ruta recupera la sesión Stripe y crea el aporte si el webhook se retrasó o se perdió en el desarrollo local. Tiene control de origen, alcance de pedido y límite de reintentos.

## Administrar tarjeta de aporte y actualización

Los patrocinadores gestionan los aportes a través de enlaces mágicos con alcance de pedido, no cuentas.

Llamada de actualizaciones de métodos de pago:

```text
POST /pledge/payment-method/start
```

El Worker crea otra sesión de pago Stripe en modo de configuración. En el modo personalizado, el modo Administrar aporte monta la interfaz de usuario de pago seguro de Stripe en el sitio. Luego, el webhook actualiza los ID de cliente/método de pago del aporte almacenado.

Si el aporte estaba en estado `payment_failed` y la campaña se financia después de la fecha límite, Worker intenta un reintento inmediato fuera de la sesión después de guardar el nuevo método de pago.

## Asentamiento

La liquidación se ejecuta solo después de que haya pasado la fecha límite de la campaña en la zona horaria configurada de la plataforma y la campaña esté financiada.

Ruta preferida:

```text
POST /admin/settle-dispatch/:slug
POST /admin/settle-batch
```

Comportamiento actual:

- `SETTLEMENT_COORDINATOR` bloquea una campaña a la vez.
- `settlement-job:{slug}` realiza un seguimiento del progreso por lotes.
- Cada lote procesa un conjunto limitado de ID de orden de aporte.
- los aportes activos no cobradas se agrupan por correo electrónico de apoyo dentro de la campaña.
- Se utiliza el método de pago guardado más reciente para el grupo de apoyo/campaña.
- Worker crea un PaymentIntent Stripe fuera de sesión por grupo de apoyo/campaña.
- Las claves de idempotencia Stripe son deterministas para el grupo de carga de campaña/patrocinador.
- Antes de llamar a Stripe, `settlement-group:v1:*` persiste como `submitted`; Los ID y estados del procesador exitoso se vuelven a escribir en el mismo registro.
- Los reintentos dentro del horizonte de idempotencia de 24 horas Stripe reutilizan la misma clave. Un PaymentIntent almacenado correctamente se recupera en lugar de volver a crearse.
- Un intento de no respuesta de más de 23 horas se convierte en `needsAttention`; El acuerdo no inventa una nueva clave ni recarga ciegamente al patrocinador.
- `settlement-job:{slug}` almacena el punto de control del lote actual antes del autodespacho y marca las reanudaciones obsoletas para evidencia del operador.
- Los aportes exitosos están marcados como `charged`.
- Los aportes fallidos se marcan como `payment_failed` y se envían por correo electrónico un enlace de Tarjeta de actualización.
- `campaign-charged:{slug}` se escribe sólo cuando no queda ningún aporte activo sin resolver.

La ruta de liquidación monolítica heredada todavía existe para casos pequeños/manuales:

```text
POST /admin/settle/:slug
```

Utilice `ADMIN_SETTLEMENT_SECRET` para la automatización de liquidación cuando esté configurado. Es más estrecho que `ADMIN_SECRET`.

## Modelo de datos

### Registro de aporte

Los campos de dinero prometido son centavos enteros:

```json
{
  "orderId": "pool-intent-abc123",
  "email": "supporter@example.com",
  "campaignSlug": "hand-relations",
  "subtotal": 5000,
  "tax": 394,
  "shipping": 300,
  "tipPercent": 5,
  "tipAmount": 250,
  "amount": 5944,
  "currency": "usd",
  "valueTime": "2026-01-15T12:00:00Z",
  "bookedAt": "2026-01-15T12:00:01Z",
  "stripeCustomerId": "cus_...",
  "stripePaymentMethodId": "pm_...",
  "stripeSetupIntentId": "seti_...",
  "pledgeStatus": "active",
  "charged": false,
  "history": [
    {
      "type": "created",
      "subtotal": 5000,
      "tax": 394,
      "shipping": 300,
      "tipAmount": 250,
      "amount": 5944,
      "at": "2026-01-15T12:00:00Z"
    }
  ]
}
```

los aportes cargados también pueden almacenar datos financieros Stripe reales:

- `stripePaymentIntentId`
- `stripeChargeId`
- `stripeBalanceTransactionId`
- `stripeFinancials.grossAmount`
- `stripeFinancials.feeAmount`
- `stripeFinancials.netAmount`
- `stripeFinancials.source`

Los análisis del panel prefieren datos reales de transacciones de saldo Stripe cuando están presentes y etiquetas de estimaciones cuando faltan datos reales.

Los registros más antiguos sin `currency` se leen como USD. Esta es una compatibilidad predeterminada, no compatibilidad con múltiples monedas. `valueTime` describe cuándo ocurrió el evento de soporte/procesador, `bookedAt` describe la persistencia de Worker y `processorAvailableAt` se completa solo cuando los datos del saldo de Stripe exponen el tiempo de disponibilidad.

### Registros de proyección

Estos son estados útiles, pero no son verdad contable:

- `stats:{slug}`
- `tier-inventory:{slug}`
- `campaign-pledges:{slug}`
- `add-on-inventory-sold:v1`

Utilice comprobaciones de deriva de proyección antes de la reparación:

```bash
./scripts/check-projections.sh
./scripts/check-projections.sh --podman
```

O llama:

```text
POST /stats/:slug/check
POST /admin/projections/check
```

### Lo que no se almacena

The Pool no almacena:

- números de tarjeta
- CVV
- Contenido sin formato del formulario de pago Stripe
- libros de contabilidad completos del procesador de pagos
- saldos permanentes

La implementación actual no conserva las cargas útiles del webhook Stripe sin procesar. Verifica el cuerpo sin formato, almacena ID/estado/cronograma e intención de solicitud redactada, y recupera objetos Stripe nuevamente cuando se necesita recuperación o reposición. Las filas del diario del procesador excluyen datos de tarjetas, direcciones, cargas útiles de metadatos sin procesar y direcciones de correo electrónico de los patrocinadores.

## Operaciones

### Observabilidad del webhook

Usar:

```text
GET /admin/observability/webhooks?days=2
```

O:

```bash
ADMIN_SECRET=... ./scripts/check-observability.sh --local
```

Revise entregas duplicadas, errores de firma, discrepancias de modo, eventos omitidos y resultados recientes.

### Webhook local perdido

Si el pago local se completó en Stripe pero no aparece ningún aporte:

1. Verifique el reenvío CLI de Stripe.
2. Confirme que el `STRIPE_WEBHOOK_SECRET*` local coincida con el oyente en ejecución.
3. Deje que el sidecar de pago vuelva a intentar `/checkout-intent/complete`.
4. Si es necesario, recupérelo manualmente:

```bash
curl -X POST http://localhost:8787/admin/recover-checkout \
  -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
  -H 'Content-Type: application/json' \
  -d '{"sessionId":"cs_test_..."}'
```

### Stripe Relleno financiero

Para aportes cargados más antiguas a las que les faltan detalles de transacción de saldo, los superadministradores pueden usar:

```text
POST /admin/analytics/stripe-financials/backfill
```

El relleno utiliza índices de aportes de campaña y búsquedas agrupadas de Stripe PaymentIntent. No debería escanear todo el espacio de nombres KV durante el funcionamiento normal.

### Lista de verificación de reconciliación

La conciliación se ejecuta diariamente en modo en vivo cuando `PAYMENT_RECONCILIATION_ENABLED=true` y puede ser invocada por un superadministrador:

```text
GET  /admin/reconciliation/:slug
POST /admin/reconciliation/:slug
```

Utiliza `campaign-pledges:{slug}` y recuperaciones limitadas de PaymentIntent. Detecta aportes cobradas a las que les falta un PaymentIntent, discrepancias cobradas/no exitosas, intenciones exitosas pero no reservadas, diferencias de monto/moneda, objetos de procesador no disponibles y trabajos de liquidación obsoletos. Las diferencias actuales son `open`; una pausa antigua que no aparece en una ejecución posterior se marca como `resolved`, lo que conserva la primera/última vista y el recuento de ocurrencias.

Una ruptura crítica abierta es evidencia para detener e investigar, no autoridad para crear un cargo de reemplazo. La recuperación manual de carga ambigua permanece deshabilitada hasta que dos operadores superadministradores distintos estén disponibles para un control real del fabricante/verificador.

Antes y después de la liquidación:

- Confirme que la campaña haya superado la fecha límite en `PLATFORM_TIMEZONE`.
- Realice un ensayo de liquidación cuando sea posible.
- Verifique la deriva de la proyección.
- Revise la observabilidad del webhook.
- Ejecute la conciliación de pagos de campaña y revise las rupturas críticas abiertas.
- Revisar los grupos de liquidación `submitted` de más de 23 horas; verifique Stripe directamente antes de cualquier intervención de código o datos.
- Verifique las filas `payment_failed` y los correos electrónicos de reintento del colaborador.
- Rellene los datos financieros de Stripe cuando los análisis necesiten tarifas/valores netos reales.
- Compare los informes CSV del panel con los resultados del script de aporte/cumplimiento para trabajos de cumplimiento de alto riesgo.

## Pruebas

Controles locales rápidos:

```bash
npm run test:unit
npm run test:security
npx vitest run tests/unit/stripe-client.test.ts tests/unit/email-outbox.test.ts tests/unit/worker-ops-integrity.test.ts
```

Cheques centrados en el pago:

```bash
npm run release:payment-smoke -- --no-dev-vars
npx vitest run \
  tests/unit/checkout-intent.test.ts \
  tests/unit/settlement.test.ts \
  tests/unit/worker-business-logic.test.ts \
  tests/unit/worker-ops-integrity.test.ts
```

Ayudantes locales de flujo completo:

```bash
./scripts/dev.sh --podman
./scripts/test-checkout.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/check-projections.sh --podman
```

Para obtener evidencia de divulgación local que ejerza rutas de aporte mutables sin enviar un correo electrónico:

```bash
PAYMENT_SMOKE_ALLOW_MUTATION=1 \
PAYMENT_SMOKE_WORKER_URL=http://127.0.0.1:8787 \
PAYMENT_SMOKE_SITE_URL=http://127.0.0.1:4000 \
POOL_EMAIL_DRY_RUN=true \
npm run release:payment-smoke -- --local-mutation
```

El humo de pago rechaza la producción de hosts The Pool en busca de evidencia de mutación a menos que se establezca explícitamente `PAYMENT_SMOKE_ALLOW_PRODUCTION=1`.

Tarjetas de prueba manuales Stripe:

- éxito: `4242 4242 4242 4242`
- 3D Seguro: `4000 0000 0000 3220`
- Tarjetas rechazadas/fallidas: utilice el catálogo actual de tarjetas de prueba Stripe

Para el comportamiento del procesador, prefiera el modo de prueba Stripe y la CLI Stripe en lugar de las cargas útiles de webhook creadas manualmente. Los entornos sandbox son útiles, pero no reemplazan la verificación de firmas, las pruebas de idempotencia y las comprobaciones de recuperación/conciliación.

## Documentos relacionados

- [FLUJOS DE TRABAJO.md](/es/docs/development/workflows/)
- [SEGURIDAD.md](/es/docs/operations/security/)
- [PRUEBA.md](/es/docs/operations/testing/)
- [PANEL.md](/es/docs/operations/admin-dashboard/)
- [CORREO ELECTRÓNICO.md](/es/docs/operations/email-system/)
- [trabajador/README.md](/es/docs/operations/worker/)
