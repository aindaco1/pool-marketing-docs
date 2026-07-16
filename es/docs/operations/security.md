---
title: Guía de seguridad
parent: Operaciones
nav_order: 8
render_with_liquid: false
lang: es
---

# Guía de seguridad

## Última actualización

16 de julio de 2026

Este documento cubre la arquitectura de seguridad, los riesgos conocidos, las medidas de refuerzo aplicadas, las compensaciones aceptadas y los procedimientos de prueba de penetración para la plataforma de financiación colectiva The Pool. Los límites de copia de seguridad cifrada, el estado de límite de velocidad/sesión en cuarentena, el manejo fuera del dispositivo y las aprobaciones de restauración de producción se definen en [BACKUP_RESTORE.md](/es/docs/operations/backup-restore/).

Úselo junto con [ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/) cuando un cambio genere un nuevo uso de datos, mensajes de apoyo, poder administrativo, intercambio público, automatización o presión de participación. La revisión de seguridad debe abarcar no sólo el aporte de credenciales y la inyección de código, sino también el uso indebido realista por parte de spammers, acosadores, estafadores, administradores descuidados y flujos de trabajo de crecimiento demasiado agresivos.

## Arquitectura de seguridad

### Mecanismos de autenticación

|Mecanismo|Puntos finales|Descripción|
|-----------|-----------|-------------|
|**Fichas de enlace mágico**|`/pledge*`, `/pledges`, `/votes`|Tokens firmados HMAC-SHA256 con vencimiento de 90 días|
|**Tokens de cancelación de suscripción de recordatorio de lanzamiento**|`GET /launch-reminders/unsubscribe`|Token HMAC con alcance que suprime un registro de recordatorio de campaña/correo electrónico|
|**Firma de webhook de Stripe**|`/webhooks/stripe`|Verificación HMAC-SHA256 según las especificaciones de Stripe|
|**Sesiones del panel de administración**|API del panel del navegador `/admin/*`|Inicio de sesión mediante enlace mágico por correo electrónico, cookie de sesión firmada, encabezado CSRF sobre mutaciones, alcance de función/campaña|
|**Fichas de revisor de vista previa de campaña**|`/campaigns/:slug/preview/` vía `/admin/campaign-preview/:slug`|Tokens de revisor firmados de corta duración destinados al slug de campaña y al correo electrónico del revisor, respaldados por una lista de permitidos de KV de 24 horas|
|**Desafío de inicio de sesión de administrador**|`POST /admin/auth/start`|Verificación opcional de Cloudflare Turnstile antes de la emisión del enlace mágico del administrador|
|**Reto de recordatorio de lanzamiento**|`POST /launch-reminders`|Verificación opcional/esperada de Cloudflare Turnstile antes de escribir el recordatorio de registro|
|**Secreto de recuperación del administrador**|Automatización y recuperación de puntos finales `/admin/*`|Encabezado `Authorization: Bearer <secret>` o `x-admin-key` para operaciones basadas en scripts|
|**Secretos de administración con alcance**|Puntos finales de automatización de liquidación y transmisión|Opcional `ADMIN_SETTLEMENT_SECRET` y `ADMIN_BROADCAST_SECRET`; cuando se configura, la ruta con alcance rechaza el `ADMIN_SECRET` más amplio|
|**Protección del modo de prueba**|`/test/*`|`APP_MODE === 'test'` verificación del entorno|

### Almacenamiento de datos (Cloudflare KV)

|Patrón clave|Espacio de nombres|Datos|Sensibilidad|
|-------------|-----------|------|-------------|
|`pledge:{orderId}`|Aportes|Correo electrónico, monto, ID de Stripe, estado|**Alta** - PII + datos de pago|
|`email:{email}`|Aportes|Matriz de ID de pedido|**Medio**: vincula el correo electrónico a los aportes|
|`stats:{slug}`|Aportes|Totales agregados|**Bajo** - público|
|`tier-inventory:{slug}`|Aportes|Recuentos de reclamos de nivel|**Bajo** - público|
|`stripe-event:{id}`|Aportes|bandera "procesada"|**Bajo** - idempotencia|
|`processor-event:v1:{time}:{id}`|Aportes|ID de solicitud/webhook Stripe redactados, estado, intención, momento, idempotencia, estado de reconciliación; TTL de 400 días|**Medio** - metadatos de operaciones de pago|
|`campaign-pledges:{slug}`|Aportes|Matriz de ID de pedido por campaña|**Bajo** - índice|
|`campaign-charged:{slug}`|Aportes|Marca de tiempo de finalización de la liquidación|**Bajo** - bandera|
|`settlement-job:{slug}`|Aportes|Progreso del lote de liquidación|**Bajo** - efímero|
|`settlement-group:v1:{slug}:{hash}`|Aportes|Estado de precarga/enviado/resultado duradero e ID del procesador; TTL de 400 días|**Medio** - metadatos de operaciones de pago|
|`reconciliation-break:v1:{slug}:{kind}:{hash}`|Aportes|Abrir/resolver diferencias entre procesador y aporte e ID de objeto/pedido; TTL de 400 días|**Medio** - metadatos de operaciones de pago|
|`pending-extras:{orderId}`|Aportes|Artículo de soporte temporal/extras de pago de cantidad personalizada|**Bajo** - efímero|
|`pending-tiers:{orderId}`|Aportes|Metadatos de nivel de desbordamiento temporal durante el pago|**Bajo** - efímero|
|`cron:lastRun`|Aportes|Última marca de tiempo de ejecución cron horaria persistente|**Bajo** - seguimiento|
|`admin-login:{hash}`|Aportes|Inicio de sesión único de administrador y correo electrónico|**Medio**: autenticación de administrador efímera|
|`admin-session:{hash}`|Aportes|Correo electrónico de administrador, función, alcance de la campaña, token CSRF, vencimiento|**Alta** - autenticación de administrador|
|`admin-users:v1`|Aportes|Usuarios administradores de tiempo de ejecución y alcances de campaña|**Alto** - control de acceso|
|`admin-marketing-referrals:{slug}`|Aportes|Código de referencia guardado y metadatos de origen QR|**Bajo**: datos de marketing escritos por el administrador|
|`admin-marketing-draft:{slug}:{surface}`|Aportes|Borrador explícito compartido de marketing/Blast con retención breve|**Medio**: contenido de enlace/correo electrónico de campaña creado por un administrador|
|`campaign-preview-reviewers:{slug}`|Aportes|Lista de correo electrónico permitido para revisores normalizada para vistas previas de campañas protegidas, con TTL de 24 horas|**Mediano**: lista de acceso a correo electrónico específica de la campaña|
|`admin-audit:{date}:{action}:{id}`|Aportes|Eventos recientes de auditoría de mutación de administrador|**Medio**: identidad del administrador + metadatos operativos|
|`launch-reminder:{slug}:{emailHash}`|Aportes|Correo electrónico de recordatorio de próxima campaña y metadatos de suscripción|**Medio**: correo electrónico relacionado con la campaña|
|`launch-reminder-suppressed:{slug}:{emailHash}`|Aportes|Marcador de supresión de recordatorio|**Medio**: hash de correo electrónico con ámbito de campaña|
|`launch-reminder-sent:{slug}:{emailHash}`|Aportes|Recordatorio de envío de marcador de idempotencia|**Bajo** - estado de envío|
|`launch-reminder-dispatch:{slug}`|Aportes|Cursor/progreso del trabajo de envío de recordatorio acotado|**Bajo** - estado operativo|
|`launch-reminder-dispatch-queue:v1`|Aportes|Cola de envío de recordatorio inactiva/marcador pendiente|**Bajo** - estado operativo|
|`abandoned-cart:{orderId}`|Aportes|Instantánea de la campaña y correo electrónico de recordatorio de pago explícitamente aceptado|**Medio**: correo electrónico relacionado con la campaña|
|`abandoned-cart-resume:{orderId}`|Aportes|Instantánea de breve duración de reanudación de pago con enlace firmado después de enviar un recordatorio|**Medio**: correo electrónico de la campaña y resumen del carrito desinfectado|
|`abandoned-cart-sent:{emailHash}:{campaignSetHash}`|Aportes|Recordatorio de pago enviar marcador de idempotencia|**Bajo** - estado de envío|
|`abandoned-cart-suppressed:{emailHash}`|Aportes|Marcador de cancelación de suscripción de recordatorio de pago|**Medio**: hash de correo electrónico del colaborador|
|`abandoned-cart-suppressed-campaign:{slug}:{emailHash}`|Aportes|Marcador de supresión de recordatorio de pago con alcance de campaña administrado por el administrador|**Medio**: hash de correo electrónico del colaborador|
|`abandoned-cart-queue:v1`|Aportes|Cola de recordatorio de pago inactiva/marcador pendiente|**Bajo** - estado operativo|
|`abandoned-cart-health:v1`|Aportes|Contadores de salud de resultados/cola de recordatorio de pago agregado|**Bajo** - agregado operativo|
|`supporter-email-retry:{orderId}`|Aportes|Carga útil de reintento de correo electrónico de confirmación de colaborador en cola|**Medio**: carga útil de correo electrónico de apoyo|
|`supporter-email-retry-queue:v1`|Aportes|Reintento de correo electrónico del colaborador inactivo/pendiente y marcador de siguiente intento|**Bajo** - estado operativo|
|`email-outbox:v1:{hash}`|Aportes|Carga útil del proveedor y destinatario congelados mientras la entrega está pendiente; TTL de 30 días|**Alto**: contenido de correo electrónico transitorio + PII|
|`email-delivery:v1:{hash}`|Aportes|ID de proveedor mínimo, hash de contenido, categoría, estado, tiempo; TTL de 400 días|**Bajo** - evidencia de entrega|
|`email-suppression:v1:{emailHash}`|Aportes|Supresión permanente de rebote/queja/proveedor con hash; TTL de 400 días|**Medio**: metadatos de consentimiento/capacidad de entrega|
|`campaign-email-suppression:v1:{slug}:{emailHash}`|Aportes|Supresión de actualizaciones de campañas con un solo clic mediante hash|**Medio**: metadatos de consentimiento|
|`resend-webhook:v1:{svixId}`|Aportes|Marcador de deduplicación de eventos Resend firmado; TTL de 35 días|**Bajo** - idempotencia|
|`add-on-inventory-sold:v1`|Aportes|Proyección de recuento de ventas de complementos de plataforma|**Bajo**: estado del inventario agregado|
|`vote:{slug}:{decision}:{email}`|VOTOS|elección de voto|**Medio** - vincula a un patrocinador para que vote|
|`results:{slug}:{decision}`|VOTOS|recuentos de votos|**Bajo** - semipúblico|
|`rl:{endpoint}:{ip}`|LÍMITE DE TARIFAS|Recuento de solicitudes + tiempo de reinicio|**Bajo** - efímero|

