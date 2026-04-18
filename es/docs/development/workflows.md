---
title: Flujos de trabajo
parent: Desarrollo
nav_order: 3
render_with_liquid: false
lang: es
---

# Flujos de trabajo

The Pool utiliza un **sistema de gestión de promesas basado en correo electrónico y sin cuenta**. Los patrocinadores guardan un método de pago a través de Stripe en el paso de pago en el sitio de The Pool, administran las promesas a través de enlaces mágicos con alcance de pedido y solo se les cobra si la campaña está financiada.

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
|`upcoming`|Botones deshabilitados, "Próximamente"|Cuenta regresiva para el lanzamiento|
|`live`|Botones de compromiso activos|Tarjetas guardadas a través del paso de pago Stripe en el sitio de The Pool|
|`post`|Campaña cerrada|Cargos procesados (si están financiados)|

---

## Componentes del sistema

|Componente|Rol|
|-----------|------|
|**Carrito propio**|Interfaz de usuario del carrito propiedad del navegador y estado de revisión del pago|
|**Raya**|Sesiones de pago en modo de configuración (paso de pago personalizado en el sitio) + PaymentIntents (cobrar más tarde)|
|**Trabajador de Cloudflare**|Backend: pago, webhooks, almacenamiento de promesas (KV), lecturas en vivo combinadas, estadísticas, cron de liquidación automática|
|**Jekyll**|Páginas estáticas + rebajas de campaña|

---

## Ciclo de vida de la promesa

```
1. BROWSE     → Visitor views campaign, adds tier to the first-party cart, adjusts optional tip
2. REVIEW     → First-party cart drawer shows pledge review, tip state, and immediate pricing
3. START      → Worker canonicalizes the cart via `/checkout-intent/start`, reserves scarce tiers when needed, and creates a setup-mode Stripe Checkout Session
4. SAVE CARD  → The existing checkout sidecar keeps the visitor on-site, mounts secure Stripe payment UI, and saves the payment method (no charge)
5. CONFIRM    → Stripe confirms the setup, then Worker persists one pledge per campaign in KV, sends campaign-specific supporter email(s), and refreshes live campaign reads before success UX completes
6. MANAGE     → Backer uses magic link to cancel/modify/update card
7. DEADLINE   → Worker cron (midnight MT) checks campaigns
8. CHARGE     → If funded + deadline passed: aggregate by email within each campaign, charge once per supporter per campaign
9. COMPLETE   → Update pledge_status to 'charged' or 'payment_failed'
```

---

## Almacenamiento de promesas (Cloudflare KV)

Las promesas se almacenan en Cloudflare KV. Patrones clave:

|clave|Contenidos|
|-----|----------|
|`pledge:{orderId}`|Datos completos del compromiso (correo electrónico, monto, nivel, ID de Stripe, estado, historial)|
|`email:{email}`|Conjunto de ID de pedido para ese correo electrónico|
|`stats:{campaignSlug}`|Totales agregados (monto prometido, recuento de promesas, recuentos de niveles, artículos de soporte)|
|`tier-inventory:{campaignSlug}`|Recuento de reclamaciones para niveles limitados|
|`campaign-pledges:{campaignSlug}`|Índice de promesas de campaña para informes, acuerdos, reconstrucciones y lecturas administrativas|
|`pending-extras:{orderId}`|Almacenamiento temporal de artículos de soporte/cantidad personalizada durante el pago|
|`pending-tiers:{orderId}`|Almacenamiento temporal para niveles adicionales cuando los metadatos de Stripe sean demasiado grandes|
|`checkout-intent:{orderId}`|Carga útil de pago canonicalizada utilizada para promover el pago combinado en promesas de campaña|

Las reservas de nivel escaso y el estado de reclamo comprometido ahora se encuentran en el coordinador de objetos duraderos por campaña en lugar de en KV. `tier-inventory:{campaignSlug}` sigue siendo la proyección pública utilizada por `/inventory/:slug` y `/live/:slug`.

