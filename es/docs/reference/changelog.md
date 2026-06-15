---
title: Registro de cambios
parent: Referencia
nav_order: 1
render_with_liquid: false
lang: es
---

# Registro de cambios

## Última actualización

15 de junio de 2026

## v1.0.5 - 2026-06-14

Alcance de la versión:

- Se agregaron vistas previas de campañas protegidas para superadministradores, usuarios de campañas asignados y correos electrónicos de revisores invitados explícitamente. Los enlaces de vista previa están firmados, tienen alcance de campaña, son visibles en el panel para el administrador de publicación y caducan después de 24 horas.
- Se agregó la creación de campañas de superadministrador para campañas de solo vista previa. Los usuarios de la campaña son opcionales en el momento de la creación; Los superadministradores pueden asignar varios usuarios existentes o crear varios usuarios nuevos, y los usuarios asignados reciben el enlace del panel de administración por correo electrónico cuando se configura la entrega.
- Se agregó el archivado de campañas por superadministradores para campañas no activas. El desarrollo local archiva a través del helper de repositorio montado, mientras que producción despacha el flujo de trabajo validado de GitHub Actions `archive-campaign`.
- Visibilidad pública preservada y límites de SEO: las campañas de solo vista previa permanecen ocultas de las rutas de campaña públicas, índices de inicio/comunidad/complementos, `/api/campaigns.json`, incrustaciones, metadatos de tarjetas compartidas, salida de mapas del sitio, intención de robots y captación previa pública hasta su lanzamiento.
- Se conserva la disciplina presupuestaria de KV: las lecturas del panel, la representación preliminar, la exploración de campos, los borradores locales, los informes, los soportes y los análisis siguen siendo de solo lectura; Las acciones explícitas de creación, vista previa de publicación, guardado de usuario, auditoría de archivo y correo electrónico realizan escrituras limitadas.
- Se agregaron salvaguardias livianas de edición multiusuario con verificaciones de revisión base de GitHub para contenido de campaña y publicaciones de vista previa, conflictos de publicación obsoleta, preservación de borradores locales y eventos de auditoría para acciones de creación, publicación de vista previa, archivo y publicación de contenido.
- Mantuvo la nueva interfaz de usuario del panel accesible, localizada, con capacidad de respuesta móvil y SECO al reutilizar etiquetas de administración compartidas/ayuda/botón de información, lista de correo electrónico, patrones modales, de enfoque y de estado.
- Se mejoró la resiliencia del desarrollo local de Podman con reinicios de servicios supervisados, intentos de recuperación de Podman obsoletos, soporte de ayuda de repositorio local para pruebas de creación/archivo y documentación actualizada de Podman.

- Se agregó publicación de vistas previas protegidas respaldada por GitHub en `/admin/campaign-preview/publish`, lecturas no-store de cargas de vista previa en `/admin/campaign-preview/:slug`, shells genéricos noindex de vista previa en `/campaigns/:slug/preview/` para cada slug de campaña, de modo que los enlaces enviados por correo no dependan de una reconstrucción posterior a la publicación, y allowlists KV de acceso a vista previa por 24 horas en `campaign-preview-reviewers:<slug>`.
- Se agregaron enlaces firmados de vista previa del panel de 24 horas para el administrador de publicación, correos electrónicos de vista previa firmados opcionales del revisor y correos electrónicos de asignaciones de campaña a través del tema de correo electrónico compartido Reenviar y el catálogo i18n.
- Se renderizaron cargas de vista previa protegidas como vistas previas completas de páginas de campaña de solo lectura con CSS/fuentes de campaña cargados, embeds de medios habilitados y controles de promesa deshabilitados.
- Se alineó el renderizado del diario de vista previa protegida con las pestañas del diario público de campaña, los paneles de fase y las tarjetas de entrada con borde punteado.
- Se agregaron controles del panel de superadministrador para la creación de nuevas campañas solo de vista previa y la publicación de vista previa protegida.
- Se agregó archivado de campañas solo para superadministradores para campañas no activas desde Campañas -> Configuración, respaldado localmente por escrituras de repositorio solo para desarrolladores y en producción por un flujo de trabajo manual de GitHub Actions que mueve `_campaigns/<slug>.md` y los medios propiedad de la campaña a `archive/campaigns/<slug>/` sin eliminar los datos archivados.
- Se agregó filtrado público/de solo vista previa en JSON de campaña, índices de página de inicio/comunidad/complementos, páginas localizadas, mapa del sitio, intención de robots y elegibilidad de captación previa.
- Se agregaron verificaciones de conflictos de revisión base para contenido de campaña y publicaciones de vista previa.
- Mantuve los correos electrónicos de vista previa fuera de la campaña Markdown respaldada por GitHub y de los artefactos generados públicamente; La fuente de la campaña ahora solo incluye el indicador de vista previa y `preview_reviewer_emails: []` vacío de compatibilidad.

