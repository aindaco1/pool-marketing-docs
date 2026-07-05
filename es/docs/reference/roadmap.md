---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

5 de julio de 2026

## Hito actual

**v1.0.8**

El hito v1.0.8 traslada el endurecimiento del tiempo de ejecución derivado de Store que se adapta a este proyecto, mantiene las lecturas de marketing diferidas y autenticadas, recuerda el contexto de la pestaña/subpestaña del panel de administración en el estado local del navegador, agrega comprobaciones de integridad de la configuración regional para que los catálogos de traducción admitidos permanezcan alineados, incorpora el patrón de auditoría SEO del sitio generado de Store en la puerta de fusión de Pool y adapta las herramientas de evidencia de lanzamiento de Store al modelo de campaña/compromiso de Pool.

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
  - Los usuarios de campaña asignados reciben correos electrónicos impulsados por Resend con el enlace del panel de administración cuando se asignan usuarios
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
  - Los superadministradores pueden cargar el uso de cuota de Cloudflare Workers/KV y Resend desde Configuración -> Planificar uso automáticamente cuando se abre la sección
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
  - el programador Worker de nivel minuto persiste `cron:lastRun` cada hora en lugar de cada minuto, manteniendo visible el estado del cron sin la rotación de escritura KV de nivel libre de referencia
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
  - Las comprobaciones de preparación de solo lectura pueden llamar a las API de proveedores en vivo de Cloudflare, GitHub, Stripe, Resend, Turnstile, USPS y ZIP.TAX durante la configuración/ejecuciones de prueba, con `--skip-readiness` disponible cuando los operadores necesitan una verificación local más específica.
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
  - La entrega de recordatorio de lanzamiento reutiliza el módulo de correo electrónico Resend existente, la configuración del remitente, el catálogo local y el ritmo en lugar de agregar una segunda integración de correo electrónico.
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
  - Los recordatorios de pago abandonado recopilan una suscripción explícita de un solo recordatorio, se ponen en cola solo después de que la creación de la sesión propia de Stripe sea exitosa, se eliminan cuando se completa la persistencia del compromiso, suprimen las audiencias duplicadas/sin suscripción y se envían a través del módulo de correo electrónico compartido Resend.
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
  - Las recargas del panel restauran la última pestaña de nivel superior permitida, la sección Configuración, la campaña Campañas seleccionada y la subpestaña Campañas desde el estado local del navegador sin agregar escrituras de trabajador o KV.
  - responsive, accesibilidad, seguridad/noindex, español i18n, navegador, unidad y cobertura de presupuesto de escritura KV cubren los flujos del panel
- [x] Herramientas de marketing de campaña
  - Campañas -> El marketing se mantiene centrado en la generación de enlaces de campaña, códigos de referencia guardados, códigos QR PNG/SVG descargables y el creador de inserciones de campaña sin agregar otra superficie de panel de nivel superior.
  - Los códigos de referencia guardados almacenan únicamente el registro de referencia explícito relacionado con la campaña; Las vistas previas/descargas de QR son locales del navegador y no leen ni escriben KV
  - La generación de QR de campaña se adaptó del enfoque del generador de QR con licencia del MIT en `1612elphi/delphitools` para el creador de URL de esta pila, los enlaces de referencia guardados y las necesidades de descarga de PNG/SVG.
  - Los borradores de marketing compartido utilizan un registro KV con alcance de campaña con vencimiento de 7 días, controles explícitos de carga/guardado/borrado, protección contra conflictos de revisión y una escritura limitada solo al guardar/borrar el usuario.
- [x] Informes de atribución de Analytics
  - Analytics reutiliza el índice de compromiso de campaña existente y las etiquetas de referencia guardadas para mostrar referencias y agregados de fuente/medio/campaña/contenido UTM sin escaneos de listas KV ni una superficie de informes de pestaña de Marketing duplicada.
- [x] Blasts de correos electrónicos de seguidores
  - Campañas -> Blast permite a los usuarios de campaña asignados y a los superadministradores enviar mensajes masivos de correo electrónico a los seguidores indexados de la campaña utilizando los campos compartidos del editor WYSIWYG, el asunto, la etiqueta del botón de CTA y la URL del botón de CTA.
  - Los borradores de Blast siguen siendo locales del navegador; Los ensayos automáticos se ejecutan antes de los envíos de prueba/en vivo, los envíos de prueba van solo al administrador que ha iniciado sesión, los envíos en vivo requieren el hash de ensayo correspondiente y el historial de envíos se muestra en modo de solo lectura debajo del editor.
  - Las cargas masivas de imágenes reutilizan la ruta de optimización/carga de medios de la campaña para que las imágenes de correo electrónico se alojen en el sitio en `assets/images/campaigns/<slug>/`; Los bloques de YouTube/Vimeo se muestran como enlaces seguros para correo electrónico en lugar de reproductores integrados
  - Los borradores compartidos de Blast utilizan el mismo modelo explícito de borrador compartido de 7 días que Marketing, incluidos conflictos de revisión y sin escrituras automáticas en segundo plano.
- [x] Selección de medios WYSIWYG
  - Los bloques de imágenes de contenido de campaña, diario y Blast pueden elegir imágenes de campaña existentes desde un cuadro de diálogo de biblioteca multimedia con alcance en lugar de requerir rutas `/assets/...` pegadas.
  - Los superadministradores también pueden seleccionar imágenes compartidas/predeterminadas; Los usuarios de campañas solo ven los medios de las campañas que administran.
  - El selector es de solo lectura, está respaldado por el directorio de GitHub y no agrega ningún estado KV nuevo ni índice de medios duplicado.
- [x] Documentos y runbooks del creador
  - La lista de verificación pública para creadores de campañas y la lista de verificación en español cubren complementos de campaña, promoción de códigos de inserción, decisiones de envío alternativo/envío gratuito, expectativas fiscales, destinatarios de informes, transferencia de cumplimiento, planificación de enlaces compartidos, carga de medios en el panel, recordatorios de lanzamiento, expectativas de zona horaria de la plataforma, incrustaciones diferidas de héroes de YouTube y variantes WebP receptivas.
  - Existe una ruta de lista de verificación de creadores en español en `/es/creator-campaign-checklist/`.

