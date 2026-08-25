---
title: README de la plataforma
parent: Desarrollo
nav_order: 11
render_with_liquid: false
lang: es
---

# The Pool

## Última actualización

25 de agosto de 2026

**Base de plataforma de crowdfunding de código abierto**

La versión actual es **v1.2.20**. Los cambios en el repositorio realizados después de esa etiqueta son
grabado en **Inédito** en [Changelog](/es/docs/reference/changelog/); trabajo prospectivo
pertenece al [Roadmap](/es/docs/reference/roadmap/).

Un sitio estático de Jekyll con un carrito propio para crowdfunding creativo de todo o nada. Los patrocinadores crean un aporte en el carrito de The Pool, el Worker de Cloudflare valida la contribución mediante `/checkout-intent/start` y Stripe recopila y guarda los datos de la tarjeta en un paso de pago seguro dentro del sitio, de modo que la tarjeta solo se cobra si una campaña exitosa alcanza su fecha límite. Una sola sesión de pago puede incluir artículos de varias campañas; tras la confirmación del webhook, el Worker distribuye ese paquete en registros de aporte separados por campaña. Si la campaña se financia, el programador del Worker envía la liquidación por lotes y cobra los aportes fuera de sesión. Los patrocinadores pueden añadir una propina opcional para la plataforma, gestionar sus aportes mediante enlaces mágicos limitados al pedido y volver a un panel de gestión de aportes optimizado para escritorio con secciones Activos y Cerrados.

## Características

