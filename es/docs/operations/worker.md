---
title: Worker de promesas
parent: Operaciones
nav_order: 2
render_with_liquid: false
lang: es
---

# The Pool - Trabajador comprometido

## Última actualización

20 de junio de 2026

Cloudflare Worker se encarga de la canonicalización de pagos propios, la integración de Stripe, la gestión de promesas, la autenticación de seguidores con alcance de pedidos, los recordatorios de lanzamiento de próximas campañas, los recordatorios de checkout abandonado basados en consentimiento, los blasts a seguidores de campaña, las vistas previas protegidas de campañas y las API del panel de administración del navegador privado.

Para el desarrollo local diario, prefiera la ruta Podman de raíz de repositorio:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Esto inicia el sitio y el trabajador juntos en los puertos locales estándar y es la forma más fácil de ejercer el pago completo en el sitio y los flujos `Update Card` localmente.

La ruta Podman de raíz de repositorio ejecuta el trabajador con el nodo 24, que coincide con las acciones de GitHub. El desarrollo de Worker solo de host también debe utilizar el Nodo 24 cuando sea posible; Wrangler 4 requiere al menos el Nodo 22. La fecha de compatibilidad de Worker se comparte intencionalmente entre entornos locales e implementados para que el comportamiento del tiempo de ejecución de Miniflare/Workers no cambie.

Si trabaja específicamente desde el directorio `worker/`, los scripts Worker npm ahora ejecutan automáticamente el espejo de configuración primero para que `worker/wrangler.toml` permanezca alineado con la raíz del repositorio `_config.yml`/`_config.local.yml`.

Trate `_config.local.yml` como un archivo de solo anulación para valores específicos del host local. La configuración canónica de orientación hacia la bifurcación debe residir en la raíz del repositorio `_config.yml`, y el espejo del trabajador seguirá desde allí.

La entrega de informes de campaña sigue el mismo patrón:

- Los destinatarios a nivel de campaña viven en el frente de la campaña como `runner_report_emails`.
- la sincronización de toda la implementación y el comportamiento del correo electrónico/informes se encuentran en `_config.yml` en `reports.campaign_runner`
- el espejo del trabajador lleva esas configuraciones no secretas a `wrangler.toml`
- el núcleo de informes compartido en `worker/src/reports.js` ahora impulsa tanto los correos electrónicos de los ejecutores programados como los asistentes de exportación del shell local para que la lógica CSV permanezca en un solo lugar.
- el panel del navegador La pestaña Informes ofrece vistas previas y descargas CSV de compromiso/cumplimiento sin enviar correos electrónicos ni escribir marcadores de envío

La configuración de Worker reflejada ahora también incluye los indicadores de depuración compartidos:

- `DEBUG_CONSOLE_LOGGING_ENABLED`
- `DEBUG_VERBOSE_CONSOLE_LOGGING`

Estos provienen de `debug.console_logging_enabled` y `debug.verbose_console_logging` en la raíz del repositorio [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml). El registro de la consola permanece habilitado de forma predeterminada, mientras que la depuración detallada/información/ruido de registro está desactivado de manera predeterminada, por lo que la salida de advertencia/error sigue siendo útil sin enviar detalles de diagnóstico amplios.

El espejo Worker también incluye los botones de captación previa de intención pública utilizados por las páginas públicas generadas:

- `INTENT_PREFETCH_ENABLED`
- `INTENT_PREFETCH_DELAY_MS`
- `INTENT_PREFETCH_LIMIT`

Estos provienen de `performance.intent_prefetch_*` en la configuración de raíz del repositorio y los superadministradores los pueden editar en **Configuración -> Rendimiento avanzado**. Están reflejados para lograr paridad de configuración y visibilidad operativa; el tiempo de ejecución de captación previa real todavía se carga solo en diseños estáticos públicos y rechaza rutas privadas, tokenizadas, de pago, de administración, de soporte y de consultas confidenciales en el navegador.

La protección DoS de ruta de escritura ahora requiere un espacio de nombres KV `RATELIMIT`. Si falta ese enlace, el trabajador no se cierra con `503` en lugar de ejecutarse sin protección contra abusos. Las lecturas públicas de datos en vivo se mantienen intencionalmente amplias para los picos de campaña, mientras que el pago, la gestión de promesas y las mutaciones de administración utilizan los límites más estrictos por IP documentados en [`docs/SECURITY.md`](/es/docs/operations/security/). Ese requisito agrega seguridad, no una nueva suposición de que cada bifurcación debe superar inmediatamente el plan Workers Free.

Los trabajadores estándar/pagados implementados ahora también configuran `limits.cpu_ms = 100` en [`wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml). Ese límite no se aplica en el desarrollo local y no es una anulación de Workers Free; es un límite conservador de denegación de billetera para implementaciones pagas que aún deja un espacio cómodo por encima de los tiempos de solicitud de ruta rápida observados actualmente en el arnés de la unidad.

El cálculo de impuestos ahora se dirige a través de una costura de proveedor en `worker/src/tax.js`:

- `TAX_PROVIDER=flat` mantiene el comportamiento de velocidad configurada actual de `SALES_TAX_RATE`
- `TAX_PROVIDER=offline_rules` utiliza reglas proporcionadas para el IVA/GST internacional y el manejo alternativo a nivel estatal
- `TAX_PROVIDER=nm_grt` utiliza el conjunto de datos inicial de Nuevo México suministrado y puede refinar las búsquedas de direcciones de calles de Nuevo México con la API gratuita EDAC GRT.
- `TAX_PROVIDER=zip_tax` agrega búsquedas de EE. UU. a nivel local/jurisdiccional a través de ZIP.TAX y recurre a `offline_rules` para destinos fuera de EE. UU./CA

La configuración del proveedor no secreto se refleja desde la raíz del repositorio `_config.yml` en [`wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml) como `TAX_PROVIDER`, `TAX_ORIGIN_COUNTRY`, `TAX_USE_REGIONAL_ORIGIN`, `NM_GRT_API_BASE` y `ZIP_TAX_API_BASE`. Si habilita `zip_tax`, configure también `ZIP_TAX_API_KEY` como secreto de trabajador o en [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars). Actualice el archivo inicial de Nuevo México suministrado con `node ../scripts/update-nm-grt-starter.mjs`.

En el flujo actual del navegador, se permite intencionalmente que las vistas previas de impuestos permanezcan provisionales. Si el carrito o el pago personalizado aún no tiene suficientes datos de ubicación, el sitio muestra `--` y espera a que `/tax/quote` o `/checkout-intent/start` finalicen el resultado del impuesto. Las búsquedas de Nuevo México son la ruta integrada más exacta en este momento y normalmente necesitan datos completos de direcciones a nivel de calle, no solo código postal/estado, antes de que el trabajador pueda devolver un resultado de GRT local confiable.

El trabajador ahora también escribe resúmenes de observabilidad ligeros en `PLEDGES` KV para dos cosas:

- Resultados de entrega del webhook de Stripe e historial de entrega reciente
- tiempos de reloj de pared muestreados para un pequeño conjunto de rutas de mutación utilizadas para sintonizar la tapa `cpu_ms`

Los informes de los ejecutores de campaña utilizan la zona horaria de la plataforma configurada. `PLATFORM_TIMEZONE` tiene como valor predeterminado `America/Denver`, y el programador de trabajo de nivel de minutos verifica la hora de envío local configurada antes de enviar para que las bifurcaciones puedan usar cualquier zona horaria compatible con IANA.

