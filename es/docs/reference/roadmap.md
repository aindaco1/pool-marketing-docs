---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

1 de julio de 2026

## Hito actual

**v1.0.8**

El hito v1.0.8 porta el hardening de runtime derivado de Store que encaja con este proyecto, mantiene las lecturas de Marketing diferidas y autenticadas, recuerda el contexto de pestañas/subpestañas del panel de administración en estado local del navegador, agrega verificaciones de completitud de locales para mantener alineados los catálogos de traducción compatibles y lleva el patrón de auditoría SEO del sitio generado de Store a la puerta de merge de Pool.

## Terminado

**Vistas previas de campañas protegidas y creación de nuevas campañas**

- [x] Páginas de vista previa protegidas
  - Las páginas de vista previa se encuentran en `/campaigns/:slug/preview/` y equivalentes localizados, pero permanecen en `noindex,nofollow,noarchive`, referencia de origen estricto con alcance para medios integrados, sin almacenamiento, salida de mapa de sitio público externo y excluida de la captación previa de intención pública.
  - Los superadministradores autenticados y los usuarios de campaña asignados pueden obtener cargas útiles de vista previa a través de la sesión de administración existente y las comprobaciones del alcance de la campaña.
  - Los administradores de publicaciones reciben un enlace de vista previa firmado visible en el panel de control, los correos electrónicos de revisores invitados explícitamente reciben enlaces de vista previa firmados que caducan en 24 horas y la copia del correo electrónico lo dice claramente.
  - El acceso a la vista previa valida el tipo de token, la caducidad, el slug de campaña y el correo electrónico permitido con una lista permitida de KV de trabajador `campaign-preview-reviewers:<slug>` de 24 horas en lugar de almacenar listas de revisores en la portada de campaña respaldada por GitHub o en JSON de campaña pública.
  - Las campañas nuevas/solo de vista previa permanecen invisibles en `/campaigns/:slug/` públicas, listas de páginas de inicio, páginas de campañas localizadas, páginas comunitarias, `/api/campaigns.json`, catálogos complementarios, tarjetas para compartir y resultados de mapas del sitio hasta su lanzamiento.
- [x] Creación de nueva campaña
  - Los superadministradores pueden crear una campaña de solo vista previa desde el panel de Campañas con solo un título obligatorio.
  - Opcionalmente, el flujo puede asignar uno o más usuarios de campaña existentes y, opcionalmente, crear uno o más usuarios de campaña nuevos con los nombres y correos electrónicos requeridos.
  - La fuente de la campaña se crea localmente en desarrollo o a través de la ruta de publicación `_campaigns/<slug>.md` existente respaldada por GitHub en producción, la reconstrucción normal se activa cuando los usuarios nuevos/asignados respaldados por GitHub se guardan en `admin-users:v1` y se registra un evento de auditoría de administrador.
  - Los usuarios de campaña asignados reciben correos electrónicos de reenvío con el enlace del panel de administración cuando se asignan usuarios
- [x] Archivado de campañas
  - La subpestaña Campañas -> Configuración muestra Archivar campaña debajo de los campos en segundo plano solo para superadministradores cuando la campaña no está activa actualmente.
  - El trabajador valida el rol, CSRF, la existencia de la campaña y el estado efectivo, luego archiva localmente en desarrollo o envía `.github/workflows/archive-campaign.yml` en producción.
  - La medida de archivo mantiene la fuente de la campaña y los medios propiedad de la campaña en `archive/campaigns/<slug>/`, escribe un manifiesto de archivo y deja los medios a los que todavía hacen referencia otras campañas activas en su lugar.
- [x] Publicar protección contra conflictos
  - El contenido de la campaña y las publicaciones preliminares incluyen una revisión base/SHA del archivo GitHub cuando esté disponible
  - Las publicaciones obsoletas se rechazan con una respuesta de conflicto específica para que los borradores locales del navegador permanezcan intactos y los usuarios puedan recargar antes de publicar.

**Análisis y operaciones del panel de administración**

- [x] Análisis de ingresos brutos y netos
  - Los ingresos de la campaña y los ingresos de la plataforma siguen siendo totales brutos de la categoría, mientras que las columnas netas de tarjetas/tabla restan la participación de las tarifas de procesador asignadas a cada categoría.
  - Los cargos exitosos del partidario almacenan la tarifa de transacción de saldo de Stripe, ID de transacción neta, bruta, de cargo y de saldo cuando estén disponibles
  - Analytics utiliza valores de tarifas de Stripe reales almacenados para promesas cobradas y el modelo de tarifa estimada existente para promesas activas o registros cobrados más antiguos sin datos de saldo de Stripe.
  - Una ruta de reabastecimiento protegida por CSRF, solo para superadministradores, recupera datos históricos de transacciones de saldo de Stripe de los índices de promesas de campaña sin escaneos de listas KV.
  - Las etiquetas de tarjetas y tablas mantienen los valores brutos y netos distintos para la conciliación