La reserva escasa de nivel limitado y la verdad del recuento comprometido ya no se almacenan en KV. Ese estado sensible a la raza ahora reside en el coordinador de Objetos Durables por campaña, mientras que KV mantiene solo la proyección pública `tier-inventory:{slug}`.

La serialización de liquidaciones también está respaldada por objetos duraderos. El enlace `SETTLEMENT_COORDINATOR` posee un bloqueo de corta duración por slug de campaña, por lo que los puntos finales de liquidación programada, liquidación directa, envío y lote no pueden cobrar la misma campaña al mismo tiempo. Los carritos de campañas múltiples aún funcionan porque la persistencia del proceso de pago crea registros de aporte separados con alcance de campaña y los bloqueos de liquidación dependen de la campaña que se cobra.

---

## Resumen de vulnerabilidad

### Crítico/alta prioridad

|identificación|Problema|Gravedad|Estado|
|----|-------|----------|--------|
|SEC-001|Omisión del token de desarrollo en `/votes` en producción|**Alto**|✅ Fijo|
|SEC-002|El webhook Stripe no se abre si no se establece el secreto|**Alto**|✅ Fijo|
|SEC-003|Los puntos finales de prueba pueden ser accesibles en producción|**Alto**|✅ Fijo|

### Prioridad media

|identificación|Problema|Gravedad|Estado|
|----|-------|----------|--------|
|SEC-004|CORS `Access-Control-Allow-Origin: *` en todos los puntos finales|**Medio**|✅ Fijo|
|SEC-005|Sin límite de velocidad en terminales costosos|**Medio**|✅ Fijo|
|SEC-006|El secreto de administrador no es seguro en comparación con el tiempo|**Medio**|✅ Fijo|
|SEC-007|La superficie del webhook del carrito alojado heredado permaneció accesible|**Medio**|✅ Fijo|

### Prioridad baja

|identificación|Problema|Gravedad|Estado|
|----|-------|----------|--------|
|SEC-008|Tokens de enlace mágico de larga duración (90 días)|**Bajo**|Aceptable|
|SEC-009|La validación de entradas de votos podría ser más estricta|**Bajo**|✅ Fijo|
|SEC-010|Tokens en cadenas de consulta (riesgo de fuga de referencia)|**Bajo**|Aceptable|
|SEC-011|Validación de entrada en cargas útiles de inicio de pago|**Bajo**|✅ Fijo|
|SEC-012|Faltan encabezados de respuesta de seguridad|**Bajo**|✅ Fijo|
|SEC-013|El panel de administración almacena lagunas en la normalización de las entradas|**Bajo**|✅ Fijo|

---

## Notas de endurecimiento aplicado

### Revisión de abuso y uso indebido ético

Los casos de abuso de mayor impacto de The Pool a menudo cruzan los límites del producto, la seguridad, la privacidad y la confianza. Ejecute la [revisión de riesgos éticos](/es/docs/development/ethical-risk-review/) antes de enviar las funciones que cambian:

- visibilidad pública, incrustaciones, vistas previas sociales, metadatos SEO, enlaces de referencia o códigos QR
- correo electrónico de patrocinadores, recordatorios, Blast, transmisiones de diarios/hitos, invitaciones de vista previa o entrega de informes
- totales de pago, propinas, impuestos, envío, escasez de inventario, liquidación o modificación de aporte
- roles de administrador, alcance de la campaña, vistas previas protegidas, creación/archivo de campañas, carga de medios o publicación respaldada por GitHub
- análisis, uso del plan del proveedor, exportaciones, copias de seguridad, comportamiento de restauración o nuevos flujos de datos de terceros

La aprobación de seguridad debe responder a las mismas preguntas prácticas cada vez:

- ¿Qué datos resultan más fáciles de recopilar, inferir, exportar o exponer?
- ¿Qué estado privado/tokenizado podría accidentalmente indexarse, captarse previamente, compartirse o enviarse por correo electrónico?
- ¿Cómo podría un actor malintencionado utilizar esta superficie para spam, acoso, fraude, doxxing, abuso de pagos o afirmaciones públicas engañosas?
- ¿Qué consentimiento explícito, alcance, limitación de velocidad, registro de auditoría, comportamiento sin almacenamiento/sin índice, validación de ensayo o ruta de recuperación mantienen el riesgo limitado?