Los recordatorios del próximo lanzamiento de campaña también se ejecutan en el programador de minutos. Las páginas de campañas públicas recopilan recordatorios explícitos por correo electrónico solo mientras se aproxima una campaña; El trabajador almacena claves de registro hash con alcance de campaña, pone en cola un trabajo de envío cuando esa campaña se activa y envía a través del módulo de correo electrónico de reenvío existente con el remitente de las actualizaciones. La cola de envío mantiene el estado `launch-reminder-dispatch-queue:v1`, por lo que los ticks programados inactivos omiten los análisis del espacio de nombres de envío; los trabajos en cola marcan el estado pendiente inmediatamente y el estado inactivo vence cada hora para compatibilidad con los trabajos insertados manualmente. La ruta del recordatorio no agrega una segunda integración de API de reenvío.

Los recordatorios de checkout abandonado usan el mismo patrón de presupuesto. El navegador muestra una casilla explícita de un solo recordatorio solo en la superficie de contacto del checkout propio personalizado, y `/checkout-intent/start` pone en cola `abandoned-cart:{orderId}` solo después de que Stripe crea correctamente la Checkout Session. La persistencia exitosa del webhook elimina el registro de recordatorio de ese mismo pedido. El pase programado lee primero `abandoned-cart-queue:v1` y omite listas de espacio de nombres cuando está inactivo o antes del siguiente vencimiento; cuando corresponde, procesa un lote acotado, revisa el índice de promesas de campaña para evitar enviar correo a seguidores que completaron desde otro pedido, escribe un marcador enviado por conjunto de correo/campaña y envía a través del módulo compartido de Resend con tokens firmados de `/abandoned-cart/unsubscribe` y enlace de reanudación. El `ABANDONED_CART_TOKEN_SECRET` opcional recurre a `MAGIC_LINK_SECRET`.

Los reintentos de correo electrónico de confirmación del colaborador utilizan el mismo patrón de nivel gratuito. Los envíos fallidos escriben `supporter-email-retry:{orderId}` más `supporter-email-retry-queue:v1` y el pase de reintento programado omite los escaneos de la lista KV mientras la cola está inactiva o antes de que venza el siguiente reintento.

La optimización de los medios de las páginas de campañas públicas sigue siendo una preocupación del sitio estático más que una preocupación del tiempo de ejecución de los trabajadores. El trabajador conserva las cargas del panel como archivos fuente y envía el optimizador del repositorio para las cargas de imágenes/videos confirmadas; Las plantillas Jekyll, el optimizador de medios del repositorio y el paso de implementación del artefacto manejan variantes WebP responsivas, fachadas de carteles de héroes locales de YouTube y minificación CSS/JS generada antes de que se publique el artefacto de páginas públicas. Las cargas de imágenes de anuncios Blast reutilizan el tipo y directorio de carga de contenido de campaña, por lo que las imágenes de correo se alojan bajo `assets/images/campaigns/<slug>/` y se optimizan mediante el mismo flujo de trabajo del repositorio en lugar de agregar procesamiento de imágenes del lado del Worker o estado KV extra.

La frecuencia de muestreo predeterminada es `0.1` y se puede anular con `OBSERVABILITY_SAMPLE_RATE=0.05` (o cualquier valor de `0-1`) si una bifurcación desea menos o más escrituras de tiempo muestreadas.

Las estadísticas del lado de los trabajadores y la reparación de inventario ahora también tratan a `campaign-pledges:{slug}` como un estado de proyección en lugar de una verdad permanente. Si el índice de una campaña se desvía de los registros de compromiso activos subyacentes, las rutas de recálculo lo reparan automáticamente mientras reconstruyen los totales de la campaña y el inventario de nivel limitado.

Antes de mutar algo, los operadores ahora pueden ejecutar comprobaciones de deriva de solo lectura a través de:

