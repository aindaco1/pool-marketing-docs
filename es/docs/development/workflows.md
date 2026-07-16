---
title: Flujos de trabajo
parent: Desarrollo
nav_order: 3
render_with_liquid: false
lang: es
---

# Flujos de trabajo

## Última actualización

16 de julio de 2026

The Pool utiliza un **sistema de gestión de aportes basado en correo electrónico y sin cuenta**. Los patrocinadores guardan un método de pago a través de Stripe en el paso de pago en el sitio de The Pool, administran los aportes a través de enlaces mágicos con alcance de pedido y solo se les cobra si la campaña está financiada.

Para la configuración, las operaciones del procesador y la conciliación, utilice [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/). Para instantáneas clasificadas, pedidos de recuperación y puertas de restauración, utilice [BACKUP_RESTORE.md](/es/docs/operations/backup-restore/). Para la configuración del remitente, los tipos de correo electrónico, la localización y el comportamiento de entrega, utilice [EMAIL.md](/es/docs/operations/email-system/).

## Diferenciadores clave

- **Sin cuentas**: solo correo electrónico + información de pago (sin registro)
- **Administración de enlaces mágicos**: cancele, modifique o actualice el método de pago mediante un enlace de correo electrónico relacionado con el pedido
- **Todo o nada**: tarjetas guardadas ahora, cobradas solo si se alcanza el objetivo
- **Sugerencia de plataforma opcional**: 0% a 15% La propina del grupo (5% predeterminado) se agrega a los totales pero se excluye del progreso de la campaña.
- **Correo electrónico propiedad del trabajador**: todos los correos electrónicos de los colaboradores provienen de Resend
- **Centrado en películas**: diseñado para crowdfunding creativo

---

## Máquina de estado de campaña

```
upcoming → live → post
```

|Estado|experiencia de usuario|Acciones|
|-------|-----|---------|
|`upcoming`|Botones deshabilitados, "Próximamente"|Cuenta regresiva para el lanzamiento, registro de recordatorio de lanzamiento único opcional|
|`live`|Botones de aporte activos|Tarjetas guardadas a través del paso de pago Stripe en el sitio de The Pool|
|`post`|Campaña cerrada|Cargos procesados (si están financiados)|

---

## Componentes del sistema

|Componente|Rol|
|-----------|------|
|**Carrito propio**|Interfaz de usuario del carrito propiedad del navegador y estado de revisión del pago|
|**Raya**|Sesiones de pago en modo de configuración (paso de pago personalizado en el sitio) + PaymentIntents (cobrar más tarde)|
|**Trabajador de Cloudflare**|Backend: pago, webhooks, almacenamiento de aportes (KV), lecturas en vivo combinadas, estadísticas, programador de liquidación automática|
|**Jekyll**|Páginas estáticas + rebajas de campaña|
|**Panel de administración**|Espacio de trabajo privado del navegador para configuraciones, campañas, complementos, informes, análisis, patrocinadores, enlaces de marketing y usuarios.|

---

## Ciclo de vida del aporte

```
1. BROWSE     → Visitor views campaign, adds tier to the first-party cart, adjusts optional tip
2. REVIEW     → First-party cart drawer shows pledge review, tip state, and immediate pricing
3. START      → Worker canonicalizes the cart via `/checkout-intent/start`, reserves scarce tiers when needed, and creates a setup-mode Stripe Checkout Session
4. SAVE CARD  → The existing checkout sidecar keeps the visitor on-site, mounts secure Stripe payment UI, and saves the payment method (no charge)
5. CONFIRM    → Stripe confirms the setup, then Worker persists one pledge per campaign in KV, sends campaign-specific supporter email(s), and refreshes live campaign reads before success UX completes
6. MANAGE     → Backer uses magic link to cancel/modify/update card
7. DEADLINE   → Worker scheduler checks campaigns after midnight in the platform timezone
8. CHARGE     → If funded + deadline passed: aggregate by email within each campaign, charge once per supporter per campaign, and store actual Stripe fee/net data when Stripe returns balance transaction details
9. COMPLETE   → Update pledge_status to 'charged' or 'payment_failed'
```

---

## Almacenamiento de aportes (Cloudflare KV)

los aportes se almacenan en Cloudflare KV. Patrones clave:

|Llave|Contenido|
|-----|----------|
|`pledge:{orderId}`|Datos completos del aporte (correo electrónico, monto, nivel, ID de Stripe, estado, historial)|
|`email:{email}`|Conjunto de ID de pedido para ese correo electrónico|
|`stats:{campaignSlug}`|Totales agregados (monto prometido, recuento de aportes, recuentos de niveles, artículos de soporte)|
|`tier-inventory:{campaignSlug}`|Recuento de reclamaciones para niveles limitados|
|`campaign-pledges:{campaignSlug}`|Índice de aportes de campaña para informes, acuerdos, reconstrucciones y lecturas administrativas|
|`pending-extras:{orderId}`|Almacenamiento temporal de artículos de soporte/cantidad personalizada durante el pago|
|`pending-tiers:{orderId}`|Almacenamiento temporal para niveles adicionales cuando los metadatos de Stripe sean demasiado grandes|
|`checkout-intent:{orderId}`|Carga útil de pago canonicalizada utilizada para promover el pago combinado en aportes de campaña|
|`launch-reminder:{campaignSlug}:{emailHash}`|Registro de recordatorio de próxima campaña y metadatos de suscripción|
|`launch-reminder-suppressed:{campaignSlug}:{emailHash}`|Marcador de cancelación de suscripción de recordatorio relacionado con la campaña|
|`launch-reminder-sent:{campaignSlug}:{emailHash}`|Recordatorio de lanzamiento enviar marcador de idempotencia|
|`launch-reminder-dispatch:{campaignSlug}`|Cursor de trabajo de envío limitado para una campaña que acaba de publicarse|
|`launch-reminder-dispatch-queue:v1`|Marcador de estado de cola que permite que los ticks programados del recordatorio de inicio inactivo omitan los análisis de la lista de envío|
|`abandoned-cart:{orderId}`|Registro de recordatorio de pago abandonado explícitamente aceptado|
|`abandoned-cart-resume:{orderId}`|Instantánea de reanudación de pago con enlace firmado de corta duración creada solo después de enviar un recordatorio|
|`abandoned-cart-queue:v1`|Marcador de estado de cola que permite que los ticks programados de pago abandonado e inactivo omitan análisis de espacios de nombres|
|`abandoned-cart-sent:{emailHash}:{campaignSetHash}`|Marcador de idempotencia de envío de pago abandonado|
|`abandoned-cart-suppressed:{emailHash}`|Marcador de cancelación de suscripción de pago abandonado|
|`abandoned-cart-suppressed-campaign:{campaignSlug}:{emailHash}`|Marcador de supresión de recordatorios con ámbito de campaña administrado por el administrador|
|`abandoned-cart-health:v1`|Agregue contadores de resultados/colas de pago abandonado para vistas de estado del ámbito de la campaña|
|`supporter-email-retry:{orderId}`|Carga útil de reintento de correo electrónico de confirmación de colaborador en cola|
|`supporter-email-retry-queue:v1`|Marcador de estado de cola con el siguiente tiempo de reintento de correo electrónico del colaborador|
|`add-on-inventory-sold:v1`|Proyección de recuento de ventas para el inventario complementario de la plataforma|
|`admin-users:v1`|Usuarios del panel de ejecución guardados desde **Configuración -> Usuarios**|
|`admin-marketing-referrals:{campaignSlug}`|Código de referencia guardado y metadatos de origen QR para la pestaña Marketing del panel|
|`admin-marketing-draft:{campaignSlug}:{surface}`|Borrador explícito compartido de Marketing/Blast con TTL de 7 días y protección contra conflictos de revisión|