- **No se requieren cuentas**: los patrocinadores administran sus aportes a través de enlaces mágicos por correo electrónico
- **Pago verificado por el servidor**: Worker canonicaliza el contenido del carrito de los artículos propios en lugar de confiar en los totales enviados por el navegador.
- **Pago de varias campañas**: un pago puede incluir varias campañas, mientras que el almacenamiento, los correos electrónicos, los informes y la administración permanecen dentro del alcance de la campaña después de la confirmación.
- **Tiempo de ejecución de carrito propio diferido**: las páginas públicas cargan primero un arranque de carrito liviano y posponen la pila de carrito más pesada hasta que el estado persistente del carrito o la intención clara del patrocinador lo requiera.
- **Aporte de todo o nada**: tarjetas guardadas ahora, cobradas solo si se alcanza el objetivo
- **Opcional propina de plataforma**: propina del 0% al 15% (5% predeterminado) incluida en los totales pero excluida del progreso de la campaña.
- **Carro y pago con reconocimiento de propinas**: la lógica de precios compartida mantiene el subtotal, la propina, los impuestos, el envío y el total sincronizados en el carrito, el pago, Worker, los informes y los correos electrónicos.
- **Cotizaciones de envío respaldadas por USPS con barreras de seguridad**: el pago físico y la modificación de flujos pueden cotizar envíos nacionales/internacionales USPS, usar tarifas fijas/manuales explícitas cuando estén configuradas, recurrir de forma segura a tarifas fijas configuradas y admitir actualizaciones de firmas nacionales opcionales sin forzar la rotación de cotizaciones en KV.
- **Complementos de plataforma con reconocimiento de inventario**: los complementos de merchandising a nivel de paquete se pueden adjuntar al proceso de pago, permanecer editables en Administrar aporte, admitir existencias por variante y seguir el mismo flujo canónico de envío, informes y correo electrónico sin contar para los objetivos de financiación de la campaña.
- **Complementos de campaña con contabilidad basada en campaña**: el descuento de campaña también puede definir complementos con alcance de campaña que se muestran en el mismo carrito/administrar la interfaz de usuario, cuentan para el subtotal de financiación de esa campaña, siguen las anulaciones de envío de la campaña y desaparecen automáticamente cuando el aporte de campaña propietario abandona el carrito.
- **Paso de pago Stripe en el sitio**: el segundo sidecar de pago existente alberga la interfaz de usuario de pago segura Stripe, y Manage Pledge utiliza el mismo patrón para `Update Card`.
- **Configuraciones configurables de precios e impuestos del proveedor**: `pricing.*` y `tax.*` viven en `_config.yml`, y las variables Worker reflejadas se sincronizan automáticamente en `worker/wrangler.toml` para que las vistas previas del navegador, los estados de impuestos provisionales y los totales del lado del servidor permanezcan alineados.
- **Niveles físicos y digitales**: los artículos físicos activan la captura de la dirección de envío durante el proceso de pago, además de cotizaciones USPS calculadas con Worker, tarifas alternativas configuradas y actualizaciones de firma nacionales opcionales cuando están habilitadas.
- **Enlaces mágicos relacionados con el pedido**: cada enlace de colaborador solo administra su propio aporte/pedido.
- **Fundación del puente de beneficios de podcast**: un cliente de concesión/revocación de podcast a podcast firmado y deshabilitado de forma predeterminada comparte el contrato de código único exacto con el tiempo de ejecución de podcast; aún no hay ninguna asignación de nivel/producto ni subvención activa
- **Sesiones de apoyo más seguras**: las páginas de la comunidad mantienen el acceso de los patrocinadores en el almacenamiento de sesiones del navegador en lugar de una cookie simbólica de larga duración.
- **Objetivos a largo plazo**: desbloqueo automático en los umbrales de financiación
- **Ciclo de vida de la campaña**: estados `upcoming` → `live` → `post` con transiciones automáticas + purga de caché Cloudflare
- **Temporizadores de cuenta regresiva**: zona horaria configurable de la plataforma IANA con manejo automático del horario de verano, prerenderizado para evitar flash
- **Recordatorios de lanzamiento**: las próximas páginas de la campaña pueden recopilar suscripciones explícitas por correo electrónico, verificar desafíos Turnstile, deduplicar registros por campaña/correo electrónico, enviar un correo electrónico de lanzamiento impulsado por Resend cuando la campaña esté activa y respetar los marcadores de cancelación/supresión antes de enviarla.
- **Recordatorios de pago basados en el consentimiento**: el pago propio personalizado puede recopilar un recordatorio explícito, poner en cola un correo electrónico de pago abandonado retrasado solo después de que la sesión Stripe se haya creado correctamente, suprimirlo en aportes completadas, respetar los enlaces de cancelación de suscripción firmados y restaurar un borrador de pago desinfectado a partir de enlaces de recordatorio firmados.
- **Representación estable del progreso de la campaña**: las barras de financiación y los marcadores de hitos representan sus posiciones en HTML/CSS estático para que la primera carga no espere a que JavaScript evite el colapso del diseño.
- **Fases de producción y registro**: interfaz con pestañas para necesidades de financiación detalladas
- **Decisiones de la comunidad**: votación/encuesta para la participación de los patrocinadores con listas de opciones permitidas publicadas y bloqueo de decisiones cerrado
- **Bloques de contenido de campaña desinfectados**: el contenido de campaña y diario de formato largo acepta Markdown más un pequeño subconjunto en línea seguro (`<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`), admite videos locales con carteles opcionales, neutraliza esquemas de enlaces de Markdown inseguros, abre automáticamente enlaces externos en una nueva pestaña y escapa o rechaza otro HTML sin formato.
- **Incrustaciones estructuradas estrictas**: las incrustaciones `spotify`, `youtube` y `vimeo` aprobadas se validan con orígenes confiables exactos y rutas de inserción en lugar de coincidencias de subcadenas.
- **Inventario serializado de niveles limitados**: las recompensas escasas se reservan a través de un Durable Object por campaña al inicio del pago y se confirman a través del mismo coordinador en el momento de la persistencia, por lo que los niveles limitados no se sobrevenden bajo demanda simultánea.
- **Liquidación de campañas serializadas**: las rutas de liquidación programadas y manuales utilizan un bloqueo de coordinador por campaña más claves de idempotencia deterministas Stripe, por lo que el cobro de la misma campaña no puede superponerse mientras los carros de varias campañas permanecen dentro del alcance de la campaña.
- **Manejo estricto de aportes faltantes** — Las lecturas de aportes de Magic-link fallan al cerrarse con `404` cuando falta el registro de aporte de respaldo
- **Diario de producción**: actualizaciones de contenido enriquecido con correos electrónicos de transmisión automática a los patrocinadores
- **Envíos masivos de correo electrónico a los patrocinadores**: los administradores de campañas pueden enviar correos electrónicos masivos a los patrocinadores con contenido WYSIWYG, imágenes alojadas en la campaña, enlaces de vídeo seguros para correo electrónico, simulacros automáticos y enlaces de CTA personalizados.
- **Panel de administración privado**: acceso de administrador Magic-link para configuraciones de ámbito de función, edición de campañas, complementos, patrocinadores, informes, análisis, herramientas de marketing/referencias, usuarios, revisión/revocación de sesión con privacidad minimizada, historial de auditoría con capacidad de búsqueda/CSV y secretos/diagnósticos de solo lectura sin exponer secretos de administrador en el código del navegador; el navegador recuerda la última pestaña permitida del panel y el contexto de la subpestaña durante las recargas sin escribir el estado Worker/KV
- **Controles de operaciones de administración**: los superadministradores pueden revisar sesiones activas/recientes con privacidad minimizada, revocar sesiones explícitamente, buscar metadatos de auditoría y exportar archivos CSV de auditoría seguros para fórmulas a través de API Worker protegidas.
- **Disciplina de recuperación**: las instantáneas cifradas clasificadas, la verificación de la suma de comprobación, las restauraciones de vista previa, los ensayos sintéticos, la conciliación Stripe, las copias fuera del dispositivo y la automatización de la retención tienen como objetivo un RPO/RTO de cuatro horas con 7 instantáneas diarias, 5 semanales, 12 mensuales y de lanzamiento.
- **Herramientas de marketing de campañas más completas** — Campañas -> Marketing puede crear enlaces de campañas rastreadas, guardar códigos de referencia, obtener una vista previa/descargar códigos QR de campaña como PNG/SVG y guardar borradores compartidos; Analytics revisa el rendimiento de las referencias/UTM a partir de aportes indexadas; Campañas -> Blast puede redactar envíos masivos de correos electrónicos de patrocinadores con el editor de contenido WYSIWYG, guardar borradores compartidos explícitamente, cargar o seleccionar imágenes de campaña alojadas a través de la ruta de medios compartida, vincular videos de YouTube/Vimeo en lugar de incorporar reproductores remotos en el correo electrónico, realizar un simulacro de audiencias automáticamente antes de los envíos de prueba/en vivo, realizar envíos de prueba al administrador que ha iniciado sesión, enviar a los patrocinadores indexados de la campaña y mostrar el historial de envíos masivos de solo lectura.
- **Vistas previas de campañas protegidas**: los superadministradores y los usuarios de campañas asignados pueden publicar vistas previas de página completa protegidas por correo electrónico y sin índice para campañas que pueden editar, con shells estáticos genéricos, controles de aporte de solo lectura, enlaces de editor visibles en el panel, enlaces de revisores invitados opcionales que caducan en 24 horas y listas de permisos de acceso a vista previa almacenadas en Worker KV de corta duración en lugar de en la fuente de la campaña.
- **Creación de nueva campaña**: los superadministradores pueden crear una campaña de solo vista previa desde el panel con solo un título, seleccionando opcionalmente uno o más usuarios de campaña existentes o creando uno o más usuarios nuevos con el nombre/correo electrónico requerido.
- **Archivo de campañas**: los superadministradores pueden archivar campañas no activas desde Campañas -> Configuración; El desarrollo local archiva directamente en el repositorio montado, mientras que la producción envía un flujo de trabajo de acciones GitHub validado que mueve el origen de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/` en lugar de eliminar los datos archivados.
- **Integración de Instagram**: CTA social opcional en los correos electrónicos de los patrocinadores
- **Financiamiento continuo** — Sección de apoyo posterior a la campaña
- **Panel de administración de aportes**: secciones activas/cerradas fáciles de usar para escritorio con controles de solo lectura en estado bloqueado después de la fecha límite
- **Correos electrónicos e informes con avisos**: los correos electrónicos de los colaboradores, los informes de aporte y las exportaciones de cumplimiento incluyen propina de plataforma cuando está presente.
- **Base de análisis de tarifas reales de Stripe**: los aportes cobradas recientemente almacenan la tarifa de transacción de saldo/valores netos de Stripe cuando están disponibles, y los análisis del panel prefieren esos valores reales al tiempo que etiquetan claramente las filas de reserva estimadas.
- **Análisis de ingresos netos**: los análisis del panel mantienen visibles los ingresos brutos de la campaña y los ingresos de la plataforma, al tiempo que agregan valores netos de campaña/plataforma después de la proporción asignada a cada categoría de las tarifas de procesador reales o estimadas.
- **Visibilidad del uso del plan del proveedor**: los superadministradores pueden abrir Configuración -> Uso del plan para ver el estado de las cuotas de Cloudflare Workers/KV y Resend desde las llamadas del proveedor del lado del servidor sin exponer los tokens ni escribir el estado de KV.
- **Cargas de medios del editor de contenido administrativo**: los editores de contenido de campañas y diarios pueden organizar cargas de imágenes, videos y audio con vistas previas inmediatas y luego publicarlas en el directorio de activos de la campaña con el cambio de contenido; La publicación también elimina los medios propiedad del panel de la misma campaña a los que ya no se hace referencia.
- **Canal de optimización de medios del panel**: los medios cargados en el panel conservan el origen en Worker, las cargas de imágenes y videos envían el optimizador del repositorio con `scope=changed` y las herramientas del repositorio pueden comprimir imágenes sin pérdidas, generar variantes de navegador WebP con capacidad de respuesta, incluido un escalón compatible con dispositivos móviles `640w`, y generar derivados WebM de alta calidad para los videos cargados.
- **Inserciones de video remotas diferidas**: los videos principales de la campaña de YouTube se muestran primero con un póster/fachada de reproducción local y cargan el iframe remoto solo después de que el patrocinador intenta reproducirla.
- **Minimización de activos generados**: las páginas de producción crean minificaciones del CSS/JS `_site` generado después de la salida de Jekyll y, al mismo tiempo, dejan los archivos fuente legibles y Cloudflare es responsable de la compresión de transferencia.
- **Captura de video de producto repetible**: un adaptador The Pool solo local impulsa el flujo `smoke-editable` real a través del motor de captura/renderizado de la plataforma anclado, produciendo salidas ProRes, WebM y HEVC transparentes sin pagos en vivo, costos de tiempo de ejecución de producción ni limpieza de salida recursiva.
- **Informes de los ejecutores de campaña**: los correos electrónicos del libro mayor de aportes diarios configurables con alcance de campaña y las exportaciones de cumplimiento posteriores a la fecha límite pueden enviarse a los destinatarios de los ejecutores configurados de cada campaña, mientras que el panel obtiene una vista previa/descarga los archivos CSV de aportes y cumplimiento sin enviar correos electrónicos ni escribir marcadores de envío.
- **Diagnóstico de deriva de proyección**: las comprobaciones administrativas de solo lectura y una CLI local pueden comparar las estadísticas almacenadas, el inventario y los índices de campaña con la verdad del aporte guardado antes de que cualquier ruta de reparación modifique los datos.
- **Sistema visual compartido**: las páginas públicas, las superficies de campaña, el carrito/pago y Manage Pledge utilizan el mismo lenguaje de tipografía, botones, campos y tarjetas reutilizables y más tranquilos.
- **Pulido adaptable para dispositivos móviles**: las páginas de campaña, los flujos de pago/administración, las páginas de la comunidad y el contenido de formato largo comparten un espacio de pantalla pequeño, cajones con reconocimiento de áreas seguras, objetivos de toque más grandes y correcciones de desbordamiento en lugar de una interfaz de usuario separada solo para dispositivos móviles.
- **Línea base de accesibilidad**: los shells públicos mantienen enlaces de omisión y puntos de referencia principales estables, mientras que los flujos de carrito/pago utilizan una semántica de diálogo más sólida, actualizaciones de regiones en vivo y etiquetas accesibles más claras sin mover los campos de pago fuera de la interfaz de usuario segura propiedad de Stripe.
- **Personalización de la primera bifurcación variable**: la configuración estructurada impulsa la marca, los precios, las configuraciones sincronizadas con Worker, los activos principales de la marca, las variables de diseño seleccionadas, el Stripe Elements temático y los correos electrónicos de soporte de marca sin necesidad de un código personalizado para el cambio de marca normal de la bifurcación.
- **Inserciones de campañas en vivo alojadas**: las páginas de la campaña se vinculan a un generador de inserciones con reconocimiento regional que genera código iframe de copiar y pegar con opciones de diseño/tema/medios/CTA, datos en vivo respaldados por Worker y comportamiento de cambio de tamaño automático.
- **Enlaces para compartir campañas**: las páginas de la campaña exponen objetivos compartidos localizados y solo con íconos para Bluesky, X, Threads, Facebook, SMS y correo electrónico, con imágenes alternativas locales y un texto de intención más rico con reconocimiento de estado cuando las plataformas lo permiten.
- **Fundación i18n en inglés + español**: `_config.yml` impulsa los idiomas admitidos, rutas de configuración regional estática, rutas de campaña localizadas generadas, datos de traducción compartidos y un selector de idioma de pie de página más silencioso, con español en vivo en inicio/acerca de/términos, páginas de campaña públicas, páginas insertadas, páginas de resultados de aportes, `/manage/`, `/community/`, rutas de la comunidad de patrocinadores, carrito/comunidad propiedad del sitio/Administrar aporte/copia en tiempo de ejecución insertada, campaña etiquetas de cuenta regresiva/galería/estadísticas en vivo, resúmenes de los botones del carrito, copia auxiliar de ubicación de impuestos de pago, video principal/avance de la comunidad/diario cromado, fechas de campaña localizadas y correos electrónicos de patrocinadores de Worker localizados
- **SEO y preparación para compras**: las páginas públicas y las páginas de campaña emiten títulos, descripciones, canónicos, etiquetas OG/Twitter, metadatos de idiomas localizados, JSON-LD honesto, tarjetas para compartir de campaña PNG generadas por Worker compatibles con rastreadores y metadatos en idiomas alternativos cuando sean compatibles. `robots.txt`, las marcas de tiempo de los mapas del sitio creados, los diagnósticos de rastreo de texto/XML coincidentes, las auditorías generadas y posteriores a la implementación y las reglas explícitas de no índice mantienen los flujos privados/tokenizados fuera de la intención de búsqueda. Una campaña puede publicar explícitamente su recompensa física destacada como una página de producto de pedido anticipado enfocada solo después de que estén presentes los datos completos de disponibilidad; La incorporación a Merchant Center sigue siendo un paso independiente del operador.
- **Captura previa de intención segura**: los enlaces de documentos públicos del mismo origen se pueden capturar previamente al pasar el cursor/enfocar/tocar, con exclusiones de ruta/consulta conservadoras y valores predeterminados configurables por el administrador.

## Arquitectura

```
[Visitor] → GitHub Pages (Jekyll + first-party cart / checkout sidecars)
          → Cloudflare Worker (on-site Stripe session bootstrap + webhook + cron)