### Límites de almacenamiento secretos

Las credenciales de tiempo de ejecución están separadas intencionalmente de la configuración del sitio editable:

- Las configuraciones no secretas pertenecen a `_config.yml`, `_config.local.yml` o borradores de configuración de administrador.
- Los secretos del desarrollo local pertenecen al `worker/.dev.vars` ignorado; ejecute `npm run secrets:dev` o `npm run setup:deploy -- --mode=local` para crear/actualizar ese archivo de forma segura. Utilice valores locales separados, no copias de seguridad de producción.
- Las credenciales de producción Worker pertenecen a los secretos Cloudflare Worker a través de `wrangler secret put`.
- Las credenciales de implementación como `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CACHE_PURGE_TOKEN`, `ADMIN_BROADCAST_SECRET` y `DIARY_CHECK_BYPASS_SECRET` pertenecen a los secretos del repositorio GitHub solo cuando las acciones GitHub o los scripts del operador necesitan llamar a esas rutas. Agregue `ADMIN_SETTLEMENT_SECRET` allí solo cuando un flujo de trabajo realmente llame a puntos finales de liquidación.
- El rastreador de uso del plan de administrador debe usar `CLOUDFLARE_USAGE_API_TOKEN` o `CLOUDFLARE_ANALYTICS_API_TOKEN` con alcance de GraphQL Analytics de solo lectura, además de lectura de facturación si la detección automática del plan Workers está habilitada. No reutilice el token de implementación más amplio Wrangler para lecturas de uso del panel.
- `CLOUDFLARE_ACCOUNT_ID` no es sensible por sí solo, pero Configuración -> Uso del plan aún lo necesita en el entorno de ejecución de Worker como una variable o secreto. Un secreto de repositorio GitHub con el mismo nombre no se convierte automáticamente en un enlace Worker implementado.
- Las implementaciones de Wrangler requieren que `CLOUDFLARE_API_TOKEN` sea un token API de usuario Cloudflare creado desde **Mi perfil -> Tokens API** con la plantilla **Editar Cloudflare Workers**. Los tokens de API de propiedad de la cuenta no son suficientes porque Wrangler todavía llama a puntos finales de ámbito de usuario durante la implementación.
- Los secretos del repositorio GitHub no son secretos de tiempo de ejecución de Worker. La aplicación de rutas de administración con alcance requiere que el `ADMIN_BROADCAST_SECRET` o `ADMIN_SETTLEMENT_SECRET` coincidente también esté presente en los secretos Cloudflare Worker.
- El panel de administración puede mostrar el estado Configurado/Falta para las credenciales de tiempo de ejecución, pero no debe exponer, editar, serializar ni publicar valores secretos.

Este límite evita que el panel de administración se convierta en un almacén de credenciales y evita que las bifurcaciones confirmen accidentalmente tokens Stripe, Resend, USPS, ZIP.TAX o Cloudflare y, al mismo tiempo, hace que la configuración faltante sea visible para los operadores. Consulte [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) para Stripe y la configuración de liquidación, y [EMAIL.md](/es/docs/operations/email-system/) para la configuración de Resend.

### Modelo de seguridad de entrada del panel de administración

El panel de administración del navegador tiene un único límite de normalización del lado del servidor antes de que los datos se escriban en YAML o Worker KV respaldados por GitHub. Los controles del lado del cliente existen únicamente para su usabilidad; el Worker sigue teniendo autoridad.

Las mutaciones administrativas utilizan estas protecciones comunes:

- Las mutaciones del panel del navegador requieren una cookie de sesión de administrador válida y un encabezado `x-pool-admin-csrf`.
- Cuando se configura `TURNSTILE_SECRET_KEY`, el inicio de sesión del correo electrónico del administrador requiere un token Cloudflare Turnstile verificado por el servidor antes de las escrituras con límite de velocidad, las escrituras nonce de inicio de sesión o los envíos de correo electrónico con enlace mágico. `ADMIN_TURNSTILE_BYPASS=true` se acepta solo en modo local/de prueba o en URL locales para pruebas automatizadas.
- Los registros de recordatorio de lanzamiento utilizan el mismo verificador Turnstile compartido con puertas de entorno específicas de recordatorio público. `LAUNCH_REMINDER_TURNSTILE_BYPASS=true` se acepta solo en modo local/de prueba o en URL locales para pruebas automatizadas.
- Los usuarios de campañas solo pueden modificar campañas en su alcance asignado; Los superadministradores pueden modificar la configuración de la plataforma y todas las campañas.
- Las configuraciones respaldadas por GitHub están incluidas en la lista permitida a través de `ADMIN_PLATFORM_SETTING_SCHEMA` y `ADMIN_CAMPAIGN_SETTING_SCHEMA`. Se rechazan las rutas desconocidas y las pseudofilas de la interfaz de usuario, como las del editor de contenido de la campaña, no se pueden asignar en masa mediante la publicación de configuraciones.
- Las cargas de medios de administración tienen un alcance del lado del servidor según el tipo de carga. Las cargas de medios de campaña requieren un slug de campaña válido más `campaign:edit_content`; Las cargas de medios predeterminadas o de plataforma requieren la ruta de superadministrador `settings:publish`. Worker valida el tipo de archivo, el tamaño, el directorio de destino y el nombre de archivo antes de confirmar una ruta de activo.
- La limpieza de medios en el momento de la publicación se deriva del lado del servidor a partir de los datos de campaña cargados previamente y del borrador de campaña normalizado que se confirma. Solo elimina los archivos seguros que pertenecen al panel de control relativo a la raíz en los directorios `assets/images`, `assets/videos` o `assets/audio` de la misma campaña, y conserva las URL externas, los activos compartidos/predeterminados y los archivos a los que todavía se hace referencia en otras partes de la campaña.
- Los usuarios administradores de solo tiempo de ejecución se guardan únicamente en KV en `admin-users:v1`; no están serializados en `_config.yml`.
- La restauración de pestañas/subpestañas del panel de administración almacena solo identificadores de interfaz de usuario locales del navegador para el último espacio de trabajo permitido. No se envía a Worker, no escribe el estado KV o GitHub, y la autorización de rol/campaña aún controla lo que se puede restaurar después del inicio de sesión.
- Los códigos de referencia de marketing se guardan solo en la acción explícita del usuario y tienen como alcance el origen/ruta de la URL de la campaña a la que puede acceder la cuenta de administrador.
- Los borradores de Shared Marketing/Blast se guardan solo tras una acción explícita del usuario, se limitan a una campaña y superficie, caducan después de 7 días y usan tokens de revisión para que los guardados obsoletos no sobrescriban el trabajo de otro administrador.
- Informes de atribución de análisis y índices de aporte de campaña de uso de salud de pago abandonado o estado de salud agregado en lugar de escaneos de espacios de nombres KV; Las respuestas de recordatorio de salud exponen contadores y resultados recientes, no listas de destinatarios de recordatorios.
- Los controles de supresión de pagos abandonados en el ámbito de la campaña requieren CSRF, almacenan identificadores de correo electrónico con hash y no exponen una acción de reintentar este carrito específico.
- Campañas -> Los envíos de Blast están dirigidos a campañas que la cuenta de administrador puede editar. Los simulacros de Blast requieren el índice de aporte de campaña y no agregan escrituras ni operaciones de lista de KV; Los envíos en vivo requieren un hash de prueba coincidente y escriben un evento de auditoría después del envío.
- La creación de nuevas campañas es solo para superadministradores, escribe un archivo Markdown de campaña de vista previa localmente en desarrollo o a través de la ruta GitHub existente en producción y mantiene esa campaña fuera de la generación de ruta pública hasta su lanzamiento. La creación de nuevos usuarios de campaña durante ese flujo se guarda en `admin-users:v1` y envía un correo electrónico a los usuarios asignados a través de la ruta de correo electrónico de administrador compartida cuando se asignan los usuarios.
- La publicación de vista previa protegida está dirigida a superadministradores y usuarios de campaña asignados. Solo envía indicadores de vista previa a la campaña Markdown, almacena los correos electrónicos del administrador de publicación más los correos electrónicos de revisores opcionales en una lista de permitidos de corta duración `campaign-preview-reviewers:{slug}` KV, devuelve un enlace de panel firmado de 24 horas para el administrador de publicación, envía enlaces de revisores firmados de 24 horas cuando se agregan revisores opcionales y registra un evento de auditoría. Los correos electrónicos de la vista previa no deben persistir en la fuente de la campaña respaldada por GitHub, en el JSON de la campaña pública, en la salida del mapa del sitio ni en los metadatos generados.
- El archivado de campañas es solo para superadministradores y no está disponible para las campañas activas actualmente. Worker valida el token CSRF, el rol, el slug, la existencia de la campaña y el estado efectivo antes de mover archivos localmente en desarrollo o enviar `.github/workflows/archive-campaign.yml` en producción. Ambas rutas de archivo validan el slug, mueven la fuente de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/`, omiten los medios a los que todavía hacen referencia otras campañas activas y escriben un `archive-manifest.json`.
- El shell de administración estático utiliza un meta CSP restrictivo sin secuencias de comandos en línea, conexiones Worker/API limitadas y iframes de vista previa en espacio aislado que reciben solo HTML de vista previa renderizado por Worker. Los iframes de vista previa permiten secuencias de comandos, pero intencionalmente no usan `allow-same-origin`, evitando la advertencia del navegador y el riesgo de escape que surge al combinar ambos tokens de sandbox. Las superficies de edición administrativa y vista previa protegida representan medios remotos de YouTube/Vimeo como fachadas en lugar de cargar reproductores en vivo al cargar la página; el CSP permite imágenes en miniatura estáticas de YouTube para esas fachadas, pero aún no carga los scripts del reproductor de YouTube en las vistas previas del editor. Las páginas de campañas públicas y las incrustaciones públicas copiadas aún pueden mostrar jugadores aprobados. La protección de tramas debe entregarse como un encabezado HTTP, como `Content-Security-Policy: frame-ancestors 'none'` o `X-Frame-Options: DENY`; Los navegadores ignoran `frame-ancestors` dentro del meta CSP.
- Los correos electrónicos de enlace mágico del administrador utilizan URL de inicio de sesión generadas internamente y eliminan los caracteres de control del encabezado del correo electrónico de los valores de remitente/asunto configurables por el administrador antes de enviarlos.

### Límite de vista previa de campaña protegida

Las vistas previas protegidas son superficies de revisión privadas para campañas editables, no páginas de campañas públicas.

- Los shells de vista previa estática se encuentran en `/campaigns/:slug/preview/` y equivalentes localizados para cada slug de campaña, por lo que los enlaces de vista previa no aceleran la reconstrucción del sitio estático. Utilizan `noindex,nofollow,noarchive`, comportamiento de referencia de origen estricto para compatibilidad con medios integrados, sin metadatos sociales públicos ni JSON-LD público.
- El shell es genérico y no incorpora el título de la campaña, los datos de carga útil ni los datos de acceso previo en el momento de la compilación. Obtiene una carga útil de vista previa de la página de campaña completa sin tienda de `/admin/campaign-preview/:slug`, con controles de aporte de solo lectura.
- Los administradores autenticados pueden recuperar la carga útil solo a través de la sesión de administrador existente, las protecciones CSRF/de origen cuando correspondan y las comprobaciones del alcance de la función/campaña.
- Los revisores explícitos utilizan tokens `t` firmados según el tipo de token, el slug de campaña, el correo electrónico del revisor y el vencimiento. Worker también compara el correo electrónico con la lista de permitidos de 24 horas de KV antes de devolver una carga útil de vista previa.
- Las solicitudes de publicación de vista previa llevan una revisión base GitHub cuando esté disponible. Las publicaciones obsoletas devuelven un conflicto en lugar de sobrescribir los cambios de otro usuario.
- Los filtros de campañas públicas tratan las campañas de solo vista previa/no lanzadas como invisibles para páginas públicas, rutas localizadas, `/api/campaigns.json`, catálogos de complementos, tarjetas compartidas, resultados de mapas del sitio, intención de rastreo de robots, incrustaciones y elegibilidad de captación previa pública.

### Límites públicos de captación previa y enlace compartido

El tiempo de ejecución de la captación previa de intención pública es deliberadamente limitado, por lo que la navegación especulativa no puede convertir los flujos privados en tráfico de fondo.

- La captación previa se carga solo en diseños de página públicos.
- Las URL elegibles deben ser rutas de documentos públicos del mismo origen de la lista de permitidos.
- Se rechazan las rutas de administración, pago, gestión de aporte, resultado de aporte, comunidad de patrocinadores, vista previa de campaña, API, Worker, tokenizado y de consultas confidenciales.
- El tiempo de ejecución respeta `data-no-prefetch`, `download`, `target`, `nofollow`, datos guardados, red lenta y protecciones de límite por página explícitas.

Los enlaces para compartir de la campaña siguen el mismo límite de privacidad. El cliente conserva solo los parámetros de consulta de referencia/UTM seguros para las URL de campañas públicas, deja atrás los parámetros de token/pedido/correo electrónico/sesión y permite que los metadatos de Open Graph proporcionen imágenes de vista previa en lugar de serializar las URL de imágenes en intenciones de compartir.

Los formularios de recordatorio de lanzamiento son públicos pero limitados: los registros requieren consentimiento explícito, tienen una velocidad limitada por IP, escriben un registro de campaña/hash de correo electrónico deduplicado y solo pueden reactivarse mediante otro registro explícito. El envío de recordatorios comprueba la supresión y los marcadores enviados inmediatamente antes de la entrega del correo electrónico.

Las clases de campos de administración se normalizan consistentemente:

- El texto sin formato elimina los caracteres de control, impone límites de longitud y rechaza el HTML sin formato.
- El texto enriquecido en línea permite Markdown más un pequeño subconjunto HTML (`<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`), rechaza scripts, iframes, controladores de eventos en línea, estilos en línea, enlaces de Markdown no seguros y enlaces relativos a padres como `../admin`.
- Las URL y las referencias multimedia deben ser rutas seguras relativas a la raíz o URL absolutas `http`/`https`. Las URL de sitios canónicos/Worker y las bases de API externas deben ser URL absolutas de `http`/`https`. Se rechazan las credenciales integradas, los esquemas inseguros como `javascript:` y `data:`, el recorrido de ruta, los espacios en blanco literales y los caracteres de marcado sin formato.
- Las entradas de diseño CSS se limitan a colores hexadecimales, pilas de fuentes simples y tokens de longitud simples, por lo que la configuración no puede contrabandear declaraciones CSS o valores `url(...)`.
- Los números, valores booleanos, enumeraciones, ID, slugs, fechas, dimensiones de envío y pesos de paquetes se analizan en tipos canónicos con límites por campo.
- Las colecciones estructuradas, como niveles, complementos, entradas de diario, decisiones y bloques de contenido, se normalizan elemento por elemento en lugar de confiar en JSON sin formato del navegador.

La inyección de SQL no es una amenaza principal para el Worker actual porque el tiempo de ejecución no utiliza SQL. Las clases de inyección relevantes son XSS almacenado, inyección de YAML/front-matter, manipulación de clave/ruta KV, inyección de URL/CSS y escalada de privilegios mediante asignación masiva; los normalizadores administrativos están diseñados en torno a esos riesgos.

### SEC-001: Bloquear la omisión del token de desarrollo (✅ CORREGIDO)

**Archivo:** `worker/src/routes/votes.js`

**Patrón histórico de vulnerabilidad:**
```javascript
if (token.startsWith('dev-token-')) {
  campaignSlug = token.replace('dev-token-', '');
  orderId = 'dev-order-1';
}
```

**Fijado:**
```javascript
if (token.startsWith('dev-token-')) {
  if (env.APP_MODE !== 'test') {
    return jsonResponse({ error: 'Invalid token' }, 401);
  }
  campaignSlug = token.replace('dev-token-', '');
  orderId = 'dev-order-1';
  email = 'dev@test.com';
}
```

**Nota:** Los votos se codifican por **correo electrónico** (no por ID de pedido) para evitar que los patrocinadores con múltiples aportes voten varias veces. Worker también resuelve decisiones de campaña en el lado del servidor, rechaza decisiones desconocidas/cerradas y solo acepta valores de opciones de la lista de permitidos publicada de la campaña.

Los títulos, las descripciones y las etiquetas de soporte creados por la campaña también tienen caracteres de escape de forma predeterminada en las superficies de carrito, administración y comunidad orientadas a los patrocinadores, por lo que las bifurcaciones con contenido editable por el creador no heredan una pistola XSS almacenada de forma predeterminada. Los bloques de diario y campaña de formato largo ahora aceptan Markdown más un subconjunto HTML en línea muy pequeño (`<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`); otras etiquetas sin formato se escapan en el momento de la renderización y la auditoría de contenido las rechaza. Los enlaces Markdown se reescriben a menos que utilicen un esquema de destino incluido en la lista de permitidos (`http:`, `https:`, `mailto:` o enlaces internos), y las incrustaciones estructuradas deben utilizar URL exactas del proveedor `https://` aprobadas en lugar de pasar una verificación de subcadena.
Las páginas de la comunidad ya no conservan el token de portador de apoyo sin procesar en una cookie de larga duración; el token ahora permanece en el almacenamiento de la sesión del navegador mientras una cookie de verificación no confidencial maneja el estado ligero de UX.