Las reservas de nivel escaso y el estado de reclamo comprometido ahora se encuentran en el coordinador de objetos duraderos por campaña en lugar de en KV. `tier-inventory:{campaignSlug}` sigue siendo la proyección pública utilizada por `/inventory/:slug` y `/live/:slug`.

**Registro de aporte:**
```json
{
  "orderId": "pledge-1234567890-abc123",
  "email": "backer@example.com",
  "campaignSlug": "hand-relations",
  "tierId": "producer-credit",
  "tierQty": 1,
  "additionalTiers": [{ "id": "frame-slot", "qty": 2 }],
  "supportItems": [{ "id": "location-scouting", "amount": 50 }],
  "customAmount": 25,
  "tipPercent": 5,
  "tipAmount": 250,
  "subtotal": 5000,
  "tax": 394,
  "shipping": 300,
  "amount": 5944,
  "shippingAddress": { "name": "Jane Doe", "address1": "123 Main St", "city": "Albuquerque", "province": "NM", "postalCode": "87101", "country": "US" },
  "stripeCustomerId": "cus_xxx",
  "stripePaymentMethodId": "pm_xxx",
  "pledgeStatus": "active",
  "charged": false,
  "history": [
    { "type": "created", "subtotal": 5000, "tax": 394, "shipping": 300, "tipPercent": 5, "tipAmount": 250, "amount": 5944, "tierId": "producer-credit", "tierQty": 1, "customAmount": 25, "at": "2026-01-15T12:00:00Z" }
  ]
}
```

**Artículos de soporte y montos personalizados:**
- `supportItems` — Matriz de `{ id, amount }` para contribuciones de la fase de producción
- `customAmount` — Monto en dólares para adiciones de soporte personalizado "sin recompensa"
- `additionalTiers`: conjunto de `{ id, qty }` para aportes de varios niveles (cuando `single_tier_only: false`)
- `tipPercent` / `tipAmount`: la sugerencia opcional de la plataforma Pool se almacena por separado del subtotal de la campaña
- Los pagos agrupados de varias campañas se conservan como registros de aporte separados, uno por campaña.
- Las variantes complementarias pueden anular el precio base del producto. Worker resuelve los precios del catálogo actual para selecciones nuevas o modificadas, mientras que un producto/variante persistente sin cambios conserva su `bundleAddOns.unitPrice` guardado a través de ediciones de solo cantidad; Los informes y correos electrónicos utilizan ese valor histórico guardado.

**Entradas del historial:**
Cada entrada del historial rastrea un evento de aporte con contexto completo:
- `type` — `created`, `modified` o `cancelled`
- `subtotal` / `subtotalDelta`: importe antes de impuestos (o delta para modificaciones)
- `tipAmount` / `tipAmountDelta` — Cantidad de propina de la plataforma (o delta)
- `tipPercent` — Porcentaje de propina seleccionado después de este evento
- `tax` / `taxDelta` — Importe del impuesto (o delta)
- `amount` / `amountDelta` — Total con impuestos + envío + propina (o delta)
- `shipping` / `shippingDelta`: monto de envío almacenado (o delta, incluidos cambios de cotización en vivo, respaldo o envío gratuito)
- `tierId`, `tierQty`, `additionalTiers`: estado del nivel después de este evento
- `customAmount`: Monto de soporte personalizado (si está presente)
- `at` — Marca de tiempo ISO

**Valores de estado:** `active`, `cancelled`, `charged`, `payment_failed`

los aportes cobradas también pueden contener metadatos financieros de Stripe:

- `stripePaymentIntentId`
- `stripeChargeId`
- `stripeBalanceTransactionId`
- `stripeFinancials.source`
- `stripeFinancials.grossAmount`
- `stripeFinancials.feeAmount`
- `stripeFinancials.netAmount`

Dashboard Analytics prefiere esos valores reales/netos para los aportes cobradas y recurre a estimaciones solo para los aportes activos o filas cobradas más antiguas que no se han completado.

---

## Fichas de enlace mágico

Tokens sin estado firmados por HMAC (no se necesita base de datos):

**Carga útil:**
```json
{
  "orderId": "pool-intent-abc123",
  "email": "backer@example.com",
  "campaignSlug": "hand-relations",
  "exp": 1754000000
}
```

**Formato de token:** `base64url(payload).base64url(HMAC-SHA256(payload, secret))`

**Verificación:**
1. Decodificar y verificar firma
2. Verificar vencimiento
3. Resolver el `orderId` autorizado
4. Obtenga el aporte de KV y verifique el correo electrónico + la campaña

Cada token sólo autoriza su propio pedido. Un enlace válido ya no otorga acceso a todo el correo electrónico a cada aporte en la misma dirección, y un token válido sin un aporte de respaldo real ahora falla al cerrarse en lugar de devolver un marcador de posición sintético.

## Límites de confianza de los patrocinadores

El ciclo de vida del aporte debe seguir siendo comprensible para un patrocinador que nunca lee el código. Utilice [ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/) cuando un cambio en el flujo de trabajo afecte la recopilación de datos, el dinero, los recordatorios, la visibilidad de la campaña, el poder administrativo o el intercambio público.