## v1.0.4 - 2026-06-11

- Se agregaron configuraciones de superadministrador -> Seguimiento del uso del plan para trabajadores de Cloudflare/KV y cuotas de reenvío, con carga automática, nombres de planes detectados por el proveedor cuando estén disponibles, barras de progreso, umbrales de advertencia y enlaces de planes de proveedor mientras se mantienen los tokens de proveedor en el servidor.
- Se agregó un panel de análisis de ingresos netos de campaña/plataforma después de asignar las tarifas reales o estimadas del procesador de Stripe, al tiempo que se conservan los ingresos brutos de la campaña y las tarjetas de ingresos de la plataforma para la conciliación.
- Se agregó la asignación de tarifas de procesador a nivel de componente entre los ingresos de la campaña, los ingresos de la plataforma, los impuestos y el envío para que las exportaciones de tablas/CSV se concilien con las transacciones de saldo almacenadas de Stripe o las estimaciones de tarifas existentes.
- Variables de entorno de seguimiento de uso documentadas y límite de token de lectura de facturación y análisis GraphQL de Cloudflare de solo lectura para el uso y la detección del plan de trabajadores.
- Se reorganizó el andamiaje local del trabajador `.dev.vars` y la salida `npm run secrets:dev` en grupos basados en propósitos, incluidas las configuraciones y anulaciones del proveedor de uso del plan.

## v1.0.3 - 2026-06-01

- Se agregaron secretos de automatización de administración con alcance opcionales: `ADMIN_SETTLEMENT_SECRET` para rutas de liquidación y `ADMIN_BROADCAST_SECRET` para rutas de anuncios, diarios e hitos. Cuando se configura un secreto de ámbito, esas rutas rechazan el `ADMIN_SECRET` más amplio.
- Se agregó serialización de liquidación en el ámbito de la campaña con el objeto duradero `SETTLEMENT_COORDINATOR`, validación por lotes de la misma campaña y claves deterministas de idempotencia de Stripe para grupos de cargos de campaña/partidarios.
- Se aclaró que los pagos de varias campañas aún se despliegan en registros de promesas separados con alcance de campaña, mientras que los bloqueos de liquidación, los lotes, el estado del trabajo y los marcadores de finalización permanecen vinculados a la campaña que se está cargando.
- Documentos actualizados de implementación y operador para `CLOUDFLARE_ACCOUNT_ID`, tokens de implementación de Cloudflare con alcance de usuario, tokens de purga de caché más limitados, tokens de exportación de informes KV de solo lectura y la diferencia entre los secretos de tiempo de ejecución de Worker y los secretos del repositorio de GitHub.
- Se ha reforzado la guía de secretos locales para que `worker/.dev.vars` utilice valores locales separados únicamente y no se trate como una copia de seguridad de secretos de producción.
- Documentación de medios del panel actualizada para el envío del optimizador de imágenes/vídeo con `scope=changed`, cargas con preservación de fuente, preservación de fuentes de audio y limpieza en el momento de la publicación de medios propiedad del panel de la misma campaña sin referencia.
- Se documentó el endurecimiento del presupuesto de lista para el envío de recordatorios de lanzamiento, las colas de reintento de correo electrónico de confirmación de los seguidores y las proyecciones de recuento de ventas de complementos de la plataforma para que las rutas de lectura normales o inactivas eviten escaneos innecesarios del espacio de nombres KV.
- Se actualizó la documentación de registro para reflejar que el registro de la consola permanece habilitado de forma predeterminada, mientras que la salida detallada de depuración/información/registro de menor gravedad está desactivada de forma predeterminada.
- Se agregó manejo de zona horaria de plataforma configurable en todo el estado de la campaña de Jekyll, cuentas regresivas del navegador, automatización del ciclo de vida de los trabajadores, informes de los ejecutores de campañas, configuración del panel y duplicación de la configuración de los trabajadores. El valor predeterminado sigue siendo `America/Denver` por motivos de compatibilidad y los superadministradores pueden elegir entre las zonas horarias admitidas por la IANA.
- Se agregaron recordatorios del próximo lanzamiento de campaña con un formulario de registro público delgado, verificación de Cloudflare Turnstile, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados, trabajos de envío de KV limitados y reenvío de entrega a través del módulo de correo electrónico compartido existente.
- Se redujo el uso de escritura de KV de los trabajadores de referencia al cambiar el latido del programador a nivel de minutos para que persista cada hora en lugar de cada minuto, preservando la visibilidad del estado del cron y manteniendo el presupuesto de escritura de nivel gratuito disponible para mutaciones reales.
- Se actualizó el desarrollo local para que `_config.local.yml` pueda ocultar los widgets Turnstile de recordatorio de lanzamiento de la misma manera que el inicio de sesión del administrador local puede ocultar su widget Turnstile.
- Se amplió la imagen y los envoltorios del optimizador de medios de Podman con `optipng` y `gifsicle` para que la compresión de origen PNG/GIF local utilice el mismo flujo de trabajo de medios del repositorio que la generación responsiva de derivados de imágenes y videos.
- Se agregó un pase de rendimiento de PageSpeed móvil para las páginas de la campaña: los videos principales de YouTube ahora se muestran como carteles locales/fachadas de reproducción y cargan el iframe remoto solo después de la intención de reproducción, evitando el costo inicial de JavaScript/CSS de YouTube.
- Se agregaron precargas de imágenes de héroe responsivas y un escalón derivado WebP `640w` para que las páginas de campañas móviles puedan elegir activos de navegador más pequeños entre las variantes `480w` y `960w` existentes.
- Se actualizó el optimizador de medios para omitir los derivados WebP receptivos generados durante la optimización de la fuente, manteniendo actualizados los recursos del navegador generados sin volver a codificarlos de forma recursiva.