- `POST /stats/:slug/check`
- `POST /admin/projections/check`
- [`scripts/check-projections.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-projections.sh) desde la raíz del repositorio

Esas comprobaciones comparan las proyecciones almacenadas `campaign-pledges:{slug}`, `stats:{slug}` y `tier-inventory:{slug}` con la verdad del compromiso activo y devuelven una diferencia estructurada en lugar de un estado de reparación silenciosa.

La misma regla de "verdad guardada sobre el estado del borrador" ahora se aplica a los complementos de la plataforma: `_config.yml` define la línea base de inventario inicial para cada producto o variante, mientras que las tiendas Worker venden recuentos en `add-on-inventory-sold:v1`, actualiza esa proyección después de los eventos de creación, modificación o cancelación de promesas, y evita escaneos repetidos del espacio de nombres de promesas para lecturas normales de inventario después del arranque de la proyección inicial.

## Configuración

Para una configuración guiada y multiplataforma desde la raíz del repositorio, prefiera:

```bash
npm run setup:deploy -- --mode=local
npm run setup:deploy -- --mode=production --dry-run
```

El helper comprueba autenticación de `gh`, `wrangler` y Stripe CLI opcional, sincroniza `_config.yml` hacia esta configuración del Worker, crea espacios de nombres KV, actualiza `wrangler.toml`, escribe secretos del Worker, escribe secretos del repositorio de GitHub y puede desplegar cuando se pasa `--deploy`. Revise primero el dry run; los secretos de producción se solicitan/generan por separado y no se copian desde `.dev.vars` locales ignorados.

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

Los secretos del desarrollo local viven en [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars) ignorado. La ruta de configuración más segura es:

```bash
npm run secrets:dev
```

El asistente crea `worker/.dev.vars` a partir de [`worker/.dev.vars.example`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars.example) cuando es necesario, aplica permisos solo locales, genera secretos de firma para el desarrollo local y solicita claves de proveedor opcionales sin devolver los valores al terminal. Los lanzadores de desarrollo también ejecutan este asistente en modo no interactivo, por lo que los secretos de firma locales existen antes de que se inicie Wrangler. No pegue valores secretos de producción en `worker/.dev.vars` como copia de seguridad; utilice valores locales separados allí.

Los secretos de producción pertenecen a los secretos de los trabajadores de Cloudflare:

```bash
# Stripe API Keys
wrangler secret put STRIPE_SECRET_KEY_LIVE
wrangler secret put STRIPE_SECRET_KEY_TEST

# Browser publishable keys for on-site Stripe fields. These are not secrets;
# set them through dashboard Settings or Worker vars, not `wrangler secret`.
STRIPE_PUBLISHABLE_KEY_LIVE=pk_live_...
STRIPE_PUBLISHABLE_KEY_TEST=pk_test_...

# Stripe Webhook Secrets
wrangler secret put STRIPE_WEBHOOK_SECRET_LIVE
wrangler secret put STRIPE_WEBHOOK_SECRET_TEST

# First-party checkout intent signing secret
wrangler secret put CHECKOUT_INTENT_SECRET

# Magic link token secret
wrangler secret put MAGIC_LINK_SECRET

# Optional dedicated campaign-preview reviewer token secret.
# Falls back to MAGIC_LINK_SECRET / admin signing secrets when omitted.
wrangler secret put CAMPAIGN_PREVIEW_SECRET

# Email delivery
wrangler secret put RESEND_API_KEY

# Admin endpoints
wrangler secret put ADMIN_SECRET
# Optional scoped admin endpoint secrets. When set, these routes reject
# ADMIN_SECRET and require their narrower secret.
wrangler secret put ADMIN_SETTLEMENT_SECRET
wrangler secret put ADMIN_BROADCAST_SECRET

# Browser admin sessions and bootstrap access
wrangler secret put ADMIN_SESSION_SECRET
# _config.yml admin.users seeds ADMIN_USERS_JSON; dashboard user edits save to
# the PLEDGES KV key admin-users:v1 and do not publish to GitHub.
# Local dev reads ADMIN_BOOTSTRAP_EMAILS from worker/.dev.vars as a
# recovery/bootstrap super-admin path.

# Cloudflare Turnstile challenge verification when public widgets are enabled
wrangler secret put TURNSTILE_SECRET_KEY

# Optional admin plan usage tracker. Use a read-only GraphQL Analytics token,
# not the broader Wrangler deploy token. Add Billing Read to detect the
# current Workers plan from account subscriptions.
wrangler secret put CLOUDFLARE_USAGE_API_TOKEN
# Also make CLOUDFLARE_ACCOUNT_ID available to the Worker runtime, either as
# a plain Worker variable or as a secret if you do not want it in config.
# CLOUDFLARE_WORKER_SCRIPT_NAME is optional and filters request metrics to one script.

# Optional: scoped launch-reminder Turnstile / unsubscribe-token secrets
wrangler secret put LAUNCH_REMINDER_TURNSTILE_SECRET_KEY
wrangler secret put LAUNCH_REMINDER_TOKEN_SECRET

# Opcional: secreto dedicado de token para recordatorios de checkout abandonado.
# Recurre a MAGIC_LINK_SECRET cuando se omite.
wrangler secret put ABANDONED_CART_TOKEN_SECRET

# USPS OAuth secret (keep the client id in site config)
wrangler secret put USPS_CLIENT_SECRET

# Optional: ZIP.TAX API key for local/jurisdiction-level tax lookup
wrangler secret put ZIP_TAX_API_KEY
```

Si un flujo de trabajo de GitHub Actions o un trabajo de operador llama a puntos finales de administración con alcance, establezca también el mismo valor con alcance como secreto del repositorio de GitHub para ese flujo de trabajo. Los secretos del repositorio autentican las acciones de GitHub; no crean ni actualizan secretos de tiempo de ejecución de Cloudflare Worker. No almacene valores secretos en `_config.yml`, campaña YAML, KV, borradores de configuración de administrador ni documentación confirmada. Las claves publicables de Stripe son claves públicas del navegador y pueden almacenarse en la configuración del panel o en las variables de implementación. El panel de administración solo informa si las credenciales de tiempo de ejecución aparecen configuradas; no lee ni persiste valores secretos.

Se debe permitir que la clave API de reenvío se envíe desde el dominio configurado en `PLEDGES_EMAIL_FROM` y `UPDATES_EMAIL_FROM`. Para la implementación en vivo de Dust Wave, esas direcciones de remitente usan `site.example.com`; autorizar solo un dominio raíz no autoriza a los remitentes de subdominios, y autorizar solo un subdominio no autoriza a los remitentes de dominios raíz.

Para Configuración -> Uso del plan, Reenviar normalmente solo necesita `RESEND_API_KEY`. Los valores opcionales `PLAN_USAGE_RESEND_PLAN`, `RESEND_EMAILS_MONTHLY_LIMIT` y `RESEND_EMAILS_DAILY_LIMIT` son anulaciones de visualización para implementaciones en las que Resend devuelve encabezados de límite de velocidad pero no expone el encabezado de uso enviado mensual a través de un punto final de lectura segura.

El pago personalizado requiere la clave publicable de Stripe correspondiente para el `APP_MODE` actual. Si el trabajador está configurado para el pago personalizado pero no hay una clave publicable disponible, el pago vuelve al pago alojado en Stripe en lugar de devolver `503`, por lo que los compromisos aún pueden continuar mientras se configura la clave publicable.

La configuración de USPS para este repositorio se divide intencionalmente:

- mantenga `shipping.usps.client_id` en la raíz del repositorio [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) o [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml)
- mantener `USPS_CLIENT_SECRET` en Secretos de trabajador o [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars)
- Si desea señalar al trabajador en USPS TEM para realizar pruebas, configure también `shipping.usps.api_base` o `USPS_API_BASE`.

Actualmente, The Pool solo necesita USPS OAuth más el conjunto de productos predeterminado de opciones de precio/envío para el cálculo de cotizaciones en vivo. **No** requiere la configuración de etiquetas/envío/EPA de USPS a menos que el proyecto crezca posteriormente hasta convertirse en la generación de etiquetas.

Ejemplo de archivo `worker/.dev.vars` local:

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

En GitHub, los envíos a `main` también implementan el trabajador automáticamente a través de `.github/workflows/deploy.yml`. El flujo de trabajo utiliza secretos de repositorio `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`; cree `CLOUDFLARE_API_TOKEN` como token API de usuario en **Mi perfil -> Tokens API** con la plantilla **Editar trabajadores de Cloudflare**, con alcance en esta cuenta y la zona `example.com`. No utilice un token API propiedad de la cuenta, porque Wrangler todavía llama a puntos finales de ámbito de usuario durante la implementación. La purga de caché puede utilizar un `CLOUDFLARE_CACHE_PURGE_TOKEN` más estrecho y, de lo contrario, recurrir a `CLOUDFLARE_API_TOKEN`; Se recomienda el token de purga de caché independiente para que el token de implementación no necesite acceso de purga de caché de zona. El trabajo de implementación de páginas requiere `pages: write` y `id-token: write`; mantenga esos permisos explícitos si el flujo de trabajo se copia en una bifurcación.

## Puntos finales API

### POST /checkout-intent/start
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

Si el navegador ya tiene un destino de impuestos de facturación, también puede incluir `billingAddress` en esa carga útil para que la cotización de pago final no tenga que recurrir a las reglas de destino de impuestos de solo envío.

El trabajador reconstruye el nivel, el complemento del paquete, el soporte personalizado, el envío y el estado del subtotal a partir de artículos del carrito propios, valida el estado y el inventario de la campaña, firma una instantánea de pago de corta duración, reserva un inventario escaso para niveles limitados antes de que se complete el paso de pago y confirma esas reservas cuando el compromiso realmente persiste. Para promesas físicas o complementos físicos, el envío lo calcula el trabajador desde el destino más los metadatos de envío de campaña/artículo, utilizando cotizaciones en vivo de USPS cuando estén disponibles y tasas de implementación o respaldo de campaña cuando no.

Cuando un compromiso califica para mejoras de envío, el Trabajador también mantiene la opción de entrega limitada seleccionada (`standard`, `signature_required` o `adult_signature_required`) para que el carrito, la Gestión del compromiso, el total del compromiso almacenado y los correos electrónicos de los seguidores permanezcan alineados.

Las reservas y los reclamos de nivel limitado se serializan a través de un coordinador de objetos duraderos por campaña antes de que se actualice la instantánea del inventario de KV, por lo que los inicios de pago simultáneos, los reintentos, las modificaciones y las finalizaciones de webhooks no pueden sobrevender las escasas recompensas.

### GET /pledges?token={token}
Obtenga la(s) promesa(s) autorizada(s) mediante un token de enlace mágico.

Comportamiento actual: el token devuelve solo su propia orden autorizada.

### GET /pledge?token={token}
Obtenga detalles de compromiso único (punto final heredado).

### POST /pledge/cancel
Cancelar un compromiso activo.

```json
{
  "token": "magic-link-token",
  "orderId": "pool-intent-abc123"
}
```

### POST /pledge/modify
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

### POST /stats/:slug/check
Ejecute una verificación de desviación de proyección de solo lectura para una campaña.

Requiere autenticación de administrador y devuelve si el índice de campaña almacenado, la proyección de estadísticas y la proyección de inventario de niveles todavía están sincronizados con la verdad del compromiso activo.

### POST /admin/projections/check
Ejecute la misma verificación de deriva de solo lectura en todas las campañas.

Este es el punto final del lado del trabajador que impulsa [`scripts/check-projections.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-projections.sh) y las nuevas afirmaciones de humo de compromiso mutable.

## Notas de seguridad del contenido