Reglas de flujo de trabajo sensibles a la confianza:

- La interfaz de usuario del navegador puede obtener una vista previa y explicar el estado, pero Worker debe canonicalizar el dinero, el inventario, los permisos y la persistencia.
- Los patrocinadores deberían poder distinguir los impuestos/envíos estimados de los finales, el borrador del aporte comprometido, las campañas activas de las cerradas y los recordatorios de registro de los pasos de pago requeridos.
- Los recordatorios por correo electrónico y las actualizaciones de campañas deben tener un alcance voluntario o comprometido, desduplicados, suprimibles cuando corresponda y enviados a través de rutas de prueba.
- Las rutas privadas, tokenizadas, de vista previa, de administrador y solo para patrocinadores no deben convertirse en objetivos indexables, captados previamente o de tarjeta compartida.
- Los flujos de trabajo masivos o automatizados deben tener lotes delimitados, registros de auditoría, idempotencia y evidencia del operador antes de envíos en vivo o mutaciones.

---

## Rutas API de trabajador

### `POST /checkout-intent/start`
Cree una sesión de pago de Stripe en modo de configuración desde el estado del carrito propio para el paso de pago en el sitio.

La integración completa del procesador de pagos, incluido el pago en modo de configuración, la persistencia del webhook, la recuperación, la liquidación y el reabastecimiento financiero Stripe, está documentada en [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/).

**Pedido:**
```json
{
  "campaignSlug": "hand-relations",
  "items": [
    { "id": "hand-relations__producer-credit", "quantity": 1 }
  ],
  "tipPercent": 5
}
```
**Respuesta:**
- modo personalizado: `{ checkoutUiMode, sessionId, clientSecret, publishableKey, orderId }`
- reserva alojada: `{ checkoutUiMode: "hosted", url }`

Si se selecciona el pago personalizado pero el entorno actual no tiene una clave publicable de Stripe, el trabajador usa la respuesta alternativa alojada en lugar de fallar el inicio del pago.

**Flujo de datos:**
1. Cart.js pasa el porcentaje de propina seleccionado más los artículos actuales del carrito propio
2. El trabajador reconstruye la forma del carrito a partir de elementos propios y reglas de campaña canónicas.
3. El trabajador valida el estado de la campaña, las reglas de un solo nivel, los umbrales y la disponibilidad de los niveles escasos.
4. Para niveles limitados, el trabajador reserva un inventario escaso a través del coordinador por campaña, luego almacena cualquier metadato de nivel desbordado/elemento de soporte en KV temporal (`pending-tiers:*`, `pending-extras:*`) y crea una sesión de pago de Stripe en modo de configuración.
5. En el modo de interfaz de usuario personalizado, el segundo sidecar de pago existente monta una interfaz de usuario de pago segura de Stripe en el sitio; Los pagos físicos también capturan los detalles de envío durante ese paso.
6. El trabajador trata la persistencia del webhook como la fuente de la verdad, con una ruta de recuperación propia disponible para casos locales o de finalización retrasada, de modo que el sidecar no afirme haber tenido éxito antes de que el aporte realmente persista.
7. En caso de persistencia, el trabajador recupera los metadatos temporales, extrae los detalles de envío de Stripe, calcula `subtotal + tax + shipping + tip`, persiste un aporte por campaña y confirma cualquier reserva de nivel limitado retenida a través del coordinador de objetos duraderos por campaña.
8. Una vez que la persistencia tiene éxito, el cliente invalida los cachés de estadísticas en vivo de la campaña y escribe un marcador de actualización de corta duración para que las pestañas restauradas y las cargas de páginas de seguimiento obtengan totales nuevos.

Las decisiones de disponibilidad de nivel limitado ahora provienen del estado consciente de la reserva del coordinador en las rutas de escritura, mientras que `/inventory/:slug` y `/live/:slug` continúan leyendo solo la proyección KV pública.

El Trabajador no confía en los nombres de niveles, cantidades, cantidades de artículos de soporte enviados por el cliente o `amountCents`. `/checkout-intent/start` ahora reserva un inventario escaso antes de que se complete el paso de pago, y la persistencia confirma esas reservas. Las campañas más antiguas no necesitan un trabajo de migración porque el inventario reclamado puede reconstruirse a partir de la verdad del aporte, y la persistencia exitosa aún puede recurrir a un nuevo reclamo de coordinador si no existe una reserva preexistente.

## Seguridad en la representación de contenidos

- El texto de campaña de formato largo se desinfecta antes de renderizar Markdown y luego se procesa posteriormente para neutralizar esquemas de enlaces inseguros.
- Las incrustaciones estructuradas solo se representan cuando su `src` se resuelve en un origen/ruta de proveedor aprobado exacto.
- Las auditorías de contenido de campaña aún protegen a `_campaigns/*.md`, pero la capa de procesamiento aplica las mismas reglas para que las bifurcaciones y las fuentes de contenido futuras no dependan únicamente de las auditorías.

### `POST /webhooks/stripe`
Manejar `checkout.session.completed`:
- Extraiga `payment_method` y `customer` de SetupIntent
- Obtenga `supportItems`, `customAmount` y niveles adicionales de KV temporal cuando sea necesario
- Almacene un aporte por campaña en KV con estado `active` (incluye artículos de soporte, monto personalizado, tarifa de envío, propina y dirección de envío)
- Actualizar estadísticas en vivo (monto prometido, tierCounts, artículos de soporte)
- Confirme las reservas retenidas de nivel limitado o reclame a través del coordinador serializado si el aporte es anterior al inicio del pago con conocimiento de la reserva.
- Generar token de enlace mágico
- Enviar correos electrónicos de confirmación de patrocinadores específicos de la campaña

La idempotencia del webhook se confirma solo después de una persistencia exitosa del aporte, de modo que las fallas transitorias puedan volver a intentarlo de manera segura.

### `GET /pledges?token=...`
Lea la colección de aportes disponible para una sesión de enlace mágico.

**Comportamiento actual:** un token devuelve solo su propio pedido autorizado.

### `GET /pledge?token=...`
Lea los detalles del aporte para la página de administración de enlaces mágicos.

Si el token es válido pero su registro de aporte ya no existe, esta ruta devuelve `404` en lugar de sintetizar un aporte de marcador de posición.

**Respuesta:**
```json
{
  "campaignSlug": "hand-relations",
  "orderId": "xxx",
  "email": "backer@example.com",
  "amount": 5000,
  "tierId": "producer-credit",
  "pledgeStatus": "active",
  "canModify": true,
  "canCancel": true,
  "canUpdatePaymentMethod": true,
  "deadlinePassed": false
}
```