## v1.0.2 - 2026-06-01

- Se agregaron correcciones de rendimiento de páginas públicas de la revisión de PageSpeed: las páginas de campañas de video remoto ya no precargan imágenes destacadas ocultas, las imágenes de nivel optan por la decodificación diferida/asíncrona, los logotipos de marca predeterminados reservan sus dimensiones intrínsecas y las páginas públicas evitan las ansiosas preconexiones de Stripe antes de la intención del carrito.
- Se amplió el proceso de optimización de medios del panel para generar variantes de imágenes WebP responsivas para imágenes de origen PNG, JPEG y GIF, de modo que las plantillas de campañas públicas puedan servir activos de navegador más pequeños y al mismo tiempo mantener las cargas originales como fuentes de respaldo de la verdad.
- Se agregó una opción manual `scope=all` al flujo de trabajo **Optimizar medios del panel** para que las campañas existentes se puedan reprocesar a través del mismo canal de medios utilizado para las cargas de nuevos paneles.
- Se actualizaron las plantillas de campaña, nivel, tarjeta, galería y contenido-imagen para usar variantes responsivas generadas cuando existan sin cambiar la estructura de la página visible o las referencias de Markdown de la campaña.

## v1.0.1 - 2026-05-29

- Se agregó la tarifa de transacción de saldo real de Stripe/captura neta para promesas cobradas recientemente y una ruta de reposición de superadministrador para registros de promesas cobradas más antiguas.
- Panel de análisis actualizado para preferir las tarifas reales almacenadas de Stripe cuando estén disponibles, mantener las tarifas estimadas solo cuando sea necesario y etiquetar claramente los valores mixtos/estimados.
- Se agregaron cargas de medios del editor de contenido administrativo para bloques de contenido de campaña y diario, con vistas previas locales inmediatas y carga en el momento de la publicación en los directorios correctos de activos de la campaña.
- Se agregó el canal de optimización de medios del panel: `npm run media:optimize`, `npm run media:optimize:check` y un flujo de trabajo de GitHub Actions que comprime sin pérdidas las imágenes cargadas, genera derivados de video WebM de alta calidad y reescribe referencias literales de video de configuración/campaña después de que existan los derivados.
- Se mantuvieron las cargas del panel para preservar la fuente en el Worker mientras se documentaba el paso de optimización externa para operadores y bifurcaciones.
- Made Supporters y Analytics devuelven vistas vacías de solo lectura para campañas sin índices de compromiso en lugar de bloquear paneles de campaña nuevos o vacíos.