**Sistema de calidad, accesibilidad y diseño**

- [x] Controles de calidad
  - Cobertura de unidad Vitest, cobertura Playwright E2E, controles de entrada de fusión y cobertura de humo local
  - La cobertura del navegador del panel de administración abarca `/admin/`, `/es/admin/`, configuración, complementos, campañas, análisis, informes, soporte, marketing y usuarios.
  - Las comprobaciones de cordura de Merge-gate cubren la sintaxis del script de lanzamiento más `release:smoke`, evidencia del proveedor y superficies de comando de humo de pago sin enviar correo electrónico.
- [x] Liberación de automatización de pruebas
  - `npm run release:smoke` envuelve la prefusión, el ensayo de preparación para la configuración/implementación, Podman E2E cuando esté disponible, evidencia de accesibilidad enfocada, evidencia de transcripción del lector de pantalla opcional, evidencia i18n/SEO renderizada, evidencia de compromiso/informe, preparación del proveedor y preparación para el humo de pago.
  - Los comandos enfocados cubren accesibilidad, i18n/SEO renderizado, promesa/informe, preparación del proveedor, humo de pago y evidencia de transcripción opcional de VoiceOver/Whisper.
  - el flujo de trabajo de GitHub Actions de Release Provider Evidence proporciona evidencia estricta de la API de DNS de Cloudflare a través de secretos de lectura de DNS dedicados.
  - `POOL_EMAIL_DRY_RUN` / `RESEND_EMAIL_DRY_RUN` permiten que la evidencia de publicación represente cargas útiles de correo electrónico sin llamar a Resend
- [x] Actuación pública
  - las páginas públicas cargan primero un cargador liviano de tiempo de ejecución de carrito y difieren la pila completa del carrito hasta que el estado persistente del carrito, el estado de recuperación o la intención clara del partidario lo requieran.
  - La captura previa de documentos públicos del mismo origen sigue un pequeño modelo de intención local con listas de rutas permitidas, exclusiones de consultas confidenciales, protecciones de red, límites bajos por página y una superficie de configuración habilitada de forma predeterminada.
  - Las páginas de producción crean minify CSS/JS generado por minify después de la salida de Jekyll, mientras que Cloudflare sigue siendo responsable de la compresión de transferencia gzip/Brotli/Zstandard y Auto Minify permanece deshabilitado.
- [x] Accesibilidad
  - Semántica de diálogo, pestaña, control deslizante de sugerencias, error y región activa
  - Cobertura de superficies críticas con respaldo de hacha.
  - Cobertura más amplia de accesibilidad del navegador en los estados de campaña, comunidad, resultado de compromiso, Acerca de y Términos.
  - los shells públicos compartidos mantienen enlaces de omisión y anclajes `main-content` estables, y el activador del carrito expone etiquetas accesibles más claras y un estado ampliado.
  - La evidencia de publicación verifica el orden de enfoque del compromiso de campaña, actualizaciones de estado en vivo de recordatorio de lanzamiento, superficies de carrito de campaña con movimiento reducido, comportamiento de zoom alto, rutas de teclado y desbordamiento móvil.
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
  - La representación de la URL del mapa del sitio se comparte a través de `_includes/seo-sitemap-url.xml`, incluidas las alternativas localizadas de `xhtml:link` para páginas públicas localizadas y páginas de campaña.
  - `npm run test:seo` valida archivos de rastreo creados, canónicos, alternativas de hreflang, metadatos sociales y JSON-LD como parte de la puerta de fusión.
  - Liberar muestras de evidencia de i18n/SEO, páginas públicas en inglés y español, metadatos de campaña activa, shells sin índice de ruta privada, mapas de sitio alternativos, límites de robots y copia de ruta.
- [x] Incrustar y compartir vistas previas
  - Las páginas de la campaña se vinculan a un generador de incrustaciones alojado con reconocimiento regional que genera código iframe de copiar y pegar con opciones de diseño, tema, medios y CTA.
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

- [ ] Paridad entre repositorios y disciplina de documentos como código
  - Trate la paridad de características de Store y Pool como porciones de implementación transferibles, no como un mandato para copiar superficies de productos. Los sectores compartidos incluyen configuración/preparación, creación de medios, puertas de rendimiento, postura de seguridad, auditoría administrativa/controles de sesión, expansiones de evidencia de accesibilidad, control de calidad de i18n, expansiones de muestreo de SEO, endurecimiento de liberación de humo, conciliación de pagos, disciplina de respaldo, endurecimiento de proveedores de impuestos y reglas adicionales de resolución de precios.
  - Mantenga intactos los nombres específicos de Pool y los límites de almacenamiento: `_campaigns/`, registros de compromiso/pedido, `PLEDGES`, `VOTES`, coordinación de objetos duraderos por campaña, complementos de plataforma/campaña, vistas previas de campaña protegidas, gestión de compromiso, comunidad de seguidores/votos, tarjetas insertadas/compartidas, diarios de campaña, Blast, recordatorios de lanzamiento, recordatorios de pagos abandonados y paneles de administración de Pool.
  - Cuando Store obtenga primero una implementación más sólida, transfiera solo la primitiva reutilizable y documente el mapeo de Pool en los documentos de Pool relevantes; por ejemplo, la selección de producto/medio predeterminado de Store se asigna a la selección de campaña/medio predeterminado de Pool, no al catálogo `_products` de Store, la biblioteca de descargas de R2, los cupones, el boleto/confirmación de asistencia o las superficies de búsqueda de pedidos.
  - Cuando Pool obtenga primero una implementación más sólida, mantenga notas de regresión que ayuden a Store a adoptar la primitiva sin cambiar el comportamiento de Pool ni debilitar la semántica de campaña/compromiso.
  - Mantenga actualizados los documentos como código actualizando el documento propietario y las pruebas con cada segmento, no solo esta hoja de ruta, de modo que README, `worker/README.md` y los archivos `docs/*.md` relevantes coincidan con la fuente de verdad implementada.