- [x] Rastreador de uso del plan
  - Los superadministradores pueden cargar Cloudflare Workers/KV y reenviar el uso de cuota desde Configuración -> Planificar uso automáticamente cuando se abre la sección
  - El rastreador muestra nombres de planes, barras de progreso, texto `used of limit`, umbrales críticos/de advertencia y enlaces de administración de planes.
  - Los tokens API del proveedor permanecen en el lado del servidor; el navegador recibe solo métricas de uso desinfectadas y mensajes de estado
  - Las cargas tienen un alcance de actualización de página y son de solo lectura, sin escrituras de KV ni operaciones de lista.

**Base de plataforma**

- [x] Branding y andamiaje i18n
  - La marca de la plataforma Pool / Dust Wave
  - complemento de formato de dinero
  - ayuda de traducción, `en.yml` y plantillas de ejemplo
- [x] Automatización y backend de los trabajadores
  - Almacenamiento de promesas, estadísticas, inventario, correos electrónicos, liquidación automática, cobro agregado a los seguidores y transiciones automáticas de estado de campaña.
  - El estado de la campaña, las cuentas regresivas del navegador, las fechas límite de los trabajadores, los informes programados, las comprobaciones de liquidación y las superficies de fecha y hora del administrador comparten el mismo modelo `platform.timezone` / `PLATFORM_TIMEZONE`.
  - el programador Worker de nivel minuto persiste `cron:lastRun` cada hora en lugar de cada minuto, manteniendo visible el estado del cron sin la rotación de escritura KV de nivel libre de referencia.
- [x] Desarrollo local de Podman
  - `./scripts/dev.sh --podman`, dramaturgo sin cabeza en contenedores, ayudantes de informes/humo compatibles con Podman, `podman:doctor` y `podman:self-check`
  - El desarrollo de host y Podman Worker utiliza Node 24 para coincidir con las implementaciones de GitHub Actions y evitar la ruta obsoleta de Node 20 Wrangler.
  - El desarrollo local de Wrangler 4 se ejecuta según la fecha de compatibilidad de Worker `2026-05-03`, lo que evita el antiguo fallo del polyfill en tiempo de ejecución local en el Nodo 24.
  - La configuración de dependencia de Podman Worker utiliza `npm ci` para que los inicios de contenedores locales no muten `worker/package-lock.json`
  - El optimizador de medios Podman incluye `optipng` y `gifsicle` para la compresión de fuentes PNG/GIF locales a través del mismo flujo de trabajo de medios del repositorio.
- [x] Configurar e implementar ayuda
  - `npm run setup:deploy` / `scripts/setup-deploy.mjs` se envía como una CLI de nodo libre de dependencias para configuración local, simulacros de producción, sincronización de configuración, creación/actualización de Cloudflare KV, escrituras de secretos de trabajo, escrituras de secretos de repositorio de GitHub, ayudantes de autenticación para `gh`/`wrangler`/CLI de Stripe opcional y `wrangler deploy` opcional.
  - El asistente mantiene en mente la idempotencia de la configuración de producción y la confirmación del operador, al mismo tiempo que evita la complejidad del contenedor de aplicaciones hasta que el flujo de trabajo basado en el script sea estable.
  - La configuración de producción ahora detecta y reutiliza los enlaces/recursos de espacios de nombres existentes de Cloudflare KV antes de planificar la creación, incluida la salida de prueba que distingue la reutilización de la creación.
  - Las comprobaciones de preparación de solo lectura pueden llamar a las API de proveedores de Cloudflare, GitHub, Stripe, Resend, Turnstile, USPS y ZIP.TAX en vivo durante la configuración/ejecuciones de prueba, con `--skip-readiness` disponible cuando los operadores necesitan una verificación local más específica.
  - Las pruebas de subproceso auxiliar de configuración ejercitan la ejecución en seco, la generación de secretos locales de repositorio temporal, la planificación de creación/reutilización de KV de producción, las escrituras de secretos de trabajo generadas y las pruebas de preparación con CLI de proveedores falsos para que la cobertura no dependa de las credenciales activas.

**Campaña y experiencia pública**

- [x] Presentación de la página de la campaña
  - clasificación de campaña
  - tarjetas de campaña uniformes con vista previa del nivel destacado
  - diseño de campaña de dos columnas
  - imagen principal / imagen ancha / variantes de video
  - pre-renderizado de cuenta regresiva
  - imágenes de nivel e imágenes de creador
  - Las barras de progreso de la campaña y los marcadores de hitos representan clases estáticas de ancho/posición, por lo que la primera carga ya no espera a JavaScript para evitar diseños de marcadores colapsados.
  - La generación de imágenes responsivas incluye un renglón WebP `640w` entre las variantes `480w` y `960w` existentes para páginas de campañas móviles.
  - Los videos de los héroes de la campaña de YouTube muestran fachadas de carteles/juegos locales y posponen el iframe remoto hasta que el partidario tenga la intención de jugar.
