---
title: Registro de cambios
parent: Referencia
nav_order: 1
render_with_liquid: false
lang: es
---

# Registro de cambios

## Última actualización

16 de julio de 2026

## v1.1.2 - 2026-07-14

Alcance de la versión:

- Se corrigió la actualización engañosa del mapa del sitio al emitir `lastmod` solo desde fechas reales de página/campaña, y se amplió la auditoría generada para rechazar XML con formato incorrecto, duplicados, marcas de tiempo no válidas/futuras, URL privadas y deriva de datos estructurados.
- Se agregó una auditoría de rastreo posterior a la implementación sin dependencias que compara las respuestas de los mapas de sitio ordinarios y de inspección de Google, valida el estado de los mapas de sitio/robots y los tipos MIME, y recupera cada URL pública enviada con reintentos de propagación limitados.
- Se agregaron páginas de productos de Shopping localizadas y cerradas por fallas que reutilizan el nivel físico destacado de una campaña, el comportamiento del carrito existente, la identidad configurada del autor/empresa y los datos de políticas. La publicación del producto requiere un interruptor de habilitación explícito además de datos completos sobre la recompensa física y una fecha exacta de disponibilidad esperada.
- Mantuvo desactivado el candidato a cartel destacado de Their Love; confirmar su fecha exacta de disponibilidad y completar la verificación de Merchant Center más la configuración de feed/destino siguen siendo características futuras explícitas antes de que se espere la colocación de la pestaña Compras.
- Se agregaron datos de contacto/política de devolución del comerciante de la organización, metadatos enfocados en productos/ofertas y enlaces directos a anclajes estables de la política de envío y devoluciones junto a la marca de pie de página de DUST WAVE en la computadora de escritorio/tableta y debajo de los Términos en el menú móvil; Los controles automatizados garantizan que una política de no devoluciones nunca publique una ventana de devolución ficticia.
- Reescribió las páginas públicas Acerca de y Términos en inglés y español neutral de EE. UU. y Latinoamérica, utilizando valores de identidad/contacto `_config.yml` y documentando cargos de todo o nada, envío, valores predeterminados de venta final, manejo de errores de cumplimiento, verificación de informes de siete días, privacidad y reglas de envío de creatividades.
- Transferencia revisada de Store v1.0.8: The Pool ya contenía el precio, los medios, Stripe, la conciliación y el trabajo de correo electrónico duradero relevantes; adoptó la solución de recuperación de AWS CLI alojada en GitHub; expuso las API de revisión/revocación y búsqueda de auditoría/CSV de sesión existentes a través de secciones de configuración localizadas; hizo que sus guías de botones de información compartidos, filtros, tablas, controles de revocación, acciones en lenguaje sencillo, objetivos normalizados (incluidos los slugs de prueba locales generados) y explicaciones de estado/cambio fueran responsivos y comprensibles desde el escritorio hasta el dispositivo móvil, conservando al mismo tiempo identificadores canónicos para filtrado, diagnóstico y exportación; secciones de configuración compartidas alineadas según el orden de Store manteniendo las costuras específicas de The Pool; Brand & SEO adaptados a la política de compras sin devoluciones; y se excluyen las superficies de preparación, caché, catálogo, pedido, cupón, ticket, descarga, R2 y multiprocesador específicas de Store.
- Se igualó la capacidad de inicio de sesión de administrador local de Store al representar la URL de inicio de sesión devuelta solo para desarrollo como un enlace **Abrir administrador** localizado y al mismo tiempo mantener los enlaces de inicio de sesión implementados solo para correo electrónico.
- Se reforzaron los ayudantes previos a la fusión de Jekyll para que un host fallido o una compilación de Podman no puedan pasar a la minificación y validar la salida obsoleta de `_site`; la puerta de liberación ahora demuestra una compilación recién generada antes de las comprobaciones de artefactos.

Limpieza posterior al lanzamiento:

- Se eliminó el resto implícito de la fecha de recopilación Jekyll del mapa del sitio, el artículo de Open Graph, JSON-LD y se generaron metadatos de productos de compras para que las implementaciones no puedan suplantar las fechas de publicación o modificación del contenido. El mapa del sitio `lastmod` ahora requiere un `last_modified_at` creado; Las fechas de los artículos de la campaña utilizan `published_at` explícito cuando se proporcionan y, en caso contrario, la fecha de inicio de la campaña.
- Se agregó `/sitemap.txt` como un mapa del sitio de diagnóstico generado utilizando exactamente el mismo selector de elementos públicos compartido que `/sitemap.xml`, sin anunciar un segundo mapa del sitio canónico en `robots.txt`. Las auditorías generadas y posteriores a la implementación requieren que su lista de URL coincida exactamente con el mapa del sitio XML y compare las respuestas de inspección ordinarias con las de Google para ambos formatos.
- Evidencia registrada posterior a la implementación de que la herramienta de inspección oficial de Search Console llegó al mapa del sitio de producción desde direcciones propiedad de Google sin mitigación Cloudflare mientras recibía una respuesta HTTP 200 XML válida, aislando el error genérico restante de la prueba en vivo del firewall del sitio y el comportamiento de origen.