```

|capa|Plataforma|Rol|
|-------|----------|------|
|Interfaz|GitHub Pages|Jekyll + Sass + tiempo de ejecución de carrito propio|
|Pagos|Stripe|Campos de pago seguros, métodos de pago guardados, cargos fuera de sesión|
|API|Cloudflare Worker|Arranque de sesión de pago, webhook, totales con reconocimiento de propinas, estadísticas, liquidación automática, purga de caché|
|Interfaz de usuario de administrador|Panel privado|Edición, configuración, complementos, informes, análisis, patrocinadores, herramientas de marketing y usuarios de campañas basadas en roles|

### Fundaciones y propiedad compartidas

Los gitlinks grabados fijan la plataforma Dust Wave inmutable y Dust Wave Jekyll
Revisiones de plantillas. Suministros de plataforma caracterizados Worker, administrador, navegador,
diseño, construcción, lanzamiento, envío, impuestos, inventario, medios, pruebas y local
primitivas de vídeo de producto. La plantilla Jekyll posee 17 archivos vinculados al manifiesto.
archivos de actualización de origen cuyas copias en tiempo de ejecución permanecen registradas.

The Pool todavía posee modelos de campaña y aporte, rutas, almacenamiento, contenido,
localización, plantillas, credenciales, política de proveedores, compilaciones, implementación y
revertir. Ninguno de los repositorios compartidos sigue una rama en movimiento en el momento de la compilación. a
Verifique los pines grabados y las copias generadas/fuente:

```bash
git submodule update --init --recursive
npm ci
npx vitest run tests/unit/platform-pin.test.ts tests/unit/jekyll-template-pin.test.ts
npm run jekyll-template:check
```

## Inicio rápido

```bash
git submodule update --init --recursive
npm run setup:deploy -- --mode=local
npm run podman:doctor
./scripts/dev.sh --podman
# Visit http://127.0.0.1:4000
```

Ése es el camino recomendado para el desarrollo local. Arranca Jekyll, Worker, el reenvío CLI Stripe opcional y los servicios de soporte local junto con los valores predeterminados actuales del repositorio.

Clona con `--recurse-submodules` cuando sea posible. Las cajas existentes deben ejecutar el comando del submódulo anterior antes de instalarlas o probarlas; CI fija e inicializa la confirmación de plataforma compartida registrada en lugar de seguir su rama en movimiento.

El asistente de configuración es Node y funciona en macOS, Windows y Linux. Utilice `npm run setup:deploy -- --mode=production --dry-run` para obtener una vista previa de Cloudflare KV, secreto Worker, secreto GitHub, preparación e implementación de los pasos antes de aplicarlos. Mantiene intencionalmente los secretos de producción Worker separados de los valores locales `worker/.dev.vars` ignorados, y la ruta de configuración está cubierta por pruebas unitarias de CLI falsas para que los ensayos, la planificación de reutilización/creación de KV, los secretos locales generados y las escrituras de secretos de producción sigan siendo comprobables sin mutaciones del proveedor activo.

El contenedor de desarrollo Worker se ejecuta en el nodo 24 para coincidir con las acciones GitHub. Wrangler 4.118 también se ejecuta contra el Worker `compatibility_date = "2026-05-03"` compartido, por lo que el comportamiento local de Miniflare/Workers permanece alineado con la semántica de tiempo de ejecución implementada.

Si desea reconstruir las imágenes de desarrollo Podman después de cambios de dependencia o de imagen base:
```bash
PODMAN_REBUILD=1 ./scripts/dev.sh --podman
```

Las configuraciones de precios compatibles con Fork se encuentran en:
- `pricing.sales_tax_rate`, `pricing.default_tip_percent` y `pricing.max_tip_percent` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Worker vars `SALES_TAX_RATE`, `DEFAULT_PLATFORM_TIP_PERCENT` y `MAX_PLATFORM_TIP_PERCENT` sincronizadas automáticamente en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

Las configuraciones del motor de impuestos compatibles con Fork se encuentran en:
- `tax.provider`, `tax.origin_country`, `tax.use_regional_origin`, `tax.nm_grt_api_base` y `tax.zip_tax_api_base` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Worker reflejadas vars `TAX_PROVIDER`, `TAX_ORIGIN_COUNTRY`, `TAX_USE_REGIONAL_ORIGIN`, `NM_GRT_API_BASE` y `ZIP_TAX_API_BASE` en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)
- `tax.provider: flat` mantiene la línea base de tasa configurada heredada de `pricing.sales_tax_rate`
- `tax.provider: offline_rules` utiliza reglas internacionales de IVA/GST suministradas además de un comportamiento alternativo a nivel estatal
- `tax.provider: nm_grt` utiliza primero el conjunto de datos inicial de Nuevo México suministrado y puede refinar las búsquedas de direcciones de calles de Nuevo México con la API gratuita EDAC GRT.
- secreto Worker opcional `ZIP_TAX_API_KEY` cuando `tax.provider: zip_tax` está habilitado para búsquedas de impuestos de EE. UU. a nivel local/jurisdiccional

El comportamiento de pago actual es intencionalmente conservador: si el navegador aún no tiene suficientes datos de destino, el carrito muestra el impuesto provisional como `--` y la cotización de impuestos final se resuelve una vez que Worker tenga suficientes detalles de ubicación de facturación o envío.

Las configuraciones de envío amigables con el fork se encuentran en:
- `shipping.origin_*`, `shipping.fallback_flat_rate`, `shipping.free_shipping_default` y `shipping.usps.*` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- variables Worker sincronizadas automáticamente como `SHIPPING_ORIGIN_ZIP`, `SHIPPING_FALLBACK_FLAT_RATE`, `USPS_ENABLED`, `USPS_CLIENT_ID` y los controles de tiempo de espera/caché/enfriamiento USPS en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

Mantenga `USPS_CLIENT_SECRET` fuera de la configuración del sitio. Configúrelo como secreto Worker o en [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars) para desarrollo local.

Si cambia esos valores localmente, reinicie `./scripts/dev.sh --podman` para que Worker use las mismas matemáticas que el sitio.

Las configuraciones globales de productos/complementos compatibles con Fork se encuentran en:
- `add_ons.enabled`, `add_ons.low_stock_threshold` y `add_ons.products` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Imágenes de productos, variantes según el tamaño, inventario por producto o por variante y referencias `shipping_preset` para artículos físicos del catálogo.
- Los complementos a nivel de paquete se pueden seleccionar en el sidecar del carrito, anclarlos a una campaña en carritos de múltiples campañas y editarlos más tarde desde Administrar aporte.
- Los mensajes de stock bajo y el filtrado de variantes agotadas provienen de la capa de estado del producto adicional compartida con reconocimiento de inventario utilizada tanto por el carrito como por Manage Pledge.
- el inventario complementario configurado es la base inicial; El stock restante se deriva del estado de aporte guardado a través de la proyección `add-on-inventory-sold:v1`, no del carrito no guardado ni de Administrar borradores.
- Los informes de aporte y cumplimiento separan el valor del aporte de campaña del valor adicional de la plataforma para facilitar las operaciones.

Las configuraciones orientadas a la bifurcación utilizan un modelo de configuración estructurado en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml):

- `platform` para identidad, URL y contacto de soporte
- `platform` también cubre activos de marca como logotipo, logotipo de pie de página, favicon e imagen social predeterminada.
- `admin` para URL de administración de producción más usuarios de inicialización/recuperación reflejados en Worker como `ADMIN_USERS_JSON`
- `title` / `description` de nivel superior para la identidad del sitio de Jekyll y la copia predeterminada de SEO
- `seo` para controles de identidad SEO limitados como `x_handle`, `same_as`, `default_social_image_alt`, `og_locale_overrides` y si el centro de la comunidad pública sigue siendo indexable
- `pricing` para la línea base de compatibilidad de tarifa plana y los valores predeterminados de sugerencias de plataforma
- `tax` para elegir el motor de impuestos Worker y su configuración de búsqueda no secreta
- `shipping` para configuración de origen, comportamiento de cotización de USPS, política de respaldo, valores predeterminados de envío gratuito, ajustes preestablecidos de envío y política de opciones de envío limitadas
- `add_ons` para un pequeño catálogo de productos global, productos de precio fijo y variantes simples como tallas de camisa.
- `reports` para tiempos de informes de campaña, archivos adjuntos, resúmenes, comportamiento de prefijo de asunto y el flujo de trabajo de correo electrónico de cumplimiento dividido junto con `platform.support_email`
- `launch_reminders` para habilitar formularios de recordatorio de próximas campañas y configurar la clave pública del sitio Turnstile
- Portada de la campaña `campaign_add_ons` para productos relacionados con la campaña que utilizan la misma interfaz de usuario de tarjeta y cuentan para el subtotal y las reglas de envío de esa campaña.
- `i18n` para idiomas predeterminados/compatibles, etiquetas de idioma y rutas de páginas públicas traducidas
- `design` para anulaciones de tipografía seleccionada, radio, ancho de diseño y token de tema
- un pequeño subconjunto seleccionado de `platform` / `design` se refleja en Worker para que los correos electrónicos de los patrocinadores también permanezcan alineados con la marca de la bifurcación.
- `debug` para el comportamiento de registro del navegador y la consola Worker
- `performance` para controles seguros de captación previa de intención pública
- `checkout` para configuraciones de pago verdaderamente variables como la clave publicable Stripe
- `cache` para TTL de navegador en vivo

[`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml) es intencionalmente delgado: solo incluye anulaciones locales verdaderas como URL de host local, `show_test_campaigns` y claves en blanco públicas Turnstile solo locales, no una segunda copia de la configuración base.