- [x] Financiamiento y características comunitarias
  - Fases de producción con elementos registrales.
  - decisiones comunitarias/votación
  - diario de producción
  - financiación continua
  - niveles con objetivos extendidos y animaciones de desbloqueo
  - Lanzamiento de la producción de Hand Relations
- [x] Recordatorios de lanzamiento
  - Las próximas páginas de la campaña pueden recopilar registros de recordatorio de lanzamiento únicos a través de un formulario localizado delgado con Turnstile, limitación de velocidad, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados y trabajos de envío limitados.
  - La entrega de recordatorio de lanzamiento reutiliza el módulo de correo electrónico de reenvío existente, la configuración del remitente, el catálogo de configuración regional y el ritmo en lugar de agregar una segunda integración de correo electrónico.
  - Las colas de reintento de envío de recordatorios de lanzamiento y confirmación de soporte mantienen pequeños marcadores de estado de cola para que los ticks programados inactivos omitan los escaneos de la lista de espacios de nombres KV, con comprobaciones de compatibilidad cada hora para trabajos heredados insertados manualmente.
  - `_config.local.yml` puede borrar la clave del sitio Turnstile de recordatorio para que el desarrollo local oculte el widget de manera coherente con el inicio de sesión del administrador local.

**Gestión de donaciones y patrocinadores**

- [x] Gestión de seguidores sin cuenta
  - arquitectura de enlace mágico
  - promesa exitosa / páginas canceladas
  - Panel de control `/manage/`
  - acceso `/community/:slug/` solo para seguidores con tokens de colaborador con ámbito de sesión
  - seguimiento del historial de promesas
- [x] Promesas flexibles
  - artículos de soporte y cantidades personalizadas que fluyen carrito → Trabajador → KV → estadísticas
  - seguimiento de estadísticas de elementos de soporte en vivo
  - soporte de compromiso de varios niveles a través de `additionalTiers`
  - soporte de niveles no apilables
  - post/live Administrar reglas de visualización de elementos de soporte de compromiso
- [x] Envío de recompensa física
  - detección propia de elementos físicos
  - envío de nivel físico
  - pago con autocompletar y soporte para dirección de envío
- [x] Recordatorios de pago abandonado
  - Los recordatorios de pago abandonado recopilan una suscripción explícita de un solo recordatorio, se ponen en cola solo después de que la creación de la sesión de Stripe propia sea exitosa, se eliminan cuando se completa la persistencia del compromiso, suprimen las audiencias duplicadas o no firmadas y se envían a través del módulo de correo electrónico de reenvío compartido.
  - Los enlaces de recordatorio firmados restauran un borrador de pago del navegador desinfectado para el mismo contexto de carrito/contacto abandonado e inician una nueva sesión de Stripe sin colocar secretos de Stripe en las URL.
  - La programación utiliza `abandoned-cart-queue:v1`, límites de retención, marcadores de envío/supresión y lotes limitados para que los cronómetros inactivos eviten escaneos de listas KV
  - Los administradores de campañas pueden ver el estado de los recordatorios de pago abandonado en el ámbito de la campaña desde los contadores agregados de colas/resultados sin enumerar los espacios de nombres KV, y las filas de supresión creadas por el administrador muestran el correo electrónico suprimido para que se puedan borrar de la tabla.
  - Los controles de supresión en el ámbito de la campaña son mutaciones administrativas explícitas con CSRF, eventos de auditoría, identificadores de correo electrónico con hash y ninguna acción de carrito abandonado específica de reintento.

**Pagos, inventario e informes**

- [x] Pago de Stripe y actualizaciones de tarjetas
  - Paso de pago nativo de Stripe en el sitio en el segundo sidecar de pago
  - `Update Card` usando el mismo patrón seguro
  - Cobertura E2E de pago totalmente automatizado
  - manejo de actualización de inventario/estadísticas en vivo posteriores a la persistencia
  - Reforzamiento del proceso de compra en torno al almacenamiento, el almacenamiento en caché, las comprobaciones de origen y los reintentos de recuperación.
- [x] Inventario y contabilidad de campañas
  - API de estadísticas en vivo
  - seguimiento de inventario de nivel limitado
  - Protección contra sobreventa duradera respaldada por objetos para niveles escasos
  - soporte de recálculo de estadísticas para `additionalTiers`
  - El inventario complementario de la plataforma utiliza una proyección duradera de recuento de ventas que crea, modifica y cancela la actualización de rutas de compromiso, por lo que las lecturas normales del inventario ya no reconstruyen los recuentos de ventas enumerando todos los compromisos después del arranque.