## v1.1.1 - 2026-07-12

Alcance de la versión:

- Se agregó un manifiesto de medios de repositorio determinista y reconstruible que cubre campañas/imágenes compartidas, videos y audio; Los hash de origen, las dimensiones, la duración, el tamaño del archivo, los derivados WebP/WebM responsivos, las ubicaciones de referencia, el estado de optimización y los derivados más grandes omitidos intencionalmente siguen siendo revisables en Git.
- Se amplió el selector de medios del panel existente con búsqueda, pestañas de tipos accesibles, clasificación reciente/por nombre, metadatos enriquecidos, advertencias de optimización y presupuesto de ubicación, visibilidad de referencias, informes de referencias rotas, selección de video/póster/audio local y acciones de reparación con alcance de función a través del flujo de trabajo del optimizador existente.
- Se agregó un reemplazo seguro de la fuente de la misma campaña con protección contra conflictos SHA GitHub, se mantuvieron los derivados generados fuera de los resultados del selector independiente y se mantuvo el repositorio como la única autoridad de medios; no se introdujo ninguna base de datos de medios KV ni backend de almacenamiento alternativo.
- Se agregó creación explícita de imágenes decorativas y se requiere texto alternativo para imágenes significativas; El contenido alternativo vacío heredado sigue siendo compatible con una advertencia de migración.
- Integración reforzada de Stripe con una versión API explícita, errores/observabilidad redactados normalizados, idempotencia determinista en escrituras seguras para reintentos, metadatos de tiempo/USD explícitos, marcadores de webhook de 35 días con concesiones de procesamiento y un diario mínimo de eventos de procesador de 400 días.
- Se hizo que la liquidación fuera segura contra fallas y reanudaciones con un estado de grupo de precarga duradero, reutilización segura dentro de la ventana de idempotencia de Stripe, puntos de control de trabajos obsoletos, recuperación exitosa de PaymentIntent y paradas de atención de necesidades en lugar de recargas ciegas después de resultados ambiguos.
- Se agregó conciliación programada y activada por superadministrador de la verdad de aportes indexadas, Stripe PaymentIntents y trabajos de liquidación, registrando evidencia `reconciliation-break:v1:*` abierta/resuelta sin escaneos de espacio de nombres KV.
- Transacciones de producción enrutadas, informes, actualizaciones de campaña, Blast, recordatorio de lanzamiento y correo electrónico de pago abandonado a través de una bandeja de salida KV compartida con cargas útiles congeladas, idempotencia determinista Resend, reintentos limitados, arrendamientos fallidos, webhooks de entrega de proveedores y evidencia de entrega a largo plazo con privacidad minimizada; El inicio de sesión de administrador y los envíos de prueba siguen siendo inmediatos.
- Se agregó la cancelación de la suscripción con un solo clic en el ámbito de la campaña para el diario, los hitos y el correo electrónico de anuncios, además de la supresión local permanente de rebotes/quejas compatible con las API de webhook y correo electrónico de Resend.
- Se agregaron medios enfocados, cliente Stripe, bandeja de salida, firma de webhook, reintento, supresión y cobertura de regresión Worker existente; configuración actualizada, configuración de Worker, pago/correo electrónico/seguridad/flujo de trabajo/panel/documentación de prueba y estado de la hoja de ruta para la versión completa.

## v1.1.0 - 2026-07-12

Alcance de la versión:

- Se agregaron precios opcionales específicos de variantes a los complementos de plataforma y campaña. Los precios en blanco heredan el precio base del producto, las anulaciones explícitas de cero dólares siguen siendo válidas y las tarjetas de carrito/Administrar aporte actualizan el precio mostrado cuando cambia la variante seleccionada.
- Autoridad monetaria mantenida en Worker: a las variantes complementarias nuevas o modificadas se les cambia el precio del catálogo actual, se ignoran los precios enviados por el navegador y un producto/variante sin cambios en un aporte existente conserva su `unitPrice` histórico válido a través de ediciones de solo cantidad.
- Se amplió el modelo de complemento compartido, las alternativas del navegador heredado, el editor de productos de administración, la validación y la serialización YAML sin introducir un segundo catálogo ni migrar productos existentes. Los precios de productos, variantes, catálogos e históricos no pueden eludir el límite de cantidad canónico `$1,000,000`.
- Se reemplazaron los ansiosos fondos de tarjetas de campaña de tamaño completo con fuentes WebP receptivas y decodificación diferida, lo que redujo la transferencia limitada medida de la página de inicio de aproximadamente 4,0 MB a 1,5 MB y el LCP de aproximadamente 20,3 segundos a 5,4 a 6,6 segundos.
- Se agregó Lighthouse centralizado y específico de ruta y evidencia de liberación de política de caché ampliada junto con los presupuestos de activos generados existentes. Se cubren once objetivos públicos/privados implementados y la caché Workers permanece deshabilitada hasta que la evidencia representativa demuestre el beneficio de p95 configurado.
- Se hicieron ejecutables los límites de tiempo del panel y Worker: las pruebas del navegador consumen presupuestos de preparación, cambio de pestañas y procesamiento de tablas; se lee el resumen/configuración del panel de muestras Worker; y una auditoría autenticada redactada evalúa los techos p95 configurados sin recopilar solicitudes ni cargas útiles del cliente.
- Se reforzaron las fallas de administración para que las respuestas no autorizadas sean privadas y no se puedan almacenar en caché, y se fijó la versión limpia y compatible de Lighthouse para que tanto las auditorías de producción como las de dependencia completa pasen sin vulnerabilidades conocidas.
- Se movió y actualizó `AGENTS.md` en la raíz del repositorio para que los contribuyentes y los agentes de codificación descubran automáticamente las invariantes de pago, seguridad, rendimiento, recuperación y versión actuales.

