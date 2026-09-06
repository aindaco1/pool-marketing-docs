---
title: API del Worker
parent: Referencia
nav_order: 5
render_with_liquid: false
lang: es
---

# API del Worker

## Última actualización

6 de septiembre de 2026

Esta es la referencia del punto final para contribuyentes y operadores que se integran con The Pool Worker. Consolida los ejemplos de ruta previamente distribuidos en las guías de arquitectura y componentes. Los controladores en [`worker/src/index.js`](https://github.com/aindaco1/pool/blob/main/worker/src/index.js) y [`worker/src/routes/`](https://github.com/aindaco1/pool/tree/main/worker/src/routes) tienen autoridad; Esta es una guía de las rutas de integración documentadas, no un inventario generado de cada controlador.

## Autenticación y Runbooks relacionados

Las rutas del panel del navegador utilizan sesiones con alcance de roles y comprobaciones de origen/CSRF. Las rutas de apoyo verifican el token de enlace mágico del alcance del pedido con la verdad del aporte. Las rutas del operador requieren la credencial de administrador correspondiente; Los acuerdos de alcance y los secretos de transmisión anulan el respaldo general en sus respectivas rutas. Los ejemplos utilizan marcadores de posición. Consulte [Security](/es/docs/operations/security/) para conocer las reglas de autenticación y caché privada.

[El Procesador de pagos](/es/docs/operations/payment-processor/) posee procedimientos de pago, liquidación, conciliación y recuperación. [Email](/es/docs/operations/email-system/) es propietario de la configuración, entrega, consentimiento y supresión del proveedor. [Dashboard](/es/docs/operations/admin-dashboard/) posee el flujo de trabajo operativo del navegador. [Deployment](/es/docs/operations/deployment/) posee acciones y configuración posterior a la implementación. Un ensayo o una respuesta en cola no constituye una entrega del proveedor ni una aceptación de pago.

## Rutas

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

El trabajador reconstruye el nivel, el complemento del paquete, el soporte personalizado, el envío y el estado del subtotal a partir de artículos del carrito propios, valida el estado y el inventario de la campaña, firma una instantánea de pago de corta duración, reserva un inventario escaso para niveles limitados antes de que se complete el paso de pago y confirma esas reservas cuando el aporte realmente persiste. Para aportes físicas o complementos físicos, el envío lo calcula el trabajador desde el destino más los metadatos de envío de campaña/artículo, utilizando cotizaciones en vivo de USPS cuando estén disponibles y tasas de implementación o respaldo de campaña cuando no.

Cuando un aporte califica para mejoras de envío, el Trabajador también mantiene la opción de entrega limitada seleccionada (`standard`, `signature_required` o `adult_signature_required`) para que el carrito, la Gestión del aporte, el total del aporte almacenado y los correos electrónicos de los patrocinadores permanezcan alineados.

Las reservas y los reclamos de nivel limitado se serializan a través de un coordinador de objetos duraderos por campaña antes de que se actualice la instantánea del inventario de KV, por lo que los inicios, reintentos, modificaciones y finalizaciones de webhooks simultáneos no pueden sobrevender las escasas recompensas.

### GET /pledges?token={token}
Obtenga la(s) aporte(s) autorizada(s) mediante un token de enlace mágico.

Comportamiento actual: el token devuelve solo su propia orden autorizada.

### GET /pledge?token={token}
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

### POST /pledge/cancel
Cancelar un aporte activo.

```json
{
  "token": "magic-link-token",
  "orderId": "pool-intent-abc123"
}
```

### POST /pledge/modify
Cambie los niveles, la cantidad o el soporte personalizado para un aporte activo.

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

Todos los campos excepto `token` son opcionales. Los cambios se rastrean en la matriz `history` del aporte con entradas `type: "modified"` que incluyen el estado del nivel, cambios de complementos del paquete, `customAmount`, deltas de envío y cualquier opción de envío seleccionada.

El trabajador valida el pedido solicitado con la carga útil del token y vuelve a calcular los totales a partir del estado del aporte almacenado más las definiciones de la campaña. Los cambios estructurales al mismo precio, como un intercambio de variante adicional, todavía cuentan como cambios de aporte reales para fines de persistencia y correo electrónico a los patrocinadores.

### POST /stats/:slug/check
Ejecute una verificación de desviación de proyección de solo lectura para una campaña.

Requiere autenticación de administrador y devuelve si el índice de campaña almacenado, la proyección de estadísticas y la proyección de inventario de niveles todavía están sincronizados con la verdad del aporte activo.

### POST /admin/projections/check
Ejecute la misma verificación de deriva de solo lectura en todas las campañas.

Este es el punto final del lado Worker que impulsa [`scripts/check-projections.sh`](https://github.com/aindaco1/pool/blob/main/scripts/check-projections.sh) y las nuevas afirmaciones de humo de aporte mutable.

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
Manejar `checkout.session.completed`:
- Extraiga `payment_method` y `customer` de SetupIntent
- Obtenga `supportItems`, `customAmount` y niveles adicionales de KV temporal cuando sea necesario
- Almacene un aporte por campaña en KV con estado `active` (incluye artículos de soporte, monto personalizado, tarifa de envío, propina y dirección de envío)
- Actualizar estadísticas en vivo (monto prometido, tierCounts, artículos de soporte)
- Confirme las reservas retenidas de nivel limitado o reclame a través del coordinador serializado si el aporte es anterior al inicio del pago con conocimiento de la reserva.
- Generar token de enlace mágico
- Enviar correos electrónicos de confirmación de patrocinadores específicos de la campaña

La idempotencia del webhook se confirma solo después de una persistencia exitosa del aporte, de modo que las fallas transitorias puedan volver a intentarlo de manera segura.

### POST /webhooks/resend
Punto final del webhook Resend/Svix para eventos entregados, rebotados, reclamados, fallidos y suprimidos. Requiere `RESEND_WEBHOOK_SECRET`, verifica el cuerpo de la solicitud sin procesar y la marca de tiempo, deduplica `svix-id`, actualiza el estado de entrega con privacidad minimizada y aplica hash a los destinatarios antes de la supresión local permanente de rebotes/quejas.

### GET or POST /campaign-email/unsubscribe?t={token}
Cancelación de suscripción firmada en el ámbito de la campaña para correo de diario, hitos y anuncios en vivo. RFC 8058 POST devuelve una respuesta de éxito en blanco; El navegador GET devuelve una página de confirmación sin tienda. La preferencia almacenada es un hash de correo electrónico y no suprime el correo electrónico de aporte/pago transaccional.

### POST /film/stripe-summary
Adaptador de película de servidor a servidor para agregados Stripe de solo resumen. Requiere `Authorization: Bearer <FILM_STRIPE_SUMMARY_ADAPTER_SECRET>`, `dataBoundary: "summary_only"`, `source: "pool"` y slugs de campaña mapeados en `mappedRefs`. La respuesta se limita a campos agregados de dinero/recuento, recuentos de referencias asignadas, estado, marca de tiempo generada y moneda. No devuelve correos electrónicos de soporte, ID de intención de pago, ID de cargo, ID de transacción de saldo ni datos de tarjeta/método de pago, y escribe un evento de auditoría de administración de solo metadatos.

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

El envío del recordatorio de lanzamiento está controlado por un programador: cuando una campaña se activa, el paso del ciclo de vida diario pone en cola un trabajo de envío; las ejecuciones programadas a nivel de minutos agotan ese trabajo en lotes limitados. Cada destinatario recibe un marcador de envío por campaña antes de que avance el trabajo, y la entrega de correo electrónico utiliza el asistente `sendLaunchReminderEmail` existente en `worker/src/email.js`, el generador de carga útil compartido Resend y `UPDATES_EMAIL_FROM`.

### GET /admin/observability/webhooks?days=2
Resumen de observabilidad del webhook solo para administradores.

Devuelve recuentos de entregas de webhooks recientes por día, resultados, resúmenes de tipos de eventos, estadísticas de duración y una breve ventana de eventos recientes para reintentos de depuración, errores de firma y picos de tráfico inesperados.

### GET /admin/observability/performance?days=2
Resumen de rendimiento de muestra solo para administradores.

Devuelve muestras de tiempos de reloj de pared para rutas de mutación clave, como inicio de pago, finalización de pago, escrituras de aporte de gestión, cotizaciones de envío y abandono de pago. Esto está pensado como una ayuda de ajuste para la tapa `cpu_ms` desplegada, no como un sistema de seguimiento de alta cardinalidad.

### Panel de administración del navegador

Los shells privados `/admin/` y `/es/admin/` utilizan rutas de trabajo respaldadas por cookies en lugar de exponer `ADMIN_SECRET` en el código del navegador:

- `POST /admin/auth/start` verifica Cloudflare Turnstile primero cuando `TURNSTILE_SECRET_KEY` está configurado y luego envía un enlace mágico localizado de corta duración para un correo electrónico de administrador autorizado. Los trabajadores desplegados envían el enlace por correo electrónico a través de Resend; El desarrollo local puede exponer el enlace en la respuesta JSON solo para configuraciones de prueba/localhost o `ADMIN_EXPOSE_LOGIN_LINK=true` explícito.
- `POST /admin/auth/exchange` intercambia ese token único por la cookie `pool_admin_session`
- `GET /admin/session` lee la sesión actual sin actualizarla ni escribirla
- `POST /admin/logout` borra la sesión
- `GET /admin/dashboard/summary` lee resúmenes de campañas con alcance de roles
- `GET /admin/settings` lee una instantánea de configuración/configuración de ámbito de función para el panel
- `POST /admin/settings/preview` valida los cambios de configuración sin publicar
- Cargas de paneles de escenario `POST /admin/settings/logo-upload`, `POST /admin/settings/image-upload`, `POST /admin/settings/audio-upload` y `POST /admin/settings/video-upload` a través de la misma ruta de publicación respaldada por GitHub que sus propios campos de configuración/contenido; Las cargas de imágenes/videos solicitan el flujo de trabajo **Optimizar medios del panel** con `scope=changed` después de la confirmación, mientras que la optimización de imágenes nativas y la transcodificación de video aún se ejecutan en la canalización de medios del repositorio en lugar de dentro del Worker.
- `POST /admin/settings/publish` valida y publica configuraciones de plataforma, complementos de plataforma, variables de campaña y datos estructurados de campaña a través de confirmaciones respaldadas por GitHub.
- El navegador recuerda el contexto de la pestaña/subpestaña del panel de control localmente durante las recargas; esta restauración no llama a una ruta de trabajo y no escribe el estado de KV o GitHub
- `POST /admin/users` guarda los usuarios administradores administrados por el panel directamente en `admin-users:v1` en Worker KV y envía por correo electrónico las instrucciones de inicio de sesión de los usuarios recién creados cuando se configura Resend
- `POST /admin/campaigns/create` permite a los superadministradores crear campañas de solo vista previa a través de la ruta de origen de la campaña respaldada por GitHub, asignar uno o más usuarios de campaña existentes,, opcionalmente, crear varios usuarios de campaña nuevos en `admin-users:v1`, enviar por correo electrónico a los usuarios asignados el enlace del panel de administración y registrar un evento de auditoría.
- `POST /admin/campaigns/archive` permite a los superadministradores archivar campañas no activas localmente en desarrollo o enviando `.github/workflows/archive-campaign.yml` a producción; el trabajador valida CSRF, rol, slug, existencia de campaña y estado efectivo, registra un evento de auditoría y mueve la fuente/medios de la campaña a través del asistente de repositorio de desarrollo o acciones de GitHub.
- `POST /admin/campaign-preview/publish` permite a los superadministradores y usuarios de campaña asignados publicar una vista previa protegida, almacena el administrador de publicación más los correos electrónicos de los revisores opcionales en `campaign-preview-reviewers:{slug}` con un TTL de 24 horas, devuelve un enlace de vista previa del panel firmado para el administrador de publicación, envía enlaces firmados a revisores opcionales, escribe solo indicadores de vista previa en la campaña Markdown y registra un evento de auditoría
- `GET /admin/campaign-preview/:slug` devuelve una carga útil de vista previa de página de campaña completa privada/no-store con fuentes de campaña/incrustaciones de medios y controles de aporte de solo lectura cuando el solicitante tiene una sesión de administrador autorizada o un token de revisor válido cuyo correo electrónico todavía está en la lista de permitidos de KV de 24 horas.
- `GET /admin/analytics` lee ingresos derivados de aportes con alcance de rol, estado, idioma, referencia, fuente/medio/campaña/contenido UTM y métricas divididas de campaña/plataforma sin escribir el estado analítico; La presentación de la moneda en el tablero mantiene los centavos exactos.
- `GET /admin/plan-usage` permite a los superadministradores cargar el uso del plan Cloudflare y Resend desde las API del proveedor sin exponer los tokens del proveedor al navegador ni escribir el estado KV; el panel lo carga automáticamente cuando se abre Configuración -> Uso del plan
- `POST /admin/analytics/stripe-financials/backfill` permite a los superadministradores reponer los valores netos y de tarifas de Stripe reales a partir de las transacciones de saldo de Stripe para los aportes cobradas, utilizando índices de aportes de campaña en lugar de escaneos de listas de KV.
- `GET /admin/reconciliation/:slug` lee las pausas de pago de campaña almacenadas; El superadministrador protegido por CSRF `POST` ejecuta la reconciliación de aporte/Stripe/liquidación limitada sin análisis del espacio de nombres KV
- `POST /film/stripe-summary` expone agregados The Pool orientados a la película solo después de la autenticación del adaptador de portador; las referencias asignadas son slugs de campaña y la respuesta sigue siendo solo un resumen
- `GET /admin/content/campaign?campaignSlug=...` carga contenido de campaña con alcance de roles en el editor del navegador sin conservar un borrador
- `POST /admin/content/preview` valida y presenta borradores de contenido de campaña con alcance de roles sin publicar, auditar ni escribir KV
- `POST /admin/content/publish` valida el mismo borrador, actualiza el archivo Markdown de la campaña a través de GitHub, activa el flujo de trabajo de reconstrucción normal y escribe un evento de auditoría.
- `GET /admin/supporters?campaignSlug=...` lee filas de patrocinadores de campaña de `campaign-pledges:{slug}` únicamente; La presentación de la cantidad en el tablero mantiene los centavos exactos.
- `GET /admin/reports/campaign-runner/preview?campaignSlug=...&reportType=pledge|fulfillment` obtiene una vista previa del resultado del informe compartido del ejecutor de campaña sin enviar correos electrónicos ni escribir marcadores
- `GET /admin/reports/campaign-runner.csv?campaignSlug=...&reportType=pledge|fulfillment` descarga el mismo informe CSV compartido sin enviar correo electrónico ni escribir marcadores
- `GET /admin/marketing/referrals?campaignSlug=...` enumera los códigos de referencia de campaña guardados sin escribir ni escanear la verdad del aporte
- `POST /admin/marketing/referrals` guarda o actualiza explícitamente un código de referencia de campaña con protección CSRF y una escritura KV con alcance de campaña.
- `DELETE /admin/marketing/referrals` elimina explícitamente un código de referencia de campaña guardado con protección CSRF y una escritura KV con alcance de campaña.
- `GET /admin/marketing/draft?campaignSlug=...&surface=marketing|blast`, `POST /admin/marketing/draft` y `DELETE /admin/marketing/draft` proporcionan carga/guardado/borrado de borradores Blast/Marketing compartido explícito con TTL de 7 días, protección contra conflictos de revisión y una escritura KV con alcance de campaña solo al guardar/borrar
- `GET /admin/media/library?campaignSlug=...` enumera imágenes de campaña existentes para bloques de imágenes WYSIWYG a través de lecturas del directorio de GitHub; los usuarios de la campaña permanecen dentro del alcance de la campaña y los superadministradores también pueden ver imágenes compartidas/predeterminadas
- `GET /admin/abandoned-checkout/health?campaignSlug=...` lee el estado agregado del recordatorio de pago abandonado sin listas KV; Los resultados de supresión creados por el administrador incluyen el correo electrónico suprimido para que los administradores de la campaña puedan borrarlos de la tabla de resultados recientes.
- `POST /admin/abandoned-checkout/suppression` y `DELETE /admin/abandoned-checkout/suppression` establecen o borran explícitamente la supresión de recordatorios de pago abandonado en el ámbito de la campaña con protección CSRF, identificadores de correo electrónico con hash, eventos de auditoría y escrituras KV limitadas.
- `GET /abandoned-cart/resume?t=...` verifica un token de reanudación firmado, lee la instantánea de corta duración de `abandoned-cart-resume:{orderId}` creada después de enviar un recordatorio y devuelve solo datos de borrador de carrito/contacto desinfectados para que el navegador pueda iniciar una nueva sesión de pago.
- `GET /admin/marketing/announcements?campaignSlug=...` lee el historial de Blast enviado recientemente desde registros de auditoría de administración limitados para la campaña seleccionada
- `POST /admin/marketing/announcement` simulacros, envíos de prueba o envíos en vivo de una campaña -> Mensaje explosivo con sesión de panel, comprobaciones de origen/CSRF, validación de audiencia indexada, aplicación de hash de ejecución en seco coincidente para envíos en vivo y una escritura de auditoría después del envío
- `GET /admin/add-ons/inventory` lee el estado inicial, vendido, restante y de anulación del complemento de plataforma para superadministradores
- `POST /admin/add-ons/inventory` establece, reabastece o restablece explícitamente las anulaciones de la línea base del inventario de complementos de la plataforma con protección CSRF y registro de auditoría

Las lecturas normales del panel, los filtros de soporte, la paginación, los análisis derivados de aportes, las listas de referencias de marketing, el estado de las compras abandonadas, las cargas del selector de bibliotecas multimedia, las vistas previas de informes, las descargas CSV, las cargas de contenido, las lecturas de carga útil de vista previa protegida, las vistas previas de contenido, los simulacros rápidos y los borradores del editor local están diseñados para agregar escrituras de KV cero y operaciones de lista de KV cero. Las cargas de uso del plan también son de solo lectura KV, pero llaman intencionalmente a las API de los proveedores de Cloudflare y Resend una vez cuando un superadministrador abre Configuración -> Uso del plan. Los guardados de usuarios iniciados por el navegador, los guardados de referencias de marketing, los guardados/borrados de borradores compartidos, las mutaciones de supresión de pago abandonado con alcance, los envíos de Blast en vivo, las publicaciones de contenido, las publicaciones de vista previa, la creación de nuevas campañas, las operaciones de archivo de campañas y los cambios de inventario son mutaciones explícitas: los guardados de usuarios escriben `admin-users:v1`, los guardados de referencias escriben una lista de referencias con alcance de campaña, los guardados de borradores compartidos escriben un registro de borrador de 7 días, las supresiones de recordatorios con alcance escriben/eliminan un registro de supresión más actualizaciones de auditoría/salud, Blast en vivo envía un evento de auditoría después del envío, las publicaciones de contenido se comprometen con GitHub, desencadenan el flujo de trabajo de reconstrucción y escriben un evento de auditoría, las publicaciones de vista previa escriben una lista de acceso permitido de corta duración `campaign-preview-reviewers:{slug}` más un evento de auditoría, la creación de una nueva campaña puede escribir `admin-users:v1` más un evento de auditoría además de la escritura del archivo de campaña, y el archivo escribe un evento de auditoría mientras el desarrollo local o `.github/workflows/archive-campaign.yml` mueve el origen/los medios a `archive/campaigns/<slug>/`. Los envíos de recordatorios de pago abandonado también escriben un registro `abandoned-cart-resume:{orderId}` de corta duración para que el CTA del correo electrónico firmado pueda restaurar un borrador de pago desinfectado del navegador sin agregar escaneos de cola. Si a una campaña anterior le falta su proyección `campaign-pledges:{slug}`, los puntos finales de lectura del panel devuelven cero filas o un aviso de índice faltante sin bloqueo en lugar de recurrir a un escaneo de espacio de nombres; ejecute las herramientas de reparación/reconstrucción de proyecciones existentes explícitamente cuando eso suceda.

Los inicios/intercambios de autenticación de administrador y las mutaciones de administrador de navegador tienen una velocidad limitada a través del enlace `RATELIMIT` y devuelven fallas privadas/sin almacenamiento cuando se aceleran. Las lecturas autenticadas normales, como comprobaciones de sesiones, resúmenes de paneles, filtros de soporte, vistas previas de informes, vistas de análisis y vistas previas de contenido, no están limitadas intencionalmente por la velocidad de KV. Los tokens de inicio de sesión de Magic-link son de un solo uso y las lecturas de sesión no actualizan las sesiones cercanas a su vencimiento ni limpian las sesiones vencidas en la ruta de lectura. Las mutaciones de administrador respaldadas por cookies requieren tanto el token CSRF de sesión como un contexto de recuperación confiable del mismo sitio `Origin`/`Referer` o que no sea entre sitios antes de escrituras duraderas.

Cuando se configura `TURNSTILE_SECRET_KEY`, `POST /admin/auth/start` verifica el desafío Cloudflare Turnstile antes de enviar un correo electrónico con enlace mágico. Mantenga esa protección solo en la ruta de envío para que no agregue vistas de página del panel o escrituras KV al escribir.

El inventario complementario de la plataforma utiliza `_config.yml` como línea base configurada, el estado KV `add-on-inventory-overrides` opcional para reabastecimientos del operador y `add-on-inventory-sold:v1` para recuentos vendidos derivados de la verdad del aporte guardado. Las vistas de la página de inventario del administrador no cargan la tabla de inventario automáticamente; la lectura del inventario del superadministrador es explícita y utiliza la proyección del recuento de ventas después del arranque, mientras que las acciones de configuración/reabastecimiento/restablecimiento escriben solo el estado de anulación más un evento de auditoría.

La sección de la herramienta de marketing mantiene la creación de URL de campaña, parámetros UTM/referencia, accesos directos al creador de incrustaciones, preferencias de campos locales, vistas previas/descargas de QR y ediciones de campos no guardados en el estado del navegador. Los códigos de referencia guardados y los borradores compartidos están separados: la lista de referencias es de solo lectura, los guardados de referencia y los borradores compartidos son mutaciones KV explícitas con alcance de campaña, y los guardados de borradores compartidos obsoletos fallan si la revisión no coincide. Los informes de rendimiento de referencias/UTM pertenecen a Analytics y permanecen como de solo lectura. Las ediciones locales masivas permanecen locales en el navegador a menos que se guarden explícitamente como un borrador compartido; La carga de imágenes es una mutación de medios explícita respaldada por GitHub antes de los envíos de prueba/en vivo, los ensayos utilizan el índice de aporte de campaña sin listas KV ni escrituras, y los envíos en vivo escriben solo el evento de auditoría requerido después del envío.

### POST /admin/broadcast/diary
Envíe una notificación de actualización del diario a todos los patrocinadores de la campaña. Requiere el encabezado `x-admin-key`.

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
Envíe notificaciones de hitos a todos los patrocinadores de la campaña. Requiere el encabezado `x-admin-key`.

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
- Los correos electrónicos de aporte diario incluyen totales de campaña únicamente más una breve nota de impulso/entrenamiento en el cuerpo.
- envíos de cumplimiento divididos por cumplimiento:
  - Los destinatarios de la campaña reciben solo las filas completadas por la campaña.
  - `platform.support_email` recibe un correo electrónico de cumplimiento de plataforma independiente cuando existen filas de plataforma
- Los correos electrónicos de cumplimiento utilizan un resumen/nota de cuerpo específico del cumplimiento en lugar de reutilizar el resumen diario del informe de aporte.
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
- `supporter`: confirmación de aporte (con elementos de aporte de muestra)
- `modified`: modificación del aporte (con elementos de aporte de muestra)
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


## Ayudantes de operadores y datos en vivo

### GET /stats/:campaignSlug
Obtenga estadísticas de aportes en vivo para una campaña.


### GET /live/:campaignSlug
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


### POST /stats/:campaignSlug/recalculate
Vuelva a calcular las estadísticas de todas los aportes en KV (solo administrador).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`


### POST /admin/rebuild
Activar una reconstrucción de páginas de GitHub (para transiciones de estado).

**Encabezados:** `Authorization: Bearer ADMIN_SECRET`

**Solicitud:** `{ "reason": "campaign-state-change" }` (opcional)


### POST /admin/marketing/announcement
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


### POST /admin/broadcast/announcement
Punto final de operador secreto compartido heredado para un correo electrónico de anuncio personalizado con un enlace CTA opcional para todos los patrocinadores de la campaña.

**Encabezados:** `Authorization: Bearer ADMIN_BROADCAST_SECRET` cuando está configurado, en caso contrario `Authorization: Bearer ADMIN_SECRET` **Solicitud:**
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


### POST /admin/recover-checkout
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