- [x] Correos electrónicos e informes de seguidores
  - notificaciones de hitos
  - Correos electrónicos con información sobre propinas con desgloses completos de subtotales, propinas, impuestos y envío.
  - Informes de promesas estilo libro mayor y exportaciones CSV de cumplimiento
  - envío incluido en el informe
  - Las transmisiones automáticas del diario utilizan ID de entrada estables para que las entradas del diario editadas no se reenvíen como nuevas actualizaciones.
- [x] Herramientas de integridad de proyección
  - comprobaciones de deriva de solo lectura para el estado de proyección por campaña y para todas las campañas
  - Envoltorio del operador `./scripts/check-projections.sh` para comprobaciones locales y respaldadas por Podman
  - La cobertura de humo de promesa mutable verifica que las campañas mantengan la proyección limpia después de la configuración, modificación y cancelación.
  - Orientación más clara para el operador sobre la desviación de la proyección frente a las diferencias entre los informes del estado actual y del libro mayor.
- [x] Productos complementarios
  - Los complementos de la plataforma admiten el primer catálogo de productos de Dust Wave (`DUST WAVE T-Shirt`, `DUST WAVE Sticker` y `DUST WAVE Butterfingers T-Shirt`), precios fijos, variantes simples, inventario, umbrales de existencias bajas, filtrado de productos agotados y tarjetas de productos compartidas.
  - Las campañas pueden definir `campaign_add_ons` al principio; El carrito y Administrar compromiso los muestran con los mismos patrones de tarjetas adicionales en una sección propiedad de la campaña.
  - Los carritos de campañas múltiples utilizan un modelo de campaña ancla y al eliminar un compromiso de campaña también se eliminan los complementos de campaña vinculados a esa campaña.
  - Los complementos de la campaña cuentan para el subtotal y el objetivo de la campaña propietaria, heredan las reglas de envío de esa campaña y se distinguen de los complementos de la plataforma en los informes y la propiedad de cumplimiento.
  - Los complementos de la plataforma utilizan una contabilidad separada de ingresos y cumplimiento de la plataforma, incluido un cargo de envío físico/envío separado para los complementos globales.
  - El accesorio Smoke Editable cubre complementos de campaña importados desde su tienda de productos para cobertura de navegador, envío y informes.
- [x] Opciones de envío y entrega
  - La calificación nacional/internacional respaldada por USPS reemplazó el antiguo modelo de tarifa física plana, con envío alternativo de implementación, anulaciones de campaña opcionales y controles de envío gratuito de implementación/campaña.
  - Los niveles físicos y los elementos de soporte definen metadatos de envío con ajustes preestablecidos compartidos; Los artículos deterministas con tarifa manual como `sticker` y `signed_script` pueden omitir el USPS cuando sean elegibles, y los ajustes preestablecidos de disco prueban clases válidas más baratas como `MEDIA_MAIL` antes de los servicios de paquetería.
  - Los totales de envío canónicos de los trabajadores fluyen a través del proceso de pago, gestión de promesas, correos electrónicos, informes y exportaciones de cumplimiento.
  - Las opciones de entrega admiten `standard`, `signature_required` y `adult_signature_required` en el carrito, el pago, la gestión de compromisos, los totales guardados y los correos electrónicos de los seguidores.
  - Los datos del país de pago provienen de una referencia del país de envío, las campañas con anulaciones de tarifa fija omiten el USPS y los carritos permanecen en modo de estimación hasta que sea posible obtener una cotización en vivo.
  - La cobertura de humo verifica la calificación nacional/internacional real de USPS, el comportamiento de respaldo y los flujos de opciones de firma

**Herramientas y contenido para creadores**