## v1.0.9 - 2026-07-12

Alcance de la versión:

- Modelo de respaldo y recuperación ante desastres adaptado a los límites de Git, `PLEDGES`, `VOTES`, `RATELIMIT`, Stripe y Durable Object de The Pool, con un RPO/RTO aprobado de cuatro horas y una política de retención de instantáneas de lanzamiento de 7 días/5 semanas/12 meses más.
- Se agregaron metadatos cubiertos por suma de verificación e instantáneas cifradas con valor KV, verificaciones de límites de repositorio, verificación de encriptación de antigüedad/GPG, recibos de liberación, poda de retención segura, copias fuera del dispositivo solo para agregar y evidencia de preparación sin exportación de valor secreto.
- Se agregaron planes de restauración basados en clasificación para local, vista previa y producción; validación de la familia autoritaria; reconstrucciones de estados derivados; exclusiones de cuarentena; limpieza de vista previa exacta; verificación de relectura; y puertas de mantenimiento de producción explícito, Stripe, resolución, conflicto, instantánea previa a la restauración y reconocimiento.
- Se agregaron ensayos de restauración semanales sintéticos y simulacros de vista previa protegidos de bajo tráfico trimestrales con datos de producción capturados deshabilitados hasta que se configuren las credenciales protegidas y la aprobación del operador. Los simulacros protegidos se cargan en un almacenamiento fuera de cuenta compatible con S3 y verifican una descarga de bytes idénticos antes de la restauración.
- Se agregó conciliación Stripe de solo lectura para los totales de aportes instantáneas y el estado de PaymentIntent, además de evidencia de verificación previa del tráfico Cloudflare de solo agregación.
- Dividió las actualizaciones de páginas de rutina desde Worker revisado manualmente/implementación de producción completa, fijó todas las acciones GitHub en confirmaciones inmutables, agregó cobertura mensual de Dependabot para acciones y ambos proyectos npm, e hizo que las sondas CLI Stripe no fueran interactivas.
- Se agregó un modelo de lectura de aporte The Pool compartido con marcas de agua deterministas seguras para la privacidad, respuestas sin cambios y lecturas masivas de producción KV en lotes de 100 en análisis, patrocinadores, informes, reparación de índices, liquidaciones y reposiciones financieras.
- Se agregó un historial de inicio de sesión de administrador con privacidad minimizada, revisión de sesiones activas/recientes, revocación explícita de sesiones, metadatos de auditoría con capacidad de búsqueda, exportaciones de CSV de auditoría seguras para fórmulas y carga diferida de Turnstile hasta que se conozca el estado no autenticado.
- Se agregó un conciliador de reglas de respuesta de administrador Cloudflare administrado y verificación pública para `private, no-store, no-transform, max-age=0, must-revalidate` en rutas de administración en inglés y español.
- Dividió el CSS exclusivo para administradores de la hoja de estilo pública, pospuso el CSS de fuente de visualización de Adobe, estableció presupuestos medidos para los activos generados y mantuvo la caché Workers desactivada hasta que la evidencia representativa muestre al menos un beneficio de p95 del 40 %.
- Se agregaron verificaciones semanales de deriva de la postura de producción, paquetes mensuales de revisión en español con hash de fuente sin reclamar revisión profesional, un flujo de trabajo E2E Podman programado y una puerta de recursos de suite de lanzamiento Podman de 6 GiB.
- Se agregaron artefactos de evidencia de proveedor JSON desinfectados para flujos de trabajo de recuperación/postura posteriores, con recuentos de fallas/advertencias/saltos y exclusiones explícitas de credenciales/datos de clientes.

## v1.0.8 - 2026-07-01

Alcance de la versión:

- Se adaptó el hardening de Cloudflare Rocket Loader derivado de Store al hacer que los layouts/includes propios de Pool emitan scripts con `data-cfasync="false"`, cubriendo campañas públicas, carritos, vista previa, administración, comunidad, resultados de aporte y superficies de administración.
- Carga de datos de marketing de administrador reforzada, por lo que los códigos de referencia guardados y el estado del proceso de pago abandonado se cargan lentamente solo cuando un administrador autenticado abre Marketing, con guardias de estado de carga y en vuelo con alcance de campaña.
- Se recordó la última pestaña del panel de administración más la sección Configuración, la campaña seleccionada de Campañas y la subpestaña Campañas en el estado local del navegador para que las recargas devuelvan a los administradores al mismo contexto de trabajo sin escrituras de Worker o KV.
- Se agregó una corrección global de navegador de proveedor de QR explícita para que el creador de QR de marketing de administrador no dependa de globales de script clásico sensibles al optimizador.
- Se agregó una auditoría de integridad local y cobertura de unidades para mantener los catálogos i18n compatibles alineados con el inglés.
- Se agregó cobertura de regresión de plantilla que escanea diseños/incluye scripts locales propios que no tienen la opción de exclusión de Rocket Loader.
- Se movieron los archivos de configuración de Vitest a los módulos ESM `.mts` y se actualizaron los scripts/exclusiones de Jekyll para evitar la ruta obsoleta de la API del nodo CJS de Vite.
- Se agregó una auditoría de SEO del sitio generado (`npm run test:seo`) adaptada de Store, se conectó a la puerta de combinación y se movió la representación de la URL del mapa del sitio a una inclusión compartida que emite alternativas de hreflang localizadas.
- Herramientas de evidencia de lanzamiento adaptadas para Pool con `release:smoke`, accesibilidad enfocada, i18n/SEO renderizado, evidencia de aporte/informe, preparación del proveedor, humo de pago y comandos de transcripción de lector de pantalla opcionales.
- Se agregó un flujo de trabajo de acciones de GitHub de evidencia del proveedor de lanzamiento para evidencia estricta de DNS de Cloudflare a través de un token de lectura de DNS dedicado.
- Se agregó soporte de ejecución en seco de correo electrónico sin envío de Pool a través de `POOL_EMAIL_DRY_RUN` / `RESEND_EMAIL_DRY_RUN` para que los humos de liberación puedan generar cargas útiles de correo electrónico de soporte/informe/administrador sin llamar a Resend.
- Se agregó evidencia de accesibilidad de lanzamiento específica de Pool para el orden de enfoque del aporte de campaña, actualizaciones de estado en vivo de recordatorio de lanzamiento y superficies de carrito de campaña de movimiento reducido.
- Se integró la cordura del comando de evidencia de liberación en la puerta de fusión y se habilitó el modo de ejecución en seco del correo electrónico de Pool para ejecuciones de humo de fusión local/CI.
- Se agregó pulido de metadatos móviles/CSS desde Store para que los encabezados de documentos públicos, administrativos, de administración, de comunidad, incrustados, de vista previa y de resultados de aporte opten por no participar en la detección automática de teléfono/fecha/dirección/correo electrónico, mientras que los controles compartidos heredan el tema actual de manera consistente.
- Se actualizó la solicitud de configuración del administrador para enviar el idioma preferido actual, manteniendo la normalización de filas i18n del lado del cliente existente de Pool lista para la localización del esquema del lado del trabajador.

## v1.0.7 - 2026-06-19

Alcance de la versión:

- Se agregó el estado del recordatorio de pago abandonado en el ámbito de la campaña en Marketing con recuentos agregados de colas/resultados, resultados recientes, controles de supresión/borrado del alcance, identificadores de correo electrónico con hash, eventos de auditoría, enlaces de reanudación de pago firmado y sin acciones de carrito abandonado específicas de reintento.
- `npm run setup:deploy` reforzado con reutilización del espacio de nombres Cloudflare KV, reutilización/creación de resultados de ejecución en seco más clara, comprobaciones de preparación del proveedor de solo lectura en vivo, `--skip-readiness` para ejecuciones en seco limitadas y cobertura de unidades basadas en subprocesos para rutas de ejecución en seco, secreto local, KV de producción, preparación y secreto generado.
- Se agregaron borradores compartidos explícitos de Marketing y Blast con un registro KV con alcance de campaña por superficie, vencimiento de 7 días, protección contra conflictos de revisión y sin escrituras en segundo plano.
- Se agregaron informes de rendimiento UTM/referencia de Analytics para enlaces de campaña guardados y no guardados, incluidos agregados de fuente/medio/campaña/contenido UTM de índices de aporte de campaña existentes sin escaneos de espacios de nombres KV.
- Se agregó un selector de medios de imágenes WYSIWYG compartido para los bloques de imágenes de contenido de campaña, diario y Blast. Los usuarios de la campaña ven medios relacionados con la campaña; Los superadministradores también pueden seleccionar imágenes compartidas/predeterminadas. El selector es de solo lectura y no agrega ningún estado KV nuevo.