- Los bloques de texto de campaña/diario aceptan Markdown más un pequeño subconjunto HTML en línea: `<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`.
- Los enlaces de Markdown se reescriben a menos que utilicen un esquema de destino incluido en la lista permitida (`http:`, `https:`, `mailto:` o enlaces internos).
- Los enlaces externos de Markdown obtienen automáticamente `target="_blank"` y `rel="noopener noreferrer"`.
- Las incrustaciones estructuradas solo se muestran cuando la URL del proveedor es una URL incrustada aprobada por `https://` Spotify, YouTube o Vimeo.
- Los bloques de video locales pueden incluir una imagen de póster opcional; sin uno, la interfaz de usuario del navegador genera un póster del primer fotograma a partir del recurso de vídeo del mismo origen sin cambiar el bloque almacenado.

### POST /pledge/payment-method/start
Inicie una sesión de Stripe para actualizar el método de pago.

```json
{
  "token": "magic-link-token"
}
```

Devuelve un arranque de sesión personalizado para el flujo `Update Card` en el sitio o una URL alternativa alojada.

### GET /share/campaign/:slug.png
Devolver una tarjeta compartida PNG pública para una campaña.

Parámetros de consulta opcionales:

- `lang=en|es` para localizar la copia de la interfaz de usuario de la campaña

La tarjeta renderizada utiliza datos de la campaña en vivo, incluido el estado actual, el total comprometido, el progreso del objetivo, los metadatos del creador/categoría y el cuadrado de la campaña `hero_image` como imagen de vista previa incrustada. The Worker rasteriza el mismo diseño de tarjeta SVG en PNG para que los rastreadores sociales obtengan una imagen compatible sin perder el estilo de vista previa más rico. Las páginas de campaña utilizan esta ruta PNG compatible con rastreadores para los metadatos `og:image`/`twitter:image`, a menos que una campaña proporcione explícitamente un `social_image` estático. La tarjeta visible no imprime la URL de la campaña; la URL permanece disponible a través de los metadatos de Open Graph circundantes.

### GET /share/campaign/:slug.svg
Devuelve el mismo concepto de tarjeta compartida de campaña que SVG para herramientas internas de vista previa/depuración. Utilice la ruta PNG para los metadatos sociales públicos porque algunos rastreadores externos rechazan las imágenes SVG.

### POST /webhooks/stripe
Punto final del webhook de Stripe (firma verificada).

### POST /tax/quote
Devuelve una vista previa de impuestos calculados por el trabajador para la interfaz de usuario del carrito/pago.

```json
{
  "subtotalCents": 1000,
  "shippingCents": 300,
  "billingAddress": {
    "country": "US",
    "postalCode": "80205",
    "state": "CO"
  }
}
```

El flujo actual del navegador utiliza esto para la visualización de impuestos de carrito provisional/pago personalizado. Tiene protección del mismo origen, velocidad limitada y está destinado a vistas previas de la interfaz de usuario de origen en lugar de uso público de terceros.

Si la carga útil no incluye suficientes detalles de destino para el proveedor configurado, el Trabajador puede devolver una respuesta de resultado provisional/sin impuestos y dejar que el navegador siga mostrando `--` hasta que el pago tenga un mejor destino de facturación o envío.

### POST /launch-reminders
Guarde un registro de recordatorio de lanzamiento público para una próxima campaña.

```json
{
  "campaignSlug": "their-love",
  "email": "supporter@example.com",
  "preferredLang": "en",
  "consent": true,
  "turnstileToken": "optional-widget-token"
}
```

El punto final está habilitado por `LAUNCH_REMINDERS_ENABLED`, acepta solo las próximas campañas, requiere consentimiento explícito, límites de velocidad por IP y verifica Cloudflare Turnstile cuando se configura un recordatorio o un secreto compartido de Turnstile. Los registros de registro tienen un alcance de campaña y se deduplican mediante un hash de correo electrónico normalizado, por lo que actualizar o enviar nuevamente actualiza un recordatorio activo en lugar de crear una lista de duplicados.

### GET /launch-reminders/unsubscribe?t={token}
Suprimir un recordatorio de lanzamiento relacionado con la campaña.

El token está firmado por `LAUNCH_REMINDER_TOKEN_SECRET` o el respaldo `MAGIC_LINK_SECRET` y solo autoriza el hash de campaña/correo electrónico codificado en el token. La ruta para cancelar la suscripción marca la cancelación del registro, escribe un marcador de supresión y devuelve una respuesta HTML sin índice/sin almacenamiento.

El envío del recordatorio de lanzamiento está controlado por un programador: cuando una campaña se activa, el paso del ciclo de vida diario pone en cola un trabajo de envío; las ejecuciones programadas a nivel de minutos agotan ese trabajo en lotes limitados. Cada destinatario recibe un marcador de envío por campaña antes de que avance el trabajo, y la entrega de correo electrónico utiliza el asistente `sendLaunchReminderEmail` existente en `worker/src/email.js`, el generador de carga útil de reenvío compartido y `UPDATES_EMAIL_FROM`.

### GET /admin/observability/webhooks?days=2
Resumen de observabilidad del webhook solo para administradores.

Devuelve recuentos de entregas de webhooks recientes por día, resultados, resúmenes de tipos de eventos, estadísticas de duración y una breve ventana de eventos recientes para reintentos de depuración, errores de firma y picos de tráfico inesperados.

### GET /admin/observability/performance?days=2
Resumen de rendimiento de muestra solo para administradores.

Devuelve muestras de tiempos de reloj de pared para rutas de mutación clave, como inicio de pago, finalización de pago, escrituras de compromiso de gestión, cotizaciones de envío y abandono de pago. Esto está pensado como una ayuda de ajuste para la tapa `cpu_ms` desplegada, no como un sistema de seguimiento de alta cardinalidad.

### Panel de administración del navegador

Los shells privados `/admin/` y `/es/admin/` utilizan rutas de trabajo respaldadas por cookies en lugar de exponer `ADMIN_SECRET` en el código del navegador:

- `POST /admin/auth/start` verifica Cloudflare Turnstile primero cuando `TURNSTILE_SECRET_KEY` está configurado y luego envía un enlace mágico localizado de corta duración para un correo electrónico de administrador autorizado. Los trabajadores desplegados envían el enlace por correo electrónico a través de Reenviar; El desarrollo local puede exponer el enlace en la respuesta JSON solo para configuraciones de prueba/localhost o `ADMIN_EXPOSE_LOGIN_LINK=true` explícito.
- `POST /admin/auth/exchange` intercambia ese token único por la cookie `pool_admin_session`
- `GET /admin/session` lee la sesión actual sin actualizarla ni escribirla
- `POST /admin/logout` borra la sesión
- `GET /admin/dashboard/summary` lee resúmenes de campañas con alcance de roles
- `GET /admin/settings` lee una instantánea de configuración/configuración de ámbito de función para el panel
- `POST /admin/settings/preview` valida los cambios de configuración sin publicar
- Cargas de paneles de escenario `POST /admin/settings/logo-upload`, `POST /admin/settings/image-upload`, `POST /admin/settings/audio-upload` y `POST /admin/settings/video-upload` a través de la misma ruta de publicación respaldada por GitHub que sus propios campos de configuración/contenido; Las cargas de imágenes/videos solicitan el flujo de trabajo **Optimizar medios del panel** con `scope=changed` después de la confirmación, mientras que la optimización de imágenes nativas y la transcodificación de video aún se ejecutan en la canalización de medios del repositorio en lugar de dentro del Worker.
- `POST /admin/settings/publish` valida y publica configuraciones de plataforma, complementos de plataforma, variables de campaña y datos estructurados de campaña a través de confirmaciones respaldadas por GitHub.
- `POST /admin/users` guarda los usuarios administradores administrados por el panel directamente en `admin-users:v1` en Worker KV y envía por correo electrónico las instrucciones de inicio de sesión de los usuarios recién creados cuando se configura Resend
- `POST /admin/campaigns/create` permite que los superadministradores creen campañas solo de vista previa a través de la ruta de código fuente de campañas respaldada por GitHub, asignen uno o más usuarios de campaña existentes, creen opcionalmente varios usuarios nuevos en `admin-users:v1`, envíen por correo electrónico el enlace del panel de administración a los usuarios asignados y registren un evento de auditoría
- `POST /admin/campaigns/archive` permite que los superadministradores archiven campañas no activas localmente en desarrollo o mediante el despacho de `.github/workflows/archive-campaign.yml` en producción; el Worker valida CSRF, rol, slug, existencia de campaña y estado efectivo, registra un evento de auditoría y mueve el código fuente/medios de la campaña mediante el helper local del repositorio o GitHub Actions
- `POST /admin/campaign-preview/publish` permite que los superadministradores y usuarios de campaña asignados publiquen una vista previa protegida, guarda el administrador publicador y los correos opcionales de revisores en `campaign-preview-reviewers:{slug}` con TTL de 24 horas, devuelve un enlace firmado de vista previa para el administrador publicador, envía enlaces firmados a los revisores opcionales, escribe solo flags de vista previa en el Markdown de campaña y registra un evento de auditoría
- `GET /admin/campaign-preview/:slug` devuelve una carga privada/no-store de vista previa completa de la página de campaña, con fuentes, embeds de medios y controles de promesa de solo lectura, cuando quien solicita tiene una sesión de administrador autorizada o un token de revisor válido cuyo correo todavía está en la allowlist KV de 24 horas
- `GET /admin/analytics` lee métricas de ingresos, estado, idioma, referencias, UTM source/medium/campaign/content y división de campaña/plataforma derivadas de compromisos con alcance de rol sin escribir el estado analítico; La presentación de la moneda en el tablero mantiene los centavos exactos.
- `GET /admin/plan-usage` permite a los superadministradores cargar Cloudflare y el uso del plan de reenvío desde las API del proveedor sin exponer los tokens del proveedor al navegador ni escribir el estado de KV; el panel lo carga automáticamente cuando se abre Configuración -> Uso del plan
- `POST /admin/analytics/stripe-financials/backfill` permite a los superadministradores reponer los valores netos y de tarifas de Stripe reales a partir de las transacciones de saldo de Stripe para las promesas cobradas, utilizando índices de promesas de campaña en lugar de escaneos de listas de KV.
- `GET /admin/content/campaign?campaignSlug=...` carga contenido de campaña con alcance de roles en el editor del navegador sin conservar un borrador
- `POST /admin/content/preview` valida y presenta borradores de contenido de campaña con alcance de roles sin publicar, auditar ni escribir KV
- `POST /admin/content/publish` valida el mismo borrador, actualiza el archivo Markdown de la campaña a través de GitHub, activa el flujo de trabajo de reconstrucción normal y escribe un evento de auditoría.
- `GET /admin/supporters?campaignSlug=...` lee filas de seguidores de campaña de `campaign-pledges:{slug}` únicamente; La presentación de la cantidad en el tablero mantiene los centavos exactos.
- `GET /admin/reports/campaign-runner/preview?campaignSlug=...&reportType=pledge|fulfillment` obtiene una vista previa del resultado del informe compartido del ejecutor de campaña sin enviar correos electrónicos ni escribir marcadores
- `GET /admin/reports/campaign-runner.csv?campaignSlug=...&reportType=pledge|fulfillment` descarga el mismo informe CSV compartido sin enviar correo electrónico ni escribir marcadores
- `GET /admin/marketing/referrals?campaignSlug=...` enumera los códigos de referencia de campaña guardados sin escribir ni escanear la verdad del compromiso
- `POST /admin/marketing/referrals` guarda o actualiza explícitamente un código de referencia de campaña con protección CSRF y una escritura KV con alcance de campaña.
- `DELETE /admin/marketing/referrals` elimina explícitamente un código de referencia de campaña guardado con protección CSRF y una escritura KV con alcance de campaña.
- `GET /admin/marketing/draft?campaignSlug=...&surface=marketing|blast`, `POST /admin/marketing/draft` y `DELETE /admin/marketing/draft` proporcionan carga/guardado/borrado explícitos de borradores compartidos de Marketing/Blast con TTL de 7 días, protección contra conflictos de revisión y una escritura KV con alcance de campaña solo al guardar/borrar
- `GET /admin/media/library?campaignSlug=...` lista imágenes de campaña existentes para bloques de imagen WYSIWYG mediante lecturas de directorios de GitHub; los usuarios de campaña permanecen limitados a su campaña, y los superadministradores también pueden ver imágenes compartidas/predeterminadas
- `GET /admin/abandoned-checkout/health?campaignSlug=...` lee salud agregada de recordatorios de checkout abandonado sin listas KV; los resultados de supresión creados por admins incluyen el correo suprimido para que los admins de campaña puedan borrarlos desde la tabla de resultados recientes
- `POST /admin/abandoned-checkout/suppression` y `DELETE /admin/abandoned-checkout/suppression` establecen o borran explícitamente una supresión de recordatorio de checkout abandonado con alcance de campaña, protección CSRF, identificadores de correo hasheados, eventos de auditoría y escrituras KV acotadas
- `GET /abandoned-cart/resume?t=...` verifica un token firmado, lee el snapshot de corta duración `abandoned-cart-resume:{orderId}` creado después de enviar un recordatorio y devuelve solo datos sanitizados de borrador de carrito/contacto para que el navegador pueda iniciar una sesión nueva de checkout
- `GET /admin/marketing/announcements?campaignSlug=...` lee historial reciente de Blast enviados desde registros acotados de auditoría administrativa para la campaña seleccionada
- `POST /admin/marketing/announcement` ejecuta prueba, envío de prueba o envío real de un mensaje Campaigns -> Blast con sesión del panel, comprobaciones CSRF/origen, validación de audiencia indexada, exigencia del hash de prueba correspondiente para envíos reales y una escritura de auditoría después del despacho
- `GET /admin/add-ons/inventory` lee el estado inicial, vendido, restante y de anulación del complemento de plataforma para superadministradores
- `POST /admin/add-ons/inventory` establece, reabastece o restablece explícitamente las anulaciones de la línea base del inventario de complementos de la plataforma con protección CSRF y registro de auditoría