**Valores de estado:** `active`, `cancelled`, `charged`, `payment_failed`

**Lógica de la bandera:**
- `canModify` / `canCancel`: `true` solo si `pledgeStatus === 'active'` Y `!charged` Y la fecha límite no pasó
- `canUpdatePaymentMethod`: `true` si `!charged` (permitido incluso después de la fecha límite para la recuperación de pagos fallidos)
- `deadlinePassed`: `true` si la fecha límite de la campaña ha pasado en la zona horaria de la plataforma

### `POST /pledge/cancel`
Cancelar un aporte activo.

**Solicitud:** `{ token }`
**Validación:**
- Rechaza si se cobra prenda
- Rechaza si ha pasado el plazo de campaña

**Acciones:**
1. Marcar aporte como cancelado en KV, actualizar estadísticas, lanzar inventario de nivel
2. Enviar correo electrónico de confirmación de cancelación
3. Si no quedan aportes activos para este correo electrónico/campaña → borre el mapeo `email:{email}` de KV (revoca el acceso a la comunidad)

### `POST /pledge/modify`
Cambiar nivel o cantidad.

**Solicitud:** `{ token, orderId, ...changes }`
**Validación:**
- Rechaza si se cobra prenda
- Rechazo si la fecha límite de la campaña ha pasado (mediante verificación `isCampaignLive`)
- Se rechaza si `orderId` no coincide con el pedido autorizado del token.
- Reconstruye los totales a partir del estado de aporte almacenado más las definiciones de campaña en lugar de confiar en los campos de dinero del cliente.

**Acción:** Actualizar el aporte en KV, ajustar el delta de estadísticas, intercambiar niveles de inventario

### `POST /pledge/payment-method/start`
Actualizar el método de pago guardado.

**Solicitud:** `{ token }`
**Respuesta:**
- modo personalizado: `{ checkoutUiMode, sessionId, clientSecret, publishableKey }`
- reserva alojada: `{ checkoutUiMode: "hosted", url }`

**Flujo de datos:**
1. Manage Pledge valida el token de enlace mágico y el estado de aporte activo
2. El trabajador crea una sesión de pago de Stripe en modo de configuración para actualizar el método de pago
3. En el modo personalizado, el modo Tarjeta de actualización existente monta la interfaz de usuario de pago seguro de Stripe en el sitio
4. El trabajador mantiene la persistencia del webhook como fuente de verdad, con la misma ruta protegida de finalización y recuperación disponible para la entrega retrasada del webhook local.
5. Si tiene éxito, el registro de aporte se actualiza al método de pago recién guardado y los reintentos de `payment_failed` pueden cobrar nuevamente inmediatamente.

### `GET /stats/:campaignSlug`
Obtenga estadísticas de aportes en vivo para una campaña.

### `GET /live/:campaignSlug`
Obtenga la instantánea pública combinada en vivo de una campaña.

**Forma de respuesta:**
```json
{
  "stats": { "pledgedAmount": 1200, "pledgeCount": 3 },
  "inventory": {
    "tiers": {
      "frame-slot": { "limit": 1000, "claimed": 2, "remaining": 998 }
    }
  }
}
```

Las páginas de campaña y la interfaz de usuario de Manage Pledge prefieren este punto final, por lo que las cargas en frío graban una solicitud de trabajador en lugar de lecturas separadas de `stats` y `inventory`. Luego, el navegador almacena en caché el resultado en `localStorage` para el TTL configurado.

**Respuesta:**
```json
{
  "campaignSlug": "hand-relations",
  "pledgedAmount": 380000,
  "pledgeCount": 42,
  "tierCounts": { "producer-credit": 10, "frame-slot": 32 },
  "goalAmount": 25000,
  "percentFunded": 15,
  "updatedAt": "2025-01-15T12:00:00Z"
}
```

### `POST /stats/:campaignSlug/recalculate`
Vuelva a calcular las estadísticas de todas los aportes en KV (solo administrador).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`

### `POST /admin/rebuild`
Activar una reconstrucción de páginas de GitHub (para transiciones de estado).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`
**Solicitud:** `{ "reason": "campaign-state-change" }` (opcional)

### `POST /admin/marketing/announcement`
Realice una ejecución en seco, un envío de prueba o un envío en vivo de campañas -> Envío masivo de correos electrónicos de apoyo desde el panel del navegador.

La ruta del navegador requiere una sesión de panel, comprobaciones de origen/CSRF, alcance de la campaña y una audiencia `campaign-pledges:{slug}` indexada. Los ensayos validan el tema/contenido/CTA/audiencia exactos y devuelven un `dryRunHash` sin enviar correos electrónicos, escribir auditorías ni enumerar espacios de nombres KV. Los envíos de prueba van únicamente al administrador que ha iniciado sesión. Los envíos en vivo requieren el hash de prueba coincidente y escriben un evento de auditoría administrativa después del envío.

**Pedido:**
```json
{
  "campaignSlug": "worst-movie-ever",
  "subject": "Submissions close March 6th!",
  "content": [
    { "type": "text", "body": "The deadline is this Thursday at midnight in the platform timezone." }
  ],
  "ctaLabel": "Submit Your Reward",
  "ctaUrl": "https://example.com/submit",
  "dryRunHash": "required-for-live-send"
}
```

### Ayudantes del panel de marketing

El rendimiento de referencias y UTM se encuentra en `GET /admin/analytics`, que lee los índices de aportes de campaña y devuelve referencias más desgloses de fuente/medio/campaña/contenido UTM sin enumerar la verdad de los aportes. Los índices de campaña que faltan generan un aviso de Analytics sin bloqueo en lugar de un error en la pestaña Marketing.

`GET /admin/marketing/draft?campaignSlug=...&surface=marketing|blast`, `POST /admin/marketing/draft` y `DELETE /admin/marketing/draft` cargan, guardan y borran borradores compartidos explícitos. Los borradores escritos tienen un alcance de campaña, caducan después de 7 días y llevan un token de revisión, por lo que los guardados obsoletos devuelven un conflicto.

`GET /admin/media/library?campaignSlug=...` enumera las imágenes de campaña existentes para bloques de imágenes WYSIWYG. Los usuarios de la campaña solo ven los medios de la campaña asignados; Los superadministradores también pueden elegir imágenes compartidas/predeterminadas. El selector lee los directorios de GitHub y no crea el estado KV.