- [x] Panel de administración
  - Shells privados `/admin/` y `/es/admin/` con manejo sin índice y copia localizada del panel
  - inicio de sesión con enlace mágico, acceso de superadministrador y usuario de campaña con alcance de rol, comprobaciones de origen/CSRF, manejo seguro de cookies y comprobaciones de sesión de solo lectura
  - La compatibilidad con el desafío Turnstile de Cloudflare protege el envío de inicio de sesión por correo electrónico del administrador antes de la entrega del correo electrónico con enlace mágico
  - Vistas de configuración, complementos, campañas, análisis, informes, soporte, marketing, usuarios, secretos y credenciales y diagnóstico en tiempo de ejecución
  - Los superadministradores pueden configurar la zona horaria predeterminada de la plataforma desde un menú de selección lleno de opciones de zona horaria compatibles con la IANA.
  - Configuración -> Los usuarios guardan directamente en Worker KV en `admin-users:v1` y envían por correo electrónico las instrucciones de inicio de sesión a los usuarios recién creados cuando se configura el correo electrónico; Secretos y credenciales siguen siendo solo de estado
  - Los informes, análisis, soportes, cargas/vistas previas de contenido, generación de enlaces de marketing y filtros de tablas evitan las escrituras de KV en rutas de lectura normales.
  - Los seguidores y Analytics devuelven vistas de campaña vacías de solo lectura para campañas sin índices de compromiso en lugar de bloquear paneles de campaña nuevos/vacíos.
  - La edición de contenido WYSIWYG basada en bloques utiliza un esquema de bloques polimórfico para el contenido de la campaña y las entradas del diario.
  - La edición del diario conserva los ID de entrada estables, los ID basados en títulos para las nuevas entradas y el espaciado de énfasis en línea para que los correos electrónicos automáticos se envíen solo para entradas genuinamente nuevas.
  - esquema de campaña completo para niveles, complementos de campaña, objetivos ambiciosos, elementos de soporte, diario y decisiones
  - Las cargas de medios del panel utilizan directorios de activos basados en convenciones, conservan los ID existentes cuando sea necesario, derivan nuevos ID a partir de nombres/etiquetas y ofrecen optimización de imágenes sin pérdidas, variantes WebP responsivas y derivados de vídeo WebM con `scope=changed`.
  - las publicaciones de contenido y diario limpian los medios propiedad del panel de control de la misma campaña a los que ya no se hace referencia; Las cargas de audio se mantienen en origen.
  - Los enlaces hash del diario abren la pestaña de la fase de coincidencia antes de desplazarse a anclajes como `#diary-production`.
  - Los editores de productos físicos exponen ajustes preestablecidos de envío o metadatos explícitos del paquete, mientras que los productos digitales ocultan campos de solo envío.
  - Configuración -> Rendimiento avanzado expone el estado habilitado de captación previa de intención, el retraso y el límite de vista de página para superadministradores, con la configuración del trabajador reflejada a través de `INTENT_PREFETCH_*`
  - El inicio de sesión por correo electrónico del administrador mantiene el desafío Turnstile existente después de un intento de inicio de sesión y utiliza el estilo de mensaje de estado del panel compartido para obtener comentarios de autenticación más destacados.
  - las recargas del panel restauran la última pestaña de nivel superior permitida, la sección de Configuración, la campaña seleccionada de Campaigns y la subpestaña de Campaigns desde estado local del navegador sin agregar escrituras de Worker ni KV
  - responsive, accesibilidad, seguridad/noindex, español i18n, navegador, unidad y cobertura de presupuesto de escritura KV cubren los flujos del panel
- [x] Herramientas de marketing de campaña
  - Campañas -> El marketing se mantiene centrado en la generación de enlaces de campaña, códigos de referencia guardados, códigos QR PNG/SVG descargables y el creador de inserciones de campaña sin agregar otra superficie de panel de nivel superior.
  - Los códigos de referencia guardados almacenan únicamente el registro de referencia explícito relacionado con la campaña; Las vistas previas/descargas de QR son locales del navegador y no leen ni escriben KV
  - La generación de QR de campaña se adaptó del enfoque del generador de QR con licencia del MIT en `1612elphi/delphitools` para el creador de URL de esta pila, los enlaces de referencia guardados y las necesidades de descarga de PNG/SVG.
  - Los borradores de marketing compartido utilizan un registro KV con alcance de campaña con vencimiento de 7 días, controles explícitos de carga/guardado/borrado, protección contra conflictos de revisión y una escritura limitada solo al guardar/borrar el usuario.
- [x] Informes de atribución de Analytics
  - Analytics reutiliza el índice de compromiso de campaña existente y las etiquetas de referencia guardadas para mostrar referencias y agregados de fuente/medio/campaña/contenido UTM sin escaneos de listas KV ni una superficie de informes de pestaña de Marketing duplicada.
- [x] Blasts de correo electrónico para seguidores
  - Campañas -> Blast permite a los usuarios de campaña asignados y a los superadministradores enviar mensajes masivos de correo electrónico a los seguidores indexados de la campaña utilizando los campos compartidos del editor WYSIWYG, el asunto, la etiqueta del botón de CTA y la URL del botón de CTA.
  - Los borradores explosivos siguen siendo locales del navegador; Los ensayos automáticos se ejecutan antes de los envíos de prueba/en vivo, los envíos de prueba van solo al administrador que ha iniciado sesión, los envíos en vivo requieren el hash de ensayo correspondiente y el historial de envíos se muestra en modo de solo lectura debajo del editor.
  - Las cargas masivas de imágenes reutilizan la ruta de optimización/carga de medios de la campaña para que las imágenes de correo electrónico se alojen en el sitio en `assets/images/campaigns/<slug>/`; Los bloques de YouTube/Vimeo se muestran como enlaces seguros para correo electrónico en lugar de reproductores integrados
  - Los borradores compartidos de Blast utilizan el mismo modelo explícito de borrador compartido de 7 días que Marketing, incluidos conflictos de revisión y sin escrituras automáticas en segundo plano.