## v1.0.0 - 2026-05-26

- Se agregó el panel de administración privado como superficie de operaciones y edición del navegador compatible en `/admin/` y `/es/admin/`.
- Se agregó autenticación de administrador de enlace mágico con alcance de rol para superadministradores y usuarios de campañas, con sesiones respaldadas por cookies, comprobaciones de origen/CSRF y API de administración seguras para el navegador que no exponen `ADMIN_SECRET`.
- Se agregó soporte de protección de desafío de inicio de sesión de administrador para implementaciones compatibles con Cloudflare Turnstile mientras se mantienen explícitas las omisiones locales/de prueba.
- Se agregaron pestañas del panel para Configuración, Complementos, Campañas, Análisis, Informes, Partidarios, Marketing, Usuarios, Secretos y credenciales, y Diagnóstico en tiempo de ejecución.
- Se reemplazó el modelo de edición de Pages CMS con el flujo de trabajo basado en el panel, manteniendo `_config.yml` y la campaña Markdown como la fuente de verdad revisable frente a la bifurcación.
- Se agregó edición de bloques WYSIWYG para contenido de campaña y entradas de diario, incluida configuración de medios, edición de enlaces, formato en línea estilo Markdown, vistas previas móviles, borradores locales y seguimiento del estado de publicación.
- Se agregó edición del panel para configuraciones de campaña, niveles, elementos de soporte, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario, decisiones, complementos de plataforma y configuraciones de plataforma.
- Se agregó manejo de carga en el panel para medios de campaña, activos de marca, imágenes complementarias y videos destacados utilizando directorios de activos basados en convenciones y nombres de archivos estilo slug.
- Se agregó un panel de administración de usuarios respaldado por Worker KV en `admin-users:v1`, separado de los flujos de publicación respaldados por GitHub.
- Se agregaron correos electrónicos de notificación para los usuarios del panel recién creados cuando se configura Reenviar; las ediciones del usuario no reenvían invitaciones.
- Se agregaron herramientas de marketing en el panel para la creación de URL de referencia/UTM, códigos de referencia guardados, interfaz de usuario de creación de inserción reutilizable y fragmentos de lanzamiento copiables.
- Se corrigieron las vistas previas de inserción de marketing para campañas con medios destacados de YouTube o Vimeo para que las barras de progreso, los hitos y las etiquetas de objetivos ampliados permanezcan contenidos.
- Se agregaron vistas de análisis, informes y partidarios del panel de control con alcance de rol con tablas ordenables/filtrables, visualización del centavo exacto de dólar y descargas CSV; Las vistas previas/descargas de informes no envían correos electrónicos ni escriben marcadores de envío.
- Se preservó el objetivo de nivel gratuito KV de Cloudflare Workers manteniendo las lecturas normales del panel, las vistas previas, los filtros, los análisis y los borradores locales en cero escrituras KV.
- Configuración del remitente de correo electrónico de promesa alineada con el dominio del remitente de reenvío autorizado y configuración documentada del dominio del remitente para bifurcaciones.
- Se hicieron explícitos los permisos de implementación de GitHub Pages para el flujo de trabajo de implementación de producción.

## v0.9.5 - 2026-05-03

- Se alineó el desarrollo de Worker local con GitHub Actions moviendo la imagen de Podman Worker al Nodo 24.
- Se actualizó el Worker `compatibility_date` a `2026-05-03` para que Wrangler 4/Miniflare comience limpiamente en el Nodo 24.
- Se actualizaron los contenedores de pruebas de host y Podman para preferir el Nodo 24, con el Nodo 22 como el respaldo mínimo de Wrangler 4.
- Se cambió el arranque de dependencia de Podman Worker a `npm ci` para que los inicios del contenedor local no reescriban `worker/package-lock.json`.
- Documentación de lanzamiento para creadores ampliada con complementos, inserciones alojadas, expectativas de respaldo de impuestos/envío, decisiones de envío gratuito, destinatarios de informes y transferencia de cumplimiento.
- Se agregó una ruta de lista de verificación de creadores en español para la incorporación de creadores y bifurcaciones.

## v0.9.4 - 2026-05-02

- Hito anterior para los informes de los ejecutores de campaña, el refuerzo de la implementación, el trabajo de la lista de verificación de los creadores y las actualizaciones de compatibilidad de la implementación de los trabajadores.