## v1.0.6 - 2026-06-18

Alcance de la versión:

- **Campañas -> Marketing** ampliadas a un espacio de trabajo de promoción de campañas más completo sin agregar otra vista de panel de nivel superior. Los administradores de campañas pueden crear URL rastreadas, guardar códigos de referencia, obtener una vista previa/descargar códigos QR de campaña como PNG/SVG y utilizar el creador de inserciones de campañas existente desde la misma pestaña.
- Se agregaron **Campañas -> Explosión** para envíos masivos de correo electrónico a los patrocinadores. Los usuarios de campaña asignados y los superadministradores pueden redactar con el editor de contenido WYSIWYG compartido, cargar imágenes alojadas en la campaña a través del canal de medios existente, vincular videos de YouTube/Vimeo de forma segura por correo electrónico, enviarse pruebas a sí mismos, enviar explosiones en vivo a los patrocinadores de la campaña indexadas y revisar el historial de envíos de solo lectura.
- Se agregó validación automática de ejecución en seco de Blast antes de los envíos de prueba o en vivo. Los ensayos validan el contenido y la audiencia del índice de aportes de campaña sin enviar correos electrónicos, escribir registros de auditoría ni enumerar espacios de nombres KV; Los envíos en vivo requieren el hash de prueba coincidente y escriben el evento de auditoría después del envío.
- Se agregó generación de QR local en el navegador adaptada del enfoque `1612elphi/delphitools` con licencia del MIT, lo que mantiene las vistas previas y descargas de QR libres de lecturas/escrituras de Worker.
- Se agregaron recordatorios de pago abandonado basados ​​en el consentimiento para la ruta de pago propia. Los patrocinadores deben optar explícitamente por participar, los recordatorios se ponen en cola solo después de que la creación de la sesión de Stripe sea exitosa, los aportes completados eliminan los recordatorios en cola, las audiencias enviadas/suprimidas se deduplican y los enlaces para cancelar la suscripción se firman.
- Se mantuvo la programación de pago abandonado en el nivel gratuito con `abandoned-cart-queue:v1`, lotes limitados, límites de retención, marcadores de envío/supresión y ticks cron inactivos que omiten los escaneos de la lista de espacios de nombres KV.
- Se agregó el asistente multiplataforma `npm run setup:deploy` para configuración local y de producción. La CLI de Nodo libre de dependencia admite ejecuciones en seco, generación de secretos locales, sincronización de configuración, creación/actualización de Cloudflare KV, escrituras de secretos de trabajadores, escrituras de secretos de repositorio de GitHub, `gh`/`wrangler`/verificaciones de autenticación de CLI de Stripe opcionales y `wrangler deploy` opcional.

## v1.0.5 - 2026-06-14

Alcance de la versión:

- Se agregaron vistas previas de campañas protegidas para superadministradores, usuarios de campañas asignados y correos electrónicos de revisores invitados explícitamente. Los enlaces de vista previa están firmados, tienen alcance de campaña, son visibles en el panel para el administrador de publicación y caducan después de 24 horas.
- Se agregó la creación de campañas de superadministrador para campañas de solo vista previa. Los usuarios de la campaña son opcionales en el momento de la creación; Los superadministradores pueden asignar varios usuarios existentes o crear varios usuarios nuevos, y los usuarios asignados reciben el enlace del panel de administración por correo electrónico cuando se configura la entrega.
- Se agregó el archivo de campañas de superadministrador para campañas no activas. El desarrollo local archiva a través del asistente de repositorio montado, mientras que la producción envía el flujo de trabajo validado de GitHub Actions `archive-campaign`.
- Visibilidad pública preservada y límites de SEO: las campañas de solo vista previa permanecen ocultas de las rutas de campaña públicas, índices de inicio/comunidad/complementos, `/api/campaigns.json`, incrustaciones, metadatos de tarjetas compartidas, salida de mapas del sitio, intención de robots y captación previa pública hasta su lanzamiento.
- Se conserva la disciplina presupuestaria de KV: las lecturas del panel, la representación preliminar, la exploración de campos, los borradores locales, los informes, los soportes y los análisis siguen siendo de solo lectura; Las acciones explícitas de creación, vista previa de publicación, guardado de usuario, auditoría de archivo y correo electrónico realizan escrituras limitadas.
- Se agregaron salvaguardias livianas de edición multiusuario con verificaciones de revisión base de GitHub para contenido de campaña y publicaciones de vista previa, conflictos de publicación obsoleta, preservación de borradores locales y eventos de auditoría para acciones de creación, publicación de vista previa, archivo y publicación de contenido.
- Mantuvo la nueva interfaz de usuario del panel accesible, localizada, con capacidad de respuesta móvil y SECO al reutilizar etiquetas de administración compartidas/ayuda/botón de información, lista de correo electrónico, patrones modales, de enfoque y de estado.
- Se mejoró la resiliencia del desarrollo local de Podman con reinicios de servicios supervisados, intentos de recuperación de Podman obsoletos, soporte de ayuda de repositorio local para pruebas de creación/archivo y documentación actualizada de Podman.
- Se agregó una publicación de vista previa protegida respaldada por GitHub en `/admin/campaign-preview/publish`, lecturas de carga útil de vista previa no-store en `/admin/campaign-preview/:slug`, shells de vista previa genéricos sin índice en `/campaigns/:slug/preview/` para cada slug de campaña para que los enlaces enviados por correo electrónico no dependan de una reconstrucción posterior a la publicación y listas permitidas de acceso a vista previa de KV de 24 horas en `campaign-preview-reviewers:<slug>`.
- Se agregaron enlaces firmados de vista previa del panel de 24 horas para el administrador de publicación, correos electrónicos de vista previa firmados opcionales del revisor y correos electrónicos de asignaciones de campaña a través del tema de correo electrónico compartido Resend y el catálogo i18n.
- Se renderizaron cargas útiles de vista previa protegidas como vistas previas completas de páginas de campaña de solo lectura con CSS/fuentes de campaña cargados, incrustaciones de medios habilitadas y controles de aporte deshabilitados.
- Representación del diario de vista previa protegida coincidente con las pestañas del diario de campaña público, paneles de fase y tarjetas de entrada con guiones.
- Se agregaron controles del panel de superadministrador para la creación de nuevas campañas solo de vista previa y la publicación de vista previa protegida.
- Se agregó archivado de campañas solo para superadministradores para campañas no activas desde Campañas -> Configuración, respaldado localmente por escrituras de repositorio solo para desarrolladores y en producción por un flujo de trabajo manual de GitHub Actions que mueve `_campaigns/<slug>.md` y los medios propiedad de la campaña a `archive/campaigns/<slug>/` sin eliminar los datos archivados.
- Se agregó filtrado público/de solo vista previa en JSON de campaña, índices de página de inicio/comunidad/complementos, páginas localizadas, mapa del sitio, intención de robots y elegibilidad de captación previa.
- Se agregaron verificaciones de conflictos de revisión base para contenido de campaña y publicaciones de vista previa.
- Mantuve los correos electrónicos de vista previa fuera de la campaña Markdown respaldada por GitHub y de los artefactos generados públicamente; La fuente de la campaña ahora solo incluye el indicador de vista previa y `preview_reviewer_emails: []` vacío de compatibilidad.

## v1.0.4 - 2026-06-11

- Se agregó Configuración de superadministrador -> Seguimiento del uso del plan para cuotas de trabajadores de Cloudflare/KV y Resend, con carga automática, nombres de planes detectados por el proveedor cuando estén disponibles, barras de progreso, umbrales de advertencia y enlaces de planes de proveedor mientras se mantienen los tokens de proveedor en el lado del servidor.
- Se agregó un panel de análisis de ingresos netos de campaña/plataforma después de asignar las tarifas reales o estimadas del procesador de Stripe, al tiempo que se conservan los ingresos brutos de la campaña y las tarjetas de ingresos de la plataforma para la conciliación.
- Se agregó la asignación de tarifas de procesador a nivel de componente entre los ingresos de la campaña, los ingresos de la plataforma, los impuestos y el envío para que las exportaciones de tablas/CSV se concilien con las transacciones de saldo almacenadas de Stripe o las estimaciones de tarifas existentes.
- Variables de entorno de seguimiento de uso documentadas y límite de token de lectura de facturación y análisis GraphQL de Cloudflare de solo lectura para el uso y la detección del plan de trabajadores.
- Se reorganizó el andamiaje local del trabajador `.dev.vars` y la salida `npm run secrets:dev` en grupos basados en propósitos, incluidas las configuraciones y anulaciones del proveedor de uso del plan.

## v1.0.3 - 2026-06-01