- [x] Selección de medios WYSIWYG
  - Los bloques de imagen de Campaign Content, Diary y Blast pueden elegir imágenes de campaña existentes desde un cuadro de diálogo de biblioteca multimedia con alcance en lugar de requerir rutas `/assets/...` pegadas.
  - Los superadministradores también pueden seleccionar imágenes compartidas/predeterminadas; Los usuarios de campañas solo ven los medios de las campañas que administran.
  - El selector es de solo lectura, está respaldado por el directorio de GitHub y no agrega ningún estado KV nuevo ni índice de medios duplicado.
- [x] Documentos y runbooks del creador
  - La lista de verificación pública para creadores de campañas y la lista de verificación en español cubren complementos de campaña, promoción de códigos de inserción, decisiones de envío alternativo/envío gratuito, expectativas fiscales, destinatarios de informes, transferencia de cumplimiento, planificación de enlaces compartidos, carga de medios en el panel, recordatorios de lanzamiento, expectativas de zona horaria de la plataforma, incrustaciones diferidas de héroes de YouTube y variantes WebP receptivas.
  - Existe una ruta de lista de verificación de creadores en español en `/es/creator-campaign-checklist/`.

**Sistema de calidad, accesibilidad y diseño**

- [x] Controles de calidad
  - Cobertura de unidad Vitest, cobertura Playwright E2E, controles de entrada de fusión y cobertura de humo local
  - La cobertura del navegador del panel de administración abarca `/admin/`, `/es/admin/`, configuración, complementos, campañas, análisis, informes, soporte, marketing y usuarios.
- [x] Actuación pública
  - las páginas públicas cargan primero un cargador liviano de tiempo de ejecución de carrito y difieren la pila completa del carrito hasta que el estado persistente del carrito, el estado de recuperación o la intención clara del partidario lo requieran.
  - La captura previa de documentos públicos del mismo origen sigue un pequeño modelo de intención local con listas de rutas permitidas, exclusiones de consultas confidenciales, protecciones de red, límites bajos por página y una superficie de configuración habilitada de forma predeterminada.
  - Las páginas de producción crean minify CSS/JS generado por minify después de la salida de Jekyll, mientras que Cloudflare sigue siendo responsable de la compresión de transferencia gzip/Brotli/Zstandard y Auto Minify permanece deshabilitado.
- [x] Accesibilidad
  - Semántica de diálogo, pestaña, control deslizante de sugerencias, error y región activa
  - Cobertura de superficies críticas con respaldo de hacha.
  - Cobertura más amplia de accesibilidad del navegador en los estados de campaña, comunidad, resultado de compromiso, Acerca de y Términos.
  - los shells públicos compartidos mantienen enlaces de omisión y anclajes `main-content` estables, y el activador del carrito expone etiquetas accesibles más claras y un estado ampliado.
- [x] Sistema de diseño y diseño responsivo
  - tokens compartidos, tipografía, botones, campos, carcasas de tarjetas, secciones apiladas, superficies responsivas, listas de pestañas, estados de píldora, cuadrículas de objetos multimedia, controladores de cantidad y botones de acción principal
  - Las páginas públicas, las páginas de campaña, el carrito/pago, la gestión de promesas, la tarjeta de actualización, las páginas de la comunidad y el contenido de formato largo utilizan el mismo diseño y patrones de respuesta en lugar de estilos paralelos.
  - La cobertura móvil incluye desbordamiento, capacidad de desplazamiento, acciones primarias accesibles, superposiciones de navegación/carrito con reconocimiento de áreas seguras, resumen en pantalla pequeña y objetivos más grandes para eliminar/cerrar toques.
  - Las tarjetas complementarias y los controles de gestión de promesas están normalizados en los puntos de interrupción de computadoras de escritorio, tabletas y teléfonos pequeños.
  - Se reparó la compatibilidad de prueba del nodo 25 para la cadena de herramientas local predeterminada
- [x] Personalización de la horquilla
  - configuraciones canónicas `platform`, `pricing`, `design`, `checkout` y `cache`
  - Duplicación de trabajadores sincronizada automáticamente desde `_config.yml` / `_config.local.yml` a `worker/wrangler.toml`
  - Puente de variable de tema CSS curado emitido en `assets/main.css`
  - activos de marca centrales configurables y superficie de personalización documentada sin código
  - Los elementos de marca Stripe y los correos electrónicos de los seguidores siguen la superficie de diseño/configuración compartida en lugar de una ruta separada del tema de pago/correo electrónico.