Las lecturas normales del panel, los filtros de seguidores, la paginación, los análisis derivados de promesas, las listas de referencias de marketing, la salud de checkout abandonado, las cargas del selector de medios, las vistas previas de informes, las descargas de CSV, las cargas de contenido, las lecturas de cargas de vista previa protegida, las vistas previas de contenido, las pruebas de Blast y los borradores del editor local están diseñados para agregar escrituras de KV cero y operaciones de lista de KV cero. Las cargas de uso del plan también son de solo lectura KV, pero llaman intencionalmente a las API del proveedor de Cloudflare y Reenvío una vez cuando un superadministrador abre Configuración -> Uso del plan. Los guardados de usuarios iniciados por el navegador, los guardados de referencias de marketing, los guardados/borrados de borradores compartidos, las mutaciones de supresión de checkout abandonado con alcance, los envíos reales de Blast, las publicaciones de contenido, las publicaciones de vista previa, la creación de nuevas campañas, las operaciones de archivado de campañas y los cambios de inventario son mutaciones explícitas: los guardados de usuarios escriben `admin-users:v1`, los guardados de referencias escriben una lista de referencias con alcance de campaña, los guardados de borrador compartido escriben un registro de borrador de 7 días, las supresiones de recordatorio con alcance escriben/eliminan un registro de supresión más actualizaciones de auditoría/salud, los envíos reales de Blast escriben un evento de auditoría después del despacho, las publicaciones de contenido hacen commit en GitHub, activan el flujo de trabajo de reconstrucción y escriben un evento de auditoría, las publicaciones de vista previa escriben una allowlist de acceso efímera `campaign-preview-reviewers:{slug}` más un evento de auditoría, la creación de una campaña nueva puede escribir `admin-users:v1` más un evento de auditoría además del archivo Markdown de campaña, y el archivado escribe un evento de auditoría mientras el desarrollo local o `.github/workflows/archive-campaign.yml` mueve el código fuente/medios a `archive/campaigns/<slug>/`. Los envíos de recordatorio de checkout abandonado también escriben un registro efímero `abandoned-cart-resume:{orderId}` para que el CTA firmado del correo pueda restaurar un borrador sanitizado de checkout del navegador sin agregar escaneos de cola. Si a una campaña anterior le falta su proyección `campaign-pledges:{slug}`, los puntos finales de lectura del panel devuelven cero filas o un aviso no bloqueante de índice faltante en lugar de recurrir a un escaneo de espacio de nombres; ejecute las herramientas de reparación/reconstrucción de proyecciones existentes explícitamente cuando eso suceda.

Los inicios/intercambios de autenticación de administrador y las mutaciones de administrador de navegador tienen una velocidad limitada a través del enlace `RATELIMIT` y devuelven fallas privadas/sin almacenamiento cuando se aceleran. Las lecturas autenticadas normales, como comprobaciones de sesiones, resúmenes de paneles, filtros de soporte, vistas previas de informes, vistas de análisis y vistas previas de contenido, no están limitadas intencionalmente por la velocidad de KV. Los tokens de inicio de sesión de Magic-link son de un solo uso y las lecturas de sesión no actualizan las sesiones cercanas a su vencimiento ni limpian las sesiones vencidas en la ruta de lectura. Las mutaciones de administrador respaldadas por cookies requieren tanto el token CSRF de sesión como un contexto de recuperación confiable del mismo sitio `Origin`/`Referer` o que no sea entre sitios antes de escrituras duraderas.

Cuando se configura `TURNSTILE_SECRET_KEY`, `POST /admin/auth/start` verifica el desafío Cloudflare Turnstile antes de enviar un correo electrónico con enlace mágico. Mantenga esa protección solo en la ruta de envío para que no agregue vistas de página del panel o escrituras KV al escribir.

El inventario complementario de la plataforma utiliza `_config.yml` como línea base configurada, el estado KV `add-on-inventory-overrides` opcional para reabastecimientos del operador y `add-on-inventory-sold:v1` para recuentos vendidos derivados de la verdad del compromiso guardado. Las vistas de la página de inventario del administrador no cargan la tabla de inventario automáticamente; la lectura del inventario del superadministrador es explícita y utiliza la proyección del recuento de ventas después del arranque, mientras que las acciones de configuración/reabastecimiento/restablecimiento escriben solo el estado de anulación más un evento de auditoría.

La sección de la herramienta de marketing mantiene la creación de URL de la campaña, los parámetros UTM/referencia, los accesos directos del creador de incrustaciones, las preferencias de campos locales, las vistas previas/descargas QR y las ediciones de campos sin guardar en el estado del navegador. Los códigos de referencia guardados y los borradores compartidos son independientes: listar referencias es de solo lectura, guardar referencias y guardar borradores compartidos son mutaciones KV explícitas con alcance de campaña, y los guardados de borrador compartido obsoletos fallan si la revisión no coincide. Los informes de rendimiento de referencia/UTM pertenecen a Analytics y permanecen en modo de solo lectura. Las ediciones locales de Blast permanecen en el navegador salvo que se guarden explícitamente como borrador compartido; la carga de imágenes es una mutación explícita de medios respaldada por GitHub antes de envíos de prueba/reales, las pruebas usan el índice de promesas de campaña sin listas ni escrituras KV, y los envíos reales escriben solo el evento de auditoría requerido después del despacho.

### POST /admin/broadcast/diary
Envíe una notificación de actualización del diario a todos los partidarios de la campaña. Requiere el encabezado `x-admin-key`.

```json
{
  "campaignSlug": "hand-relations",
  "diaryTitle": "Week 3 Update",
  "diaryExcerpt": "Optional preview text...",
  "dryRun": true  // Set to true to preview recipients without sending
}
```

### POST /admin/diary/check
Verifique todas las campañas en busca de nuevas entradas del diario y transmítalas automáticamente. Lo llaman GitHub Actions después de la implementación. Requiere `Authorization: Bearer {ADMIN_BROADCAST_SECRET}` cuando se configura el secreto de difusión con ámbito; de lo contrario, `Authorization: Bearer {ADMIN_SECRET}`.

Si la seguridad de la zona de Cloudflare desafía la solicitud de GitHub Actions antes de que llegue al trabajador, establezca un secreto de repositorio llamado `DIARY_CHECK_BYPASS_SECRET` y agregue una regla de omisión WAF de Cloudflare para `POST /admin/diary/check` cuando `X-Pool-Diary-Check` coincida con ese secreto. Mantenga habilitado el administrador del trabajador o el secreto de transmisión; el encabezado de omisión es solo una señal de regla de borde, no una autenticación de trabajador.

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

### POST /admin/broadcast/milestone
Envíe notificaciones de hitos a todos los seguidores de la campaña. Requiere el encabezado `x-admin-key`.

```json
{
  "campaignSlug": "hand-relations",
  "milestone": "one-third",  // "one-third", "two-thirds", "goal", or "stretch"
  "stretchGoalName": "Director's Commentary",  // Required for "stretch" milestone
  "dryRun": true
}
```

### POST /admin/report/campaign-runner
Obtenga una vista previa o envíe manualmente un informe de ejecución de campaña para una campaña. Requiere el encabezado `x-admin-key`.

```json
{
  "campaignSlug": "hand-relations",
  "reportType": "pledge",   // "pledge" or "fulfillment"
  "dryRun": true,
  "markAsSent": false
}
```

Notas:

- `dryRun: true` devuelve destinatarios, recuentos de filas, nombre de archivo y estado del marcador sin enviar
- Al omitir `markAsSent`, el valor predeterminado es `true` para envíos en vivo, de modo que la ejecución programada coincidente no duplique inmediatamente el informe.
- Los destinatarios de la campaña todavía provienen del frente de la campaña `runner_report_emails`.
- `reportType: "pledge"` es el informe diario de la campaña en vivo.
- `reportType: "fulfillment"` es el informe único de envío/exportación posterior a la fecha límite
- Los correos electrónicos de informes utilizan asuntos cortos, sin emojis y que priorizan la entregabilidad con el prefijo configurado más el tipo de informe y el título de la campaña.
- Los correos electrónicos de compromiso diario incluyen totales de campaña únicamente más una breve nota de impulso/entrenamiento en el cuerpo.
- envíos de cumplimiento divididos por cumplimiento:
  - Los destinatarios de la campaña reciben solo las filas completadas por la campaña.
  - `platform.support_email` recibe un correo electrónico de cumplimiento de plataforma independiente cuando existen filas de plataforma
- Los correos electrónicos de cumplimiento utilizan un resumen/nota de cuerpo específico del cumplimiento en lugar de reutilizar el resumen diario del informe de compromiso.
- Los simulacros de cumplimiento/respuestas de informes exponen `campaignRowCount`, `platformRowCount` y `platformRecipient`.