Las mutaciones de inventario de nivel limitado ahora fluyen a través de un coordinador Durable Object por campaña desde el inicio del pago en adelante. Los niveles escasos se reservan antes de redirigir a Stripe, se confirman en el momento de persistencia exitosa y solo se proyectan nuevamente en KV para lecturas públicas. Esto mantiene la verdad del inventario sensible a la raza fuera del KV visible para el cliente y al mismo tiempo preserva las lecturas públicas eficientes de `/inventory/:slug`.

Los nuevos flujos de pago Stripe y `Update Card` en el sitio ahora también fallan de forma más privada de forma predeterminada: las respuestas Worker que llevan datos de arranque de sesión Stripe o el estado de finalización específico del pedido se entregan con `Cache-Control: private, no-store`, los POST del navegador entre sitios para inicio de pago / pago-completo / inicio de método de pago se rechazan a menos que se originen en `SITE_BASE`, y el navegador solo mantiene marcadores de pago a bordo de corta duración para la recuperación de reservas en lugar de dejarlos en un almacenamiento de larga duración indefinidamente. La persistencia del carrito de larga duración ahora solo mantiene la estructura del carrito y los datos de precios; Los borradores de contactos y direcciones se degradan a almacenamiento con alcance de sesión, y `/checkout-intent/complete` tiene su propio presupuesto de reintento para que la recuperación local no pueda enviarse spam indefinidamente. Después de una persistencia exitosa del aporte, el flujo de pago ahora también invalida las estadísticas en vivo/cachés de inventario inmediatamente y deja un marcador de actualización de corta duración para que las páginas de campaña restauradas no sigan mostrando totales obsoletos desde el estado previo al aporte del navegador.

La evidencia de la caché de liberación está centralizada en `config/performance-budgets.json` y se ejecuta con `npm run test:cache-policy`. Verifica que las páginas/recursos públicos cumplan con la vida útil mínima de la caché, mientras que los objetivos de administración/sesión siguen siendo `private, no-store`; un cambio de rendimiento que debilita una ruta privada es un error de versión. Workers La caché permanece deshabilitada a menos que la evidencia representativa borre el umbral de mejora p95 configurado.

El precio de los complementos está limitado al mismo límite máximo `$1,000,000` que los montos de pago canónicos. La normalización de variantes y productos de administración rechaza valores mayores antes de que se publique GitHub, la resolución del catálogo Worker vuelve a verificar los centavos resultantes y nunca se confía en un `unitPrice` histórico guardado fuera de rango como anulación de preservación de precios.

La revisión de la dependencia de la versión ejecuta tanto `npm audit --omit=dev --audit-level=moderate` como el `npm audit --audit-level=moderate` completo. Los hallazgos de producción son obstáculos. Los hallazgos exclusivos para desarrolladores en las herramientas de compilación o lanzamiento deben eliminarse, anclarse a una versión limpia y compatible o aceptarse explícitamente con alcance y justificación. The Pool fija Lighthouse `12.6.1` porque la cadena transitiva Sentry/OpenTelemetry posterior llevaba un aviso de asignación moderado, mientras que esta versión compatible realiza auditorías limpias.

Los recordatorios de pagos abandonados son solo opcionales. El navegador envía `abandonedCartConsent` solo cuando el colaborador marca la casilla de recordatorio, y Worker pone en cola un recordatorio solo después de que Stripe crea una sesión de pago propia válida. Los registros de recordatorio son de corta duración, utilizan enlaces de cancelación de suscripción firmados, se eliminan si el aporte persiste exitosamente para ese pedido y verifican los índices de aporte de la campaña antes de enviarlos para que un aporte completado posteriormente suprima el correo electrónico obsoleto de pago abandonado. Después de enviar un recordatorio, Worker almacena una instantánea separada de `abandoned-cart-resume:{orderId}` de corta duración para los enlaces de currículum firmados; esa instantánea contiene solo los campos de contacto/carrito desinfectados necesarios para reconstruir una nueva sesión de pago y nunca coloca secretos de Stripe en la URL.

---

### SEC-002: No procesar el secreto del webhook Stripe faltante (✅ CORREGIDO)

**Archivo:** `worker/src/index.js` (handleStripeWebhook)

**Patrón histórico de vulnerabilidad:**
```javascript
const webhookSecret = getStripeWebhookSecret(env);
if (webhookSecret) {
  // Only verifies if secret exists
}
```

**Fijado:**
```javascript
const webhookSecret = getStripeWebhookSecret(env);
if (!webhookSecret) {
  console.warn('Stripe webhook secret not configured for this mode, acknowledging receipt');
  return jsonResponse({ received: true, skipped: 'webhook secret not configured' }, 200);
}

const { valid, error } = await verifyStripeSignature(body, sig, webhookSecret);
if (!valid) {
  return jsonResponse({ error: 'Invalid signature' }, 401);
}
```

Worker reconoce los webhooks secretos faltantes para evitar infinitos reintentos de Stripe para el modo incorrecto, pero no analiza ni aplica el evento. La preparación para la producción aún debe tratar un secreto de webhook activo faltante como un defecto de implementación.