**Registro de compromiso:**
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
- `additionalTiers`: conjunto de `{ id, qty }` para promesas de varios niveles (cuando `single_tier_only: false`)
- `tipPercent` / `tipAmount`: la sugerencia opcional de la plataforma Pool se almacena por separado del subtotal de la campaña
- Los pagos agrupados de varias campañas se conservan como registros de compromiso separados, uno por campaña.

**Entradas del historial:**
Cada entrada del historial rastrea un evento de compromiso con contexto completo:
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
4. Obtenga el compromiso de KV y verifique el correo electrónico + la campaña

Cada token sólo autoriza su propio pedido. Un enlace válido ya no otorga acceso a todo el correo electrónico a cada compromiso en la misma dirección, y un token válido sin un compromiso de respaldo real ahora falla al cerrarse en lugar de devolver un marcador de posición sintético.

---

## Rutas API de trabajador

### `POST /checkout-intent/start`
Cree una sesión de pago de Stripe en modo de configuración desde el estado del carrito propio para el paso de pago en el sitio.

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

**Flujo de datos:**
1. Cart.js pasa el porcentaje de propina seleccionado más los artículos actuales del carrito propio
2. El trabajador reconstruye la forma del carrito a partir de elementos propios y reglas de campaña canónicas.
3. El trabajador valida el estado de la campaña, las reglas de un solo nivel, los umbrales y la disponibilidad de los niveles escasos.
4. Para niveles limitados, el trabajador reserva un inventario escaso a través del coordinador por campaña, luego almacena cualquier metadato de nivel desbordado/elemento de soporte en KV temporal (`pending-tiers:*`, `pending-extras:*`) y crea una sesión de pago de Stripe en modo de configuración.
5. En el modo de interfaz de usuario personalizado, el segundo sidecar de pago existente monta una interfaz de usuario de pago segura de Stripe en el sitio; Los pagos físicos también capturan los detalles de envío durante ese paso.
6. El trabajador trata la persistencia del webhook como la fuente de la verdad, con una ruta de recuperación propia disponible para casos locales o de finalización retrasada, de modo que el sidecar no afirme haber tenido éxito antes de que el compromiso realmente persista.
7. En caso de persistencia, el trabajador recupera los metadatos temporales, extrae los detalles de envío de Stripe, calcula `subtotal + tax + shipping + tip`, persiste un compromiso por campaña y confirma cualquier reserva de nivel limitado retenida a través del coordinador de objetos duraderos por campaña.
8. Una vez que la persistencia tiene éxito, el cliente invalida los cachés de estadísticas en vivo de la campaña y escribe un marcador de actualización de corta duración para que las pestañas restauradas y las cargas de páginas de seguimiento obtengan totales nuevos.

Las decisiones de disponibilidad de nivel limitado ahora provienen del estado consciente de la reserva del coordinador en las rutas de escritura, mientras que `/inventory/:slug` y `/live/:slug` continúan leyendo solo la proyección KV pública.

El Trabajador no confía en los nombres de niveles, cantidades, cantidades de artículos de soporte enviados por el cliente o `amountCents`. `/checkout-intent/start` ahora reserva un inventario escaso antes de que se complete el paso de pago, y la persistencia confirma esas reservas. Las campañas más antiguas no necesitan un trabajo de migración porque el inventario reclamado puede reconstruirse a partir de la verdad del compromiso, y la persistencia exitosa aún puede recurrir a un nuevo reclamo de coordinador si no existe una reserva preexistente.

## Seguridad en la representación de contenidos

- El texto de campaña de formato largo se desinfecta antes de renderizar Markdown y luego se procesa posteriormente para neutralizar esquemas de enlaces inseguros.
- Las incrustaciones estructuradas solo se representan cuando su `src` se resuelve en un origen/ruta de proveedor aprobado exacto.
- Las auditorías de contenido de campaña aún protegen a `_campaigns/*.md`, pero la capa de procesamiento aplica las mismas reglas para que las forks y las fuentes de contenido futuras no dependan únicamente de las auditorías.

