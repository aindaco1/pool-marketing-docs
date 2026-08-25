---
title: Guía de seguridad
parent: Operaciones
nav_order: 8
render_with_liquid: false
lang: es
---

# Guía de seguridad

## Última actualización

25 de agosto de 2026

Este documento cubre la arquitectura de seguridad, los riesgos conocidos, las medidas de refuerzo aplicadas, las compensaciones aceptadas y los procedimientos de prueba de penetración para la plataforma de financiación colectiva The Pool. Los límites de copia de seguridad cifrada, el estado de límite de velocidad/sesión en cuarentena, el manejo fuera del dispositivo y las aprobaciones de restauración de producción se definen en [BACKUP_RESTORE.md](/es/docs/operations/backup-restore/).

Úselo junto con [ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/) cuando un cambio genere un nuevo uso de datos, mensajes de apoyo, poder administrativo, intercambio público, automatización o presión de participación. La revisión de seguridad cubre no solo el aporte de credenciales y la inyección de código, sino también el uso indebido realista por parte de spammers, acosadores, estafadores, administradores descuidados y flujos de trabajo de crecimiento demasiado agresivos.

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
|**Puente de beneficios de podcast**|Eventos de concesión/revocación de The Pool salientes|Firma HMAC-SHA256 dedicada sobre `{timestamp}.{exact body}`, validación exacta de punto final, ventana de actualización del receptor de cinco minutos, ID de eventos estables y un interruptor de apagado The Pool deshabilitado de forma predeterminada.|
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

La escasa reserva de nivel limitado y la verdad del recuento comprometido residen en el coordinador Durable Object por campaña en lugar de en KV, mientras que KV mantiene solo la proyección pública `tier-inventory:{slug}`.

La serialización de liquidaciones también está respaldada por objetos duraderos. El enlace `SETTLEMENT_COORDINATOR` posee un bloqueo de corta duración por slug de campaña, por lo que los puntos finales de liquidación programada, liquidación directa, envío y lote no pueden cobrar la misma campaña al mismo tiempo. Los carritos de campañas múltiples aún funcionan porque la persistencia del proceso de pago crea registros de aporte separados con alcance de campaña y los bloqueos de liquidación dependen de la campaña que se cobra.

---


## Notas de endurecimiento aplicado

### Revisión de abuso y uso indebido ético

Los casos de abuso de mayor impacto de The Pool a menudo cruzan los límites del producto, la seguridad, la privacidad y la confianza. Ejecute la [revisión de riesgos éticos](/es/docs/development/ethical-risk-review/) antes de enviar las funciones que cambian:

- visibilidad pública, incrustaciones, vistas previas sociales, metadatos SEO, enlaces de referencia o códigos QR
- correo electrónico de patrocinadores, recordatorios, Blast, transmisiones de diarios/hitos, invitaciones de vista previa o entrega de informes
- totales de pago, propinas, impuestos, envío, escasez de inventario, liquidación o modificación de aporte
- roles de administrador, alcance de la campaña, vistas previas protegidas, creación/archivo de campañas, carga de medios o publicación respaldada por GitHub
- análisis, uso del plan del proveedor, exportaciones, copias de seguridad, comportamiento de restauración o nuevos flujos de datos de terceros

La aprobación de seguridad responde siempre a las mismas preguntas prácticas:

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

### Protección de solicitudes de tiempo de ejecución

El límite de solicitud Worker actual tiene estas propiedades obligatorias:

- Las rutas `/test/*` devuelven `404` fuera de `APP_MODE=test`; voto de desarrollo
Los tokens se aceptan solo en modo de prueba.
- Las lecturas agregadas públicas pueden utilizar CORS comodín. Acreditado, pago, administrador,
y otras respuestas protegidas utilizan el origen del sitio configurado normalizado.
- Las respuestas JSON compartidas incluyen `X-Content-Type-Options: nosniff`,
`X-Frame-Options: DENY`, la compatibilidad heredada de `X-XSS-Protection`
encabezado y `Referrer-Policy: strict-origin-when-cross-origin`.
- Arranque de pago, finalización de pago, método de pago, administrador, vista previa y
otras respuestas específicas de pedidos utilizan la política privada/sin tienda cuando corresponda.
Los POST de métodos de pago y pago entre sitios no superan las comprobaciones de origen.
- Los analizadores de solicitudes imponen límites de tamaño corporal antes que los costosos JSON, Stripe o KV
trabajo. Slugs, correos electrónicos, identificadores/opciones de voto, cantidades de centavos enteros, administración
campos, valores de catálogo, rutas de medios, URL y colecciones estructuradas son
normalizado y acotado en el límite Worker.
- La ruta del webhook del carrito alojado eliminada está ausente. El pago propio y
El webhook Stripe firmado son las únicas rutas de ingreso de pago admitidas.
- Los tokens de portador comunitario permanecen en el almacenamiento de la sesión; un aporte de respaldo faltante
devuelve `404` incluso cuando una firma de enlace mágico es válida.
- Las reclamaciones de nivel escaso y la serialización de acuerdos utilizan su campaña
Coordinadores Durable Object. KV expone proyecciones, no sensibles a la raza
autoridad.
- El catálogo de complementos y los precios históricos permanecen dentro del canónico Worker
El límite de cantidad y los precios enviados por el navegador no son autorizados.
- Los recordatorios de pago abandonado requieren consentimiento explícito, firmado
Enlaces para cancelar suscripción/reanudar, retención limitada, deduplicación e índice de campaña
controles antes de la entrega.

### Comportamiento de falla del webhook Stripe