- Se agregó manejo de zona horaria de plataforma configurable en todo el estado de la campaña de Jekyll, cuentas regresivas del navegador, automatización del ciclo de vida de los trabajadores, informes de los ejecutores de campañas, configuración del panel y duplicación de la configuración de los trabajadores. El valor predeterminado sigue siendo `America/Denver` por motivos de compatibilidad y los superadministradores pueden elegir entre las zonas horarias admitidas por la IANA.
- Se agregaron recordatorios del próximo lanzamiento de campaña con un formulario de registro público delgado, verificación de Cloudflare Turnstile, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados, trabajos de envío de KV limitados y entrega de Resend a través del módulo de correo electrónico compartido existente.
- Se agregó serialización de liquidación de campañas respaldada por Durable Object, claves de idempotencia deterministas Stripe y rechazo de lotes de campañas mixtas para que la liquidación programada/manual no pueda superponerse a los cargos de la misma campaña mientras los carros de campañas múltiples permanecen dentro del alcance de la campaña.
- Se agregaron secretos de automatización de administración con alcance para rutas de liquidación y transmisión. Cuando se configuran, `ADMIN_SETTLEMENT_SECRET` y `ADMIN_BROADCAST_SECRET` rechazan el uso alternativo del `ADMIN_SECRET` más amplio.
- Credenciales de implementación de producción reforzadas al requerir autenticación Cloudflare basada en token, documentar la forma del token API de usuario Cloudflare requerida para implementaciones Wrangler, dividir la purga de caché en `CLOUDFLARE_CACHE_PURGE_TOKEN` y eliminar secretos de repositorio heredados o no utilizados.
- Se fortaleció el flujo de trabajo de implementación para que la optimización de medios del panel abra una solicitud de extracción en lugar de enviar los cambios de medios generados directamente a `main`.
- Valores predeterminados de CORS privados ajustados, redacción de errores Stripe, pruebas de autenticación de pago/liquidación y generación de secretos locales para secretos de administración con alcance.
- Contenido público reforzado y límites de inserción: la desinfección de enlaces de Markdown de campaña ahora maneja esquemas inseguros anidados/codificados, las incrustaciones alojadas utilizan orígenes de destino específicos de postMessage y las páginas de administración tokenizadas optan por un comportamiento sin referencia.
- Se redujo el uso de escritura de KV de los trabajadores de referencia al cambiar el latido del programador a nivel de minutos para que persista cada hora en lugar de cada minuto, preservando la visibilidad del estado del cron y manteniendo el presupuesto de escritura de nivel gratuito disponible para mutaciones reales.
- Se redujo el uso de la lista de referencia Workers KV al agregar marcadores de estado de cola para el envío de recordatorios de lanzamiento y los reintentos de correo electrónico de confirmación del colaborador, de modo que los ticks programados inactivos omitan los escaneos de espacios de nombres y los reintentos esperen hasta que venza el siguiente intento en cola.
- Se agregó una proyección duradera del recuento de ventas del inventario adicional mantenida por las rutas de creación, modificación y cancelación del aporte, evitando escaneos repetidos del espacio de nombres del aporte para lecturas normales del inventario adicional después del primer arranque de proyección.
- Se actualizó el desarrollo local para que `_config.local.yml` pueda ocultar los widgets Turnstile de recordatorio de lanzamiento de la misma manera que el inicio de sesión del administrador local puede ocultar su widget Turnstile.
- Se amplió la imagen y los envoltorios del optimizador de medios de Podman con `optipng` y `gifsicle` para que la compresión de origen PNG/GIF local utilice el mismo flujo de trabajo de medios del repositorio que la generación responsiva de derivados de imágenes y videos.
- Se agregó un pase de rendimiento de PageSpeed móvil para las páginas de la campaña: los videos principales de YouTube ahora se muestran como carteles locales/fachadas de reproducción y cargan el iframe remoto solo después de la intención de reproducción, evitando el costo inicial de JavaScript/CSS de YouTube.
- Se agregaron precargas de imágenes de héroe responsivas y un escalón derivado WebP `640w` para que las páginas de campañas móviles puedan elegir activos de navegador más pequeños entre las variantes `480w` y `960w` existentes.
- Se actualizó el optimizador de medios para omitir los derivados WebP receptivos generados durante la optimización de la fuente, manteniendo actualizados los recursos del navegador generados sin volver a codificarlos de forma recursiva.
- Se corrigió el texto enriquecido del diario creado en el tablero para que los marcadores en negrita/cursiva/subrayado en línea normalicen los espacios de límites iniciales y finales en lugar de mostrar delimitadores de Markdown perdidos en las páginas de campañas públicas.
- Se corrigieron los enlaces hash del diario público, incluidos enlaces a pestañas del diario no predeterminadas, como `#diary-production`, para que la pestaña correspondiente se abra antes de que la página se desplace hasta el ancla.
- Se actualizaron las cargas de imágenes y videos del panel para enviar el flujo de trabajo **Optimizar medios del panel** con `scope=changed` después de que la confirmación de GitHub que preserva el origen sea exitosa; Las cargas de audio permanecen conservadas en origen.
- Se agregó una limpieza en el momento de la publicación para el contenido de la campaña propiedad del panel y los medios del diario que se eliminan del contenido publicado y ya no se hace referencia a ellos en ninguna otra parte de la misma campaña.

## v1.0.2 - 2026-06-01