`GET /admin/abandoned-checkout/health?campaignSlug=...` lee el estado agregado del recordatorio de pago abandonado sin operaciones de lista KV. Los resultados de la supresión creados por el administrador incluyen el correo electrónico suprimido para que el panel pueda mostrar y borrar esas filas. `POST` y `DELETE /admin/abandoned-checkout/suppression` establecen o borran explícitamente supresiones de recordatorios en el ámbito de la campaña con CSRF, identificadores de correo electrónico con hash, eventos de auditoría y escrituras KV limitadas. Los enlaces de reanudación de recordatorio firmados leen `abandoned-cart-resume:{orderId}` y restauran una instantánea de pago del navegador desinfectada para que los patrocinadores puedan iniciar una nueva sesión de Stripe desde el mismo contexto de campaña/carrito.

### `POST /admin/broadcast/announcement`
Punto final de operador secreto compartido heredado para un correo electrónico de anuncio personalizado con un enlace CTA opcional para todos los patrocinadores de la campaña.

**Encabezados:** `Authorization: Bearer ADMIN_BROADCAST_SECRET` cuando está configurado, de lo contrario `Authorization: Bearer ADMIN_SECRET`
**Pedido:**
```json
{
  "campaignSlug": "worst-movie-ever",
  "subject": "Submissions close March 6th!",
  "heading": "Last call for submissions!",
  "body": "The deadline is this Thursday at midnight in the platform timezone.",
  "ctaLabel": "Submit Your Reward",
  "ctaUrl": "https://example.com/submit",
  "dryRun": true
}
```
**Respuesta:** `{ success, campaignSlug, subject, sent, failed, errors }`

**Campos:**
- `subject` (obligatorio): cuerpo de la línea de asunto del correo electrónico; la entrega lo formatea como `{Subject} | {Campaign Title}`
- `heading` (opcional): encabezado del correo electrónico (el valor predeterminado es el asunto si se omite)
- `body` (obligatorio) — Texto del cuerpo del mensaje
- `ctaLabel` + `ctaUrl` (opcional): agrega un botón destacado que vincula a la URL
- `dryRun` (opcional): devuelve la lista de destinatarios sin enviar

### Panel de administración del navegador

El panel privado está disponible en `/admin/` y `/es/admin/`. Utiliza inicio de sesión con enlace mágico y una sesión de trabajador respaldada por cookies; El código del navegador nunca recibe `ADMIN_SECRET`.

Flujos primarios:

- El resumen del panel, los análisis, los informes, los soportes, las cargas de contenido y las vistas previas de contenido son flujos de navegación de solo lectura.
- El contenido/configuración de la campaña y la configuración/complementos de la plataforma se publican a través de la validación del trabajador y las confirmaciones respaldadas por GitHub.
- El superadministrador **Crear nueva campaña** escribe un archivo Markdown de campaña de solo vista previa localmente en desarrollo o a través de la ruta respaldada por GitHub en producción, opcionalmente guarda varios usuarios de campaña nuevos en `admin-users:v1`, envía correos electrónicos a los usuarios asignados con el enlace del panel de administración y mantiene la campaña oculta de las rutas públicas hasta el lanzamiento.
- La campaña **Vista previa** publica indicadores de vista previa protegidos a través de GitHub, almacena el administrador de publicación más los correos electrónicos de revisores opcionales solo en una lista permitida de `campaign-preview-reviewers:{slug}` KV de 24 horas, devuelve un enlace de 24 horas visible en el panel para el administrador de publicación, envía enlaces firmados de 24 horas a revisores opcionales y ofrece cargas útiles de vista previa privadas/no-store a través de `/admin/campaign-preview/:slug`.
- El superadministrador **Campaña de archivo** está disponible solo para campañas no activas. El trabajador valida el rol, CSRF, slug de campaña y estado efectivo, luego archiva directamente en el repositorio montado para desarrollo local o envía `.github/workflows/archive-campaign.yml` en producción; el movimiento del archivo escribe `archive-manifest.json` y mantiene la fuente/medios de la campaña en `archive/campaigns/<slug>/`.
- **Configuración -> Usuarios** guarda directamente en Worker KV en `admin-users:v1`.
- Los códigos de referencia guardados y los borradores compartidos de Marketing/Blast se guardan en KV con alcance de campaña solo cuando se guardan o borran explícitamente.
- **Análisis** informes de atribución y **Marketing** estado de pago abandonado leen datos indexados/agregados sin escaneos de espacios de nombres KV.
- **Informes** muestra una vista previa de las filas de aportes/cumplimiento y descarga archivos CSV; no envía correos electrónicos y no marca informes como enviados.
- **Analytics** utiliza datos netos y de tarifas de Stripe reales almacenados cuando están disponibles y expone un reabastecimiento de superadministrador para aportes cobradas más antiguas.
- Los medios del editor de contenido cargan archivos provisionales localmente, los cargan en publicación o envío masivo y confirman activos conservados en origen a través de la ruta respaldada por GitHub; Las cargas de imágenes/videos luego solicitan el flujo de trabajo `Optimize dashboard media` con `scope=changed` para compresión de imágenes, variantes WebP responsivas (`320w`, `480w`, `640w`, `960w`, `1600w`) y derivados de video. Los bloques de imágenes también pueden elegir imágenes de campaña existentes desde un selector de medios de solo lectura con alcance. Publicar también elimina los medios propiedad del panel de la misma campaña que desaparecieron de los bloques de contenido o eliminaron las entradas del diario y no se hace referencia a ellos en ninguna otra parte de la campaña.
- **Secretos y credenciales** informes configurados/estado faltante únicamente; no expone ni almacena valores secretos.

Informe de puntos finales de vista previa/descarga utilizados por el panel:

```bash
curl "http://localhost:8787/admin/reports/campaign-runner/preview?campaignSlug=hand-relations&reportType=pledge"
```

```bash
curl "http://localhost:8787/admin/reports/campaign-runner.csv?campaignSlug=hand-relations&reportType=fulfillment"
```

Para el uso del navegador autenticado, estos puntos finales requieren la cookie de sesión del panel y protecciones de origen/CSRF cuando corresponda. Los puntos finales de administración basados ​​en scripts que utilizan secretos de portador permanecen separados del contrato del panel del navegador. Las rutas de liquidación pueden requerir `ADMIN_SETTLEMENT_SECRET`, y las rutas de transmisión/diario/hitos pueden requerir `ADMIN_BROADCAST_SECRET`; Si no se configura un secreto de ámbito, la ruta vuelve a `ADMIN_SECRET`. Establezca secretos de alcance en los secretos de Cloudflare Worker para la aplicación del tiempo de ejecución y agregue secretos coincidentes del repositorio de GitHub solo para acciones o flujos de trabajo de operadores que llamen a esos puntos finales.