- [ ] Configuración guiada del contenedor TUI
  - Cree una interfaz de usuario de terminal delgada y atractiva alrededor del núcleo de configuración `scripts/setup-deploy.mjs` existente en lugar de crear una aplicación de escritorio separada o duplicar la lógica del proveedor.
  - Tome las indicaciones de la interfaz de las herramientas modernas de terminal, como [Hermes Agent CLI](https://hermes-agent.nousresearch.com/docs/user-guide/cli) y [Amp CLI](https://ampcode.com/manual): área de estado clara, progreso responsivo, navegación fácil de usar con el teclado, salida de tareas en streaming, posibilidades de interrupción/reintento y una sensación pulida de paleta de comandos
  - Mantenga intacto el contrato de script primero: cada acción de TUI debe asignarse a un modo de configuración existente o una pequeña extensión de ese modo, y los usuarios CI/no interactivos aún deben poder usar la CLI subyacente directamente.
  - Respalde las rutas locales y de producción actuales: generación de secretos locales, ejecución en seco de producción, comprobaciones de preparación del proveedor, planificación de creación/reutilización de KV, escrituras de secretos de trabajadores, escrituras de secretos de GitHub, implementación opcional y guía de preparación de Podman.
  - Muestre un tablero de preparación paso a paso con el estado del proveedor, las credenciales requeridas, las mutaciones planificadas, las comprobaciones omitidas, los secretos locales generados y borre las siguientes acciones antes de cualquier mutación activa.
  - Mantenga los secretos privados en la interfaz de usuario: entradas enmascaradas, sin eco de terminal, sin registros que contengan valores secretos y recordatorios explícitos de que los secretos de producción no se copian en `worker/.dev.vars`
  - Proporcione comandos de respaldo copiables para cada paso fallido para que los operadores puedan volver a Wrangler, GitHub CLI, Stripe CLI o el script de configuración existente sin perder el contexto.
  - Agregue exportación de transcripción/registro que redacte secretos y capture decisiones de configuración, estados de proveedores, versiones de comandos y motivos de falla para soporte sin crear un nuevo backend de telemetría.
  - Agregue atajos de prueba de humo después de la configuración, como `podman:doctor`, `./scripts/dev.sh --podman`, `./scripts/test-checkout.sh --podman`, `npm run test:secrets` y `npm run test:i18n`, sin dejar la orquestación de prueba real en los scripts existentes.
  - Mantenga la implementación pequeña y multiplataforma: prefiera una capa Node TUI sobre el núcleo de configuración actual, evite el empaquetado Electron/nativo hasta que el contenedor del terminal resulte útil y documente cualquier limitación del terminal específica de la plataforma.
- [ ] Flujo de trabajo de optimización y usabilidad de la biblioteca multimedia
  - Mejorar el selector de medios existente con alcance de campaña y la ruta de carga para los creadores sin agregar un segundo índice de medios, una base de datos de medios respaldada por KV o un backend de almacenamiento alternativo.
  - Haga que la URL de origen sea una posibilidad avanzada/de edición de rutas existentes para que los creadores normales elijan entre los medios de campaña existentes, carguen un archivo nuevo o reemplacen un archivo de referencia sin tener que pegar las rutas `/assets/...` a mano.
  - Agregue navegación de medios amigable para los creadores: filtros con alcance de campaña, pestañas de tipo de imagen/video/audio, vistas previas en miniatura, filtrado de nombre de archivo/búsqueda, recursos cargados recientemente, visualización de dimensiones/duración/tamaño de archivo y etiquetas claras de fuente versus derivadas.
  - Mejore la accesibilidad y la calidad de publicación en el punto de uso: texto alternativo requerido para imágenes significativas, manejo de imágenes decorativas, subtítulos cuando sean compatibles, guía focal/de recorte para héroe cuadrado, héroe ancho, tarjetas, vistas previas sociales e imágenes Blast seguras para correo electrónico
  - Agregue flujos de reemplazo/reutilización seguros que muestren dónde se hace referencia a un activo en el contenido de la campaña, entradas del diario, campos de héroe, imágenes de niveles/complementos, borradores de Blast, incrustaciones y superficies sociales/compartidas antes de cambiarlo o eliminarlo.
  - Estado de optimización de superficie en el panel mediante la reutilización de los resultados del optimizador de medios del repositorio: archivo fuente, anchos de WebP generados, derivados de WebM generados, optimización pendiente, derivado obsoleto, derivado faltante y advertencias de fuente de gran tamaño
  - Agregue acciones de reparación que envíen o sugieran el flujo de trabajo de optimización de medios existente con `scope=changed` o `scope=all`, en lugar de introducir el procesamiento de imágenes/vídeo del lado del trabajador.
  - Agregue comprobaciones de referencias rotas para los medios propiedad de la campaña para que los creadores vean archivos faltantes, recursos fuente eliminados, generación derivada fallida y rutas de imágenes de correo electrónico que no se resolverán públicamente.
  - Agregue presupuestos de rendimiento livianos para ubicaciones comunes, incluida la imagen principal, la imagen de la galería, la imagen del nivel, la imagen explosiva y el póster de video, con advertencias en lugar de bloques rígidos, a menos que el archivo no sea seguro o no sea compatible.
  - Mantenga la limpieza conservadora y explicable: la limpieza en el momento de la publicación debe continuar eliminando solo los medios propiedad del panel de la misma campaña que desaparecieron del contenido normalizado y no se mencionan en ningún otro lugar.
  - Amplíe las pruebas sobre la usabilidad del selector de medios, la representación del estado de optimización, las advertencias de referencias rotas, la seguridad de la limpieza, la selección responsiva de imágenes y la seguridad de la carga útil de imágenes de Blast sin duplicar las comprobaciones de las herramientas nativas del optimizador.
  - Actualice los documentos dirigidos a los creadores con nombres de medios, texto alternativo, expectativas de fuentes/derivados, advertencias de optimización, comportamiento de reemplazo y cuándo solicitarle a un operador de plataforma medios compartidos/predeterminados.
- [ ] Puertas de calidad de producción y endurecimiento de las operaciones administrativas
  - Adapte el fortalecimiento del trabajo futuro de Store relevante a The Pool sin importar productos exclusivos de Store, boletos/confirmación de asistencia, descarga R2 o sistemas de catálogo de escaparate; centrarse en campañas públicas, inserciones, carrito/pago, gestión de promesas, panel de administración, flujos de trabajo de creadores de campañas, rutas de trabajadores y trabajos programados.
  - Agregue presupuestos de rendimiento ligeros para páginas de campaña, inserciones, carrito, pago, gestión de compromiso y rutas de administración, que abarquen el tamaño de JavaScript, el tamaño de CSS, el peso de la imagen/video, el tiempo de la ruta crítica, el tiempo de respuesta del trabajador y la latencia de procesamiento/tabla del panel.
  - Agregue comprobaciones repetibles de Lighthouse/PageSpeed para rutas públicas principales e incrustaciones antes de implementar la producción, manteniendo las comprobaciones programables y opcionales cuando las credenciales de proveedores externos o las URL estables no estén disponibles.
  - Percentiles de tiempo de Surface Worker y resúmenes de ruta lenta en Configuración -> Planificar uso o diagnóstico de tiempo de ejecución reutilizando muestras de observabilidad existentes en lugar de agregar un segundo backend de telemetría
  - Agregue comprobaciones de estado de caché para activos estáticos, feeds JSON generados, páginas de campaña, activos integrados, respuestas de tarjetas compartidas y rutas privadas/no-store para que las mejoras públicas en el rendimiento no debiliten las reglas de pago, administración, vista previa o caché tokenizada.
  - Amplíe las comprobaciones de configuración/preparación para que reflejen la guía de seguridad completa: secretos de trabajo, webhooks de Stripe, remitentes Resend, widgets de torniquete, credenciales USPS y ZIP.TAX, `RATELIMIT`, CSP, orígenes permitidos, usuarios de arranque administrativo, vistas previas protegidas, tokens de búsqueda/administración, recordatorios y modo de producción.
  - Agregue una vista de revisión de dispositivo/sesión de administrador con metadatos de inicio de sesión recientes y revocación de sesión explícita, utilizando el modelo de auditoría/sesión/autenticación de administrador existente en lugar de un sistema de cuenta separado.
  - Amplíe los eventos de auditoría de administración a una vista de auditoría de panel con capacidad de búsqueda con filtros y exportación CSV, reutilizando registros de auditoría existentes respaldados por KV y manteniendo las cargas útiles confidenciales redactadas.
  - Agregue comprobaciones programadas de postura de configuración/secreto que adviertan cuando los secretos requeridos por la producción, los puntos finales de webhook, los orígenes permitidos, la preparación del proveedor o la postura del usuario administrador se desvíen de la configuración esperada; resultados visibles a través de diagnósticos de administración y/o problemas de GitHub en lugar de mutar silenciosamente el estado de tiempo de ejecución
  - Amplíe el soporte de artefactos de lanzamiento más allá del asistente opcional de VoiceOver/Whisper al pase manual documentado de VoiceOver y NVDA, incluida la lista de evidencia de verificación para páginas de campañas públicas, carrito/pago, gestión de compromiso, edición del panel de creador, informes y flujos de autenticación de administrador.
  - Amplíe la cobertura de accesibilidad automatizada más allá del enfoque/estado/evidencia de lanzamiento de movimiento reducido de la campaña actual a superficies de pago/caja montadas cuando los accesorios de prueba de Stripe estén disponibles, además de capturas de pantalla con gran zoom para carrito, caja, gestión de compromiso, edición de campaña, informes, tablas de apoyo y controles del creador de incrustaciones de campaña.
  - Mantenga títulos de campaña largos, etiquetas de nivel/complemento/variante, nombres de archivos, etiquetas de referencia/UTM, nombres/correos electrónicos de los seguidores, asuntos de Blast y filas densas de administradores de tabletas/móviles en elementos de regresión para que el diseño reforzado cubra el contenido real del creador/administrador.
  - Mueva las cadenas de tiempo de ejecución públicas/administradoras codificadas restantes a `_data/i18n/*` o mensaje de tiempo de ejecución JSON a medida que se tocan, y agregue instantáneas de control de calidad localizadas para errores de pago, gestión de promesas, creación/edición de campañas, descargas de informes, envíos masivos y copia de cumplimiento/estado.
  - Defina un ciclo de revisión de traductor/hablante nativo antes de agregar configuraciones regionales más allá del inglés y el español, incluidos metadatos de campaña localizados, enlaces alternativos, valores de idioma JSON-LD, correos electrónicos y texto de ayuda del panel.
  - Mantenga la cobertura de humo de Podman alineada con la puerta de fusión del host, agregue notas de solución de problemas para `gvproxy` obsoletos, conflictos de puertos y reconstrucciones de imágenes de primera ejecución si se repiten, y considere un trabajo programado de Podman E2E CI si el soporte del ejecutor sigue siendo confiable
  - Amplíe el control de calidad de SEO renderizado más allá de las muestras de la versión actual con campañas más activas, páginas de campaña localizadas, verificaciones de URL de tarjetas compartidas y manejo sin índice para vistas previas, pago y rutas exclusivas para seguidores.
  - Expanda el script de liberación de humo dedicado y la lista de verificación de evidencia más allá de la línea de base de compromiso/informe/pago/proveedor actual para compromisos físicos pagados, compromisos solo digitales, complementos de plataforma y campaña, administración de rutas de tarjetas de modificación/cancelación/actualización de compromisos, recordatorios de lanzamiento, recordatorios de pagos abandonados, envíos masivos de correos electrónicos de partidarios, acuerdos, informes de compromisos/cumplimiento, análisis y descargas de administrador.
  - Actualice `docs/PERFORMANCE.md`, `docs/SECURITY.md`, `docs/ACCESSIBILITY.md`, `docs/I18N.md`, `docs/PODMAN.md`, `docs/SEO.md`, `docs/TESTING.md`, `docs/DASHBOARD.md` y `docs/WORKFLOWS.md` a medida que aterriza cada segmento de endurecimiento para que el procedimiento de liberación siga siendo documentos como código en lugar de conocimiento tribal.
- [ ] Refuerzo de la integridad de los pagos del Manual de ingeniería de Fintech
  - Mantenga la arquitectura actual: Stripe sigue siendo el procesador, Stripe posee los datos de la tarjeta, Cloudflare Worker sigue siendo el límite de pago canónico, KV sigue siendo el almacenamiento de compromiso/proyección, los objetos duraderos serializan el inventario y la liquidación escasos, y el programador del trabajador maneja el trabajo en segundo plano limitado.
  - Evite agregar un libro de contabilidad de doble entrada completo a menos que The Pool luego agregue reembolsos, pagos, saldos almacenados, movimientos de dinero en múltiples monedas o divisiones estilo mercado; Para el modelo de compromiso actual, prefiera un diario de eventos de pago liviano que solo se pueda agregar y que haga referencia a los ID de compromiso, pedido o campaña existentes.
  - Agregue metadatos `currency` explícitos a las filas de compromiso, manifiesto de pago, liquidación, informe y análisis recientemente persistentes, estableciendo de forma predeterminada las filas más antiguas con la suposición actual de USD de la implementación durante las lecturas en lugar de introducir un comportamiento multidivisa.
  - Agregue campos de tiempo de pago más claros sin duplicar el historial existente: tiempo de valor para eventos de soporte/Stripe, tiempo de reserva de trabajadores para persistencia y tiempo de disponibilidad de liquidación/procesador cuando los datos de transacciones del saldo de Stripe estén disponibles
  - Agregue un diario de eventos de procesador delimitado y redactado para interacciones y webhooks de Stripe de alto valor, almacenando ID de eventos, ID de objetos, intención de solicitud, estado de respuesta, clave de idempotencia, modo, marcas de tiempo, estado de conciliación y solo la carga útil mínima del proveedor sin procesar necesaria para la recuperación o auditoría, con retención explícita y minimización de PII.
  - Reutilice los resúmenes de observabilidad existentes y la lógica de reabastecimiento financiero de Stripe para crear trabajos de conciliación periódicos que comparen la verdad de las promesas, los trabajos de liquidación, los Stripe PaymentIntents, los marcadores de idempotencia de webhooks y los datos netos/de tarifas almacenados a través de índices `campaign-pledges:{slug}` en lugar de escaneos de espacios de nombres.
  - Representar las diferencias de conciliación como registros `reconciliation-break:*` explícitos con estado, gravedad, ID de objeto de origen, marcas de tiempo vistas por primera y última vez y notas del operador; Las vistas del panel y los scripts deberían leer esos registros en lugar de inventar un segundo modelo de informes.
  - Mueva los efectos secundarios adyacentes al pago hacia una pequeña bandeja de salida respaldada por KV compartida por confirmaciones de seguidores, correos electrónicos de éxito/fallo de pago, correos electrónicos de informes, transmisiones de diario/hitos y envíos de Blast, de modo que la persistencia de las promesas y la entrega de notificaciones se puedan reintentar de forma independiente a través del programador existente y el asistente Resend.
  - Fortalezca la capacidad de reanudación de la liquidación haciendo que cada paso del lote se vuelva a ejecutar de manera segura, agregando detección de trabajos obsoletos y registrando suficiente estado por lote para reanudar o avanzar de manera segura sin recargar a los partidarios.
  - Agregue pruebas invariantes y de choque/reanudación usando los arneses de humo y Vitest existentes: no se duplica el compromiso cargado para un grupo de liquidación, no se cobra el compromiso sin ID de Stripe PaymentIntent, las proyecciones del subtotal de la campaña equivalen a la verdad del compromiso activo después de crear/modificar/cancelar secuencias, los correos electrónicos fallidos se pueden volver a intentar sin mutar la verdad del compromiso, y los webhooks/lotes repetidos siguen siendo idempotentes
  - Mantenga todas las transacciones de prueba de pago de producción claramente etiquetadas, contabilizadas normalmente y conciliadas a través de las mismas rutas de promesa/pago en lugar de ocultarlas detrás de un comportamiento de informes o contabilidad de casos especiales.
  - Agregue una ruta de creador/verificador de alcance limitado solo para operaciones de recuperación manuales que afecten el dinero y que aún no estén automatizadas o no sean seguras para los reintentos, utilizando sesiones de administración, alcances de roles, CSRF y registros de auditoría existentes en lugar de introducir un servicio de aprobación separado.
  - Documente el nuevo diario, las interrupciones de conciliación y la bandeja de salida en `docs/PAYMENT_PROCESSOR.md`, `docs/WORKFLOWS.md`, `docs/SECURITY.md` y `worker/README.md`, incluida la retención, la PII y los runbooks del operador.
- [ ] Runbook de copia de seguridad, restauración y recuperación ante desastres
  - Adapte la disciplina de copia de seguridad/restauración de Store al modelo de datos real de The Pool: campañas/configuración/medios respaldados por Git, compromiso/administrador/estado de votación de Cloudflare KV, estado de coordinación de objetos duraderos, Stripe/Resend/identificadores de proveedor y exportaciones de operadores.
  - Cree `docs/BACKUP_RESTORE.md` como el runbook canónico para los datos propiedad del grupo que no se pueden recrear mediante una implementación normal y vincúlelo desde README, `docs/WORKFLOWS.md`, `docs/SECURITY.md`, `docs/TESTING.md`, `docs/PAYMENT_PROCESSOR.md` y `worker/README.md`.
  - Mantenga la implementación de respaldo SECO empaquetando las herramientas existentes en lugar de agregar exportadores paralelos: reutilice `scripts/setup-deploy.mjs` para el descubrimiento de recursos cuando sea práctico, `scripts/pledge-report.sh`, `scripts/fulfillment-report.sh`, `scripts/check-projections.sh`, `scripts/check-observability.sh`, sincronización de configuración de trabajador generada y código de informe/CSV del panel.
  - Agregue un pequeño operador auxiliar para instantáneas repetibles que capturen el estado de confirmación de Git, el historial de `git bundle`, las diferencias sucias, los resultados generados de la compilación pública/de los trabajadores, los ID de recursos de Cloudflare, los metadatos de implementación de los trabajadores, los ID de los puntos finales del proveedor y los resultados de preparación/estado desinfectados sin enviar artefactos de respaldo al repositorio.
  - Realice una copia de seguridad del estado de KV autorizado por prefijo y espacio de nombres, especialmente registros `PLEDGES` como `pledge:*`, `email:*`, `campaign-pledges:*`, `admin-users:v1`, `admin-audit:*`, `admin-marketing-referrals:*`, registros de inventario adicional vendido/anulado, registros de recordatorio de lanzamiento, registros de pago abandonado, colas de reintento de correo electrónico de soporte, marcadores de idempotencia/pago de Stripe, liquidación. marcadores y cualquier registro futuro de conciliación/bandeja de salida
  - Realice una copia de seguridad del estado de decisión del espacio de nombres `VOTES`, incluidos `vote:*` y `results:*`, para que las decisiones de la comunidad se puedan restaurar independientemente del estado de compromiso/contabilidad.
  - Excluir o poner en cuarentena explícitamente registros efímeros/sensibles de la restauración normal: entradas `admin-session:*`, `admin-login:*`, `campaign-preview-reviewers:*`, `RATELIMIT`, nonce de pago/internos de objetos duraderos, registros borrador de pago `pending-*`, tokens de reanudación de corta duración, marcadores de estado de cron, filas de observabilidad de muestra y marcadores de webhook de Stripe, a menos que el incidente requiera específicamente control de reproducción.
  - Trate los secretos como inventario, no como carga útil de respaldo: registre los nombres de los secretos requeridos, el estado configurado/faltante, la propiedad del proveedor, las notas de rotación y los comandos de configuración, pero nunca exporte los valores de los secretos de producción ni los copie en `worker/.dev.vars`.
  - Defina un orden de restauración que minimice el riesgo de doble carga y deriva: restaurar la campaña/configuración/historial de medios de Git primero cuando sea posible, restaurar el acceso de administrador, restaurar la verdad del compromiso antes de los registros de correo electrónico/índice/proyección, reconstruir o verificar las estadísticas de campaña derivadas y las proyecciones de nivel/complementos, restaurar el estado de votación por separado y restaurar las colas de recordatorio/supresión/envío solo después de la revisión de privacidad y envío duplicado.
  - Documentar que el estado del Objeto duradero no se restablece directamente; El inventario de nivel escaso, la coordinación de la intención de pago y los bloqueos de liquidación deben reconstruirse o revalidarse a partir de la verdad del compromiso, la configuración de la campaña, el estado de Stripe y las comprobaciones de proyección en lugar de escribirse manualmente en el almacenamiento DO.
  - Agregue puertas de restauración específicas de pago antes de tocar la liquidación, la idempotencia de Stripe, `campaign-charged:*` o futuros registros de conciliación/bandeja de salida, incluida una restauración provisional requerida, comparación de API/panel de Stripe, revisión de cargos duplicados y aprobación del operador antes de la reproducción o mutación de producción.
  - Agregue verificación de restauración que utiliza las comprobaciones de operador y puerta de fusión actuales: Jekyll build, `npm run sync:worker-config`, comprobaciones de SEO/secrets/i18n, humo de Podman Worker, humo de pago donde sea seguro, comprobaciones de deriva de proyección, vistas previas de informes de compromiso y cumplimiento, comprobaciones de observabilidad y revisión del panel de administración para campañas, análisis, informes, seguidores, usuarios, marketing, medios y complementos.
  - Agregue pruebas sobre la clasificación de copias de seguridad y la generación de comandos con CLI falsas de Wrangler/GitHub/proveedor, además de un dispositivo de ensayo de restauración provisional que demuestra que la reparación de índice/proyección puede recuperarse de `campaign-pledges:*` faltantes o estadísticas obsoletas sin escaneos de espacio de nombres KV
- [ ] Ampliación de la calculadora de impuestos y refuerzo del cumplimiento
  - Comience desde la línea base implementada actualmente: `worker/src/tax.js` ya proporciona los modos de proveedor `flat`, `offline_rules`, `nm_grt` y `zip_tax`; `_config.yml` refleja la configuración no secreta de `tax.*` en `worker/wrangler.toml`; `/tax/quote`, pago, gestión de compromiso, compromiso almacenado `taxDetails`, correos electrónicos, análisis e informes ya utilizan totales de impuestos calculados por el trabajador; y el navegador mantiene el impuesto provisional como `--` hasta que tenga suficientes detalles de destino
  - Mantenga la arquitectura actual SECO: el Trabajador sigue siendo la única autoridad tributaria, el carrito y Administrar Promesa siguen solicitando cotizaciones en lugar de duplicar las matemáticas de impuestos, `_config.yml` posee configuraciones de proveedor no secretas, los secretos del Trabajador poseen claves de proveedor y los informes/análisis continúan leyendo `tax` / `taxDetails` persistentes en lugar de volver a calcular las obligaciones históricas del catálogo actual o los datos de tarifas.
  - Dar prioridad primero a la experiencia estadounidense y luego tratar el cumplimiento del IVA/GST internacional como una fase posterior; El trabajo a corto plazo debe centrarse en una cobertura estatal, de condado, municipal, de distrito especial, del Distrito de Columbia y del territorio de EE. UU. confiable antes de agregar el registro transfronterizo, la facturación o el comportamiento de cobro revertido.
  - Aclare el modelo impositivo antes de ampliar el alcance: documente qué montos están sujetos a impuestos hoy (`subtotal`, incluidos niveles, artículos de soporte, complementos de campaña y complementos de plataforma), cuáles no están sujetos a impuestos actualmente (`tipAmount` y la mayoría de los envíos a menos que una respuesta del proveedor marque el envío como sujeto a impuestos) y si cada categoría de producto futura debe estar sujeta a impuestos, estar exenta, tener una tasa reducida, ser digital, ser una admisión, ser similar a una donación o estar sujeta a impuestos por envío.
  - Agregue clasificación de impuestos a nivel de artículo sin dividir el modelo de pago: introduzca un generador de líneas de impuestos compartidas que convierta niveles, artículos de soporte, soporte personalizado, complementos de campaña, complementos de plataforma y envíos en líneas imponibles escritas con ID estables, códigos de categoría, montos, cantidad, propiedad de campaña/plataforma e indicadores de exención, luego permita que los proveedores agreguen esas líneas cuando solo admitan cotizaciones a nivel de subtotal.
  - Preservar la experiencia de usuario actual del colaborador mientras se mejora la corrección: mantenga la visualización provisional de `--` cuando el destino esté incompleto, pero haga explícitos los estados de cotización (`needs_input`, `quoted`, `provider_unavailable`, `fallback_used`) para que el carrito, el pago, la gestión de compromiso y los diagnósticos del administrador puedan distinguir la dirección faltante de una falla del proveedor o una alternativa deliberada.
  - Resuelva la discrepancia en la documentación/comportamiento de `/tax/quote`: decida si el punto final debe continuar devolviendo `400`/`503` por falla de destino/proveedor faltante, o devolver una respuesta provisional estructurada que coincida con la copia del navegador en `worker/README.md`; actualice las pruebas y los documentos de la ruta del trabajador de cualquier manera
  - Termine primero la ruta de Nuevo México porque coincide con la implementación actual: amplíe el conjunto de datos iniciales de GRT suministrado más allá de las cinco ubicaciones de referencia actuales, agregue metadatos para la fecha/fuente/período efectivo de generación, mejore los diagnósticos de coincidencia de ciudades/correos/calles y agregue un flujo de trabajo de actualización repetible con diferencias revisables en lugar de una deriva silenciosa de la tasa en vivo
  - Agregue un flujo de trabajo de vigilancia de tasas impositivas mensual de GitHub Actions con activadores `schedule` y `workflow_dispatch` que verifica los cambios en las tasas de EE. UU. en los niveles de estado, condado, municipio y distrito especial, ejecuta la actualización inicial de Nuevo México, muestra cotizaciones ZIP.TAX para accesorios configurados, compara resultados con instantáneas registradas y abre una solicitud de extracción o problema con diferencias revisables en lugar de cambiar el comportamiento de producción silenciosamente.
  - Agregue controles de estado del proveedor para búsquedas en vivo: tiempos de espera, reintentos limitados donde el almacenamiento en caché de cotizaciones es seguro y de corta duración codificado por destino/proveedor/versión de tarifa normalizada, comportamiento de límite de velocidad/disyuntor para ZIP.TAX y EDAC, registro de errores redactado y diagnósticos de administrador/tiempo de ejecución que muestran la preparación del proveedor sin exponer las claves API
  - Combine la solución específica de Nuevo México con ZIP.TAX en una estrategia integral de EE. UU.: use datos de EDAC/proveedor de NM donde sean más sólidos y gratuitos, use ZIP.TAX como proveedor de tarifas locales generales para todos los demás estados, D.C. y territorios de EE. UU., y mantenga un contrato de adaptador de proveedor para que al realizar el pago, administrar el compromiso, los informes y las pruebas no les importe qué fuente produjo la cotización.
  - Decida la política de respaldo explícitamente por proveedor y etapa de pago: mantenga el respaldo de tarifa plana configurado existente como una opción disponible, pero defina cuándo las vistas previas pueden usar el respaldo, cuándo debe bloquearse el pago de producción, cuándo se puede usar una tarifa de respaldo aprobada por el operador y si alguna vez se permiten cotizaciones sin impuestos cuando ZIP.TAX o EDAC no están disponibles.
  - Fortalecer el comportamiento internacional más adelante: tratar a `offline_rules` como una vista previa/alternativa conservadora, luego decidir si el IVA/GST internacional debe seguir siendo suministrado, pasar a una ruta respaldada por el proveedor o permanecer deshabilitado de forma predeterminada hasta que se conozcan las obligaciones de registro/nexo; agregar accesorios de normalización y prueba de país/estado/provincia para los países de lanzamiento previstos antes de permitir la recopilación
  - Agregue funciones de impuestos para empresas/clientes solo después de aprobar el alcance: captura y validación de ID de IVA, manejo de reversión de cargos, certificados de exención, precios con impuestos incluidos, reglas B2B/B2C, requisitos de evidencia de destino y copia localizada de facturas/recibos deben estar detrás de la configuración explícita, los documentos administrativos y las pruebas en lugar del comportamiento de pago implícito.
  - Mejore la privacidad y la retención de los destinos fiscales: revise si el `taxDetails.destination` persistente debe conservar la dirección postal completa para siempre, si las pruebas fiscales almacenadas se pueden minimizar o aplicar hash después de las ventanas de liquidación/informe, y cómo esto interactúa con las direcciones de cumplimiento que ya requieren retención de PII.
  - Agregue soporte de conciliación y remesas: cree exportaciones de obligaciones tributarias agrupadas por proveedor, fuente, jurisdicción, código de ubicación, tasa efectiva, subtotal imponible, envío sujeto a impuestos, impuestos recaudados, propiedad de campaña/plataforma y deltas de reembolso/cancelación/modificación; Asegúrese de que los informes conserven los detalles históricos de impuestos almacenados incluso después de que cambien la configuración del proveedor o las categorías del catálogo.
  - Amplíe las pruebas en las capas correctas: pruebas unitarias para la construcción de líneas de impuestos y adaptadores de proveedores, pruebas de fijación para el inicio de NM/respaldo de API y la tributación de envío ZIP.TAX, pruebas de trabajadores para el pago y administración de deltas de impuestos de compromiso, pruebas de navegador para estados de IU provisionales/de error/de respaldo, pruebas de informes para exportaciones de obligaciones tributarias y pruebas de configuración para el manejo de credenciales/preparación del proveedor.
  - Actualice los documentos después de la implementación: `docs/CUSTOMIZATION.md`, `docs/WORKFLOWS.md`, `docs/TESTING.md`, `docs/SECURITY.md`, `worker/README.md`, `docs/PAYMENT_PROCESSOR.md`, las listas de verificación del creador y el texto de ayuda del panel deben explicar la selección de proveedores, la política alternativa, la cadencia de actualización, el comportamiento de las categorías de impuestos, la evidencia almacenada y lo que los operadores deben verificar con un profesional de impuestos.
- [ ] Precios adicionales específicos de cada variante
  - Adapte el patrón de Store con cuidado: Store ya admite precios variantes para `_products` de primera clase y su tiempo de ejecución de sugerencia de complemento resuelve `variant.price ?? product.price`, pero Pool debería tomar prestado solo ese comportamiento de resolución de precios en lugar del catálogo de productos más amplio, la descarga, el SKU y el modelo R2 de Store.
  - Mantenga la arquitectura actual de Pool: los complementos de la plataforma permanecen en `_config.yml` en `add_ons.products`, los complementos de campaña permanecen en el frente de la campaña en `campaign_add_ons`, `/api/add-ons.json` sigue siendo el catálogo estático compartido, el trabajador sigue teniendo autoridad para los totales y `bundleAddOns.unitPrice` persistente sigue siendo el valor denominado en centavos utilizado para el pago, la gestión de promesas, los correos electrónicos, los análisis, los informes y el cumplimiento.
  - Agregue una única regla compartida de resolución de precios para complementos: una variante puede definir un dólar opcional `price`; cuando está presente y es válido, anula el precio base del producto y, cuando está ausente o en blanco, el precio del producto sigue siendo el precio alternativo, por lo que las variantes `id`/`label`/`inventory` existentes mantienen su comportamiento actual.
  - Implemente ayudantes DRY en lugar de matemáticas ad hoc: agregue `resolveAddOnUnitPriceCents(product, variant)` del lado del navegador en la utilidad complementaria compartida, agregue el equivalente del lado del trabajador utilizado por `validateBundleAddOns` y actualice el respaldo heredado de `PoolAddOnUtils` en línea dentro de `assets/js/cart-provider.js` para que las rutas de arranque más antiguas no se desvíen
  - Actualice el carrito y la normalización del estado del producto de Manage Pledge para que cada estado de variante lleve `priceCents`, las tarjetas de producto muestren el precio de la variante seleccionada o un rango de precios apropiado, y cambie una variante con un subtotal de actualizaciones de precio diferente, entradas de vista previa de impuestos/envío, estado sucio del botón de guardar y líneas de pedido de Stripe a través del flujo de selección de complementos existente
  - Actualice la canonicalización del trabajador para que nunca se confíe en los precios enviados del navegador: `validateBundleAddOns` debe volver a calcular `unitPrice` a partir del catálogo y la variante seleccionada, rechazar productos/variantes no válidos como lo hace ahora y mantener la cantidad lógica de asignación de inventario solo para que `add-on-inventory-sold:v1` y las anulaciones de inventario no necesiten un cambio de esquema.
  - Amplíe los editores de complementos del panel de administración para complementos de plataforma y campaña con un campo de precio de variante opcional junto a la etiqueta/inventario de variante, texto de ayuda localizado que explica que los espacios en blanco significan heredar el precio base, validación que rechaza precios negativos/mal formados/no finitos y serialización YAML que escribe `price` solo cuando existe una anulación de variante real.
  - Mantenga `/api/add-ons.json` y `POOL_CONFIG.addOns` como únicas superficies del catálogo; Dado que la inclusión de Liquid ya emite `variants` sin formato, la implementación solo debería necesitar pruebas que demuestren que la variante `price` sobrevive a la configuración/material frontal en las lecturas del navegador y del catálogo de trabajadores.
  - Preservar los límites de informes/contabilidad: los complementos variantes con alcance de campaña aún cuentan para el subtotal de la campaña y el progreso de financiamiento, los complementos de la plataforma aún permanecen en los ingresos por complementos de la plataforma y los informes/análisis/exportaciones de cumplimiento deben continuar leyendo persisted `unitPrice` en lugar de volver a resolver los precios históricos del catálogo actual.
  - Agregue cobertura a todos los arneses existentes: pruebas unitarias para la resolución de precios de servicios públicos adicionales y visualización del estado del producto, pruebas de trabajador para el manifiesto de pago y recálculo de la promesa de gestión con diferentes precios de variantes, pruebas del panel de administración para validación/serialización YAML, pruebas de informes para resultados de precios unitarios persistentes y una ruta de navegador/E2E enfocada que cambia una variante y observa cambios de subtotal/estado de guardado
  - Actualice `docs/ADD_ON_PRODUCTS.md`, la copia de la lista de verificación del creador y el panel/texto de ayuda con ejemplos de precios de complementos heredados versus variantes específicas, incluida una advertencia de que cambiar los precios del catálogo afecta los pagos futuros, mientras que los compromisos existentes mantienen el `unitPrice` guardado.

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número CC, vencimiento y CVV están dentro del iframe de Stripe para cumplir con PCI; no son accesibles para nuestros scripts de autocompletar.