- [x] Localización en español
  - `_config.yml` posee idiomas admitidos, etiquetas de idiomas y rutas de páginas públicas localizadas y seleccionadas.
  - Existen rutas en inglés + español para `/`, `/about/`, `/terms/`, `/pledge-success/`, `/pledge-cancelled/`, `/manage/`, `/community/` y páginas de la comunidad de seguidores.
  - un conmutador de idioma de pie de página más silencioso y asistentes de ruta compartidos que preservan las cadenas de consulta y los hashes para rutas tokenizadas como `/manage/?t=...`
  - etiquetas compartidas de campaña pública/comunidad, carrito de propiedad del sitio/comunidad/cadenas de tiempo de ejecución de compromiso de administración, cuenta regresiva de campaña/galería/copia de estadísticas en vivo y correos electrónicos de apoyo de los trabajadores leídos desde datos locales más `preferredLang` persistente
  - Los resúmenes de los botones del carrito, la copia auxiliar de ubicación de impuestos de pago y los metadatos públicos localizados siguen el mismo modelo de configuración regional compartida.
- [x] SEO y metadatos estructurados
  - Los metadatos compartidos cubren títulos, descripciones, canónicos, etiquetas OG/Twitter e imágenes sociales predeterminadas en diseños públicos.
  - `robots.txt`, `sitemap.xml` y el manejo explícito de `noindex,nofollow` mantienen los flujos privados/tokenizados/solo para seguidores fuera de la intención de búsqueda.
  - las páginas públicas emiten `Organization` / `WebSite` JSON-LD conservador, y las páginas de campaña emiten `CreativeWork` conservador más JSON-LD de ruta de navegación
  - el centro de la comunidad pública dirige a las personas a las páginas públicas de la campaña en lugar de dirigir a los rastreadores a rutas exclusivas para los seguidores.
  - La puerta de fusión y la cobertura de unidades protegen los metadatos en idiomas alternativos, la inclusión de mapas del sitio y la superficie de rastreo pública.
  - La configuración de SEO delimitada hacia la bifurcación cubre `seo.x_handle`, `seo.same_as`, `seo.default_social_image_alt`, `seo.og_locale_overrides` y si el centro de la comunidad pública debe permanecer indexable.
  - El navegador estructurado y el registro de depuración de trabajadores se envían como una ayuda para desarrolladores basada en la configuración con marcas de tiempo, etiquetas de gravedad, prefijos de alcance y captura de errores globales del navegador.
  - Los metadatos públicos emiten sugerencias de idioma/nombre de aplicación, etiquetas de imágenes sociales seguras cuando sea posible y raíces de ruta de navegación/idioma JSON-LD con reconocimiento local.
  - el renderizado de URLs del sitemap se comparte mediante `_includes/seo-sitemap-url.xml`, incluidos alternates localizados `xhtml:link` para páginas públicas y páginas de campaña localizadas
  - `npm run test:seo` valida archivos de rastreo generados, canónicos, alternates `hreflang`, metadatos sociales y JSON-LD como parte de la puerta de merge
- [x] Incrustar y compartir vistas previas
  - Las páginas de la campaña se vinculan a un generador de incrustaciones alojado que reconoce la configuración regional y genera código iframe de copiar y pegar con opciones de diseño, tema, medios y CTA.
  - el widget de inserción utiliza un estado de campaña en vivo respaldado por los trabajadores, cambia de tamaño automáticamente después de pegar y admite enlaces de retorno localizados además de copia localizada en tiempo de ejecución/generador
  - La vista previa de inserción de marketing del administrador mantiene el progreso, los hitos, el marcador de objetivos y las etiquetas de objetivos ampliados contenidos para las campañas dirigidas por vídeo.
  - Las páginas de la campaña emiten metadatos sociales más ricos y conscientes del estado, además de imágenes de tarjetas compartidas PNG generadas por los trabajadores, con SVG retenido para herramientas internas de vista previa/depuración.
  - Las rutas de campaña localizadas, las rutas de inserción localizadas y las URL de tarjetas compartidas con reconocimiento regional mantienen las incrustaciones y las vistas previas enriquecidas alineadas en inglés y español.
  - Las páginas de campaña muestran enlaces compartidos de íconos reutilizables para Bluesky, X, Threads, Facebook, SMS y correo electrónico, utilizando URL localizadas, íconos PNG alternativos para casos extremos de SVG en línea y texto CTA con reconocimiento de estado donde las plataformas permiten el texto del mensaje.
  - Los controles interactivos para compartir aparecen debajo de la breve propaganda en dispositivos móviles/tabletas y encima del botón de inserción solo en computadoras de escritorio.
- [x] Sitio web externo y preguntas frecuentes
  - `thepool.fund` aloja el sitio de marketing de la plataforma y las preguntas frecuentes para desarrolladores derivadas de la documentación interna.
- [x] Protección contra denegación de servicio
  - `RATELIMIT` KV es un requisito estricto, con un comportamiento de cierre fallido cuando falta el enlace
  - los puntos finales de lectura pública mantienen intencionalmente espacio para la viralidad de la campaña, mientras que el pago, la gestión de promesas y las mutaciones administrativas utilizan límites de tasa específicos y límites de tamaño de solicitud.
  - El análisis del cuerpo de la solicitud rechaza antes las cargas útiles con formato incorrecto o obviamente sobredimensionadas en la superficie del trabajador.
  - `/checkout-intent/abandon` utiliza un presupuesto de reintento con alcance de orden en lugar de un limitador ingenuo por IP
  - Los trabajadores estándar/pagados desplegados declaran un tope conservador `cpu_ms = 100` como salvaguarda de denegación de billetera
  - Los puntos finales de observabilidad solo para administradores y `scripts/check-observability.sh` exponen resúmenes de resultados de webhooks y tiempos de mutación de muestra para su ajuste.