Reabastecimiento financiero de Stripe para superadministradores:

```bash
curl -X POST "http://localhost:8787/admin/analytics/stripe-financials/backfill" \
  -H 'Content-Type: application/json' \
  -H 'x-pool-admin-csrf: <dashboard-csrf-token>' \
  --cookie "pool_admin_session=<session-cookie>" \
  -d '{"campaignSlug":"hand-relations","dryRun":true}'
```

El reabastecimiento utiliza índices `campaign-pledges:{slug}` y búsquedas de PaymentIntent agrupadas, no escaneos de espacios de nombres KV.

### `POST /admin/recover-checkout`
Recupere un webhook de Stripe perdido creando manualmente una contribución a partir de una sesión de pago completada.

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`
**Solicitud:** `{ sessionId: "cs_test_..." }` o `{ orderId: "pledge-..." }`
**Respuesta:**
```json
{
  "success": true,
  "message": "Pledge recovered from Stripe checkout session",
  "pledge": { ... },
  "stripeSessionId": "cs_test_..."
}
```

**Caso de uso:** Cuando el desarrollo local pierde un webhook (el trabajador no se estaba ejecutando, la CLI de Stripe no se reenvía, etc.), use esto para recuperar:
```bash
curl -X POST http://localhost:8787/admin/recover-checkout \
  -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
  -H 'Content-Type: application/json' \
  -d '{"sessionId": "cs_test_abc123..."}'