Ejemplo de ejecución en seco:

```bash
curl -X POST https://worker.example.com/admin/report/campaign-runner \
  -H "Content-Type: application/json" \
  -H "x-admin-key: YOUR_ADMIN_SECRET" \
  -d '{"campaignSlug":"hand-relations","reportType":"pledge","dryRun":true}'
```

Ejemplo de envío manual:

```bash
curl -X POST https://worker.example.com/admin/report/campaign-runner \
  -H "Content-Type: application/json" \
  -H "x-admin-key: YOUR_ADMIN_SECRET" \
  -d '{"campaignSlug":"hand-relations","reportType":"fulfillment","dryRun":false,"markAsSent":true}'
```

Orientación operativa:

- prefiera `dryRun: true` primero al verificar una nueva campaña, lista de destinatarios o cambio de personalización
- configure `markAsSent: false` solo cuando desee intencionalmente un envío manual sin consumir el marcador de envío programado
- El comportamiento en toda la implementación proviene de `_config.yml` bajo `reports.campaign_runner`, mientras que los destinatarios por campaña permanecen al frente.
- para el cumplimiento, valide tanto el corredor como la plataforma antes de enviar si una campaña incluye complementos de plataforma

### POST /test/email
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

|Variable|Descripción|
|----------|-------------|
|`SITE_BASE`|URL base del sitio Jekyll|
|`WORKER_BASE`|URL base pública del Trabajador|
|`PLATFORM_NAME`|Nombre de la plataforma pública utilizada en las respuestas de los trabajadores y en la copia del correo electrónico|
|`PLATFORM_COMPANY_NAME`|Nombre de la empresa/autor de la plataforma utilizado para la copia de sugerencias de la plataforma|
|`SUPPORT_EMAIL`|Contacto de soporte reflejado desde la configuración del sitio|
|`PLEDGES_EMAIL_FROM`|Identidad del remitente de correos electrónicos relacionados con promesas; su dominio debe estar autorizado en Reenviar|
|`UPDATES_EMAIL_FROM`|Identidad del remitente para correos electrónicos de actualización/hitos/Blast/anuncios; su dominio debe estar autorizado en Reenviar|
|`EMAIL_LOGO_PATH`|Ruta del logotipo de correo electrónico del colaborador reflejada desde `platform.logo_path`|
|`EMAIL_FONT_FAMILY`|Pila de fuentes del cuerpo del correo electrónico del colaborador reflejada desde `design.font_body`|
|`EMAIL_HEADING_FONT_FAMILY`|Pila de fuentes de encabezado de correo electrónico de apoyo reflejada desde `design.font_display`|
|`EMAIL_COLOR_TEXT`|Color del texto base del correo electrónico del colaborador reflejado desde `design.color_text`|
|`EMAIL_COLOR_MUTED`|Color de texto silenciado del correo electrónico de soporte reflejado desde `design.color_text_muted`|
|`EMAIL_COLOR_SURFACE`|Color de la superficie de la tarjeta de correo electrónico de apoyo reflejado de `design.color_surface_subtle`|
|`EMAIL_COLOR_BORDER`|Color del borde del correo electrónico de apoyo reflejado desde `design.color_border`|
|`EMAIL_COLOR_PRIMARY`|Color de enlace/CTA principal del correo electrónico del colaborador reflejado desde `design.color_primary`|
|`EMAIL_BUTTON_RADIUS`|Radio del botón de correo electrónico del colaborador reflejado desde `design.radius_lg`|
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
|`APP_MODE`|`"test"` o `"live"`: determina qué claves API utilizar. Las implementaciones de producción deben utilizar `"live"`; `dev` local usa `"test"`.|
|`ADMIN_LOCAL_REPO_WRITES_ENABLED`|Guard de solo desarrollo que permite que `APP_MODE=test` cree archivos de campañas solo de vista previa y archive el código fuente/medios de campaña en el repositorio local montado. No habilitar en Workers desplegados.|
|`ADMIN_LOCAL_REPO_SERVICE`|URL del helper local de solo desarrollo usado por Wrangler/Podman porque el runtime del Worker no puede escribir archivos directamente. El valor predeterminado es `http://127.0.0.1:8799` en `env.dev`.|
|`CORS_ALLOWED_ORIGIN`|El origen del navegador permite llamar al trabajador desde el panel/sitio|
|`CAMPAIGN_PREVIEW_SECRET`|Secreto HMAC dedicado opcional para enlaces de revisor de vista previa de campaña de 24 horas; recurre a los secretos de firma existentes cuando se omite|
|`ADMIN_EXPOSE_LOGIN_LINK`|Trampilla de escape opcional solo local para devolver las URL de inicio de sesión de administrador en las respuestas `/admin/auth/start`. No habilitar en trabajadores desplegados.|
|`ADMIN_SESSION_SECRET`|Secreto utilizado para las cookies de sesión de administración del navegador|
|`ADMIN_BOOTSTRAP_EMAILS`|Correos electrónicos de superadministrador de arranque/recuperación opcionales; configure esto en `worker/.dev.vars` para desarrolladores locales|
|`ADMIN_USERS_JSON`|Usuarios administradores de semilla/recuperación reflejados desde `_config.yml`; Las ediciones del panel de tiempo de ejecución se guardan en KV en `admin-users:v1`.|
|`ADMIN_TEST_CAMPAIGNS`|Slugs de campaña opcionales separados por comas expuestos a la configuración de prueba del panel de administración local|
|`TURNSTILE_SECRET_KEY`|Clave secreta compartida de Cloudflare Turnstile para el inicio de sesión del correo electrónico del administrador y la verificación del desafío del recordatorio de lanzamiento|
|`ADMIN_TURNSTILE_SECRET_KEY`|Secreto de torniquete opcional específico del administrador cuando no se utiliza `TURNSTILE_SECRET_KEY`|
|`ADMIN_TURNSTILE_REQUIRED`|Indicador opcional de cierre fallido para implementaciones que esperan que se configure Turnstile|
|`ADMIN_TURNSTILE_BYPASS`|Omisión local/solo de prueba para pruebas de autenticación de administrador automatizadas; no habilitar en trabajadores desplegados|
|`CLOUDFLARE_USAGE_API_TOKEN` / `CLOUDFLARE_ANALYTICS_API_TOKEN`|Token GraphQL Analytics de solo lectura opcional para Configuración -> Plan de uso; agregue la detección automática del plan Billing Read for Workers y manténgalo separado de los tokens de implementación|
|`CLOUDFLARE_ACCOUNT_ID`|ID de cuenta utilizada por las consultas GraphQL de uso del plan Cloudflare|
|`CLOUDFLARE_WORKER_SCRIPT_NAME`|Filtro de script de trabajador opcional para métricas de solicitud de Cloudflare; omitir para el uso de trabajadores en toda la cuenta|
|`PLAN_USAGE_CLOUDFLARE_PLAN` / `PLAN_USAGE_RESEND_PLAN`|Teclas de plan de visualización opcionales (`free`, `standard`/`paid`, `pro`, `scale`) se usan solo cuando la detección automática del plan de proveedor no está disponible|
|`CLOUDFLARE_*_DAILY_LIMIT` / `CLOUDFLARE_*_MONTHLY_LIMIT`|Anulaciones de límites de métricas opcionales de Cloudflare para solicitudes de trabajadores y lecturas/escrituras/eliminaciones/listas de KV, por ejemplo `CLOUDFLARE_WORKERS_REQUESTS_MONTHLY_LIMIT`|
|`RESEND_EMAILS_MONTHLY_LIMIT` / `RESEND_EMAILS_DAILY_LIMIT`|Anulaciones de cuota de visualización de reenvío opcionales que se utilizan cuando Resend expone datos de límite de tarifa/plan pero omite encabezados de uso de envío mensual|
|`PLAN_USAGE_WARNING_PERCENT` / `PLAN_USAGE_CRITICAL_PERCENT`|Umbrales de advertencia opcionales para las barras de progreso de uso del plan|
|`LAUNCH_REMINDERS_ENABLED`|Habilita el manejo público del registro de recordatorios de lanzamiento de próximas campañas; reflejado de `_config.yml`|
|`LAUNCH_REMINDER_TURNSTILE_SECRET_KEY`|Secreto de torniquete específico de recordatorio opcional cuando no se utiliza `TURNSTILE_SECRET_KEY`|
|`LAUNCH_REMINDER_TURNSTILE_REQUIRED`|Indicador opcional de cierre fallido para registros de recordatorio cuando se espera un widget de torniquete de recordatorio|
|`LAUNCH_REMINDER_TURNSTILE_BYPASS`|Omisión local/solo de prueba para la automatización del registro de recordatorios; no habilitar en trabajadores desplegados|
|`LAUNCH_REMINDER_TOKEN_SECRET`|Secreto de firma de token de cancelación de suscripción opcional; vuelve a `MAGIC_LINK_SECRET`|
|`LAUNCH_REMINDER_DISPATCH_BATCH_SIZE`|Anulación opcional del tamaño del lote de envío de recordatorio por trabajo|
|`LAUNCH_REMINDER_DISPATCH_JOB_LIMIT`|Número opcional de trabajos de envío de recordatorios para procesar por tick programado|
|`ABANDONED_CART_TOKEN_SECRET`|Secreto opcional de token para recordatorios de checkout abandonado, usado por enlaces de cancelación de suscripción y reanudación; recurre a `MAGIC_LINK_SECRET`|
|`INTENT_PREFETCH_ENABLED`|Indicador habilitado de captación previa de intención de documento público reflejado desde la configuración del sitio|
|`INTENT_PREFETCH_DELAY_MS`|Retraso de desplazamiento/enfoque antes de que comience la captación previa de documentos públicos|
|`INTENT_PREFETCH_LIMIT`|Precargas máximas de documentos públicos por vista de página|