Consulte [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/) para conocer la superficie de personalización sin código admitida y qué configuraciones se reflejan automáticamente en Worker.
Consulte [docs/SEO.md](/es/docs/operations/seo/) para conocer la implementación fundamental actual de SEO y la superficie SEO compatible.
Consulte [docs/ACCESSIBILITY.md](/es/docs/operations/accessibility/) para conocer la línea base de accesibilidad actual y los flujos críticos verificados.
Consulte [docs/I18N.md](/es/docs/development/internationalization/) para conocer el modelo local, las fuentes de traducción compartidas y el comportamiento de la ruta localizada.
Consulte [docs/PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) para conocer el modelo de configuración, pago, webhook, liquidación y conciliación de Stripe.
Consulte [docs/TAX_CALCULATOR.md](/es/docs/operations/tax-calculator/) para seleccionar el proveedor de impuestos, cotizaciones canónicas de Worker, configuración, solución de problemas y verificación.
Consulte [docs/EMAIL.md](/es/docs/operations/email-system/) para conocer la configuración del remitente, los tipos de correo electrónico, la localización y el comportamiento de entrega de Resend.

Los creadores pueden utilizar la [Lista de verificación para creadores de campañas](https://github.com/your-org/your-project/blob/main/creator-campaign-checklist.md) pública] para la preparación del lanzamiento. Cubre complementos de campaña, inserciones alojadas, enlaces de referencia/QR, preparación de Blast de apoyo, planificación de vista previa de enlaces compartidos/sociales, carga de medios en el panel, expectativas de impuestos/envíos, decisiones de envío gratuito y tasas de reserva, destinatarios de informes y transferencia de cumplimiento; la ruta española vive en `/es/creator-campaign-checklist/`.

Para la localización, el modelo admitido es:

- UI compartida/tiempo de ejecución/copia de correo electrónico vive en `_data/i18n/{lang}.yml`
- Las páginas localizadas de formato largo aún necesitan archivos fuente localizados bajo el prefijo local.
- Las páginas de campaña generadas y las páginas insertadas también participan en el modelo local, por lo que `/campaigns/{slug}/` puede cambiar limpiamente a `/es/campaigns/{slug}/`.
- el conmutador de idioma de pie de página compartido conserva la cadena de consulta y el hash actuales, por lo que las rutas tokenizadas como `/manage/?t=...` pueden cambiar a `/es/manage/?t=...` sin perder el acceso al aporte.

Las principales rutas locales/dev/test ya llaman al script de sincronización existente, [`scripts/sync-worker-config.rb`](https://github.com/your-org/your-project/blob/main/scripts/sync-worker-config.rb), para mantener alineados los valores reflejados de Worker. Si edita `_config.yml` / `_config.local.yml` directamente y desea actualizar la configuración de Worker antes de reiniciar la pila, ejecute:

```bash
npm run sync:worker-config
```

Si en su lugar necesita específicamente el respaldo de solo host:
```bash
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml
```

Para una pila completa solo de host, ejecute Worker por separado con `cd worker && wrangler dev --env dev --port 8787`.

Las pruebas del panel de administración local leen el correo electrónico del superadministrador de arranque de `worker/.dev.vars` ignorado como `ADMIN_BOOTSTRAP_EMAILS`. `npm run secrets:dev` crea ese archivo desde `worker/.dev.vars.example`, donde las bifurcaciones pueden reemplazar el marcador de posición con su propio correo electrónico de inicio de sesión local. Los valores predeterminados del desarrollador comprometido Worker aún configuran `CORS_ALLOWED_ORIGIN=http://127.0.0.1:4000` y las dos campañas de solo prueba `hand-relations,smoke-editable`. `_config.yml` `admin.users` es la lista de semillas/recuperación de producción reflejada en el Worker implementado como `ADMIN_USERS_JSON`; Las ediciones del usuario administrador realizadas en el panel se guardan directamente en Worker KV en `admin-users:v1`, entran en vigor de inmediato y no se publican en GitHub. Los secretos específicos de la máquina y el acceso de arranque local pertenecen al `worker/.dev.vars` ignorado.

El inicio de sesión del correo electrónico del administrador también puede usar Cloudflare Turnstile. Configure la clave del widget público en `_config.yml` como `admin.turnstile_site_key` y almacene el `TURNSTILE_SECRET_KEY` correspondiente como un secreto Worker. La automatización local/de prueba puede usar `ADMIN_TURNSTILE_BYPASS=true`, pero el Workers implementado no debe habilitar esa omisión.

Los formularios de recordatorio de inicio utilizan `_config.yml` `launch_reminders.turnstile_site_key` y el mismo asistente de verificación compartido Turnstile en Worker. `_config.local.yml` puede borrar esa clave pública para ocultar el widget localmente; Las implementaciones pueden reutilizar `TURNSTILE_SECRET_KEY` o configurar `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY`. La automatización local/de prueba puede usar `LAUNCH_REMINDER_TURNSTILE_BYPASS=true` solo en contextos locales/de prueba Worker.

Las rutas de publicación del panel están divididas intencionalmente:

- Las configuraciones, los complementos, las campañas y las publicaciones de contenido se validan a través de Worker y confirman los cambios en GitHub antes del flujo de implementación normal.
- Las publicaciones de vista previa de campaña establecen un indicador de vista previa respaldado por GitHub, almacenan la lista de correos electrónicos permitidos del revisor invitado en un registro KV de 24 horas, envían enlaces de vista previa firmados y registran un evento de auditoría.
- La creación de una nueva campaña por parte del superadministrador escribe un archivo `_campaigns/<slug>.md` de solo vista previa a través de escrituras de repositorio local en desarrollo o la ruta de publicación GitHub en producción, guarda los usuarios de la campaña nuevos o asignados en `admin-users:v1`, envía correos electrónicos a los usuarios asignados cuando están presentes y mantiene la página de la campaña pública oculta hasta el lanzamiento.
- El archivo de campaña de superadministrador valida una campaña no activa en Worker, registra un evento de auditoría y archiva localmente en desarrollo o envía `.github/workflows/archive-campaign.yml` en producción para mover la fuente de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/`.
- Configuración -> Los usuarios guardan directamente en Worker KV y no utilizan el botón de publicar.
- Los códigos de referencia guardados de marketing escriben un registro KV con alcance de campaña solo cuando se guardan explícitamente; Las vistas previas de QR, las lecturas del selector de biblioteca multimedia, las cargas de atribución de Analytics, las lecturas de estado de pago abandonado y los borradores locales de Blast no escriben KV. Los borradores guardados de Shared Marketing/Blast escriben un registro de borrador con alcance de campaña de 7 días solo en el guardado explícito, y los guardados obsoletos fallan en caso de conflicto de revisión. Live Blast envía y escribe el evento de auditoría requerido y el historial enviado lee los registros de auditoría recientes solo cuando se abre la subpestaña Blast. El recordatorio de pago abandonado envía una instantánea de breve duración del currículum para que los enlaces de recordatorio firmados puedan restaurar el mismo contexto del carrito sin almacenar secretos Stripe en la URL.
- Los informes, análisis, soportes, cargas/vistas previas de contenido, borradores locales, filtros, clasificación y descargas de CSV son flujos de navegación de solo lectura.

Para crear o actualizar secretos locales de forma segura, ejecute:

```bash
npm run secrets:dev
```

Ese asistente crea `worker/.dev.vars` a partir de `worker/.dev.vars.example` cuando es necesario, lo bloquea con permisos de archivo solo locales, genera secretos de firma locales, mantiene las variables agrupadas por propósito y solicita claves de proveedor opcionales sin imprimir valores secretos en el terminal. Mantenga esos valores separados de los secretos de producción; `worker/.dev.vars` es para desarrollo local, no una copia de seguridad de las credenciales implementadas. El panel de administración muestra secciones de solo lectura **Secretos y credenciales** y **Uso del plan**, pero nunca almacena valores secretos en confirmaciones `_config.yml`, KV, GitHub ni en borradores de configuración de administrador.

Para iniciar ambas campañas de prueba de administrador en un Worker local en ejecución:

```bash
./scripts/seed-admin-test-campaigns.sh
```

Consulte [docs/PODMAN.md](/es/docs/operations/podman-local-dev/) para conocer el alcance y las limitaciones actuales.

La ruta Podman está validada por el host en macOS. Linux y Windows son compatibles por diseño y tienen cobertura médica/autocontrol, pero no fueron validados por el host en este hilo.

Los scripts de pago y de ayuda E2E también admiten ese modo:

```bash
./scripts/test-checkout.sh --podman
./scripts/test-e2e.sh --podman
./scripts/test-worker.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/pledge-report.sh --podman --local
./scripts/fulfillment-report.sh --podman --local
./scripts/check-projections.sh --podman
npm run test:e2e:headless:podman
npm run podman:doctor
npm run podman:self-check
```

Si desea realizar el pago en el sitio Stripe localmente, agregue `STRIPE_PUBLISHABLE_KEY_TEST=pk_test_...` a [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars) antes de iniciar la pila. La configuración completa de Stripe y el flujo del webhook local están documentados en [docs/PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/).

Para producción, utilice los secretos Cloudflare Worker para las credenciales de tiempo de ejecución y los secretos del repositorio GitHub para la implementación de credenciales o la automatización de acciones GitHub. Los secretos del repositorio GitHub no se convierten automáticamente en secretos de tiempo de ejecución Worker, por lo que las credenciales de administrador con alcance, como `ADMIN_SETTLEMENT_SECRET` y `ADMIN_BROADCAST_SECRET`, también deben configurarse en Cloudflare cuando las rutas implementadas las imponen. No coloque claves secretas Stripe, secretos de webhook, claves Resend, secretos Turnstile, secretos de cliente USPS, claves ZIP.TAX, secretos de administrador ni tokens API Cloudflare en `_config.yml`.

El asistente de configuración/implementación multiplataforma puede impulsar la ruta de configuración de producción común:

```bash
npm run setup:deploy -- --mode=production --dry-run
npm run setup:deploy -- --mode=production
```

Comprueba la autenticación CLI `gh`, `wrangler` y Stripe opcional; ejecuta sincronización de configuración; realiza comprobaciones de preparación de solo lectura cuando hay credenciales disponibles; crea o reutiliza espacios de nombres Cloudflare KV para `VOTES`, `PLEDGES` y `RATELIMIT`; actualiza `worker/wrangler.toml` con los ID de espacio de nombres devueltos; escribe secretos Worker con `wrangler secret put`; escribe secretos del repositorio GitHub con `gh secret set`; y puede ejecutar `wrangler deploy` cuando pasa `--deploy`. Utilice `--skip-readiness` cuando desee un ensayo más estrecho que evite sondas de proveedores activos.

Los dominios del remitente Resend deben coincidir con las direcciones del remitente configuradas. Para esta implementación, los correos electrónicos de aporte y actualización utilizan remitentes `site.example.com` como `The Pool <pledges@site.example.com>`, por lo que la clave API Resend debe estar autorizada para `site.example.com`. Consulte [docs/EMAIL.md](/es/docs/operations/email-system/) para obtener la guía completa de configuración e integración del correo electrónico.

## Cloudflare Guía de planificación para horquillas

The Pool tiene una forma intencionada para que la mayor parte del tráfico siga siendo barato:

- GitHub Pages sirve al sitio estático, por lo que las cargas normales de página no invocan el Worker.
- los datos públicos en vivo prefieren una solicitud `/live/:slug` combinada en lugar de estadísticas separadas + llamadas de inventario
- Las páginas de campaña almacenan en caché las estadísticas en vivo y el inventario en `localStorage` para `cache.live_stats_ttl_seconds` / `cache.live_inventory_ttl_seconds` (`300` predeterminado)
- las pestañas de fondo dejan de actualizarse hasta que la página vuelve a ser visible
- los informes del panel, los patrocinadores, los análisis, las reconstrucciones de estadísticas, los asistentes de liquidación y la enumeración de los patrocinadores de los administradores prefieren los índices `campaign-pledges:{slug}` antes de recurrir a costosos escaneos de espacios de nombres, y las reconstrucciones de estadísticas/inventario reparan los índices de campaña obsoletos cuando detectan una desviación
- Las lecturas normales del panel, la representación de vista previa protegida, las vistas previas de contenido, las vistas previas/descargas de informes, los filtros de soporte, las vistas de análisis, la creación de URL de marketing, las cargas del selector de biblioteca multimedia, el estado de pago abandonado y los borradores del editor local están diseñados para agregar cero escrituras KV.
- La publicación de vista previa protegida escribe una lista de acceso permitido de corta duración `campaign-preview-reviewers:{slug}` más un registro de auditoría, mientras que la campaña respaldada por GitHub Markdown no almacena direcciones de correo electrónico de vista previa.
- el archivo de campaña escribe solo el registro de auditoría de administración en KV; el movimiento de fuente/medio ocurre localmente en dev y en GitHub Acciones para producción
- Las nuevas comprobaciones de deriva de solo lectura facilitan la confirmación cuando las proyecciones están obsoletas antes de ejecutar una ruta de reparación.
- Las rutas de escritura de nivel limitado solicitan al coordinador disponibilidad según la reserva en lugar de reconstruir la verdad a partir de las claves de reserva KV.
- Las lecturas de inventario adicionales de la plataforma utilizan una proyección de recuento de ventas después del arranque inicial, por lo que las actualizaciones normales del inventario no enumeran todas las claves de aporte.
- el envío de recordatorios de lanzamiento, el sondeo de reintento de confirmación de los patrocinadores y los recordatorios de pago abandonado utilizan marcadores de estado de cola; Los ticks cron inactivos omiten los escaneos de la lista KV y las colas inactivas obtienen una nueva verificación de compatibilidad cada hora en lugar de un sondeo de espacio de nombres a nivel de minutos o de 15 minutos.
- Las rutas de lectura públicas siguen siendo intencionalmente permisivas para que una campaña legítimamente popular no alcance límites artificiales anti-DoS, mientras que las costosas escrituras de pago/administración/administración conllevan límites de velocidad y límites de tamaño de solicitud más estrictos.
- Una vez que un cliente ya ha superado una ventana de límite de velocidad, las solicitudes bloqueadas repetidas ya no reescriben el mismo contador KV en cada visita.
- `POST /checkout-intent/abandon` utiliza un depósito de reintentos con alcance de orden para que la limpieza de descarga/reintento siga siendo compatible con las IP compartidas sin dejar abierta la ruta de lanzamiento.
- la configuración Worker también configura `limits.cpu_ms = 100` para Workers estándar/pago implementado, que está muy por encima de los tiempos representativos actuales de distribución de unidades (`6-28 ms`) y, al mismo tiempo, dramáticamente por debajo del límite predeterminado de 30 segundos de Cloudflare para implementaciones pagas.

Perillas de horquilla que vale la pena conocer:

- configuración del sitio: `cache.live_stats_ttl_seconds`, `cache.live_inventory_ttl_seconds`, `performance.intent_prefetch_*`, `pricing.sales_tax_rate`, `shipping.fallback_flat_rate`, `tax.*`
- Entorno Worker: precios sincronizados automáticamente y valores del proveedor de impuestos en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

### Escenarios prácticos de escalabilidad

Estos son escenarios de planificación aproximados, no garantías. Asumen el valor predeterminado
TTL de caché del navegador de cinco minutos y comportamiento de usuario mayoritariamente normal. Límites del proveedor
y los precios cambian independientemente de este repositorio; verificarlos en Cloudflare's
documentación actual antes de elegir un plan.

|Escenario|Actividad diaria dura|Perspectivas del plan|
|----------|----------------------|--------------|
|Pequeño lanzamiento colectivo|~1500 visitas a la página de la campaña, ~75 visitas de administradores/colaboradores, ~20 inicios de pago, ~10 aportes completadas|Gratis es un punto de partida razonable para la forma operativa que The Pool está diseñado para manejar de forma económica.|
|Semana de lanzamiento ocupada|~8000 visitas a la página de la campaña, ~250 visitas de administradores/colaboradores, ~60 inicios de pago, ~25 aportes completados o modificados|A menudo, sigue siendo plausible en el modo Gratis si el abuso se mantiene bajo y los flujos de reparación del administrador son raros, pero aquí es donde el Pago comienza a comprar un margen real.|
|Estudio multiproyecto en crecimiento|~20,000+ lecturas dinámicas por día o muchas docenas de aportes completadas/modificadas/canceladas por día|Comience a planificar el pago antes de un impulso importante. Los días con muchas mutaciones y el camino de abuso se convierten en la parte a tener en cuenta primero.|

Utilice la documentación del proveedor como fuente de verdad para la solicitud actual.
Tiempo de CPU, lectura/escritura/lista de KV y límites de precios:

- [Precios Cloudflare Workers](https://developers.cloudflare.com/workers/platform/pricing/)
- [Cloudflare Workers KV precios](https://developers.cloudflare.com/kv/platform/pricing/)
- [Cloudflare Workers KV límites](https://developers.cloudflare.com/kv/platform/limits/)

La conclusión práctica para las bifurcaciones es simple: The Pool aún puede adaptarse al plan gratuito Workers para su forma prevista de "pequeña cantidad de campañas simultáneas, volumen modesto de patrocinadores, ejecución de un mes", especialmente porque el tráfico de lectura pública es barato y la mayoría de los días tiene poco tráfico de mutación. La razón para pasar a Pagado no es que Gratis de repente dejó de funcionar, sino que Pagado ofrece un margen más saludable para picos de flash, escrituras de ruta de abuso KV, actividad de modificación/cancelación más intensa y más herramientas de operador.

Se espera que un día normal sin colas utilice aproximadamente `48-75` Workers KV solicitudes de lista durante 24 horas: aproximadamente una nueva verificación inactiva cada hora para el envío de recordatorios de lanzamiento y las colas de reintento de correo electrónico de soporte, además de arranques de proyección ocasionales o rutas de reparación del operador. Los trabajos de recordatorio de lanzamiento activos y los reintentos de correo electrónico de los colaboradores aún muestran sus colas limitadas cuando hay trabajo real pendiente.

Un matiz de implementación: el bloque `limits` configurable de Cloudflare solo se aplica en el modelo de uso estándar y solo en Workers implementado, no en el desarrollo local. Eso significa que la nueva protección `cpu_ms` es un respaldo de denegación de billetera para implementaciones pagas, mientras que Workers Free todavía depende de los techos de plan libre integrados de Cloudflare.

## Pruebas

```bash
npm run test:premerge  # Syntax + full/focused regressions + first-party build checks + local smoke + security + headless E2E
npm run test:secrets   # Secret exposure audit against local env files, tracked files, and git history
npm run release:smoke -- --evidence-file /tmp/pool-release-smoke.md # Release sign-off wrapper
npm run release:a11y-evidence # Focused campaign/cart accessibility evidence
npm run release:i18n-seo-evidence # Rendered i18n/SEO evidence over built _site
npm run release:pledge-evidence # Worker-backed pledge/report evidence
npm run release:providers -- --no-dev-vars # Read-only external provider readiness
npm run release:payment-smoke -- --no-dev-vars # Payment contract and no-send smoke evidence
npm run test:unit      # Unit tests (Vitest)
npm run test:e2e       # E2E tests (Playwright) — fully automated browser coverage
npm run test:e2e:headless # CI-style automated browser suite
npm run test:e2e:headless:podman -- tests/e2e/accessibility-public-pages.spec.ts --project=chromium # Podman-backed public accessibility slice
npx playwright test tests/e2e/admin-dashboard.spec.ts --project=chromium # Focused admin dashboard browser suite
npm run test:e2e:headless:podman -- tests/e2e/admin-dashboard.spec.ts --project=chromium # Podman-backed admin create/preview dashboard suite
node --check assets/js/admin-dashboard.js # Dashboard JavaScript syntax check
npm run test:security  # Security tests — pen testing the Worker API
npm run test:security:podman # Security tests with a Podman-backed local stack in one invocation
npm run assets:minify:check # Check built _site CSS/JS for remaining minification savings
npm run media:optimize:check # Check uploaded media for pending optimization/derivatives
npm run media:optimize:check:podman # Same media check inside the Podman toolchain
npm test               # Run unit + e2e
```

Para aprobar la versión de producción, prefiera `npm run release:smoke -- --evidence-file /tmp/pool-release-smoke.md`. Incluye la puerta de fusión, el ensayo de preparación para la configuración/implementación, Podman E2E cuando esté disponible, evidencia de accesibilidad enfocada, evidencia i18n/SEO renderizada, evidencia de aporte/informe, verificaciones de proveedores y preparación para el humo de pago. Utilice las banderas `--skip-*` solo cuando el elemento omitido esté cubierto por evidencia separada en las notas de la versión.

Informes locales:
```bash
./scripts/pledge-report.sh --local
./scripts/fulfillment-report.sh --local
./scripts/check-projections.sh
ADMIN_SECRET=... ./scripts/check-observability.sh --local
```

Los informes de producción/desarrollo remotos leen Cloudflare KV hasta Wrangler, por lo tanto, autentique Wrangler primero:
```bash
cd worker && npx wrangler login

# Or, for non-interactive shells and Podman-backed report runs:
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
./scripts/pledge-report.sh --env production --remote > ~/Desktop/pool-pledge-report.csv
./scripts/fulfillment-report.sh --env production --remote > ~/Desktop/pool-fulfillment-report.csv
```
Para informes remotos respaldados por Podman, prefiera `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` en el shell del host o un archivo env local ignorado como `.env.local`, `.env.cloudflare` o `worker/.dev.vars`; los contenedores de informes pasan esos valores de autenticación Cloudflare a `podman exec`. Configuración de la horquilla:

1. En Cloudflare, cree un token API de usuario desde **Mi perfil -> Tokens API -> Crear token**.
2. Conceda **Cuenta/Workers KV Almacenamiento/Lectura** para la cuenta propietaria del espacio de nombres `PLEDGES` KV.
3. Agregue el token y la identificación de la cuenta a `worker/.dev.vars`:

```bash
CLOUDFLARE_API_TOKEN=your-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

Luego ejecute las exportaciones de producción remota a través del contenedor de trabajadores Podman:

```bash
./scripts/pledge-report.sh --podman --env production --remote > ~/Desktop/pool-pledge-report.csv
./scripts/fulfillment-report.sh --podman --env production --remote > ~/Desktop/pool-fulfillment-report.csv
```

Los informes remotos imprimen el progreso de la recuperación de aportes en stderr, por lo que la salida CSV redirigida permanece limpia.

Pruebas locales respaldadas por Podman:

```bash
./scripts/test-checkout.sh --podman  # Manual interactive checkout helper against the Podman dev stack
./scripts/test-e2e.sh --podman       # Automated browser helper against the Podman dev stack
./scripts/test-worker.sh --podman    # Site/Worker contract smoke against the Podman dev stack
./scripts/smoke-pledge-management.sh --podman  # Mutable-pledge smoke against the Podman dev stack
./scripts/pledge-report.sh --podman --local    # Local ledger CSV through the Worker container
./scripts/fulfillment-report.sh --podman --local # Local fulfillment CSV through the Worker container
npm run test:e2e:headless:podman     # Automated browser suite with Playwright in a container
npm run test:security:podman         # Security suite against a one-shot Podman-backed local stack
```

La puerta previa a la fusión prueba primero la ruta del host Bundler/Jekyll, incluido un intento único de `bundle install` cuando Bundler está presente pero faltan gemas. Mantiene el humo más ligero del host Worker, pero ejecuta el humo de aporte mutable a través de la pila respaldada por Podman, de modo que la ruta de modificación/cancelación con estado utiliza un estado de servicio local aislado incluso cuando la ruta de compilación del host tiene éxito. Ese humo mutable también rota sus IP de solicitud de administrador sintéticas para que el límite de tasa de administración real de Worker no cree fallas falsas durante las verificaciones de reconstrucción de proyección local. Si la ruta Ruby del host aún no puede producir una compilación limpia, la puerta recurre a la compilación del artefacto respaldada por Podman en lugar de fallar temprano en la configuración del host.

El arnés del navegador sin cabeza crea un `_site` estático limpio y lo sirve con un servidor HTTP liviano en lugar de depender de `jekyll serve`, lo que mantiene las regresiones del navegador más cercanas a la forma real de los activos publicados.

- `pledge-report.sh` es una exportación de libro mayor/historial, por lo que los aportes modificados aparecen como deltas y los cambios mixtos mantienen el contexto de actualización de sugerencias en la columna `items`.
- `fulfillment-report.sh` es la vista fusionada del estado actual según `email + campaign`, que es el mejor punto de comparación para patrocinadores repetidos y proyectos no acumulables.
- `check-projections.sh` es la verificación del operador de solo lectura para la deriva almacenada de `campaign-pledges:{slug}`, `stats:{slug}` y `tier-inventory:{slug}` antes de decidir reparar algo.
- Si el sitio alguna vez se desvía de la vista de cumplimiento del estado actual, las rutas de cálculo de estadísticas/inventario del administrador reparan automáticamente los índices `campaign-pledges:{slug}` obsoletos en lugar de confiar en ellos para siempre.

**Verificación:** `npm run test:premerge` es el canónico local y PR `Merge
Puerta de humo. Utilice el resultado del flujo de trabajo más reciente o publique evidencia para un pase fechado
registrar en lugar de tratar esta guía como evidencia de prueba.

**La cobertura de la prueba incluye:** funciones de estadísticas en vivo, asistentes propina de plataforma, hash de intención de pago de primera mano y cableado de carga útil, desgloses de sugerencias de correo electrónico de soporte, rutas de registro/cancelación de suscripción/envío de recordatorio de lanzamiento, rutas de suscripción/envío/supresión de pago abandonado, indicadores de gestión de aportes, totales de liquidación, barras de progreso, desbloqueo de niveles, elementos de soporte, temporizadores de cuenta regresiva, flujo de carrito, accesibilidad (incluido el respaldo de hacha). comprobaciones de páginas públicas en estados de campaña, comunidad y resultados de aportes, instantáneas de ARIA y aserciones de pago/administración/comunidad/control público solo con teclado), regresiones de ventana gráfica móvil para páginas públicas y flujos de aportes, estados de campaña, auditoría de exposición secreta, auditoría de HTML/enlace/incrustación de contenido de campaña, coordinación de inventario de niveles serializado y refuerzo en torno a `/checkout-intent/start`, manejo de webhook, alcance de enlace mágico, integridad de liquidación y paginación. reconstruir/rellenar rutas.

Para humo de fusión local en aportes mutables, utilice:

```bash
./scripts/smoke-pledge-management.sh
```

Para el humo de contrato más ligero del sitio/Worker, incluidas las comprobaciones de puntos finales eliminados y la cobertura `/checkout-intent/start` con formato incorrecto, utilice:

```bash
./scripts/test-worker.sh
```

Consulte [TESTING.md](/es/docs/operations/testing/) para obtener una guía de prueba completa y [SECURITY.md](/es/docs/operations/security/) para ver la arquitectura de seguridad.

## Documentación

Consulte [`docs/`](/es/docs/) para obtener la documentación completa:

Buenos puntos de partida después de clonar una bifurcación son [PROJECT_OVERVIEW.md](/es/docs/development/project-overview/), [CUSTOMIZATION.md](/es/docs/development/customization-guide/), [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/), [EMAIL.md](/es/docs/operations/email-system/), [SECURITY.md](/es/docs/operations/security/), [ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/) y [PRUEBAS.md](/es/docs/operations/testing/).

- [CONTRIBUTING.md](/es/docs/development/contributing/) — Guía de introducción, configuración y contribución
- [CHANGELOG.md](/es/docs/reference/changelog/) — Notas de la versión
- [PODMAN.md](/es/docs/operations/podman-local-dev/) — Ruta de desarrollo local Podman sin raíz para Jekyll + Worker
- [BACKUP_RESTORE.md](/es/docs/operations/backup-restore/) — Runbook de copia de seguridad, restauración, retención, reconciliación y recuperación ante desastres
- [PROJECT_OVERVIEW.md](/es/docs/development/project-overview/) — Arquitectura del sistema
- [WORKFLOWS.md](/es/docs/development/workflows/) — Ciclo de vida del aporte, enlaces mágicos y flujo de carga
- [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) — Configuración de Stripe, canonicalización del pago, webhooks, liquidación y conciliación
- [TAX_CALCULATOR.md](/es/docs/operations/tax-calculator/) — Modos de proveedor de impuestos, cotizaciones canónicas Worker, configuración reflejada y verificación
- [EMAIL.md](/es/docs/operations/email-system/) — Configuración del remitente Resend, tipos de correo electrónico transaccional/de campaña, localización y comportamiento de entrega
- [DEV_NOTES.md](/es/docs/development/developer-notes/) — Notas de desarrollo, modelo de contenido y preguntas frecuentes
- [TESTING.md](/es/docs/operations/testing/) — Guía de prueba completa y referencia de secretos
- [SECURITY.md](/es/docs/operations/security/) — Arquitectura de seguridad, limitación de velocidad y prueba de penetración
- [ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/) — Solicitudes de revisión de riesgos éticos para datos, dinero, mensajes, administración, uso compartido y cambios de automatización
- [ACCESSIBILITY.md](/es/docs/operations/accessibility/) — Estándares de accesibilidad, superficies críticas y cobertura actual
- [CUSTOMIZATION.md](/es/docs/development/customization-guide/) — Anulaciones de diseño, precios y marcas orientadas a la bifurcación admitidas
- [EMBEDS.md](/es/docs/development/campaign-embeds/) — Rutas, opciones, localización y modelo de cambio de tamaño del widget de campaña alojado
- [I18N.md](/es/docs/development/internationalization/) — Estructura de localización actual, modelo de enrutamiento y flujo de trabajo de adición de idiomas
- [SHIPPING.md](/es/docs/operations/shipping/): modelo de envío actual, configuración de USPS y política alternativa
- [SEO.md](/es/docs/operations/seo/): rastreo actual, metadatos, JSON-LD y modelo sin índice
- [PERFORMANCE.md](/es/docs/operations/performance/): modelo de rendimiento de la plataforma, minificación de activos generados, compresión Cloudflare, carga en tiempo de ejecución, almacenamiento en caché, medios, incrustaciones diferidas de héroes de YouTube y captación previa pública segura
- [ADD_ON_PRODUCTS.md](/es/docs/development/add-on-products/) — Estructura actual del catálogo de complementos global y modelo inicial de importación de productos
- [DASHBOARD.md](/es/docs/operations/admin-dashboard/) — Referencia del panel de administración privado para operaciones y edición de campañas
- [ROADMAP.md](/es/docs/reference/roadmap/): solo trabajo potencial; El comportamiento actual se encuentra en el archivo README y en las guías de práctica.
- [Lista de verificación para creadores de campañas](https://github.com/your-org/your-project/blob/main/creator-campaign-checklist.md): hoja de trabajo de preparación para el lanzamiento del creador público, con ruta en español en `/es/creator-campaign-checklist/`

## Directorios clave

```
admin.md              # Private admin dashboard route
_campaigns/           # Markdown campaign files
_layouts/             # Page templates (campaign, community, manage, etc.)
_includes/            # Reusable components
  └── blocks/         # Content block renderers (text, image, video, gallery, etc.)
_plugins/             # Jekyll plugins (money filter, campaign state)
assets/
  ├── main.scss       # Sass entry point
  ├── partials/       # Modular Sass (14 focused partials)
  │   ├── _variables.scss     # Colors, spacing, typography tokens
  │   ├── _mixins.scss        # Breakpoints, button patterns
  │   ├── _base.scss          # Reset, typography, links
  │   ├── _layout.scss        # Page structure, grid, header
  │   ├── _buttons.scss       # Button variants
  │   ├── _forms.scss         # Form elements
  │   ├── _cards.scss         # Campaign cards, tier cards
  │   ├── _progress.scss      # Progress bars, stats
  │   ├── _modal.scss         # Modal dialogs
  │   ├── _campaign.scss      # Campaign page specifics
  │   ├── _community.scss     # Community/voting pages
  │   ├── _manage.scss        # Pledge management page
  │   ├── _content-blocks.scss # Rich content rendering
  │   ├── _utilities.scss     # Helper classes
  └── js/             # Client-side scripts
      ├── cart.js             # Pledge flow (tiers, support items, tip UI, shipping detection)
      ├── campaign.js         # Phase tabs, toasts
      ├── admin-dashboard.js  # Private dashboard UI, editors, tables, and publish flows
      ├── buy-buttons.js      # Button handlers
      ├── live-stats.js       # Real-time stats, inventory, tier unlocks, late support
      └── cart-provider.js    # First-party cart/runtime provider
worker/               # Cloudflare Worker (worker.example.com)
  └── src/            # Worker source (Stripe, email, voting, tokens, tip-aware totals)
scripts/              # Automation & reporting
  ├── dev.sh               # Start all dev services (host mode or Podman mode)
  ├── dev-podman.sh        # Rootless Podman launcher for Jekyll + Worker
  ├── setup-deploy.mjs     # Cross-platform local/production setup helper
  ├── pledge-report.sh     # Ledger-style CSV report (history entries incl. tip columns)
  ├── fulfillment-report.sh # Aggregated CSV report (current state by backer, total incl. tip)
  ├── smoke-pledge-management.sh # Local end-to-end modify/cancel smoke on the test-only campaign
  └── seed-all-campaigns.sh # Seed test pledges for all campaigns (local KV)
tests/                # Test suites
  ├── unit/               # Vitest unit tests (JS functions)
  ├── e2e/                # Playwright E2E tests (browser flows)
  └── security/           # Vitest security / abuse-path coverage for the Worker
```

## Despliegue

Envíe los cambios revisados ​​a `main` para actualizar el sitio de producción GitHub Pages:

```bash
git push origin main
```

Las versiones de Worker utilizan el flujo de trabajo de acciones **Implementar producción** GitHub enviado manualmente con una rama, etiqueta o confirmación inmutable revisada en su entrada `ref`. Para una versión normal, combine la rama de versión con `main` y luego envíe **Implementar producción** con `ref=main`. Ese flujo de trabajo implementa ambos:

- el sitio GitHub Pages
- el Cloudflare Worker de `worker/wrangler.toml`

Las ejecuciones rutinarias de **Actualizar páginas de producción**, incluidas las actualizaciones programadas del estado de la campaña, no implementan Worker.

La compilación de páginas ejecuta Jekyll primero, luego `npm run assets:minify` contra el CSS/JavaScript `_site/assets` generado y las copias generadas de los scripts del navegador Site Shell anclados antes de cargar el artefacto. Las raíces seleccionadas son explícitas y seguras para el recorrido; Los archivos fuente permanecen legibles en el repositorio. Cloudflare todavía maneja la compresión gzip/Brotli/Zstandard en el borde, por lo que Cloudflare Auto Minify permanece deshabilitado.

Secretos del repositorio GitHub necesarios para la implementación automática de Worker:
- `CLOUDFLARE_API_TOKEN` a partir de un **token de API de usuario** creado en **Mi perfil -> Tokens de API**, utilizando la plantilla **Editar Cloudflare Workers** y con alcance en esta cuenta y la zona `example.com`. No utilice un token API propiedad de la cuenta; Wrangler todavía llama a puntos finales de ámbito de usuario, como membresías, durante la implementación.
- `CLOUDFLARE_ACCOUNT_ID`
- `ADMIN_SECRET` para la verificación del diario posterior a la implementación
- `ADMIN_BROADCAST_SECRET` opcional para la verificación del diario posterior a la implementación cuando Worker usa credenciales de transmisión con alcance
- `CLOUDFLARE_CACHE_PURGE_TOKEN` opcional con permisos de purga de caché de zona si desea que la purga de caché utilice un token más estrecho que el token de implementación. Esto es recomendable; de lo contrario, también se debe permitir que el token de implementación purgue la caché.
- `CLOUDFLARE_DNS_API_TOKEN`, `CLOUDFLARE_ZONE_ID` y `CLOUDFLARE_ZONE` opcionales para el flujo de trabajo de publicación de evidencia del proveedor. El token DNS utiliza acceso de zona/DNS/lectura de solo lectura para la zona de producción.
- `CLOUDFLARE_CACHE_RULES_API_TOKEN` más `CLOUDFLARE_ZONE_ID` para aplicar/conciliar la regla de respuesta del administrador con alcance de ruta. Utilice un token dedicado con Edición de reglas de caché; La verificación pública posterior a la implementación no necesita credenciales.
- `DIARY_CHECK_BYPASS_SECRET` opcional si Cloudflare WAF desafía la verificación del diario posterior a la implementación

Para una configuración guiada por primera vez, ejecute:

```bash
npm run setup:deploy -- --mode=production --dry-run
npm run setup:deploy -- --mode=production --deploy
```

Revise el ensayo antes de aplicar los cambios. La ayuda automatiza la configuración repetitiva, pero no reemplaza la revisión de los alcances de los tokens Cloudflare, los permisos del repositorio GitHub, los puntos finales del webhook Stripe, la verificación del remitente Resend, los widgets Turnstile, las credenciales del proveedor USPS/ZIP.TAX y la lista de verificación de humo de fusión.

Establezca los secretos `ADMIN_BROADCAST_SECRET` o `ADMIN_SETTLEMENT_SECRET` coincidentes en Cloudflare Worker antes de confiar en la aplicación de rutas con alcance en producción. Agregue `ADMIN_SETTLEMENT_SECRET` a los secretos del repositorio GitHub solo si una acción GitHub o un flujo de trabajo del operador realmente llama a puntos finales de liquidación. Mantenga valores locales separados en `worker/.dev.vars`; no copie los valores de producción allí como copia de seguridad.

El flujo de trabajo también necesita permisos de implementación GitHub Pages. Mantenga `pages: write` y `id-token: write` explícitos en el trabajo de implementación de páginas si copia o refactoriza `.github/workflows/deploy.yml`.

Los medios cargados en el panel conservan el origen cuando ingresan al repositorio. Las cargas de imágenes y videos envían el flujo de trabajo separado **Optimizar medios del panel** con `scope=changed` después de que la confirmación GitHub se realice correctamente; las cargas de audio permanecen conservadas en origen porque ese flujo de trabajo no procesa `assets/audio`. El contenido de la campaña, el contenido del diario y las cargas de imágenes de correo electrónico Blast reutilizan esta misma ruta de recursos de la campaña, por lo que las imágenes de correo electrónico se alojan en el dominio del sitio y se optimizan mediante el flujo de trabajo de medios del repositorio en lugar de vincularse desde hosts externos arbitrarios. Los bloques de imágenes también pueden seleccionar imágenes de campaña existentes desde un selector de biblioteca multimedia de solo lectura; Los superadministradores pueden elegir imágenes compartidas/predeterminadas, mientras que los usuarios de la campaña permanecen dentro del alcance de la campaña. El flujo de trabajo también se ejecuta en `main` para cambios `assets/images/**`, `assets/videos/**`, `_campaigns/**` y `_config.yml`; comprime imágenes cuando hay una salida más pequeña disponible, genera variantes WebP responsivas para plantillas de imágenes públicas en `320w`, `480w`, `640w`, `960w` y `1600w`, genera derivados WebM para videos cargados, reescribe referencias de video literales después de que existan derivados y abre una solicitud de extracción con esos cambios de optimización en lugar de enviar directamente a `main`. Utilice la opción de flujo de trabajo manual `scope=all` cuando los medios de campaña existentes necesiten un reprocesamiento completo o cuando sea necesario barrer los medios que no están en el panel.

Si la verificación del diario registra una página de desafío HTTP `403` Cloudflare, la solicitud se detiene antes de que llegue a Worker. Agregue una regla personalizada WAF Cloudflare que omita los desafíos administrados para:

- anfitrión es igual a `worker.example.com`
- ruta es igual a `/admin/diary/check`
- método es igual a `POST`
- encabezado `X-Pool-Diary-Check` es igual al valor `DIARY_CHECK_BYPASS_SECRET`

Expresión sugerida:

```text
(http.host eq "worker.example.com" and http.request.method eq "POST" and http.request.uri.path eq "/admin/diary/check" and any(http.request.headers["x-pool-diary-check"][*] eq "your-bypass-secret"))
```

Worker aún requiere `Authorization: Bearer ADMIN_BROADCAST_SECRET` cuando se configuran las credenciales de transmisión con alcance; de ​​lo contrario, `Authorization: Bearer ADMIN_SECRET`; el encabezado de omisión solo permite que la automatización de acciones GitHub llegue a ese punto final autenticado.

Respaldo manual de Worker desde la raíz del repositorio:
```bash
npm run deploy:worker
```

El Worker potencia:
- Arranque de sesión en el modo de configuración Stripe en el sitio para el sidecar de pago propio y el modal Manage Pledge `Update Card`, con respaldo alojado aún disponible como ruta de compatibilidad
- Procesamiento de webhooks y persistencia de aportes.
- cálculo total teniendo en cuenta las propinas
- entrega de correo electrónico a patrocinadores a través de Resend
- Envío de recordatorio de lanzamiento de próxima campaña a través de la ruta compartida Resend
- entrega de recordatorio de pago abandonado basado en el consentimiento a través de la ruta compartida Resend
- Campañas -> Envío de correo electrónico a colaboradores de Blast a través de la ruta compartida Resend
- flujos de liquidación y reintento por lotes
- autenticación del panel de administración del navegador, API de lectura, API de publicación respaldadas por GitHub, vistas previas de campañas protegidas, creación de nuevas campañas, administración de usuarios, guardado de referencias de marketing y puntos finales de administración de secreto compartido heredados

---