```

---

## Páginas de inicio

### `/campaigns/:slug/`
Detalle de campaña con botones de nivel → cajón del carrito propio

### `/campaigns/:slug/pledge-success/`
Página de éxito posterior a la persistencia con confirmación + enlace de administración

### `/campaigns/:slug/pledge-cancel/`
El usuario abandonó el paso de pago antes de completarlo (no el aporte en sí)

### `/manage/`
Página de inicio del enlace mágico para la gestión de aportes:
- Lee el token `?t=...`
- Obtiene detalles del aporte del trabajador
- Muestra tarjetas de aporte con interfaz de usuario dependiente del estado.
- Agrupa proyectos en secciones **Activo** y **Cerrado**
- Ordena las tarjetas activas primero con las campañas más recientes
- Muestra el desglose completo: subtotal, propina opcional de The Pool, impuesto sobre las ventas configurado y monto de envío almacenado para el aporte, más el total.
- Lee etiquetas de precios y tarifas de la configuración compartida para que la interfaz de usuario del carrito, los totales de trabajadores, los correos electrónicos y los informes permanezcan alineados para las bifurcaciones.

**Estados de la tarjeta de aporte:**

|Estado|Tratamiento de la IU|
|--------|-------------|
|`active`|Controles de edición completos (selección de niveles, elementos de soporte, botón cancelar)|
|`active` + fecha límite pasada|Insignia bloqueada + aviso bloqueado, controles de contribución de solo lectura, solo "Tarjeta de actualización"|
|`charged`|Tarjeta silenciada, aviso " ✓ Cargado exitosamente el {fecha}"|
|`payment_failed`|Aviso de advertencia con el botón "Actualizar método de pago"|
|`cancelled`|Aviso "Este aporte ha sido cancelado"|

**Envío en flujo de modificación:** Cuando un colaborador cambia niveles o artículos de soporte físico, la página de administración recalcula dinámicamente el envío. Las selecciones físicas pueden utilizar cotizaciones en vivo respaldadas por USPS, tarifas alternativas configuradas, anulaciones de envío gratuito y actualizaciones limitadas de opciones de firma nacionales. El modal de confirmación muestra el envío actualizado y el total antes de que el usuario confirme.

**Sugerencia para modificar el flujo:** La página de administración muestra el mismo control deslizante de propina del 0% al 15%. Durante las campañas en vivo, los patrocinadores pueden ajustarlo y ver la actualización del subtotal/propina/impuestos/envío/total inmediatamente. Una vez que pasa la fecha límite, el control deslizante de propinas pasa a ser de solo lectura junto con el resto de los controles de contribución.

**Modo de desarrollo:** Agregue `?dev` a la URL para realizar pruebas simuladas de datos de aporte

### `/community/:slug/`
Página de la comunidad exclusiva para patrocinadores:
- Siempre verifica con Worker API (no confía únicamente en las cookies)
- En caso de éxito: establece una cookie `supporter_{slug}` no confidencial para la optimización de UX y almacena el token de portador sin formato solo en `sessionStorage`.
- En caso de error (aporte cancelado, token caducado): borra el estado del token de sesión, muestra acceso denegado CTA
- Muestra decisiones de votación/encuesta exclusivas de los patrocinadores.
- La API `/votes` devuelve 403 para aportes cancelados (acceso de doble verificación)
- `/votes` solo acepta ID de decisión definidos por la campaña y valores de opciones definidos por la campaña.
- Las decisiones cerradas siguen siendo legibles pero rechazan nuevos votos
- Los votos se ingresan por **correo electrónico** (no por ID de pedido): los patrocinadores con múltiples aportes aún obtienen un voto por decisión.

---

## Flujo de carga (cron del trabajador)

El trabajador tiene un activador programado a nivel de minutos. El trabajo del ciclo de vida diario se limita a una pequeña ventana de medianoche en la zona horaria de la plataforma configurada y se reclama una vez por fecha local:

```toml
# wrangler.toml
[triggers]
crons = ["* * * * *"]
```

**Qué hace:**

1. Registra un latido por hora (`cron:lastRun` en KV) para que el programador de nivel de minutos no queme el presupuesto de escritura de KV libre.
2. Enumera todas las campañas con `goal_deadline` y `goal_amount`
3. Drena los trabajos de envío de recordatorios de lanzamiento en cola en lotes limitados solo cuando el estado de la cola indica que el trabajo está pendiente
4. Pone en cola un trabajo de envío de recordatorio de lanzamiento cuando una próxima campaña se activa
5. Para cada campaña en la que ya pasó la fecha límite en la zona horaria de la plataforma, se cumple el objetivo y no se establece `campaign-charged:{slug}`:
   - Envía liquidación por lotes a través de `POST /admin/settle-dispatch/:slug`
6. Activa la reconstrucción de páginas de GitHub si se detecta alguna transición de estado de campaña

El programador tiene en cuenta intencionadamente los niveles gratuitos. Las colas de reintento de envío de recordatorios de lanzamiento y de correo electrónico de confirmación del colaborador mantienen cada una una pequeña clave de estado de cola. Cuando se sabe que una cola está inactiva, las ejecuciones programadas omiten la operación de lista de espacios de nombres KV correspondiente y dependen de una nueva verificación de inactividad cada hora para comprobar la compatibilidad con los trabajos insertados manualmente. Cuando el trabajo real está en cola, la ruta de escritura marca esa cola como pendiente inmediatamente para que la siguiente ejecución programada pueda procesarla sin esperar a que se vuelva a verificar la compatibilidad.

**Envío de liquidación (lotes autoencadenados):**

El punto final `settle-dispatch` maneja el cobro real en lotes para permanecer dentro del límite de 50 subsolicitudes de CF Worker:

1. Reclama el bloqueo de objetos duraderos `SETTLEMENT_COORDINATOR` de la campaña.
2. Lee el índice de aporte de campaña (`campaign-pledges:{slug}` en KV)
3. Inicializa un trabajo de liquidación (`settlement-job:{slug}`) que sigue el progreso.
4. Procesa 6 aportes de la misma campaña por lote a través de `POST /admin/settle-batch`
5. Se autoinvoca para el siguiente lote hasta que se procesen todos los aportes, reenviando al mismo propietario del bloqueo
6. Cada lote es una invocación de trabajador separada con su propio presupuesto de subsolicitud
7. **Agrega aportes por correo electrónico**: cada patrocinador recibe UN cargo por campaña
8. Utiliza una clave de idempotencia determinista de Stripe por grupo de carga de campaña/patrocinador
9. Al finalizar, establece `campaign-charged:{slug}` solo cuando ningún aporte activo todavía necesita atención.

**Índice de aporte de campaña:**

Se mantiene automáticamente una serie de ID de pedido por campaña (`campaign-pledges:{slug}`):
- Agregado en la creación de aportes (webhook) y recuperación (`/admin/recover-checkout`)
- Eliminado al cancelar el aporte
- Se puede reconstruir: `POST /admin/campaign-index/rebuild/:slug`
- Las estadísticas y el recálculo de inventario ahora también reparan índices obsoletos si la matriz almacenada ya no coincide con los registros de aporte activos.
- La deriva ahora se puede verificar sin mutación a través de `POST /stats/:slug/check` o `POST /admin/projections/check`

**Comportamientos clave:**
- Los aportes cancelados nunca se cobran
- Varias aportes del mismo correo electrónico = un cargo agregado (subtotales + envío + impuestos + propina sumada)
- Los carritos de múltiples campañas siguen siendo compatibles porque la persistencia del pago crea un registro de aporte por campaña; los bloqueos y lotes de liquidación tienen un alcance de campaña y rechazan lotes de campaña mixta
- Utiliza el método de pago actualizado más recientemente para cada patrocinador
- los aportes ya cobradas se omiten de forma segura (idempotentes)
- Se puede activar manualmente a través de `POST /admin/settle-dispatch/:slug` con `ADMIN_SETTLEMENT_SECRET` cuando está configurado; de lo contrario, `ADMIN_SECRET`
- El asentamiento monolítico heredado todavía está disponible: `POST /admin/settle/:slug`; Utiliza el mismo bloqueo de campaña y la misma ruta de clave de idempotencia de Stripe, pero se prefiere `settle-dispatch` para campañas grandes.
- Latido del cron: verificar a través de `GET /admin/cron/status`

### Error de pago y reintento

Cuando un cargo falla durante la liquidación:

1. **Aporte marcado como `payment_failed`** con mensaje de error almacenado
2. **Correo electrónico enviado** con el botón "Actualizar método de pago" vinculado a la página de administración
3. **Tarjeta de actualizaciones de soporte** vía `/pledge/payment-method/start`
4. **El cargo por reintento automático** ocurre inmediatamente después de la actualización exitosa del método de pago
5. Si el reintento tiene éxito: aporte marcado `charged`, correo electrónico de éxito enviado
6. Si el reintento falla nuevamente: el aporte permanece `payment_failed`, puede volver a intentarlo

Esto permite a los patrocinadores reparar tarjetas vencidas/rechazadas sin la intervención manual del administrador.

---

## Arquitectura de correo electrónico

Esta sección resume el comportamiento del correo electrónico relacionado con los aportes. La configuración completa de Resend y la referencia de tipo de correo electrónico se encuentran en [EMAIL.md](/es/docs/operations/email-system/).

|Proveedor|Propósito|
|----------|---------|
|**Resend**|Todos los correos electrónicos de los patrocinadores (confirmación, hitos, actualizaciones del diario, anuncios, carga exitosa, pago fallido)|

El Trabajador maneja todos los correos electrónicos relacionados con aportes a través de Resend.

En producción, las personas que llaman ponen en cola un registro `email-outbox:v1:*` duradero en lugar de esperar Resend. El programador congela la carga útil renderizada en el primer intento, la envía con una clave determinista de idempotencia del proveedor y mantiene la verdad del aporte independiente del reintento de notificación. Los envíos de prueba, el renderizado de prueba y los enlaces de inicio de sesión de administrador siguen siendo inmediatos. Los eventos Resend firmados en `POST /webhooks/resend` actualizan el estado de entrega mínimo y la supresión de hash; The Pool no sincroniza las audiencias comprometidas con los contactos o transmisiones de Resend.

El correo de diario, hito y anuncios en vivo incluye una URL para cancelar la suscripción con un solo clic RFC 8058 con alcance de campaña. La supresión se comprueba inmediatamente antes de la entrega del proveedor. El correo del ciclo de vida de pagos y aportes sigue siendo transaccional.

### Integración Resend (Trabajador)

El trabajador envía correos electrónicos a sus patrocinadores después de que el webhook de Stripe confirma la sesión en modo de configuración. El dominio del remitente debe estar autorizado para la clave API Resend configurada; Para esta implementación, las confirmaciones de aporte utilizan `The Pool <pledges@site.example.com>` porque `site.example.com` es el dominio de envío autorizado.

```js
// In Worker: POST /webhooks/stripe handler
async function sendSupporterEmail(env, { orderId, email, campaignSlug, campaignTitle, amount, token }) {
  return enqueueEmailOutbox(env, {
    kind: 'supporter',
    campaignSlug,
    dedupeKey: `supporter-confirmation:${orderId}`,
    payload: { email, campaignSlug, campaignTitle, amount, token }
  });
}
```

### Plantillas de correo electrónico

Todos los correos electrónicos muestran cantidades exactas con 2 decimales (sin redondeo).

**Confirmación de aporte** (enviada después de que la sesión de Stripe en el modo de configuración se complete con éxito)
- Asunto: "Aporte confirmado | {Título de la campaña}"
- Contiene: desglose completo (subtotal, propina opcional de The Pool, impuestos, envío si es físico, total), artículos prometidos, enlace de administración, enlace comunitario
- Incluye: CTA de Instagram (si la campaña tiene URL de Instagram)
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.

**Aporte modificado** (se envía cuando el colaborador cambia su aporte)
- Asunto: "Aporte actualizado | {Título de la campaña}"
- Contiene: subtotal anterior, subtotal nuevo, monto modificado (+/-), propina opcional de The Pool, impuestos, envío (si es físico), total nuevo, artículos de aporte actualizados
- Incluye: CTA de Instagram (si la campaña tiene URL de Instagram)
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.

**Cargo exitoso** (se envía cuando el aporte se cobra en el momento de la liquidación)
- Asunto: "Pago confirmado | {Título de la campaña}"
- Contiene: desglose completo (subtotal + propina + impuestos + envío + total cobrado), artículos prometidos
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.
- Nota: No hay CTA de Instagram (la campaña ha finalizado)

**Error en el pago** (se envía cuando falla el cargo fuera de sesión)
- Asunto: "Actualizar método de pago | {Título de la campaña}"
- Contiene: desglose completo (subtotal + propina + impuestos + envío + monto adeudado), artículos prometidos, enlace de administración para actualizar la tarjeta
- Nota: No hay CTA de Instagram (la campaña ha finalizado)

**Aporte cancelado** (se envía cuando el colaborador cancela su aporte)
- Asunto: "Aporte cancelado | {Título de la campaña}"
- Contiene: desglose que incluye propina opcional, no se cobró a la tarjeta de confirmación, enlace para ver la campaña (se puede volver a realizar el aporte)
- Nota: El colaborador se elimina de futuras actualizaciones por correo electrónico de la campaña.

**Actualización del diario** (se envía cuando se agrega una nueva entrada del diario a la campaña)
- Asunto: "{Título del diario} | {Título de la campaña}"
- Contiene: título del diario, extracto en texto plano (200 caracteres + puntos suspensivos), botón "Leer actualización completa" que enlaza con el diario de la campaña.
- Incluye: enlaces de acceso de patrocinadores (comunidad + administración), CTA de Instagram (si la campaña tiene URL de Instagram)
- Nota: Los extractos eliminan el formato de rebajas; el contenido completo está en la página de la campaña

**Blast/Anuncio** (enviado a través de Campañas -> Blast o transmisión de administrador heredada con enlace CTA opcional)
- Asunto: "{Asunto} | {Título de la campaña}"
- Contiene: contenido de actualización específico de la campaña, imágenes de campaña alojadas opcionales, enlaces de YouTube/Vimeo seguros para correo electrónico y un botón CTA resaltado opcional (etiqueta personalizada + URL)
- Incluye: enlaces de acceso de patrocinadores (comunidad + administración), CTA de Instagram (si la campaña tiene URL de Instagram)
- Puntos finales: `POST /admin/marketing/announcement` para navegador Blast, `POST /admin/broadcast/announcement` para envíos de operadores heredados

**Recordatorio de lanzamiento** (se envía una vez cuando se activa una próxima campaña)
- Asunto: "Ya disponible | {Título de la campaña}"
- Contiene: título de la campaña, texto de lanzamiento localizado, CTA de la campaña y enlace para cancelar la suscripción.
- Usos: Registro `preferredLang`, configuración de remitente Resend existente, marcadores de supresión y marcadores de envío
- Nota: El registro de recordatorio es independiente del aporte y se puede cancelar desde el correo electrónico de recordatorio.

---

## Consideraciones de seguridad

- Los enlaces mágicos caducan (90 días)
- Tokens verificados con respecto al registro de aporte de KV (correo electrónico + coincidencia de campaña)
- Las mutaciones del aporte se bloquean una vez que se cobra el aporte
- Todos los secretos de las variables de entorno de Cloudflare Worker
- Firmas de webhook de Stripe verificadas
- Las respuestas confidenciales de arranque del método de pago y de pago son `private, no-store`
- Los POST de pago y pago propios imponen orígenes confiables de `SITE_BASE`
- Los borradores de pago almacenados en el navegador y los identificadores en vuelo tienen un alcance de sesión o un tiempo limitado
- Todos los plazos evaluados en la zona horaria de la plataforma.
- Los registros de recordatorio de lanzamiento requieren suscripción explícita de campaña/correo electrónico, limitación de velocidad y verificación de torniquete cuando se configuran
- Los enlaces para cancelar la suscripción del recordatorio de lanzamiento utilizan tokens firmados con alcance y suprimen solo ese recordatorio de campaña/correo electrónico
- El acceso a la comunidad/voto se revoca inmediatamente cuando se cancela el aporte
- La API `/votes` verifica el estado del aporte en cada solicitud (no solo la validez del token)

---

## Manejo de condiciones de carrera

- `/pledge/cancel` y `/pledge/modify` rechazan el aporte `charged: true`
- `/pledge/cancel` y `/pledge/modify` rechazan si la fecha límite de la campaña ha pasado en la zona horaria de la plataforma
- Cron comprueba `pledgeStatus === 'active'` y `!charged` antes de cargar
- Los indicadores `pledgeStatus` y `charged` evitan la doble carga
- La agregación por correo electrónico garantiza un cargo por patrocinador por campaña, incluso con varias filas de aportes.
- La página de administración muestra un aviso de fecha límite superada, una insignia bloqueada y controles de aporte de solo lectura una vez que pasa la fecha límite.
- Las actualizaciones de los métodos de pago permanecen disponibles después de la fecha límite (para recuperación de pago fallida)

---

## Metas extendidas

- Definido en el frente de campaña: `stretch_goals[]`
- Desbloqueo automático cuando `pledged_amount >= threshold`
- Mostrar como `achieved` o `locked`
- Opcional: niveles de puerta con `requires_threshold`

---
