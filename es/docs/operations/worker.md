---
title: Worker de promesas
parent: Operaciones
nav_order: 1
render_with_liquid: false
lang: es
---

# The Pool - Trabajador comprometido

Cloudflare Worker se encarga de la canonicalización de pagos propios, la integración de Stripe, la gestión de promesas y la autenticación de patrocinadores en el ámbito de los pedidos.

Para el desarrollo local diario, prefiera la ruta Podman de raíz de repositorio:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Esto inicia el sitio y el trabajador juntos en los puertos locales estándar y es la forma más fácil de ejercer el pago completo en el sitio y los flujos `Update Card` localmente.

Si trabaja específicamente desde el directorio `worker/`, los scripts Worker npm ahora ejecutan automáticamente el espejo de configuración primero para que `worker/wrangler.toml` permanezca alineado con la raíz del repositorio `_config.yml`/`_config.local.yml`.

Trate `_config.local.yml` como un archivo de solo anulación para valores específicos del host local. La configuración canónica de orientación hacia la fork debe residir en la raíz del repositorio `_config.yml`, y el espejo del trabajador seguirá desde allí.

La configuración de Worker reflejada ahora también incluye los indicadores de depuración compartidos:

- `DEBUG_CONSOLE_LOGGING_ENABLED`
- `DEBUG_VERBOSE_CONSOLE_LOGGING`

Estos provienen de `debug.console_logging_enabled` y `debug.verbose_console_logging` en la raíz del repositorio [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml), y ambos están predeterminados en `true`, por lo que los trabajadores locales y desplegados permanecen detallados a menos que una fork rechace explícitamente el inicio de sesión.

Las estadísticas del lado de los trabajadores y la reparación de inventario ahora también tratan a `campaign-pledges:{slug}` como un estado de proyección en lugar de una verdad permanente. Si el índice de una campaña se desvía de los registros de compromiso activos subyacentes, las rutas de recálculo lo reparan automáticamente mientras reconstruyen los totales de la campaña y el inventario de nivel limitado.

Antes de mutar algo, los operadores ahora pueden ejecutar comprobaciones de deriva de solo lectura a través de:

- `POST /stats/:slug/check`
- `POST /admin/projections/check`
- [`scripts/check-projections.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-projections.sh) de la raíz del repositorio

Esas comprobaciones comparan las proyecciones almacenadas `campaign-pledges:{slug}`, `stats:{slug}` y `tier-inventory:{slug}` con la verdad del compromiso activo y devuelven una diferencia estructurada en lugar de un estado de reparación silenciosa.

La misma regla de "verdad guardada sobre el estado borrador" ahora se aplica a los complementos de la plataforma: `_config.yml` define la línea base de inventario inicial para cada producto o variante, mientras que el Trabajador deriva el inventario restante efectivo del estado de compromiso guardado e invalida el inventario de complementos en caché después de los eventos de creación, modificación o cancelación del compromiso.

## Configuración

### 1. Cree espacios de nombres KV

```bash
cd worker

wrangler kv:namespace create "VOTES"
wrangler kv:namespace create "VOTES" --preview
wrangler kv:namespace create "PLEDGES"
wrangler kv:namespace create "PLEDGES" --preview
```

Actualice `wrangler.toml` con los ID devueltos.

### 2. Configurar secretos

```bash
# Stripe API Keys
wrangler secret put STRIPE_SECRET_KEY_LIVE
wrangler secret put STRIPE_SECRET_KEY_TEST

# Stripe Webhook Secrets
wrangler secret put STRIPE_WEBHOOK_SECRET_LIVE
wrangler secret put STRIPE_WEBHOOK_SECRET_TEST

# First-party checkout intent signing secret
wrangler secret put CHECKOUT_INTENT_SECRET

# Magic link token secret
wrangler secret put MAGIC_LINK_SECRET

# Email delivery
wrangler secret put RESEND_API_KEY

# Admin endpoints
wrangler secret put ADMIN_SECRET

# USPS OAuth secret (keep the client id in site config)
wrangler secret put USPS_CLIENT_SECRET
```

La configuración de USPS para este repositorio se divide intencionalmente:

- mantenga `shipping.usps.client_id` en la raíz del repositorio [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) o [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml)
- mantener `USPS_CLIENT_SECRET` en Secretos del trabajador o [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars)
- Si desea señalar al trabajador en USPS TEM para realizar pruebas, configure también `shipping.usps.api_base` o `USPS_API_BASE`.

Actualmente, The Pool solo necesita USPS OAuth más el conjunto de productos predeterminado de opciones de precio/envío para el cálculo de cotizaciones en vivo. **No** requiere la configuración de etiquetas/envío/EPA de USPS a menos que el proyecto crezca posteriormente hasta convertirse en la generación de etiquetas.

Ejemplo de archivo local `worker/.dev.vars`:

```dotenv
STRIPE_SECRET_KEY_TEST=sk_test_your_test_key
STRIPE_WEBHOOK_SECRET_TEST=whsec_your_test_webhook_secret
CHECKOUT_INTENT_SECRET=replace_with_a_long_random_string
MAGIC_LINK_SECRET=replace_with_a_different_long_random_string
RESEND_API_KEY=re_example_key
ADMIN_SECRET=replace_with_a_third_long_random_string
USPS_CLIENT_SECRET=replace_with_usps_client_secret
```

Notas:

- mantener `worker/.dev.vars` sin seguimiento y ignorado
- use secretos locales/de prueba aquí, no credenciales de producción en vivo
- `./scripts/dev.sh --podman` puede generar automáticamente o actualizar algunos valores solo locales, como `CHECKOUT_INTENT_SECRET` o el secreto del webhook de Stripe, durante el desarrollo.

### 3. Configurar los webhooks de Stripe

1. Vaya a [Stripe Webhooks](https://dashboard.stripe.com/webhooks)
2. Agregar punto final: `https://worker.example.com/webhooks/stripe`
3. Seleccionar eventos:
   - `checkout.session.completed`
   - `payment_intent.payment_failed`
4. Copie el secreto de firma a `STRIPE_WEBHOOK_SECRET_LIVE`
5. Repita para el modo de prueba con `STRIPE_WEBHOOK_SECRET_TEST`

### 4. Implementar/Ejecutar

Para un desarrollo local completo, prefiera la ruta Podman de raíz de repositorio anterior. Si necesita específicamente ejecutar solo el trabajador en el host:

```bash
npm run dev
```

Implementar con:

```bash
npm run deploy
npm run deploy:worker
```

En GitHub, los envíos a `main` también implementan el trabajador automáticamente a través de `.github/workflows/deploy.yml`. La configuración preferida utiliza los secretos del repositorio `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`. Como alternativa temporal, el flujo de trabajo también acepta la autenticación heredada de Cloudflare a través de `CLOUDFLARE_EMAIL` y `CLOUDFLARE_KEY`.

## Puntos finales API

### POST /intención-de-compra/inicio
Canonicalice la carga útil del carrito propio y cree una sesión de pago en modo de configuración de Stripe para una nueva contribución.

```json
{
  "campaignSlug": "hand-relations",
  "items": [
    { "id": "hand-relations__producer-credit", "quantity": 1 }
  ],
  "customAmount": 0,
  "email": "supporter@example.com",
  "tipPercent": 5,
  "shippingAddress": {
    "country": "US",
    "postalCode": "87120"
  },
  "shippingOption": "standard"
}
```

Devuelve un arranque de sesión personalizado (`checkoutUiMode`, `sessionId`, `clientSecret`, `publishableKey`, `orderId`) o una URL alternativa alojada.

El trabajador reconstruye el nivel, el complemento del paquete, el soporte personalizado, el envío y el estado del subtotal a partir de artículos del carrito propios, valida el estado y el inventario de la campaña, firma una instantánea de pago de corta duración, reserva un inventario escaso para niveles limitados antes de que se complete el paso de pago y confirma esas reservas cuando el compromiso realmente persiste. Para promesas físicas o complementos físicos, el envío lo calcula el trabajador desde el destino más los metadatos de envío de campaña/artículo, utilizando cotizaciones en vivo de USPS cuando estén disponibles y tasas de implementación o respaldo de campaña cuando no.

Cuando un compromiso califica para mejoras de envío, el Trabajador también mantiene la opción de entrega limitada seleccionada (`standard`, `signature_required` o `adult_signature_required`) para que el carrito, la Gestión del compromiso, el total del compromiso almacenado y los correos electrónicos de los seguidores permanezcan alineados.

Las reservas y los reclamos de nivel limitado se serializan a través de un coordinador de objetos duraderos por campaña antes de que se actualice la instantánea del inventario de KV, por lo que los inicios, reintentos, modificaciones y finalizaciones de webhooks simultáneos no pueden sobrevender las escasas recompensas.

### OBTENER /pledges?token={token}
Obtenga la(s) promesa(s) autorizada(s) mediante un token de enlace mágico.

Comportamiento actual: el token devuelve solo su propia orden autorizada.

### OBTENER /compromiso?token={token}
Obtenga detalles de compromiso único (punto final heredado).

### POST /promesa/cancelar
Cancelar un compromiso activo.

```json
{
  "token": "magic-link-token",
  "orderId": "pool-intent-abc123"
}
```

### POST /promesa/modificar
Cambie los niveles, la cantidad o el soporte personalizado para un compromiso activo.

```json
{
  "token": "magic-link-token",
  "orderId": "pool-intent-abc123",
  "newTierId": "sfx-slot",
  "newTierQty": 2,
  "addTiers": [{ "id": "frame", "qty": 5 }],
  "customAmount": 25
}
```

Todos los campos excepto `token` son opcionales. Los cambios se rastrean en la matriz `history` del compromiso con entradas `type: "modified"` que incluyen el estado del nivel, cambios de complementos del paquete, `customAmount`, deltas de envío y cualquier opción de envío seleccionada.

El trabajador valida el pedido solicitado con la carga útil del token y vuelve a calcular los totales a partir del estado del compromiso almacenado más las definiciones de la campaña. Los cambios estructurales al mismo precio, como un intercambio de variante adicional, todavía cuentan como cambios de compromiso reales para fines de persistencia y correo electrónico a los seguidores.

### ENVIAR /estadísticas/:slug/check
Ejecute una verificación de desviación de proyección de solo lectura para una campaña.

Requiere autenticación de administrador y devuelve si el índice de campaña almacenado, la proyección de estadísticas y la proyección de inventario de niveles todavía están sincronizados con la verdad del compromiso activo.

### ENVIAR /admin/proyecciones/verificar
Ejecute la misma verificación de deriva de solo lectura en todas las campañas.

Este es el punto final del lado del trabajador que impulsa [`scripts/check-projections.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-projections.sh) y las nuevas afirmaciones de humo de compromiso mutable.

## Notas de seguridad del contenido

- Los bloques de texto de campaña/diario aceptan Markdown más un pequeño subconjunto HTML en línea: `<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`.
- Los enlaces de Markdown se reescriben a menos que utilicen un esquema de destino incluido en la lista permitida (`http:`, `https:`, `mailto:` o enlaces internos).
- Los enlaces externos de Markdown obtienen automáticamente `target="_blank"` y `rel="noopener noreferrer"`.
- Las incrustaciones estructuradas solo se muestran cuando la URL del proveedor es una URL incrustada aprobada por `https://` Spotify, YouTube o Vimeo.

### POST /promesa/método-de-pago/inicio
Inicie una sesión de Stripe para actualizar el método de pago.

```json
{
  "token": "magic-link-token"
}
```

Devuelve un arranque de sesión personalizado para el flujo `Update Card` en el sitio o una URL alternativa alojada.

### OBTENER /share/campaign/:slug.svg
Devuelve una tarjeta compartida SVG pública para una campaña.

Parámetros de consulta opcionales:

- `lang=en|es` para localizar la copia de la interfaz de usuario de la campaña y el enlace de la campaña en el pie de página

La tarjeta renderizada utiliza datos de la campaña en vivo, incluido el estado actual, el total prometido, el progreso del objetivo y los metadatos del creador/categoría. Las etiquetas `og:image` / `twitter:image` de la página de campaña apuntan a esta ruta para que las vistas previas sociales permanezcan alineadas con la campaña activa y el estado de inserción.

### ENVIAR /webhooks/raya
Punto final del webhook de Stripe (firma verificada).

### POST /admin/broadcast/diario
Envíe una notificación de actualización del diario a todos los partidarios de la campaña. Requiere el encabezado `x-admin-key`.

```json
{
  "campaignSlug": "hand-relations",
  "diaryTitle": "Week 3 Update",
  "diaryExcerpt": "Optional preview text...",
  "dryRun": true  // Set to true to preview recipients without sending
}
```

### POST /admin/diario/verificar
Verifique todas las campañas en busca de nuevas entradas del diario y transmítalas automáticamente. Lo llaman GitHub Actions después de la implementación. Requiere el encabezado `Authorization: Bearer {ADMIN_SECRET}`.

```json
{
  "dryRun": true  // Optional: preview without sending
}
```

Devoluciones:
```json
{
  "success": true,
  "checked": 2,
  "newEntries": [
    { "campaignSlug": "...", "campaignTitle": "...", "date": "2026-01-15", "title": "..." }
  ],
  "sent": 10,
  "failed": 0,
  "errors": []
}
```

### POST /admin/broadcast/hito
Envíe notificaciones de hitos a todos los seguidores de la campaña. Requiere el encabezado `x-admin-key`.

```json
{
  "campaignSlug": "hand-relations",
  "milestone": "one-third",  // "one-third", "two-thirds", "goal", or "stretch"
  "stretchGoalName": "Director's Commentary",  // Required for "stretch" milestone
  "dryRun": true
}
```

### ENVIAR /prueba/correo electrónico
Envíe un correo electrónico de prueba de cualquier tipo. En modo de prueba (`APP_MODE=test`), no se requiere autenticación. En producción, requiere el encabezado `x-admin-key`.

```json
{
  "type": "supporter",  // See types below
  "email": "test@example.com",
  "campaignSlug": "hand-relations"
}
```

Tipos válidos:
- `supporter`: confirmación de compromiso (con elementos de compromiso de muestra)
- `modified`: modificación de la promesa (con elementos de promesa de muestra)
- `payment-failed` - Fallo en el pago (con subtotal/desglose de impuestos y elementos comprometidos)
- `charge-success`: cargo exitoso (con subtotal/desglose de impuestos y elementos comprometidos)
- `diary` - Notificación de actualización del diario
- `milestone-one-third` - Hito de 1/3 de gol
- `milestone-two-thirds` - Hito de 2/3 de gol
- `milestone-goal` - Objetivo alcanzado
- `milestone-stretch` - Meta ampliada desbloqueada

**Uso de producción:**
```bash
curl -X POST https://worker.example.com/test/email \
  -H "Content-Type: application/json" \
  -H "x-admin-key: YOUR_ADMIN_SECRET" \
  -d '{"email": "test@example.com", "type": "supporter", "campaignSlug": "hand-relations"}'
```

## Variables de entorno

|variable|Descripción|
|----------|-------------|
|`SITE_BASE`|URL base del sitio Jekyll|
|`WORKER_BASE`|URL base pública del Trabajador|
|`PLATFORM_NAME`|Nombre de la plataforma pública utilizada en las respuestas de los trabajadores y en la copia del correo electrónico|
|`PLATFORM_COMPANY_NAME`|Nombre de la empresa/autor de la plataforma utilizado para la copia de sugerencias de la plataforma|
|`SUPPORT_EMAIL`|Contacto de soporte reflejado desde la configuración del sitio|
|`PLEDGES_EMAIL_FROM`|Identidad del remitente para correos electrónicos relacionados con promesas|
|`UPDATES_EMAIL_FROM`|Identidad del remitente para correos electrónicos de actualización/hitos/anuncios|
|`I18N_CATALOG_JSON`|Anulación opcional del catálogo local en línea para la localización del correo electrónico de los trabajadores en pruebas o implementaciones personalizadas|
|`SALES_TAX_RATE`|Tasa de impuesto sobre las ventas reflejada de `pricing.sales_tax_rate`|
|`FLAT_SHIPPING_RATE`|Línea base de compatibilidad de envío plano heredada reflejada desde `pricing.flat_shipping_rate`|
|`SHIPPING_ORIGIN_ZIP`|Código postal de origen de envío de USPS reflejado de `shipping.origin_zip`|
|`SHIPPING_ORIGIN_COUNTRY`|País de origen del envío de USPS reflejado desde `shipping.origin_country`|
|`SHIPPING_FALLBACK_FLAT_RATE`|Tarifa de envío alternativa reflejada desde `shipping.fallback_flat_rate`|
|`FREE_SHIPPING_DEFAULT`|Valor predeterminado de envío gratuito en toda la implementación reflejado desde `shipping.free_shipping_default`|
|`USPS_ENABLED`|Si las cotizaciones en vivo de USPS están habilitadas|
|`USPS_CLIENT_ID`|ID de cliente USPS OAuth reflejado desde `shipping.usps.client_id`|
|`USPS_API_BASE`|URL base de la API de USPS reflejada desde `shipping.usps.api_base`|
|`USPS_TIMEOUT_MS`|Tiempo de espera de solicitud de USPS en ms|
|`USPS_QUOTE_CACHE_TTL_SECONDS`|TTL de caché de cotizaciones de USPS en memoria de corta duración|
|`USPS_FAILURE_COOLDOWN_SECONDS`|Enfriamiento después de repetidas fallas de USPS|
|`USPS_RATE_LIMIT_COOLDOWN_SECONDS`|Enfriamiento después de las respuestas de USPS `429`|
|`DEFAULT_PLATFORM_TIP_PERCENT`|Porcentaje de propina de plataforma predeterminado reflejado desde `pricing.default_tip_percent`|
|`MAX_PLATFORM_TIP_PERCENT`|Porcentaje máximo de propina de plataforma reflejado desde `pricing.max_tip_percent`|
|`APP_MODE`|`"test"` o `"live"`: determina qué claves API usar|
|`RESEND_RATE_LIMIT_DELAY`|Retraso entre correos electrónicos en ms (predeterminado: 600 ms para mantenerse por debajo del límite de 2 solicitudes por segundo de reenvío)|

Cuando `SITE_BASE` apunta al desarrollador local (`localhost` / `127.0.0.1`), las imágenes de correo electrónico incrustadas aún regresan a la base de activos pública `https://site.example.com` para que los clientes de la bandeja de entrada no reciban URL de imágenes de host local rotas.

Nota de fork: trate esas variables de identidad, precios y envío como espejos de la configuración estructurada del sitio en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml), especialmente las secciones `platform`, `pricing` y `shipping`. El carrito/tiempo de ejecución propios y la interfaz de usuario de pago en el sitio personalizada son comportamientos integrados de la plataforma ahora, no opciones de entorno de trabajo que normalmente debería personalizar.

Mantenga `USPS_CLIENT_SECRET` fuera de la configuración del sitio. Pertenece a los secretos del trabajador o [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars).

Nota de localización: el trabajador ahora localiza los asuntos/el cuerpo del correo electrónico dirigidos a los seguidores y los enlaces `/manage/` / `/community/:slug/` localizados desde el catálogo de configuración regional del sitio compartido. En funcionamiento normal, recupera ese catálogo de `SITE_BASE/assets/i18n.json`; las pruebas y las implementaciones avanzadas pueden inyectar `I18N_CATALOG_JSON` en su lugar. Eso significa que los correos electrónicos de soporte localizados y las rutas localizadas como `/es/manage/` o `/es/community/:slug/` permanecen alineadas con el modelo local del sitio cuando una implementación agrega esas rutas.

The Worker también ofrece vistas previas localizadas de tarjetas compartidas de campaña en `GET /share/campaign/:slug.svg` con una consulta opcional `?lang=es`. Las páginas de la campaña utilizan esa ruta para los metadatos de sus imágenes sociales, y el SVG generado refleja el idioma de estado/progreso de la inserción de la campaña mientras se vincula a la ruta de la campaña pública localizada.

## Flujo de datos

1. **Compromisos de usuarios en la página de la campaña**
   - carrito propio creado con un artículo de nivel
   - `POST /checkout-intent/start` crea la sesión Stripe en modo de configuración utilizada por el paso de pago en el sitio
   - el sidecar de pago existente monta la interfaz de usuario de pago segura de Stripe para guardar la tarjeta

2. ** Webhook de banda: checkout.session.completed **
   - Extraiga el método de pago y el cliente de SetupIntent
   - Conservar los datos de compromiso en KV y actualizar las estadísticas/inventario
   - Confirme la idempotencia del webhook solo después de una persistencia exitosa
   - Enviar correo electrónico de confirmación con un enlace mágico relacionado con el pedido

3. **El usuario gestiona el compromiso a través de /manage/?t={token}**
   - Llamadas frontales GET `/pledges`
   - El token puede leer/modificar sólo su propio pedido autorizado
   - El usuario puede modificar el nivel, cancelar o actualizar el método de pago.

4. **La campaña alcanza el objetivo**
   - El administrador activa el proceso de cobro (script separado)
   - Crea PaymentIntents utilizando métodos de pago almacenados
   - Actualiza el estado del compromiso a "cargado"

## Modo de prueba

Ruta de desarrollo local preferida:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Eso inicia el sitio y el Trabajador juntos, y el Trabajador todavía se ejecuta con `--env dev` bajo el capó.

La ruta más amplia del navegador automatizado ahora crea y ofrece un `_site` estático, por lo que las comprobaciones locales sin cabeza utilizan el mismo diseño de recursos de estilo publicado que el sitio creado en lugar de depender de `jekyll serve`.

Si necesita específicamente el respaldo solo para trabajadores:

```bash
cd worker
wrangler dev --env dev
```

El entorno `dev`:
- Conjuntos `APP_MODE=test`
- Utiliza `STRIPE_SECRET_KEY_TEST`
- Apunta `SITE_BASE` a localhost

Agregue `?dev` a la URL de la página de administración para obtener datos simulados: `http://127.0.0.1:4000/manage/?dev`

## Transmisiones diarias automatizadas

Las entradas del diario se transmiten automáticamente a los seguidores cuando se despliegan:

1. Cuando se agrega una nueva entrada del diario y se implementa el sitio, la acción de GitHub `deploy.yml` llama a `POST /admin/diary/check`.
2. El trabajador recupera datos de la campaña y compara las entradas del diario con lo que se ha enviado.
3. Las nuevas entradas se transmiten a todos los seguidores de la campaña por correo electrónico.
4. Las entradas enviadas se rastrean en KV (`diary-sent:{campaignSlug}`) para evitar correos electrónicos duplicados

**Configuración:** Asegúrese de que `ADMIN_SECRET` esté configurado como secreto del repositorio de GitHub para que la acción de implementación se autentique.