### `POST /webhooks/stripe`
Manejar `checkout.session.completed`:
- Extraiga `payment_method` y `customer` de SetupIntent
- Obtenga `supportItems`, `customAmount` y niveles adicionales de KV temporal cuando sea necesario
- Almacene un compromiso por campaña en KV con estado `active` (incluye artículos de soporte, monto personalizado, tarifa de envío, propina y dirección de envío)
- Actualizar estadísticas en vivo (monto prometido, tierCounts, artículos de soporte)
- Confirme las reservas retenidas de nivel limitado o reclame a través del coordinador serializado si el compromiso es anterior al inicio del pago con conocimiento de la reserva.
- Generar token de enlace mágico
- Enviar correos electrónicos de confirmación de seguidores específicos de la campaña

La idempotencia del webhook se confirma solo después de una persistencia exitosa del compromiso, de modo que las fallas transitorias puedan volver a intentarlo de manera segura.

### `GET /pledges?token=...`
Lea la colección de compromisos disponible para una sesión de enlace mágico.

**Comportamiento actual:** un token devuelve solo su propio pedido autorizado.

### `GET /pledge?token=...`
Lea los detalles del compromiso para la página de administración de enlaces mágicos.

Si el token es válido pero su registro de compromiso ya no existe, esta ruta devuelve `404` en lugar de sintetizar un compromiso de marcador de posición.

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
- `deadlinePassed`: `true` si la fecha límite de la campaña ha pasado (Hora de la Montaña)

### `POST /pledge/cancel`
Cancelar un compromiso activo.

**Solicitud:** `{ token }`
**Validación:**
- Rechaza si se cobra prenda
- Rechaza si ha pasado el plazo de campaña

**Acciones:**
1. Marcar compromiso como cancelado en KV, actualizar estadísticas, lanzar inventario de nivel
2. Enviar correo electrónico de confirmación de cancelación
3. Si no quedan compromisos activos para este correo electrónico/campaña → borre el mapeo `email:{email}` de KV (revoca el acceso a la comunidad)

### `POST /pledge/modify`
Cambiar nivel o cantidad.

**Solicitud:** `{ token, orderId, ...changes }`
**Validación:**
- Rechaza si se cobra prenda
- Rechazo si la fecha límite de la campaña ha pasado (mediante verificación `isCampaignLive`)
- Se rechaza si `orderId` no coincide con el pedido autorizado del token.
- Reconstruye los totales a partir del estado de compromiso almacenado más las definiciones de campaña en lugar de confiar en los campos de dinero del cliente.

**Acción:** Actualizar el compromiso en KV, ajustar el delta de estadísticas, intercambiar niveles de inventario

### `POST /pledge/payment-method/start`
Actualizar el método de pago guardado.

**Solicitud:** `{ token }`
**Respuesta:**
- modo personalizado: `{ checkoutUiMode, sessionId, clientSecret, publishableKey }`
- reserva alojada: `{ checkoutUiMode: "hosted", url }`

**Flujo de datos:**
1. Manage Pledge valida el token de enlace mágico y el estado de compromiso activo
2. El trabajador crea una sesión de pago de Stripe en modo de configuración para actualizar el método de pago
3. En el modo personalizado, el modo Tarjeta de actualización existente monta la interfaz de usuario de pago seguro de Stripe en el sitio
4. El trabajador mantiene la persistencia del webhook como fuente de verdad, con la misma ruta protegida de finalización y recuperación disponible para la entrega retrasada del webhook local.
5. Si tiene éxito, el registro de compromiso se actualiza al método de pago recién guardado y los reintentos de `payment_failed` pueden cobrar nuevamente inmediatamente.