---

### SEC-003: Puntos finales de prueba de guardia (✅ FIJO)

**Archivo:** `worker/src/index.js` (enrutador)

Worker ahora bloquea los puntos finales de prueba fuera de `APP_MODE === 'test'` antes de que se ejecuten esos controladores:

```javascript
// Block test endpoints in production
if (path.startsWith('/test/') && env.APP_MODE !== 'test') {
  return jsonResponse({ error: 'Not found' }, 404);
}
```

Cada manejador también verifica el entorno como defensa en profundidad:
```javascript
async function handleTestSetup(request, env) {
  if (env.APP_MODE !== 'test') {
    return jsonResponse({ error: 'Not found' }, 404);
  }
  // ...
}
```

---

### SEC-004: Restringir orígenes CORS (✅ FIJO)

**Archivo:** `worker/src/index.js`

CORS ahora está restringido según el tipo de punto final:
- **Puntos finales públicos** (`/stats/*`, `/inventory/*`): Permitir `*`
- **Puntos finales protegidos**: utilice un `env.CORS_ALLOWED_ORIGIN` normalizado, un `env.SITE_BASE` normalizado o el origen del sitio de producción canónico.

```javascript
function getAllowedOrigin(env, isPublic = false) {
  if (isPublic) return '*';
  return normalizeOrigin(env.CORS_ALLOWED_ORIGIN) ||
         normalizeOrigin(env.SITE_BASE) ||
         'https://site.example.com';
}

// Public endpoints pass isPublic=true:
return jsonResponse(data, 200, env, true);

// Protected endpoints use default:
return jsonResponse(data, 200, env);
```

---

### SEC-005: Limitación de Tarifa (✅ FIJA)

**Archivo:** `worker/src/index.js`

La limitación de velocidad In-Worker ahora se implementa utilizando el almacenamiento KV con seguimiento por IP.

**Límites de velocidad de ruta de escritura:**

|Punto final|Límite|ventana|Notas|
|----------|-------|--------|-------|
|`/checkout-intent/start`|40 solicitudes|1 minuto|Comienza el pago; ajustado más alto para que las NAT compartidas y los picos legítimos sigan encajando|
|`/shipping/quote`|90 solicitudes|1 minuto|Las actualizaciones de cotizaciones de envío se mantienen amplias durante las ediciones del carrito|
|`/checkout-intent/complete`|12 solicitudes|1 minuto|Clave por `orderId` en lugar de solo IP para evitar castigar los reintentos reales|
|`/checkout-intent/abandon`|12 solicitudes|1 minuto|Con la clave `orderId` para que los reintentos de limpieza de reservas sean amigables con las IP compartidas.|
|`/pledge` + `/pledges`|120 solicitudes|1 minuto|Las lecturas de aporte de gestión siguen siendo generosas porque son lecturas orientadas al usuario|
|`/pledge/cancel`, `/pledge/modify`, `/pledge/payment-method/start`|30 solicitudes|1 minuto|Escrituras de aporte de gestión|
|`/votes`|45 solicitudes|1 minuto|Puntos finales de votación|
|`/admin/*`|5 solicitudes|1 minuto|Operaciones de administración|

**Cómo funciona:**

- Los límites de velocidad se rastrean **por dirección IP** mediante el encabezado `CF-Connecting-IP`
- Cada IP tiene su propio depósito, por lo que 100 usuarios diferentes no interferirán entre sí.
- Los puntos finales de lectura pública como `/live/:slug`, `/stats/:slug` y `/inventory/:slug` permanecen sin límites para que una campaña legítimamente viral no active una defensa DoS solo por ser popular.
- Las rutas de escritura de pago y Gestión de aporte mantienen límites más altos que un límite de fuerza bruta típico, por lo que los entornos NAT compartidos todavía tienen espacio para respirar.
- `/checkout-intent/complete` tiene la clave `orderId`, que es más amigable para los reintentos de recuperación legítimos que un depósito por IP puro.
- `/checkout-intent/abandon` también está codificado por `orderId`, por lo que los reintentos de limpieza/liberación no castigan a los patrocinadores detrás del mismo NAT durante un lanzamiento ocupado.
- Los webhooks Stripe están protegidos con verificación de firma, idempotencia y un límite de tamaño del cuerpo de la solicitud en lugar de un límite estricto por IP que podría interferir con la entrega normal de Stripe.
- Una vez que un cliente ya supera el límite de la ventana actual, las solicitudes bloqueadas repetidas no se cierran sin reescribir el mismo contador KV en cada visita. Eso evita que la presión abusiva se convierta en un plan gratuito innecesario que escribe KV.
- Las costosas rutas POST ahora también rechazan cuerpos de solicitud obviamente sobredimensionados antes de analizar JSON o tocar flujos pesados Stripe/KV.
- El Workers estándar/pago implementado ahora también declara `limits.cpu_ms = 100` en `wrangler.toml`. Esto es una barrera de protección de la billetera, no una afirmación de que las solicitudes normales sean tan costosas.
- Los puntos finales de observabilidad exclusivos para administradores ahora exponen resúmenes de entrega de webhooks y tiempos de mutación muestreados para que los operadores puedan ajustar las defensas DoS sin depender únicamente de colas de registros sin procesar.

**Configuración:**

1. Cree el espacio de nombres KV:
   ```bash
   wrangler kv:namespace create "RATELIMIT"
   wrangler kv:namespace create "RATELIMIT" --preview
   ```

2. Agregue a `wrangler.toml` (ambas secciones de producción y desarrollo):
   ```toml
   # Production
   [[kv_namespaces]]
   binding = "RATELIMIT"
   id = "YOUR_RATELIMIT_KV_ID"
   preview_id = "YOUR_RATELIMIT_PREVIEW_ID"

   # Development (in [env.dev] section)
   [[env.dev.kv_namespaces]]
   binding = "RATELIMIT"
   id = "YOUR_RATELIMIT_KV_ID"
   preview_id = "YOUR_RATELIMIT_PREVIEW_ID"
   ```

**Nota:** `RATELIMIT` ahora es un requisito estricto. Si falta el enlace, Worker falla al cerrarse con `503` en lugar de servir tráfico sin protección contra abusos. Ese cambio aumenta la importancia de tener un margen de maniobra real para KV, pero no significa que el plan gratuito Workers sea repentinamente incompatible con la escala de financiación colectiva de baja a moderada prevista para el proyecto.

**Nota sobre el límite de CPU:** El bloque `limits` configurable de Cloudflare solo se aplica en el modelo de uso estándar y solo en Workers implementado, no en el desarrollo local. El valor actual de `cpu_ms = 100` se eligió como un respaldo conservador después de que las solicitudes representativas de aprovechamiento de unidades aterrizaran alrededor del tiempo de reloj de pared `6 ms`, `15 ms` y `28 ms` para los flujos de luz de administración, recuperación de pago y abandono de pago, respectivamente. Esta es sólo una medida aproximada, pero es suficiente para justificar un techo bajo con margen de maniobra en lugar de dejar el valor predeterminado pagado en `30 seconds`.