- [x] UX de impuestos y pago
  - Costura de trabajador/proveedor, interfaz de usuario de impuestos provisionales y carrito de cobertura de plomería de destino final de impuestos, pago, gestión de promesas, datos de promesas almacenados y correos electrónicos de apoyo
  - La experiencia del usuario del navegador mantiene los impuestos en `--` hasta que el pago tenga suficientes datos de destino, en lugar de inventar un valor preciso falso demasiado pronto.
  - El pago personalizado recopila la ubicación del impuesto de facturación para los carritos solo digitales, mientras que los carritos físicos/mixtos mantienen la dirección primero y admiten el autocompletado del navegador nuevamente.
  - Existe una ruta gratuita para Nuevo México a través de un conjunto de datos inicial suministrado más un refinamiento EDAC opcional.
  - Las instalaciones de humo locales y la cobertura de puertas de entrada funcionan con proveedores de impuestos que reconocen la ubicación en lugar de asumir un impuesto fijo.
- [x] Informes del ejecutor de campaña
  - El frente de la campaña admite `runner_report_emails`, con vacío/faltante, lo que significa que no hay informes de corredores para esa campaña.
  - `_config.yml` expone una superficie de personalización `reports.campaign_runner` limitada para habilitación, hora de envío de zona horaria de plataforma, resúmenes, archivos adjuntos y prefijo de asunto.
  - El trabajador envía correos electrónicos diarios del libro mayor de compromisos relacionados con la campaña a la hora de envío local configurada para campañas activas y divide los correos electrónicos de cumplimiento posteriores a la fecha límite para los que cumplen la campaña frente a los que cumplen la plataforma.
  - La pestaña Informes del panel muestra una vista previa de las filas de promesas/cumplimiento y descarga archivos CSV sin enviar correos electrónicos ni escribir marcadores de enviados.
  - Los puntos finales de informes de secreto compartido permanecen separados para los flujos de trabajo de script/operador que envían informes intencionalmente.
  - Las exportaciones CLI locales y los correos electrónicos programados de los trabajadores comparten el mismo núcleo de informes JS para evitar la deriva de CSV.

## Funciones futuras

- [ ] seguimientos posteriores a v1.0.8
  - [ ] Configuración del contenedor de la aplicación
    - Cree un contenedor de aplicación simple para Mac/Windows/Linux alrededor del mismo núcleo de configuración después de que el flujo de trabajo del script primero se mantenga estable en más instalaciones de bifurcación.
  - [ ] Pulido de biblioteca multimedia
    - Considere hacer que la URL de origen sea una opción avanzada/de edición de ruta existente después de que el selector de alcance se haya ejercido en producción.
- [ ] Ampliación de la calculadora de impuestos
  - Soporte USA e internacional
  - Apunte a tarifas estadounidenses a nivel local o jurisdiccional, no solo a nivel estatal
  - Enfoque a corto plazo: finalizar la cobertura del impuesto local sobre ingresos brutos de Nuevo México para que la calculadora pueda probarse manualmente de principio a fin con mayor confianza.
  - Agregue una cobertura más sólida fuera de línea/en repositorio para obtener más conjuntos de datos estatales de jurisdicción local gratuitos después de Nuevo México
  - Decida cuánta lógica internacional debe mantenerse fuera de línea en comparación con la opción respaldada por el proveedor.
  - Agregue un flujo de trabajo documentado de actualización/importación de datos tributarios para futuros conjuntos de datos de jurisdicciones
  - Consideración futura: manejo de impuestos comerciales, como validación de identificación de IVA, flujos de inversión de cargo, exenciones y clases de impuestos de productos.
- [ ] Precios adicionales específicos de cada variante
  - Amplíe los esquemas de variantes complementarias de plataforma y campaña para que una variante pueda anular el precio base sin necesidad de productos duplicados.
  - Actualice el carrito, el proceso de pago, administre el compromiso, los análisis, los informes y las exportaciones de cumplimiento para utilizar el precio de la variante resuelta de manera consistente.
  - Preservar la compatibilidad con versiones anteriores de complementos existentes cuyas variantes solo definen `id`, `label` y `inventory`.
  - Agregue la validación del panel de administración para que las anulaciones de precios no puedan ser negativas, mal formadas o ignoradas silenciosamente.

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número CC, vencimiento y CVV están dentro del iframe de Stripe para cumplir con PCI; no son accesibles para nuestros scripts de autocompletar.