### `GET /stats/:campaignSlug`
Obtenga estadísticas de compromisos en vivo para una campaña.

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
Vuelva a calcular las estadísticas de todas las promesas en KV (solo administrador).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`

### `POST /admin/rebuild`
Activar una reconstrucción de páginas de GitHub (para transiciones de estado).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`
**Solicitud:** `{ "reason": "campaign-state-change" }` (opcional)

### `POST /admin/broadcast/announcement`
Envíe un correo electrónico de anuncio personalizado con un enlace CTA opcional a todos los partidarios de la campaña.

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`
**Pedido:**
```json
{
  "campaignSlug": "worst-movie-ever",
  "subject": "Submissions close March 6th!",
  "heading": "Last call for submissions!",
  "body": "The deadline is this Thursday at midnight MT.",
  "ctaLabel": "Submit Your Reward",
  "ctaUrl": "https://example.com/submit",
  "dryRun": true
}
```
**Respuesta:** `{ success, campaignSlug, subject, sent, failed, errors }`

**Campos:**
- `subject` (obligatorio) — Línea de asunto del correo electrónico (con el prefijo 📢 emoji)
- `heading` (opcional): encabezado del correo electrónico (el valor predeterminado es el asunto si se omite)
- `body` (obligatorio) — Texto del cuerpo del mensaje
- `ctaLabel` + `ctaUrl` (opcional): agrega un botón destacado que vincula a la URL
- `dryRun` (opcional): devuelve la lista de destinatarios sin enviar

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
El usuario abandonó el paso de pago antes de completarlo (no el compromiso en sí)

### `/manage/`
Página de inicio del enlace mágico para la gestión de promesas:
- Lee el token `?t=...`
- Obtiene detalles del compromiso del trabajador
- Muestra tarjetas de compromiso con interfaz de usuario dependiente del estado.
- Agrupa proyectos en secciones **Activo** y **Cerrado**
- Ordena las tarjetas activas primero con las campañas más recientes
- Muestra el desglose completo: subtotal, propina opcional de The Pool, impuesto sobre las ventas configurado y monto de envío almacenado para la promesa, más el total.
- Lee etiquetas de precios y tarifas de la configuración compartida para que la interfaz de usuario del carrito, los totales de trabajadores, los correos electrónicos y los informes permanezcan alineados para las forks.

**Estados de la tarjeta de compromiso:**

|Estado|Tratamiento de la IU|
|--------|-------------|
|`active`|Controles de edición completos (selección de niveles, elementos de soporte, botón cancelar)|
|`active` + fecha límite pasada|Insignia bloqueada + aviso bloqueado, controles de contribución de solo lectura, solo "Tarjeta de actualización"|
|`charged`|Tarjeta silenciada, aviso " ✓ Cargado exitosamente el {fecha}"|
|`payment_failed`|Aviso de advertencia con el botón "Actualizar método de pago"|
|`cancelled`|Aviso "Este compromiso ha sido cancelado"|

**Envío en flujo de modificación:** Cuando un colaborador cambia niveles o artículos de soporte físico, la página de administración recalcula dinámicamente el envío. Las selecciones físicas pueden utilizar cotizaciones en vivo respaldadas por USPS, tarifas alternativas configuradas, anulaciones de envío gratuito y actualizaciones limitadas de opciones de firma nacionales. El modal de confirmación muestra el envío actualizado y el total antes de que el usuario confirme.

**Sugerencia para modificar el flujo:** La página de administración muestra el mismo control deslizante de propina del 0% al 15%. Durante las campañas en vivo, los seguidores pueden ajustarlo y ver la actualización del subtotal/propina/impuestos/envío/total inmediatamente. Una vez que pasa la fecha límite, el control deslizante de propinas pasa a ser de solo lectura junto con el resto de los controles de contribución.

**Modo de desarrollo:** Agregue `?dev` a la URL para realizar pruebas simuladas de datos de compromiso

### `/community/:slug/`
Página de la comunidad exclusiva para seguidores:
- Siempre verifica con Worker API (no confía únicamente en las cookies)
- En caso de éxito: establece una cookie `supporter_{slug}` no confidencial para la optimización de UX y almacena el token de portador sin formato solo en `sessionStorage`.
- En caso de error (compromiso cancelado, token caducado): borra el estado del token de sesión, muestra acceso denegado CTA
- Muestra decisiones de votación/encuesta exclusivas de los patrocinadores.
- La API `/votes` devuelve 403 para promesas canceladas (acceso de doble verificación)
- `/votes` solo acepta ID de decisión definidos por la campaña y valores de opciones definidos por la campaña.
- Las decisiones cerradas siguen siendo legibles pero rechazan nuevos votos
- Los votos se ingresan por **correo electrónico** (no por ID de pedido): los partidarios con múltiples promesas aún obtienen un voto por decisión.

---

## Flujo de carga (cron del trabajador)

El trabajador tiene un activador programado que se ejecuta diariamente a las **7:00 a. m. UTC** (medianoche, hora de la montaña):

```toml
# wrangler.toml
[triggers]
crons = ["0 7 * * *"]
```

**Qué hace:**

1. Registra un latido (`cron:lastRun` en KV)
2. Enumera todas las campañas con `goal_deadline` y `goal_amount`
3. Para cada campaña en la que ya pasó la fecha límite (en MT), se cumplió el objetivo y no se estableció `campaign-charged:{slug}`:
   - Envía liquidación por lotes a través de `POST /admin/settle-dispatch/:slug`
4. Activa la reconstrucción de páginas de GitHub si se detecta alguna transición de estado de campaña

**Envío de liquidación (lotes autoencadenados):**

El punto final `settle-dispatch` maneja el cobro real en lotes para permanecer dentro del límite de 50 subsolicitudes de CF Worker:

1. Lee el índice de compromiso de campaña (`campaign-pledges:{slug}` en KV)
2. Inicializa un trabajo de liquidación (`settlement-job:{slug}`) que sigue el progreso.
3. Procesa 6 promesas por lote a través de `POST /admin/settle-batch`
4. Autoinvocaciones para el siguiente lote hasta que se procesen todas las promesas
5. Cada lote es una invocación de trabajador separada con su propio presupuesto de subsolicitud
6. **Agrega promesas por correo electrónico**: cada colaborador recibe UN cargo
7. Al finalizar, establece `campaign-charged:{slug}` solo cuando ningún compromiso activo todavía necesita atención.

**Índice de compromiso de campaña:**

Se mantiene automáticamente una serie de ID de pedido por campaña (`campaign-pledges:{slug}`):
- Agregado en la creación de promesas (webhook) y recuperación (`/admin/recover-checkout`)
- Eliminado al cancelar el compromiso
- Se puede reconstruir: `POST /admin/campaign-index/rebuild/:slug`
- Las estadísticas y el recálculo de inventario ahora también reparan índices obsoletos si la matriz almacenada ya no coincide con los registros de compromiso activos.
- La deriva ahora se puede verificar sin mutación a través de `POST /stats/:slug/check` o `POST /admin/projections/check`

**Comportamientos clave:**
- Los compromisos cancelados nunca se cobran
- Varias promesas del mismo correo electrónico = un cargo agregado (subtotales + envío + impuestos + propina sumada)
- Utiliza el método de pago actualizado más recientemente para cada partidario
- Las promesas ya cobradas se omiten de forma segura (idempotentes)
- Se puede activar manualmente a través de `POST /admin/settle-dispatch/:slug`
- La liquidación monolítica heredada todavía está disponible: `POST /admin/settle/:slug` (use la liquidación-despacho para campañas grandes)
- Latido del cron: verificar a través de `GET /admin/cron/status`

### Error de pago y reintento

Cuando un cargo falla durante la liquidación:

1. **Compromiso marcado como `payment_failed`** con mensaje de error almacenado
2. **Correo electrónico enviado** con el botón "Actualizar método de pago" vinculado a la página de administración
3. **Tarjeta de actualizaciones de soporte** vía `/pledge/payment-method/start`
4. **El cargo por reintento automático** ocurre inmediatamente después de la actualización exitosa del método de pago
5. Si el reintento tiene éxito: compromiso marcado `charged`, correo electrónico de éxito enviado
6. Si el reintento falla nuevamente: el compromiso permanece `payment_failed`, puede volver a intentarlo

Esto permite a los seguidores reparar tarjetas vencidas/rechazadas sin la intervención manual del administrador.

---

## Arquitectura de correo electrónico

|Proveedor|Propósito|
|----------|---------|
|**Reenviar**|Todos los correos electrónicos de los seguidores (confirmación, hitos, actualizaciones del diario, anuncios, carga exitosa, pago fallido)|

El Trabajador maneja todos los correos electrónicos relacionados con el compromiso a través de Resend.

### Reenviar Integración (Trabajador)

El trabajador envía correos electrónicos de soporte después de que el webhook de Stripe confirma la sesión en modo de configuración:

```js
// In Worker: POST /webhooks/stripe handler
async function sendSupporterEmail(env, { email, campaignSlug, campaignTitle, amount, token }) {
  const manageUrl = `${env.SITE_BASE}/manage/?t=${token}`;
  const communityUrl = `${env.SITE_BASE}/community/${campaignSlug}/?t=${token}`;
  
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${env.RESEND_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: 'The Pool <pledges@example.com>',
      to: email,
      subject: `Your pledge to ${campaignTitle}`,
      html: `
        <h1>Thanks for backing ${campaignTitle}!</h1>
        <p><strong>Pledge amount:</strong> $${(amount / 100).toFixed(0)}</p>
        <p><strong>Remember:</strong> Your card is saved but won't be charged unless this campaign reaches its goal.</p>
        <hr>
        <h2>Your Supporter Access</h2>
        <p>No account needed — these links are your keys:</p>
        <p><a href="${manageUrl}">Manage Your Pledge</a> — Cancel, modify, or update payment method</p>
        <p><a href="${communityUrl}">Supporter Community</a> — Vote on creative decisions</p>
        <hr>
        <p style="color:#666;font-size:12px;">Save this email! You'll need these links to manage your pledge.</p>
      `
    })
  });
}
```

### Plantillas de correo electrónico

Todos los correos electrónicos muestran cantidades exactas con 2 decimales (sin redondeo).

**Confirmación de compromiso** (enviada después de que la sesión de Stripe en el modo de configuración se complete con éxito)
- Asunto: "Su compromiso con {Título de la campaña}"
- Contiene: desglose completo (subtotal, propina opcional de The Pool, impuestos, envío si es físico, total), artículos prometidos, enlace de administración, enlace comunitario
- Incluye: CTA de Instagram (si la campaña tiene URL de Instagram)
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.

**Compromiso modificado** (se envía cuando el colaborador cambia su compromiso)
- Asunto: "Compromiso actualizado para {Título de la campaña}"
- Contiene: subtotal anterior, subtotal nuevo, monto modificado (+/-), propina opcional de The Pool, impuestos, envío (si es físico), total nuevo, artículos de compromiso actualizados
- Incluye: CTA de Instagram (si la campaña tiene URL de Instagram)
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.

**Cargo exitoso** (se envía cuando la promesa se cobra en el momento de la liquidación)
- Asunto: "Pago confirmado para {Título de la campaña}"
- Contiene: desglose completo (subtotal + propina + impuestos + envío + total cobrado), artículos prometidos
- El enlace de la comunidad se muestra solo si la campaña tiene decisiones activas.
- Nota: No hay CTA de Instagram (la campaña ha finalizado)

**Error en el pago** (se envía cuando falla el cargo fuera de sesión)
- Asunto: "Acción necesaria: actualizar el pago de {Título de la campaña}"
- Contiene: desglose completo (subtotal + propina + impuestos + envío + monto adeudado), artículos prometidos, enlace de administración para actualizar la tarjeta
- Nota: No hay CTA de Instagram (la campaña ha finalizado)

**Compromiso cancelado** (se envía cuando el colaborador cancela su compromiso)
- Asunto: "Compromiso cancelado para {Título de la campaña}"
- Contiene: desglose que incluye propina opcional, no se cobró a la tarjeta de confirmación, enlace para ver la campaña (se puede volver a realizar la promesa)
- Nota: El colaborador se elimina de futuras actualizaciones por correo electrónico de la campaña.

**Actualización del diario** (se envía cuando se agrega una nueva entrada del diario a la campaña)
- Asunto: "📝 {Título del diario} — {Título de la campaña}"
- Contiene: título del diario, extracto en texto plano (200 caracteres + puntos suspensivos), botón "Leer actualización completa" que enlaza con el diario de la campaña.
- Incluye: enlaces de acceso de seguidores (comunidad + administración), CTA de Instagram (si la campaña tiene URL de Instagram)
- Nota: Los extractos eliminan el formato de rebajas; el contenido completo está en la página de la campaña

**Anuncio** (enviado a través de transmisión administrativa con enlace CTA opcional)
- Asunto: "📢 {Asunto} — {Título de la campaña}"
- Contiene: encabezado personalizado, cuerpo del mensaje, botón CTA resaltado opcional (etiqueta personalizada + URL)
- Incluye: enlaces de acceso de seguidores (comunidad + administración), CTA de Instagram (si la campaña tiene URL de Instagram)
- Punto final: `POST /admin/broadcast/announcement`

---

## Consideraciones de seguridad

- Los enlaces mágicos caducan (90 días)
- Tokens verificados con respecto al registro de compromiso de KV (correo electrónico + coincidencia de campaña)
- Las mutaciones del compromiso se bloquean una vez que se cobra el compromiso
- Todos los secretos de las variables de entorno de Cloudflare Worker
- Firmas de webhook de Stripe verificadas
- Las respuestas confidenciales de arranque del método de pago y de pago son `private, no-store`
- Los POST de pago y pago propios imponen orígenes confiables de `SITE_BASE`
- Los borradores de pago almacenados en el navegador y los identificadores en vuelo tienen un alcance de sesión o un tiempo limitado
- Todos los plazos evaluados en Mountain Time
- El acceso a la comunidad/voto se revoca inmediatamente cuando se cancela el compromiso
- La API `/votes` verifica el estado del compromiso en cada solicitud (no solo la validez del token)

---

## Manejo de condiciones de carrera

- `/pledge/cancel` y `/pledge/modify` rechazan el compromiso `charged: true`
- `/pledge/cancel` y `/pledge/modify` rechazan si ha pasado el plazo de campaña (Mountain Time)
- Cron comprueba `pledgeStatus === 'active'` y `!charged` antes de cargar
- Los indicadores `pledgeStatus` y `charged` evitan la doble carga
- La agregación por correo electrónico garantiza un cargo por partidario por campaña, incluso con varias filas de promesas.
- La página de administración muestra un aviso de fecha límite superada, una insignia bloqueada y controles de compromiso de solo lectura una vez que pasa la fecha límite.
- Las actualizaciones de los métodos de pago permanecen disponibles después de la fecha límite (para recuperación de pago fallida)

---

## Metas extendidas

- Definido en el frente de campaña: `stretch_goals[]`
- Desbloqueo automático cuando `pledged_amount >= threshold`
- Mostrar como `achieved` o `locked`
- Opcional: niveles de puerta con `requires_threshold`

---