**Nota de observabilidad:** Utilice `GET /admin/observability/webhooks` para inspeccionar el volumen de webhooks, entregas duplicadas, errores de firma y resultados recientes, y `GET /admin/observability/performance` para inspeccionar tiempos de reloj de pared de muestra para las rutas de mutación clave. El script auxiliar [`scripts/check-observability.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-observability.sh) envuelve ambos puntos finales para verificaciones locales o implementadas.

**Respuesta cuando la tarifa es limitada:**
```json
{
  "error": "Too many requests",
  "retryAfter": 45
}
```

Estado: `429 Too Many Requests` con encabezados:
- `Retry-After`: Segundos hasta que se restablezca el límite
- `X-RateLimit-Limit`: Máximo de solicitudes permitidas
- `X-RateLimit-Remaining`: Solicitudes restantes en ventana
- `X-RateLimit-Reset`: marca de tiempo de Unix cuando se restablece la ventana

**Pruebas locales:**

Reinicie Worker para restablecer los contadores de límite de velocidad (el KV local se simula y se reinicia al reiniciar):
```bash
lsof -ti:8787 | xargs kill -9
cd worker && npx wrangler dev --port 8787
```

---

### SEC-006: Comparación de secretos de administración seguros en el tiempo (✅ CORREGIDO)

**Archivo:** `worker/src/index.js`

El Worker ahora utiliza una ayuda de comparación segura para los secretos de administrador:
```javascript
function timingSafeEqual(a, b) {
  if (!a || !b || a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

function requireAdmin(request, env, scope = 'default') {
  const authHeader = request.headers.get('Authorization') || '';
  const provided = authHeader.startsWith('Bearer ')
    ? authHeader.slice('Bearer '.length)
    : request.headers.get('x-admin-key') || '';
  const credential = getAdminSecretForScope(env, scope);

  if (!credential) {
    console.error('admin secret not configured');
    return { ok: false, status: 500, error: 'Admin not configured' };
  }

  if (!timingSafeEqual(provided, credential.secret)) {
    return { ok: false, status: 401, error: 'Unauthorized' };
  }

  return { ok: true };
}
```

---

## Compensaciones aceptadas / Candidatos de seguimiento

Estos son los elementos actualmente conocidos que no se tratan como vulnerabilidades activas que requieren cambios inmediatos en el código:

### SEC-008: Tokens Magic Link de larga duración (90 días)

Estado: **Compensación aceptada**

Por qué permanece:
- Los enlaces mágicos no tienen intencionalmente cuentas y deben seguir siendo utilizables durante cronogramas de campaña más prolongados.
- cada token tiene como alcance una ruta de pedido/campaña específica en lugar de otorgar un amplio acceso a la cuenta.

Si esto alguna vez cambia, el seguimiento probable sería acortar la vida útil del token y combinarlo con una experiencia de usuario de reemisión/recuperación más sencilla.

### SEC-010: Tokens en cadenas de consulta (riesgo de fuga de referencia)

Estado: **Compensación aceptada**

Por qué permanece:
- La entrada de enlace mágico actualmente depende de las URL enviadas por correo electrónico con parámetros de consulta.
- la plataforma ya limita la fuga de referencias con encabezados de respuesta más estrictos y un comportamiento de acceso con alcance

Si esto se convierte en una preocupación de mayor prioridad, el seguimiento probable sería un flujo de intercambio de tokens único que elimine el token sin procesar de la URL visible después de la primera carga.

---

### SEC-007: Eliminar la superficie del webhook del carrito alojado heredado (✅ CORREGIDO)

**Archivo:** `worker/src/index.js`

Worker ya no expone la ruta del webhook de pago de terceros eliminada, lo que elimina una superficie de devolución de llamada innecesaria que el flujo en vivo ya no necesita.

---

### SEC-009: Validación de entrada más estricta en votos (✅ FIJADO)

**Archivo:** `worker/src/routes/votes.js`, `worker/src/validation.js`

Los puntos finales de votación ahora validan:
- ID de decisión: máximo 100 caracteres, solo alfanuméricos + guiones
- Opciones de votación: máximo 50 caracteres
- Máximo 20 ID de decisión por solicitud

```javascript
// Validation rules
const MAX_VOTE_OPTION_LENGTH = 50;
const MAX_DECISION_ID_LENGTH = 100;
const VALID_SLUG_REGEX = /^[a-z0-9-]+$/;

// Validated before processing
if (!isValidDecisionId(decisionId)) {
  return jsonResponse({ error: 'Invalid decision ID format' }, 400, env);
}

if (!isValidVoteOption(option)) {
  return jsonResponse({ error: 'Invalid vote option format' }, 400, env);
}
```

---

### SEC-011: Validación de entrada al inicio del pago (✅ FIJO)

**Archivo:** `worker/src/index.js`, `worker/src/validation.js`

La ruta `/checkout-intent/start` ahora valida:
- Slugs de campaña: máximo 100 caracteres, solo alfanuméricos + guiones (evita la inyección/recorrido)
- Direcciones de correo electrónico: formato compatible con RFC, máximo 254 caracteres
- ID y cantidades de artículos del carrito
- Soporte/entradas de cantidades personalizadas a través de la reconstrucción de contribuciones canónicas

```javascript
if (!isValidSlug(campaignSlug)) {
  return jsonResponse({ error: 'Invalid campaign slug format' }, 400);
}

if (email && !isValidEmail(email)) {
  return jsonResponse({ error: 'Invalid email format' }, 400);
}

if (!parsedCart.valid) {
  return jsonResponse({ error: parsedCart.error }, 400);
}
```

---

### SEC-012: Encabezados de respuesta de seguridad (✅ CORREGIDO)

**Archivo:** `worker/src/validation.js`

Todas las respuestas de API ahora incluyen encabezados de seguridad:

```javascript
const SECURITY_HEADERS = {
  'X-Content-Type-Options': 'nosniff',     // Prevents MIME-type sniffing
  'X-Frame-Options': 'DENY',                // Prevents clickjacking
  'X-XSS-Protection': '1; mode=block',      // Legacy XSS protection
  'Referrer-Policy': 'strict-origin-when-cross-origin'  // Limits referer leakage
};
```

---

### SEC-013: Normalización de entradas almacenadas en el panel de administración (✅ CORREGIDO)

**Archivo:** `worker/src/index.js`

El panel de administración ahora valida cada escritura en el panel respaldada por GitHub y KV a través de ayudas de normalización de administración compartidas antes de la persistencia.

Rutas de escritura cubiertas:
- `/admin/settings/preview` y `/admin/settings/publish`
- `/admin/content/preview` y `/admin/content/publish`
- `/admin/settings/logo-upload`, `/admin/settings/image-upload`, `/admin/settings/audio-upload` y `/admin/settings/video-upload`
- `/admin/users`
- `/admin/campaigns/create`, `/admin/campaigns/archive` y `/admin/campaign-preview/publish`
- `/admin/marketing/referrals`
- `/admin/marketing/announcement`

El refuerzo rechaza primitivas XSS almacenadas, como `<script>` sin formato, atributos de controlador de eventos, enlaces de Markdown inseguros, enlaces de Markdown relativos a los padres, URL `javascript:`/`data:`, inyección de declaración/función CSS y rutas de activos inseguras. También rechaza la asignación masiva de configuraciones para filas exclusivas del panel y normaliza matrices estructuradas para complementos de plataforma, complementos de campaña, niveles, elementos de soporte, entradas de diario, objetivos ambiciosos, elementos en curso y decisiones. Las cargas de medios tienen un alcance de función, un tipo de contenido incluido en una lista permitida, un tamaño limitado y se escriben únicamente en directorios de activos del panel canónico. La representación de correo electrónico de Blast incluye solo rutas de imágenes alojadas en el sitio y enlaces de video seguros para correo electrónico en lugar de enlaces de imágenes remotas arbitrarias o incrustaciones de iframe.

El panel del navegador también tiene un refuerzo de defensa en profundidad alrededor del shell de edición: el meta CSP de la página de administración evita scripts en línea, limita las conexiones Worker/API y mantiene las vistas previas del contenido en iframes aislados. Las implementaciones deben agregar protección de marcos a través de encabezados HTTP, como `Content-Security-Policy: frame-ancestors 'none'` o `X-Frame-Options: DENY`, porque el meta CSP no puede hacer cumplir esa directiva. Las cargas útiles de correo electrónico Magic-link eliminan los caracteres CRLF/de control de los valores de encabezado configurables antes de llamar a Resend para que los nombres de las plataformas o la configuración del remitente no puedan crear cargas útiles de inyección de encabezado.

---

## Lista de verificación de secretos

Antes de implementar en producción, verifique que estos secretos estén configurados:

La configuración específica del pago está documentada en [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/). La configuración específica del correo electrónico está documentada en [EMAIL.md](/es/docs/operations/email-system/).

|Secreto|Variable de entorno|Longitud mínima|
|--------|---------------------|------------|
|Clave API de banda|`STRIPE_SECRET_KEY_LIVE`|N/A|
|Secreto del webhook de Stripe|`STRIPE_WEBHOOK_SECRET_LIVE`|32+ caracteres|
|Secreto de intención de pago|`CHECKOUT_INTENT_SECRET`|32+ caracteres|
|Secreto del enlace mágico|`MAGIC_LINK_SECRET`|32+ caracteres|
|Secreto del token de recordatorio de lanzamiento|Reserva `LAUNCH_REMINDER_TOKEN_SECRET` o `MAGIC_LINK_SECRET`|32+ caracteres|
|Secreto del token de pago abandonado|Reserva `ABANDONED_CART_TOKEN_SECRET` o `MAGIC_LINK_SECRET` para enlaces de recordatorio para cancelar/reanudar suscripción|32+ caracteres|
|Secreto de sesión de administrador|`ADMIN_SESSION_SECRET`|32+ caracteres|
|Secreto de administrador|`ADMIN_SECRET`|32+ caracteres|
|Secreto de administración de liquidación|`ADMIN_SETTLEMENT_SECRET` (opcional, con alcance)|32+ caracteres|
|Secreto de administrador de transmisión|`ADMIN_BROADCAST_SECRET` (opcional, con alcance)|32+ caracteres|
|Secreto del torniquete|`TURNSTILE_SECRET_KEY`, `ADMIN_TURNSTILE_SECRET_KEY` o `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY`|N/A|
|Clave API Resend|`RESEND_API_KEY`|N/A|
|Token de análisis de uso de Cloudflare|`CLOUDFLARE_USAGE_API_TOKEN` o `CLOUDFLARE_ANALYTICS_API_TOKEN`|Lectura de análisis GraphQL; Lectura de facturación opcional para detección de planes|

Cuando GitHub Actions o un script de operador llaman a puntos finales de administración protegidos, agregue solo el secreto coincidente necesario a los secretos del repositorio de GitHub. El flujo de trabajo de implementación predeterminado utiliza `ADMIN_BROADCAST_SECRET` para la verificación del diario posterior a la implementación cuando está configurado; La futura automatización de liquidaciones debería utilizar `ADMIN_SETTLEMENT_SECRET` en lugar del secreto alternativo más amplio.

Generar secretos seguros:
```bash
openssl rand -base64 32
```

---

## Pruebas de penetración

Consulte [tests/security/README.md](/es/docs/operations/security-test-suite/) para conocer el conjunto de pruebas de penetración.

Para una revisión de abuso de productos, combine el paquete de seguridad con la lista de verificación de riesgos éticos. Red Team al menos un escenario de operador malicioso o descuidado para cualquier función que pueda enviar mensajes, cambiar dinero, exponer datos, publicar contenido público o alterar permisos de administrador.

Ejecute pruebas de seguridad:
```bash
npm run test:secrets            # Audit local secret exposure in files + history
npm run test:security           # Against local Worker
npm run test:security:staging   # Against a staging worker, if you maintain one
npm audit --omit=dev --audit-level=moderate
npm audit --audit-level=moderate
```

`npm run test:premerge` ahora incluye la auditoría secreta automáticamente, por lo que la activación de combinación local verifica tanto el comportamiento de seguridad como la exposición accidental de credenciales.

Para ejecuciones locales, mantenga configurado `CHECKOUT_INTENT_SECRET` si desea que la suite de inicio de pago y pago del trabajador en vivo ejerza la ruta de firma propia real.

---

## Respuesta a incidentes

### Aporte de token

Si un token de enlace mágico está comprometido:
1. El token está vinculado a un ID de pedido/correo electrónico/campaña específico.
2. Sólo puede acceder/modificar ese pedido autorizado.
3. Para invalidar: elimine el aporte de KV (`GET /pledge` luego devolverá `404` para ese token)
4. Opcionalmente: regenerar MAGIC_LINK_SECRET (invalida TODOS los tokens)

### Sesión de administración o aporte secreto

1. Gire inmediatamente `ADMIN_SESSION_SECRET` y `ADMIN_SECRET` a través de `wrangler secret put`
2. Borrar claves `admin-session:*` activas del espacio de nombres Worker KV
3. Revise los eventos `admin-audit:*` y las confirmaciones de GitHub para detectar acciones administrativas no autorizadas
4. Vuelva a verificar las estadísticas de la campaña, los datos de los aportes, la configuración y los alcances de los usuarios administradores.

### Aporte secreto de Stripe Webhook

1. Gire el secreto del webhook en Stripe Dashboard → Webhooks
2. Actualizar `STRIPE_WEBHOOK_SECRET_*` en Worker
3. Verifique si hay aportes sospechosas creadas durante la ventana de exposición

### Webhook de Stripe perdido (Desarrollo)

Si el paso de pago en el sitio se completa pero el aporte aún no aparece (común en desarrolladores locales cuando el reenvío del webhook se retrasa o no funciona):

1. Verifique la salida de Stripe CLI para conocer el estado de entrega del webhook
2. El cliente primero intentará `/checkout-intent/complete` automáticamente para la recuperación local, pero si el aporte aún no aparece, use el punto final de recuperación del administrador para crearlo manualmente:
   ```bash
   curl -X POST http://localhost:8787/admin/recover-checkout \
     -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
     -H 'Content-Type: application/json' \
     -d '{"sessionId": "cs_test_..."}'
   ```
3. El punto final obtiene la sesión de pago de Stripe y crea el aporte si no existe.

Consulte [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) para obtener el runbook de reconciliación y recuperación de webhooks más completo.

**Prevención:**
- Utilice `scripts/dev.sh` que ejecuta el trabajador con simulación KV local
- `scripts/dev.sh` inicia un único oyente Stripe, reenvía eventos a `127.0.0.1:8787/webhooks/stripe`, escribe el secreto `whsec_...` de ese mismo oyente en `worker/.dev.vars` y borra los procesos locales obsoletos en los puertos de desarrollo estándar antes del inicio.
- Si inicia Stripe manualmente, use la misma instancia de escucha para reenviar y para el secreto que copia en la configuración local.
- `./scripts/dev.sh --podman` es la forma más fácil de mantener el límite de producción del sitio local/trabajador sin depender de la configuración del host Ruby/Wrangler.
- Para realizar pruebas con datos inicializados, ejecute `./scripts/seed-all-campaigns.sh` después de iniciar el trabajador.

---

## Contactos de seguridad

- **Seguridad de Stripe:** [stripe.com/docs/security](https://stripe.com/docs/security)
- **Estado de Cloudflare:** [cloudflarestatus.com](https://www.cloudflarestatus.com)

---