El Worker comprueba el modo de evento antes de aplicar un webhook Stripe. Un secreto perdido
para el modo seleccionado se reconoce con un resultado omitido, por lo que Stripe no
Vuelva a intentarlo indefinidamente, pero el evento no se analiza en estado de aporte ni
aplicado. Las firmas no válidas devuelven `401`. La postura de producción trata una falta
El secreto del webhook en vivo es un defecto de implementación.

El procesamiento de webhooks utiliza un contrato de arrendamiento, marcadores procesados, tamaño corporal limitado,
observabilidad redactada y operaciones de pago idempotentes. Aporte canónica
El estado no retrocede cuando falla un correo electrónico u otro efecto secundario de notificación.

### Límites de tarifas y controles de denegación de billetera

Se requiere `RATELIMIT`. Un enlace faltante o no disponible falla al cerrarse con
`503`; Las solicitudes bloqueadas repetidas en la misma ventana no reescriben lo mismo.
contador.

|Clase de punto final|Límite|ventana|Llave|
| --- | ---: | ---: | --- |
|inicio de pago|40|60 segundos|IP|
|Cotización de envío|90|60 segundos|IP|
|cotización de impuestos|90|60 segundos|IP|
|Finalización del pago|12|60 segundos|Orden|
|Abandono de pago|12|60 segundos|Orden|
|Iniciar registro de recordatorio|5|60 segundos|IP|
|Administrar lecturas de aporte|120|60 segundos|IP|
|Gestionar escrituras de aporte|30|60 segundos|IP|
|Voto lee/escribe|45|60 segundos|IP|
|Operaciones de administración|5|60 segundos|IP|
|Adaptador de resumen de película Stripe|30|60 segundos|IP|

Las lecturas públicas `/live/:slug`, `/stats/:slug` y `/inventory/:slug` permanecen
sin límite para el tráfico legítimo de la campaña. Los webhooks Stripe se basan en la firma
verificación, idempotencia y límites corporales en lugar de un límite estricto de IP compartida.
El Workers estándar/pago implementado también declara `limits.cpu_ms = 100` como
techo de denegación de cartera; el desarrollo local no hace cumplir eso Cloudflare
límite.

Utilice `GET /admin/observability/webhooks`,
`GET /admin/observability/performance`, y
[`scripts/check-observability.sh`](https://github.com/your-org/your-project/blob/main/scripts/check-observability.sh) para revisar
resúmenes de entrega y tiempos limitados sin exponer cargas útiles de solicitudes sin procesar.

### Comparación y alcance de credenciales

Valores de portador de administrador, secretos de administrador con alcance, tokens CSRF, firmas de pago,
las firmas de enlace mágico y los hashes de ejecución en seco utilizan ayudas de comparación seguras en el tiempo.
Las credenciales de administrador que faltan fallan al cerrarse. Acuerdo de alcance, transmisión y
Las rutas de mantenimiento prefieren su credencial dedicada y rechazan la más amplia.
reserva cuando se configura el secreto de ámbito.

### Seguridad de dependencia y liberación

Tanto `npm audit --omit=dev --audit-level=moderate` como el completo
`npm audit --audit-level=moderate` son comprobaciones de liberación. Hallazgos de producción
liberación del bloque. Los hallazgos exclusivos para desarrolladores en las herramientas de compilación o lanzamiento requieren eliminación, una
pasador limpio y compatible o un registro de aceptación con alcance explícito. la corriente
El pin del faro se registra en el archivo de bloqueo; el registro de cambios y la evidencia de publicación,
no en esta guía, conserve el historial de resolución específico de la versión.

### Riesgos aceptados

Se siguen aceptando dos compensaciones de baja gravedad:

- Los enlaces mágicos caducan después de 90 días para que los patrocinadores sin cuenta puedan regresar
cronogramas de campaña prolongados. Cada enlace tiene como alcance un pedido y requiere una
aporte de respaldo.
- La entrada Magic-link utiliza un parámetro de consulta. Comportamiento estricto del referente, ruta
el alcance, la política de caché privada y la exclusión de la indexación/búsqueda previa reducen
riesgo de fuga.

Los enlaces potenciales de menor duración y el intercambio único de tokens de URL se rastrean en
la [Hoja de ruta](/es/docs/reference/roadmap/).


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
|The Pool–El secreto del puente del podcast|`POOL_PODCAST_BRIDGE_SECRET` (obligatorio solo cuando los beneficios de Podcast están habilitados)|32+ caracteres|
|Secreto del torniquete|`TURNSTILE_SECRET_KEY`, `ADMIN_TURNSTILE_SECRET_KEY` o `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY`|N/A|
|Clave API Resend|`RESEND_API_KEY`|N/A|
|Token de análisis de uso de Cloudflare|`CLOUDFLARE_USAGE_API_TOKEN` o `CLOUDFLARE_ANALYTICS_API_TOKEN`|Lectura de análisis GraphQL; Lectura de facturación opcional para detección de planes|

Cuando las acciones GitHub o un script de operador llaman a puntos finales de administración protegidos, agregue solo el secreto coincidente necesario a los secretos del repositorio GitHub. El flujo de trabajo de implementación predeterminado utiliza `ADMIN_BROADCAST_SECRET` para la verificación del diario posterior a la implementación cuando se configura. La automatización de la liquidación utiliza `ADMIN_SETTLEMENT_SECRET` en lugar del secreto alternativo más amplio.

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

`npm run test:premerge` incluye la auditoría secreta, por lo que la activación de combinación local verifica tanto el comportamiento de seguridad como la exposición accidental de credenciales.
El comando es un adaptador de política delgado The Pool sobre el escáner Dust Wave compartido:
conserva el `worker/.dev.vars` ignorado y las reglas de accesorios de prueba, escanea
formularios de credenciales rastreados más valores locales exactos en el árbol de trabajo/historial, y
nunca imprime ni enmascara parcialmente un valor coincidente.

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