- Se agregaron correcciones de rendimiento de páginas públicas de la revisión de PageSpeed: las páginas de campañas de video remoto ya no precargan imágenes destacadas ocultas, las imágenes de nivel optan por la decodificación diferida/asíncrona, los logotipos de marca predeterminados reservan sus dimensiones intrínsecas y las páginas públicas evitan las ansiosas preconexiones de Stripe antes de la intención del carrito.
- Se amplió el proceso de optimización de medios del panel para generar variantes de imágenes WebP responsivas para imágenes de origen PNG, JPEG y GIF, de modo que las plantillas de campañas públicas puedan servir activos de navegador más pequeños y al mismo tiempo mantener las cargas originales como fuentes de respaldo de la verdad.
- Se agregó una opción manual `scope=all` al flujo de trabajo **Optimizar medios del panel** para que las campañas existentes se puedan reprocesar a través del mismo canal de medios utilizado para las cargas de nuevos paneles.
- Se actualizaron las plantillas de campaña, nivel, tarjeta, galería y contenido-imagen para usar variantes responsivas generadas cuando existan sin cambiar la estructura de la página visible o las referencias de Markdown de la campaña.

## v1.0.1 - 2026-05-29

- Se agregó la tarifa de transacción de saldo real de Stripe/captura neta para aportes cobradas recientemente y una ruta de reposición de superadministrador para registros de aportes cobradas más antiguas.
- Panel de análisis actualizado para preferir las tarifas reales almacenadas de Stripe cuando estén disponibles, mantener las tarifas estimadas solo cuando sea necesario y etiquetar claramente los valores mixtos/estimados.
- Se agregaron cargas de medios del editor de contenido administrativo para bloques de contenido de campaña y diario, con vistas previas locales inmediatas y carga en el momento de la publicación en los directorios correctos de activos de la campaña.
- Se agregó el canal de optimización de medios del panel: `npm run media:optimize`, `npm run media:optimize:check` y un flujo de trabajo de GitHub Actions que comprime sin pérdidas las imágenes cargadas, genera derivados de video WebM de alta calidad y reescribe referencias literales de video de configuración/campaña después de que existan los derivados.
- Se mantuvieron las cargas del panel para preservar la fuente en el Worker mientras se documentaba el paso de optimización externa para operadores y bifurcaciones.
- Made Supporters y Analytics devuelven vistas vacías de solo lectura para campañas sin índices de aporte en lugar de bloquear paneles de campaña nuevos o vacíos.

## v1.0.0 - 2026-05-26

- Se agregó el panel de administración privado como superficie de operaciones y edición del navegador compatible en `/admin/` y `/es/admin/`.
- Se agregó autenticación de administrador de enlace mágico con alcance de rol para superadministradores y usuarios de campañas, con sesiones respaldadas por cookies, comprobaciones de origen/CSRF y API de administración seguras para el navegador que no exponen `ADMIN_SECRET`.
- Se agregó soporte de protección de desafío de inicio de sesión de administrador para implementaciones compatibles con Cloudflare Turnstile mientras se mantienen explícitas las omisiones locales/de prueba.
- Se agregaron pestañas del panel para Configuración, Complementos, Campañas, Análisis, Informes, Patrocinadores, Marketing, Usuarios, Secretos y credenciales, y Diagnóstico en tiempo de ejecución.
- Se reemplazó el modelo de edición de Pages CMS con el flujo de trabajo basado en el panel, manteniendo `_config.yml` y la campaña Markdown como la fuente de verdad revisable frente a la bifurcación.
- Se agregó edición de bloques WYSIWYG para contenido de campaña y entradas de diario, incluida configuración de medios, edición de enlaces, formato en línea estilo Markdown, vistas previas móviles, borradores locales y seguimiento del estado de publicación.
- Se agregó edición del panel para configuraciones de campaña, niveles, elementos de soporte, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario, decisiones, complementos de plataforma y configuraciones de plataforma.
- Se agregó manejo de carga en el panel para medios de campaña, activos de marca, imágenes complementarias y videos destacados utilizando directorios de activos basados en convenciones y nombres de archivos estilo slug.
- Se agregó un panel de administración de usuarios respaldado por Worker KV en `admin-users:v1`, separado de los flujos de publicación respaldados por GitHub.
- Se agregaron correos electrónicos de notificación para los usuarios del panel recién creados cuando se configura Resend; las ediciones del usuario no reenvían invitaciones.
- Se agregaron herramientas de marketing en el panel para la creación de URL de referencia/UTM, códigos de referencia guardados, interfaz de usuario de creación de inserción reutilizable y fragmentos de lanzamiento copiables.
- Se corrigieron las vistas previas de inserción de marketing para campañas con medios destacados de YouTube o Vimeo para que las barras de progreso, los hitos y las etiquetas de objetivos ampliados permanezcan contenidos.
- Se agregaron vistas de análisis, informes y patrocinadores del panel de control con alcance de rol con tablas ordenables/filtrables, visualización del centavo exacto de dólar y descargas CSV; Las vistas previas/descargas de informes no envían correos electrónicos ni escriben marcadores de envío.
- Se preservó el objetivo de nivel gratuito KV de Cloudflare Workers manteniendo las lecturas normales del panel, las vistas previas, los filtros, los análisis y los borradores locales en cero escrituras KV.
- Configuración del remitente de correo electrónico de aporte alineada con el dominio del remitente autorizado Resend y configuración del dominio del remitente documentada para bifurcaciones.
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