Cuando `SITE_BASE` apunta al desarrollador local (`localhost` / `127.0.0.1`), las imágenes de correo electrónico incrustadas aún regresan a la base de activos pública `https://site.example.com` para que los clientes de la bandeja de entrada no reciban URL de imágenes de host local rotas.

El ritmo de reenvío se centraliza como `RESEND_RATE_LIMIT_DELAY_MS` en `worker/src/email.js` y se reutiliza en transmisiones de seguidores, informes, recordatorios de lanzamiento, recordatorios de checkout abandonado y envíos de Campaigns -> Blast. Mantenga los nuevos flujos de trabajo de correo electrónico en la ruta compartida `sendResendEmail`/generador de carga útil para que la identidad del remitente, la localización, la marca y el comportamiento del límite de velocidad no se desvíen.

Nota de bifurcación: trate esas variables de identidad, marca de correo electrónico, precios y envío como espejos de la configuración estructurada del sitio en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml), especialmente las secciones `platform`, `design`, `pricing` y `shipping`. El carrito/tiempo de ejecución propios y la interfaz de usuario de pago en el sitio personalizada son comportamientos integrados de la plataforma ahora, no opciones de entorno de trabajo que normalmente debería personalizar directamente.

Mantenga `USPS_CLIENT_SECRET` fuera de la configuración del sitio. Pertenece a Secretos de trabajador o [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars).

Nota de localización: el trabajador ahora localiza los asuntos/el cuerpo del correo electrónico dirigidos a los seguidores y los enlaces `/manage/` / `/community/:slug/` localizados desde el catálogo de configuración regional del sitio compartido. En funcionamiento normal, recupera ese catálogo de `SITE_BASE/assets/i18n.json`; las pruebas y las implementaciones avanzadas pueden inyectar `I18N_CATALOG_JSON` en su lugar. Eso significa que los correos electrónicos de soporte localizados y las rutas localizadas como `/es/manage/` o `/es/community/:slug/` permanecen alineadas con el modelo local del sitio cuando una implementación agrega esas rutas.

The Worker también ofrece vistas previas localizadas de tarjetas compartidas de campaña en `GET /share/campaign/:slug.png` con una consulta opcional `?lang=es`. El PNG generado refleja el lenguaje de estado/progreso de la campaña insertada y utiliza la campaña cuadrada `hero_image` dentro de la tarjeta. La ruta SVG permanece disponible en `GET /share/campaign/:slug.svg` para herramientas internas de vista previa/depuración, pero los metadatos públicos de `og:image` deben usar PNG u otra imagen rasterizada estática porque no todos los rastreadores externos aceptan imágenes SVG.

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
   - El planificador o un operador autorizado envía la liquidación de la campaña.
   - El coordinador de asentamientos de la campaña serializa lotes de asentamientos
   - El trabajador crea PaymentIntents utilizando métodos de pago almacenados y claves de idempotencia deterministas
   - Las promesas se actualizan a "cargadas" o "pago_fallido"

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
- Establece `CORS_ALLOWED_ORIGIN` en el origen local de Jekyll.
- Permite que la ruta de inicio de sesión del administrador devuelva la URL de inicio de sesión de desarrollo local en lugar de requerir la entrega por correo electrónico.
- Lee `ADMIN_BOOTSTRAP_EMAILS` de `worker/.dev.vars` para acceso de superadministrador de arranque local
- Guarda las ediciones de gestión de usuarios del panel directamente en la clave PLEDGES KV `admin-users:v1`
- Utiliza `hand-relations` y `smoke-editable` como campañas `/test/setup` predeterminadas.

Para iniciar ambas campañas de prueba del panel de administración con un trabajador local en ejecución:

```bash
../scripts/seed-admin-test-campaigns.sh
```

Agregue `?dev` a la URL de la página de administración para obtener datos simulados: `http://127.0.0.1:4000/manage/?dev`

## Transmisiones diarias automatizadas

Las entradas del diario se transmiten automáticamente a los seguidores cuando se despliegan:

1. Cuando se agrega una nueva entrada del diario y se implementa el sitio, la acción de GitHub `deploy.yml` llama a `POST /admin/diary/check`.
2. El trabajador recupera datos de la campaña y compara las entradas del diario con lo que se ha enviado.
3. Las nuevas entradas se transmiten a todos los seguidores de la campaña por correo electrónico.
4. Las entradas enviadas se rastrean en KV (`diary-sent:{campaignSlug}`) para evitar correos electrónicos duplicados

Las entradas del diario deben tener valores `id` estables. El panel conserva los ID existentes y el trabajador obtiene ID basados ​​en títulos al publicar entradas que aún no tienen uno. Las transmisiones automáticas rastrean los marcadores `id:{entryId}` y aún reconocen los marcadores de fecha heredados, incluidas las cadenas de fecha que solo difieren en el formato de segundos `:00`. La actualización del título de una entrada del diario, visualización de fecha, fase o contenido existente no debería enviar otro correo electrónico automático.

**Configuración:** Asegúrese de que `ADMIN_SECRET` esté configurado como secreto del repositorio de GitHub para que la acción de implementación se autentique, o configure `ADMIN_BROADCAST_SECRET` tanto en los secretos de Cloudflare Worker como en los secretos del repositorio de GitHub cuando use credenciales de transmisión con alcance. Si la verificación posterior a la implementación recibe una página de desafío de Cloudflare, configure también `DIARY_CHECK_BYPASS_SECRET` más la regla de omisión de WAF correspondiente descrita anteriormente.
