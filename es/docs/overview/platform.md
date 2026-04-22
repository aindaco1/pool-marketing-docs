---
title: Resumen de la plataforma
parent: Resumen
nav_order: 1
render_with_liquid: false
lang: es
---

# The Pool

**Plataforma de financiación colectiva de código abierto de Dust Wave** — [site.example.com](https://site.example.com)

Hito de lanzamiento actual: **v0.9.4**. The Pool considerará **v1.0** como el hito de lanzamiento público más amplio una vez que se completen los elementos restantes de la hoja de ruta.

Un sitio estático de carrito propio Jekyll + para crowdfunding creativo de todo o nada. Los patrocinadores crean una promesa en el carrito propiedad del navegador de The Pool, el trabajador de Cloudflare canonicaliza la contribución a través de `/checkout-intent/start` y Stripe recopila y guarda los detalles de la tarjeta a través de un paso de pago seguro en el sitio para que las tarjetas solo se carguen después de que una campaña exitosa alcance su fecha límite. Un pago único puede incluir artículos de múltiples campañas; Después de la confirmación del webhook, los fanáticos de los trabajadores se agrupan en registros de compromiso separados con alcance de campaña. Si se financia, un cron de trabajador envía liquidaciones por lotes y cobra promesas fuera de sesión. Opcionalmente, los seguidores pueden agregar un consejo sobre la plataforma, administrar promesas a través de enlaces mágicos con alcance de pedido y volver a visitar un panel de administración de promesas compatible con escritorio con secciones Activas/Cerradas.

## Características

- **No se requieren cuentas**: los patrocinadores administran sus promesas a través de enlaces mágicos por correo electrónico
- **Pago verificado por el servidor**: el trabajador canonicaliza el contenido del carrito a partir de artículos de carrito propios en lugar de confiar en los totales enviados por el navegador.
- **Pago de varias campañas**: un pago puede incluir varias campañas, mientras que el almacenamiento, los correos electrónicos, los informes y la administración permanecen dentro del alcance de la campaña después de la confirmación.
- **Promesa de todo o nada**: tarjetas guardadas ahora, cobradas solo si se alcanza el objetivo
- **Propina de plataforma opcional**: propina del 0% al 15% (5% predeterminado) incluida en los totales, pero excluida del progreso de la campaña.
- **Carro y pago con reconocimiento de propinas**: la lógica de precios compartida mantiene sincronizados el subtotal, las propinas, los impuestos, el envío y el total en el carrito, el pago, el trabajador, los informes y los correos electrónicos.
- **Cotizaciones de envío respaldadas por USPS con barreras de seguridad**: el pago físico y la modificación de flujos pueden cotizar envíos nacionales/internacionales de USPS, usar tarifas planas/manuales explícitas cuando estén configuradas, recurrir de forma segura a tarifas fijas configuradas y admitir actualizaciones de firmas nacionales opcionales sin forzar la rotación de cotizaciones en KV.
- **Complementos de plataforma con reconocimiento de inventario**: los complementos de merchandising a nivel de paquete se pueden adjuntar al proceso de pago, permanecer editables en Administrar compromiso, admitir existencias por variante y seguir el mismo flujo canónico de envío, informes y correo electrónico sin contar para los objetivos de financiación de la campaña.
- **Complementos de campaña con contabilidad basada en campaña**: el descuento de campaña también puede definir complementos con alcance de campaña que se muestran en el mismo carrito/administrar la interfaz de usuario, cuentan para el subtotal de financiación de esa campaña, siguen las anulaciones de envío de la campaña y desaparecen automáticamente cuando el compromiso de campaña propietario abandona el carrito.
- **Paso de pago de Stripe en el sitio**: el segundo sidecar de pago existente aloja la interfaz de usuario de pago de Stripe segura y Manage Pledge utiliza el mismo patrón para `Update Card`.
- **Configuraciones configurables de precios e impuestos del proveedor**: `pricing.*` y `tax.*` viven en `_config.yml`, y las variables de trabajador reflejadas se sincronizan automáticamente en `worker/wrangler.toml` para que las vistas previas del navegador, los estados de impuestos provisionales y los totales del lado del servidor permanezcan alineados.
- **Niveles físicos y digitales**: los artículos físicos activan la captura de la dirección de envío durante el proceso de pago, además de cotizaciones de USPS calculadas por el trabajador, tarifas alternativas configuradas y actualizaciones de firma nacionales opcionales cuando están habilitadas.
- **Enlaces mágicos relacionados con el pedido**: cada enlace de colaborador solo administra su propio compromiso/pedido.
- **Sesiones de apoyo más seguras**: las páginas de la comunidad mantienen el acceso de los seguidores en el almacenamiento de sesiones del navegador en lugar de una cookie simbólica de larga duración.
- **Objetivos a largo plazo**: desbloqueo automático en los umbrales de financiación
- **Ciclo de vida de la campaña**: estados `upcoming` → `live` → `post` con transiciones automáticas + purga de caché de Cloudflare
- **Temporizadores de cuenta regresiva** — Hora de montaña (MST/MDT) con detección automática de horario de verano, renderizado previamente para evitar flashes
- **Fases de producción y registro**: interfaz con pestañas para necesidades de financiación detalladas
- **Decisiones de la comunidad**: votación/encuesta para la participación de los patrocinadores con listas de opciones permitidas publicadas y bloqueo de decisiones cerrado
- **Bloques de contenido de campaña desinfectados**: el contenido de campaña y diario de formato largo acepta Markdown más un pequeño subconjunto en línea seguro (`<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`), neutraliza los esquemas de enlaces de Markdown no seguros, abre automáticamente enlaces externos en una nueva pestaña y escapa o rechaza otro HTML sin formato.
- **Incrustaciones estructuradas estrictas**: las incrustaciones `spotify`, `youtube` y `vimeo` aprobadas se validan con orígenes confiables exactos y rutas de inserción en lugar de coincidencias de subcadenas.
- **Inventario serializado de niveles limitados**: las recompensas escasas se reservan a través de un objeto duradero por campaña al inicio del pago y se confirman a través del mismo coordinador en el momento de la persistencia, por lo que los niveles limitados no se sobrevenden bajo demanda simultánea.
- **Manejo estricto de promesas faltantes** — Las lecturas de promesas de Magic-link fallan al cerrarse con `404` cuando falta el registro de promesa de respaldo
- **Diario de producción**: actualizaciones de contenido enriquecido con correos electrónicos de transmisión automática a los seguidores
- **Anuncios**: el administrador transmite correos electrónicos con enlaces de CTA personalizados a los seguidores.
- **Integración de Instagram**: CTA social opcional en los correos electrónicos de los seguidores
- **Financiamiento continuo** — Sección de apoyo posterior a la campaña
- **Panel de administración de promesas**: secciones activas/cerradas fáciles de usar para escritorio con controles de solo lectura en estado bloqueado después de la fecha límite
- **Correos electrónicos e informes con sugerencias**: los correos electrónicos de los colaboradores, los informes de compromiso y las exportaciones de cumplimiento incluyen la sugerencia de la plataforma cuando está presente.
- **Informes de ejecución de campaña**: los correos electrónicos configurables del libro mayor de compromisos diarios con alcance de campaña y las exportaciones de cumplimiento posteriores a la fecha límite pueden ir a los destinatarios de ejecución configurados de cada campaña, mientras que las filas completadas por la plataforma se pueden enrutar por separado a `support_email`, con asuntos concisos que priorizan la entregabilidad, notas de orientación específicas de la campaña y una ruta de administración de ejecución en seco/envío manual para las operaciones.
- **Diagnóstico de deriva de proyección**: las comprobaciones administrativas de solo lectura y una CLI local pueden comparar las estadísticas almacenadas, el inventario y los índices de campaña con la verdad del compromiso guardado antes de que cualquier ruta de reparación modifique los datos.
- **Sistema visual compartido**: las páginas públicas, las superficies de campaña, el carrito/pago y Manage Pledge utilizan el mismo lenguaje de tipografía, botones, campos y tarjetas reutilizables y más tranquilos.
- **Pulido adaptable para dispositivos móviles**: las páginas de campaña, los flujos de pago/administración, las páginas de la comunidad y el contenido de formato largo comparten un espacio de pantalla pequeño, cajones con reconocimiento de áreas seguras, objetivos de toque más grandes y correcciones de desbordamiento en lugar de una interfaz de usuario separada solo para dispositivos móviles.
- **Línea base de accesibilidad**: los shells públicos ahora mantienen enlaces de omisión y puntos de referencia principales estables, mientras que los flujos de carrito/pago utilizan una semántica de diálogo más sólida, actualizaciones de regiones en vivo y etiquetas accesibles más claras sin mover los campos de pago fuera de la interfaz de usuario segura propiedad de Stripe.
- **Personalización de la primera bifurcación variable**: la configuración estructurada ahora impulsa la marca, los precios, las configuraciones sincronizadas con los trabajadores, los activos principales de la marca, las variables de diseño seleccionadas, los elementos Stripe temáticos y los correos electrónicos de los seguidores de la marca sin necesidad de un código personalizado para el cambio de marca normal de la bifurcación.
- **Inserciones de campañas en vivo alojadas**: las páginas de la campaña ahora se vinculan a un generador de inserciones con reconocimiento regional que genera código iframe de copiar y pegar con opciones de diseño/tema/medios/CTA, datos en vivo respaldados por los trabajadores y comportamiento de cambio de tamaño automático.
- **Fundación i18n en inglés + español**: `_config.yml` ahora ofrece idiomas admitidos, rutas de configuración regional estática, rutas de campaña localizadas generadas, datos de traducción compartidos y un selector de idioma de pie de página más silencioso, con español en vivo en inicio/acerca de/términos, páginas de campaña públicas, páginas insertadas, páginas de resultados de promesas, `/manage/`, `/community/`, rutas de la comunidad de seguidores, carrito/comunidad propiedad del sitio/Administrar compromiso/copia en tiempo de ejecución insertada, campaña etiquetas de cuenta regresiva/galería/estadísticas en vivo, resúmenes de los botones del carrito, copia auxiliar de ubicación de impuestos de pago, video principal/avance de la comunidad/diario cromado, fechas de campaña localizadas y correos electrónicos de apoyo de los trabajadores localizados
- **Línea de base de los fundamentos de SEO**: las páginas públicas y las páginas de campaña ahora emiten títulos consistentes, descripciones, canónicos, etiquetas OG/Twitter, metadatos de idiomas localizados, JSON-LD honesto, imágenes de tarjetas compartidas de campaña generadas por los trabajadores y metadatos de idiomas alternativos cuando sean compatibles, mientras que `robots.txt`, `sitemap.xml` y las reglas explícitas de noindex mantienen los flujos privados/tokenizados fuera de la intención de búsqueda.
- **Integración de CMS**: [Páginas CMS](https://pagescms.org) para edición visual de campañas

## Arquitectura

```
[Visitor] → GitHub Pages (Jekyll + first-party cart / checkout sidecars)
          → Cloudflare Worker (on-site Stripe session bootstrap + webhook + cron)
```

|capa|Plataforma|Rol|
|-------|----------|------|
|Interfaz|Páginas de GitHub|Jekyll + Sass + tiempo de ejecución del carrito propio|
|Pagos|raya|Campos de pago seguros, métodos de pago guardados, cargos fuera de sesión|
|API|Trabajador de Cloudflare|Arranque de sesión de pago, webhook, totales con reconocimiento de propinas, estadísticas, liquidación automática, purga de caché|
|CMS|Páginas CMS|Edición de campaña visual (se compromete con GitHub)|

## Inicio rápido

```bash
npm run podman:doctor
./scripts/dev.sh --podman
# Visit http://127.0.0.1:4000
```

Ése es el camino recomendado para el desarrollo local. Arranca Jekyll, el Worker, el reenvío opcional de Stripe CLI y los servicios de soporte local junto con los valores predeterminados actuales del repositorio.

Si desea reconstruir las imágenes de desarrollo de Podman después de cambios de dependencia o de imagen base:
```bash
PODMAN_REBUILD=1 ./scripts/dev.sh --podman
```

Las configuraciones de precios compatibles con Fork se encuentran en:
- `pricing.sales_tax_rate`, `pricing.default_tip_percent` y `pricing.max_tip_percent` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Vars de trabajo sincronizadas automáticamente `SALES_TAX_RATE`, `DEFAULT_PLATFORM_TIP_PERCENT` y `MAX_PLATFORM_TIP_PERCENT` en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

Las configuraciones del motor de impuestos compatibles con Fork se encuentran en:
- `tax.provider`, `tax.origin_country`, `tax.use_regional_origin`, `tax.nm_grt_api_base` y `tax.zip_tax_api_base` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Vars de trabajador reflejadas `TAX_PROVIDER`, `TAX_ORIGIN_COUNTRY`, `TAX_USE_REGIONAL_ORIGIN`, `NM_GRT_API_BASE` y `ZIP_TAX_API_BASE` en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)
- `tax.provider: flat` mantiene la línea base de tasa configurada heredada de `pricing.sales_tax_rate`
- `tax.provider: offline_rules` utiliza reglas internacionales de IVA/GST suministradas además de un comportamiento alternativo a nivel estatal
- `tax.provider: nm_grt` utiliza primero el conjunto de datos inicial de Nuevo México suministrado y puede refinar las búsquedas de direcciones de calles de Nuevo México con la API gratuita EDAC GRT.
- Secreto de trabajador opcional `ZIP_TAX_API_KEY` cuando `tax.provider: zip_tax` está habilitado para búsquedas de impuestos de EE. UU. a nivel local/jurisdiccional

El comportamiento de pago actual es intencionalmente conservador: si el navegador aún no tiene suficientes datos de destino, el carrito muestra el impuesto provisional como `--` y la cotización de impuestos final se resuelve una vez que el Trabajador tiene suficientes detalles de ubicación de facturación o envío.

Las configuraciones de envío amigables con el fork se encuentran en:
- `shipping.origin_*`, `shipping.fallback_flat_rate`, `shipping.free_shipping_default` y `shipping.usps.*` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Variables de trabajo sincronizadas automáticamente como `SHIPPING_ORIGIN_ZIP`, `SHIPPING_FALLBACK_FLAT_RATE`, `USPS_ENABLED`, `USPS_CLIENT_ID` y las perillas de tiempo de espera/caché/enfriamiento de USPS en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

Mantenga `USPS_CLIENT_SECRET` fuera de la configuración del sitio. Configúrelo como secreto de trabajador o en [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars) para desarrollo local.

Si cambia esos valores localmente, reinicie `./scripts/dev.sh --podman` para que el trabajador use las mismas matemáticas que el sitio.

Las configuraciones globales de productos/complementos compatibles con Fork ahora también se encuentran en:
- `add_ons.enabled`, `add_ons.low_stock_threshold` y `add_ons.products` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- Imágenes de productos, variantes según el tamaño, inventario por producto o por variante y referencias `shipping_preset` para artículos físicos del catálogo.
- Los complementos a nivel de paquete ahora se pueden seleccionar en el sidecar del carrito, anclarlos a una campaña en carritos de múltiples campañas y editarlos más tarde desde Administrar compromiso.
- Los mensajes de stock bajo y el filtrado de variantes agotadas ahora provienen de la capa de estado del producto adicional compartida con reconocimiento de inventario utilizada tanto por el carrito como por Manage Pledge.
- el inventario complementario configurado es la base inicial; El stock restante se deriva del estado del compromiso guardado, no del carrito no guardado o de Administrar borradores.
- Los informes de compromiso y cumplimiento ahora separan el valor del compromiso de campaña del valor adicional de la plataforma para facilitar las operaciones.

Las configuraciones orientadas a la bifurcación ahora usan un modelo de configuración estructurado en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml):

- `platform` para identidad, URL y contacto de soporte
- `platform` también cubre activos de marca como logotipo, logotipo de pie de página, favicon e imagen social predeterminada.
- `title` / `description` de nivel superior para la identidad del sitio de Jekyll y la copia SEO predeterminada
- `seo` para controles de identidad SEO locales como `x_handle`, `same_as`, `default_social_image_alt`, `og_locale_overrides` y si el centro de red público debe seguir siendo indexable.
- `pricing` para la línea base de compatibilidad de tarifa plana y los valores predeterminados de sugerencias de plataforma
- `tax` para elegir el motor de impuestos de los trabajadores y su configuración de búsqueda no secreta
- `shipping` para configuración de origen, comportamiento de cotización de USPS, política alternativa, valores predeterminados de envío gratuito, ajustes preestablecidos de envío y política de opciones de envío limitadas
- `add_ons` para un pequeño catálogo de productos global, productos de precio fijo y variantes simples como tallas de camisa.
- `reports` para tiempos de informes de campaña, archivos adjuntos, resúmenes, comportamiento de prefijo de asunto y el flujo de trabajo de correo electrónico de cumplimiento dividido junto con `platform.support_email`
- Tema frontal de la campaña `campaign_add_ons` para productos relacionados con la campaña que deben usar la misma interfaz de usuario de tarjeta pero que cuentan para el subtotal y las reglas de envío de esa campaña.
- `i18n` para idiomas predeterminados/compatibles, etiquetas de idioma y rutas de páginas públicas traducidas
- `design` para anulaciones de tipografía seleccionada, radio, ancho de diseño y token de tema
- un pequeño subconjunto seleccionado de `platform` / `design` se refleja en el Worker para que los correos electrónicos de los seguidores también permanezcan alineados con la marca de la bifurcación.
- `debug` para el comportamiento de registro del navegador y de la consola de trabajo
- `checkout` para configuraciones de pago verdaderamente variables como la clave publicable de Stripe
- `cache` para TTL de navegador en vivo

[`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml) ahora es intencionalmente delgado: solo debe contener anulaciones locales verdaderas como las URL de localhost y `show_test_campaigns`, no una segunda copia de la configuración base.

Consulte [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/) para conocer la superficie de personalización sin código admitida y qué configuraciones se reflejan automáticamente en el trabajador.
Consulte [docs/SEO.md](/es/docs/operations/seo/) para conocer la implementación actual de los fundamentos de SEO y la superficie de SEO compatible.
Consulte [docs/ACCESSIBILITY.md](/es/docs/operations/accessibility/) para conocer la línea base de accesibilidad actual y los flujos críticos verificados.
Consulte [docs/I18N.md](/es/docs/development/internationalization/) para conocer el modelo local, las fuentes de traducción compartidas y el comportamiento de la ruta localizada.

Para la localización, el modelo admitido es:

- UI compartida/tiempo de ejecución/copia de correo electrónico vive en `_data/i18n/{lang}.yml`
- Las páginas localizadas de formato largo aún necesitan archivos fuente localizados bajo el prefijo local.
- Las páginas de campaña generadas y las páginas insertadas ahora también participan en el modelo local, por lo que `/campaigns/{slug}/` puede cambiar limpiamente a `/es/campaigns/{slug}/`.
- el conmutador de idioma de pie de página compartido conserva la cadena de consulta y el hash actuales, por lo que las rutas tokenizadas como `/manage/?t=...` pueden cambiar a `/es/manage/?t=...` sin perder el acceso al compromiso.

Las principales rutas locales/dev/test ya sincronizan automáticamente los valores de Worker reflejados. Si desea actualizar la configuración del trabajador directamente, ejecute:

```bash
npm run sync:worker-config
```

Si en su lugar necesita específicamente el respaldo de solo host:
```bash
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml
```

Para una pila completa solo de host, ejecute el trabajador por separado con `cd worker && wrangler dev --env dev --port 8787`.

Consulte [docs/PODMAN.md](/es/docs/operations/podman-local-dev/) para conocer el alcance y las limitaciones actuales.

La ruta de Podman está validada por el host en macOS. Linux y Windows son compatibles por diseño y tienen cobertura médica/autocontrol, pero no fueron validados por el host en este hilo.

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

Si desea realizar el pago de Stripe en el sitio localmente, agregue `STRIPE_PUBLISHABLE_KEY_TEST=pk_test_...` a [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars) antes de iniciar la pila.

## Guía del plan Cloudflare para bifurcaciones

The Pool tiene una forma intencionada para que la mayor parte del tráfico siga siendo barato:

- GitHub Pages sirve el sitio estático, por lo que las cargas normales de página no invocan al trabajador
- los datos públicos en vivo ahora prefieren una solicitud combinada `/live/:slug` en lugar de estadísticas separadas + llamadas de inventario
- Las páginas de campaña almacenan en caché las estadísticas en vivo y el inventario en `localStorage` para `cache.live_stats_ttl_seconds` / `cache.live_inventory_ttl_seconds` (`300` predeterminado)
- las pestañas de fondo dejan de actualizarse hasta que la página vuelve a ser visible
- Los informes de una sola campaña, las reconstrucciones de estadísticas, los asistentes de liquidación y la enumeración de los partidarios de los administradores prefieren los índices `campaign-pledges:{slug}` antes de recurrir a costosos escaneos de espacios de nombres, y las reconstrucciones de estadísticas/inventario ahora reparan los índices de campaña obsoletos cuando detectan una desviación.
- Las nuevas comprobaciones de deriva de solo lectura facilitan la confirmación cuando las proyecciones están obsoletas antes de ejecutar una ruta de reparación.
- Las rutas de escritura de nivel limitado ahora solicitan al coordinador disponibilidad según la reserva en lugar de reconstruir la verdad a partir de claves de reserva KV.
- Las rutas de lectura públicas siguen siendo intencionalmente permisivas para que una campaña legítimamente popular no alcance límites artificiales anti-DoS, mientras que las costosas escrituras de pago/administración/administración conllevan límites de velocidad y límites de tamaño de solicitud más estrictos.
- Una vez que un cliente ya ha superado una ventana de límite de velocidad, las solicitudes bloqueadas repetidas ya no reescriben el mismo contador KV en cada visita.
- `POST /checkout-intent/abandon` utiliza un depósito de reintentos con alcance de orden para que la limpieza de descarga/reintento siga siendo compatible con las IP compartidas sin dejar abierta la ruta de lanzamiento.
- la configuración de trabajador también establece `limits.cpu_ms = 100` para trabajadores estándar/pagados implementados, lo cual está muy por encima de los tiempos actuales de aprovechamiento de unidades representativas (`6-28 ms`) y al mismo tiempo está dramáticamente por debajo del límite predeterminado de 30 segundos de Cloudflare para implementaciones pagas.

Perillas de horquilla que vale la pena conocer:

- configuración del sitio: `cache.live_stats_ttl_seconds`, `cache.live_inventory_ttl_seconds`, `pricing.sales_tax_rate`, `pricing.flat_shipping_rate`, `tax.*`
- Entorno del trabajador: precios sincronizados automáticamente y valores del proveedor de impuestos en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

### Escenarios prácticos de escalabilidad

Estos son escenarios de planificación aproximados, no garantías. Asumen los TTL de caché del navegador predeterminados de 5 minutos, en su mayoría el comportamiento normal del usuario y los precios/límites de KV y trabajadores publicados actualmente de Cloudflare.

|Escenario|Actividad diaria dura|Perspectivas del plan|
|----------|----------------------|--------------|
|Pequeño lanzamiento colectivo|~1500 visitas a la página de la campaña, ~75 visitas de administradores/colaboradores, ~20 inicios de pago, ~10 promesas completadas|Lo gratuito debería seguir siendo viable. Esta es la forma operativa que The Pool está diseñada para manejar de forma económica.|
|Semana de lanzamiento ocupada|~8000 visitas a la página de la campaña, ~250 visitas de administradores/colaboradores, ~60 inicios de pago, ~25 compromisos completados o modificados|A menudo, sigue siendo plausible en el modo Gratis si el abuso se mantiene bajo y los flujos de reparación del administrador son raros, pero aquí es donde el Pago comienza a comprar un margen real.|
|Estudio multiproyecto en crecimiento|~20,000+ lecturas dinámicas por día o muchas docenas de promesas completadas/modificadas/canceladas por día|Comience a planificar el pago antes de un impulso importante. Los días con muchas mutaciones y el camino de abuso se convierten en la parte a tener en cuenta primero.|

A partir del 18 de abril de 2026, Cloudflare documenta el plan Workers Free en `100,000` solicitudes por día. El plan Workers Paid comienza en `$5/month` e incluye solicitudes de `10 million` por mes más `30 million` ms de CPU por mes antes del precio excedente. Workers KV Free incluye lecturas `100,000`/día más solo escrituras `1,000`/día y solicitudes de lista `1,000`/día, mientras que Workers KV en el plan pago incluye lecturas `10 million`/mes y escrituras `1 million`/mes antes de los excedentes:

- [Precios para trabajadores de Cloudflare](https://developers.cloudflare.com/workers/platform/pricing/)
- [Precios de Cloudflare Workers KV](https://developers.cloudflare.com/kv/platform/pricing/)
- [Límites KV de los trabajadores de Cloudflare](https://developers.cloudflare.com/kv/platform/limits/)

La conclusión práctica de las bifurcaciones es simple: The Pool aún puede adaptarse al plan Workers Free para su forma prevista de "pequeña cantidad de campañas simultáneas, volumen modesto de patrocinadores, ejecución de un mes", especialmente porque el tráfico de lectura pública es barato y la mayoría de los días tienen poco tráfico de mutación. La razón para pasar a Pagado no es que Gratis dejó de funcionar repentinamente, sino que Pagado brinda un margen más saludable para picos de flash, escrituras KV de ruta de abuso, actividad de modificación/cancelación más intensa y más herramientas de operador.

Un matiz de implementación: el bloque `limits` configurable de Cloudflare solo se aplica en el modelo de uso estándar y solo en los trabajadores implementados, no en el desarrollo local. Eso significa que la nueva protección `cpu_ms` es un respaldo de denegación de billetera para implementaciones pagas, mientras que Workers Free todavía depende de los límites máximos de plan gratuito integrados de Cloudflare.

## Pruebas

```bash
npm run test:premerge  # Syntax + full/focused regressions + first-party build checks + local smoke + security + headless E2E
npm run test:secrets   # Secret exposure audit against local env files, tracked files, and git history
npm run test:unit      # Unit tests (Vitest)
npm run test:e2e       # E2E tests (Playwright) — fully automated browser coverage
npm run test:e2e:headless # CI-style automated browser suite
npm run test:e2e:headless:podman -- tests/e2e/accessibility-public-pages.spec.ts --project=chromium # Podman-backed public accessibility slice
npm run test:security  # Security tests — pen testing the Worker API
npm run test:security:podman # Security tests with a Podman-backed local stack in one invocation
npm test               # Run unit + e2e
```

Informes locales:
```bash
./scripts/pledge-report.sh --local
./scripts/fulfillment-report.sh --local
./scripts/check-projections.sh
ADMIN_SECRET=... ./scripts/check-observability.sh --local
```

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

La puerta previa a la fusión ahora prueba primero la ruta del host Bundler/Jekyll, incluido un intento único `bundle install` cuando Bundler está presente pero faltan gemas. Mantiene el humo del trabajador del host más ligero, pero ejecuta el humo de compromiso mutable a través de la pila respaldada por Podman para que la ruta de modificación/cancelación con estado utilice un estado de servicio local aislado incluso cuando la ruta de compilación del host tiene éxito. Ese humo mutable también rota sus IP de solicitud de administrador sintéticas para que el límite de tasa de administración real del Trabajador no cree fallas falsas durante las verificaciones de reconstrucción de la proyección local. Si la ruta Ruby del host aún no puede producir una compilación limpia, la puerta ahora recurre a la compilación del artefacto respaldada por Podman en lugar de fallar al principio de la configuración del host.

El arnés del navegador sin cabeza ahora construye un `_site` estático limpio y lo sirve con un servidor HTTP liviano en lugar de depender de `jekyll serve`, lo que mantiene las regresiones del navegador más cercanas a la forma real de los activos publicados.

- `pledge-report.sh` es una exportación de libro mayor/historial, por lo que los compromisos modificados aparecen como deltas y los cambios mixtos ahora mantienen el contexto de actualización de sugerencias en la columna `items`.
- `fulfillment-report.sh` es la vista fusionada del estado actual según `email + campaign`, que es el mejor punto de comparación para patrocinadores repetidos y proyectos no acumulables.
- `check-projections.sh` es la verificación del operador de solo lectura para la deriva almacenada de `campaign-pledges:{slug}`, `stats:{slug}` y `tier-inventory:{slug}` antes de decidir reparar algo.
- Si el sitio alguna vez se sale de la vista de cumplimiento del estado actual, las rutas de cálculo de estadísticas/inventario del administrador ahora reparan automáticamente los índices `campaign-pledges:{slug}` obsoletos en lugar de confiar en ellos para siempre.

**Línea base actual de suite completa:**
- Puerta previa a la fusión: pasa localmente y en el flujo de trabajo PR `Merge Smoke`
- Las suites de unidad, seguridad y E2E sin cabeza están en verde en esta sucursal

**La cobertura de la prueba incluye:** funciones de estadísticas en vivo, ayudas de sugerencias de la plataforma, hash de intención de pago propio y cableado de carga útil, desgloses de sugerencias de correo electrónico de los seguidores, indicadores de gestión de promesas, totales de liquidación, barras de progreso, desbloqueos de niveles, elementos de soporte, temporizadores de cuenta regresiva, flujo de carrito, accesibilidad (incluidas verificaciones de páginas públicas respaldadas por hacha en los estados de campaña, comunidad y resultados de promesas, instantáneas de ARIA y solo teclado). pago/administración/comunidad/afirmaciones de control público), regresiones de ventanas gráficas móviles para páginas públicas y flujos de promesas, estados de campaña, auditoría de exposición secreta, auditoría de HTML/enlace/incrustación de contenido de campaña, coordinación de inventario de niveles serializado y refuerzo en torno a `/checkout-intent/start`, manejo de webhooks, alcance de enlace mágico, integridad de liquidación y rutas de reconstrucción/relleno paginadas.

Para humo de fusión local en compromisos mutables, utilice:

```bash
./scripts/smoke-pledge-management.sh
```

Para el humo más ligero del sitio/contrato del trabajador, incluidas las verificaciones de puntos finales eliminados y la cobertura `/checkout-intent/start` con formato incorrecto, use:

```bash
./scripts/test-worker.sh
```

Consulte [TESTING.md](/es/docs/operations/testing/) para obtener una guía de prueba completa y [SECURITY.md](/es/docs/operations/security/) para ver la arquitectura de seguridad.

## Documentación

Consulte [`docs/`](/es/docs/) para obtener la documentación completa:

Buenos puntos de partida después de clonar una bifurcación son [PROJECT_OVERVIEW.md](/es/docs/development/project-overview/), [CUSTOMIZATION.md](/es/docs/development/customization-guide/), [SECURITY.md](/es/docs/operations/security/) y [TESTING.md](/es/docs/operations/testing/).

- [CONTRIBUTING.md](/es/docs/development/contributing/) — Guía de introducción, configuración y contribución
- [PODMAN.md](/es/docs/operations/podman-local-dev/) — Ruta de desarrollo local de Rootless Podman para Jekyll + Worker
- [PROJECT_OVERVIEW.md](/es/docs/development/project-overview/) — Arquitectura del sistema
- [WORKFLOWS.md](/es/docs/development/workflows/) — Ciclo de vida de la promesa, enlaces mágicos y flujo de carga
- [DEV_NOTES.md](/es/docs/development/developer-notes/) — Notas de desarrollo, modelo de contenido y preguntas frecuentes
- [TESTING.md](/es/docs/operations/testing/) — Guía de prueba completa y referencia de secretos
- [SECURITY.md](/es/docs/operations/security/) — Arquitectura de seguridad, limitación de velocidad y prueba de penetración
- [ACCESSIBILITY.md](/es/docs/operations/accessibility/) — Estándares de accesibilidad, superficies críticas y cobertura actual
- [CUSTOMIZATION.md](/es/docs/development/customization-guide/) — Anulaciones de diseño, precios y marcas orientadas a la bifurcación admitidas
- [EMBEDS.md](/es/docs/development/campaign-embeds/) — Rutas, opciones, localización y modelo de cambio de tamaño del widget de campaña alojado
- [I18N.md](/es/docs/development/internationalization/) — Estructura de localización actual, modelo de enrutamiento y flujo de trabajo de adición de idiomas
- [SHIPPING.md](/es/docs/operations/shipping/): modelo de envío actual, configuración de USPS y política alternativa
- [SEO.md](/es/docs/operations/seo/): rastreo actual, metadatos, JSON-LD y modelo sin índice
- [ADD_ON_PRODUCTS.md](/es/docs/development/add-on-products/) — Estructura actual del catálogo de complementos global y modelo inicial de importación de productos
- [ROADMAP.md](/es/docs/reference/roadmap/) — Funciones planificadas
- [CMS.md](/es/docs/reference/cms-integration/) — Guía de edición de campañas y configuración de Pages CMS

## Directorios clave

```
.pages.yml            # Pages CMS configuration
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
      ├── buy-buttons.js      # Button handlers
      ├── live-stats.js       # Real-time stats, inventory, tier unlocks, late support
      └── cart-provider.js    # First-party cart/runtime provider
worker/               # Cloudflare Worker (worker.example.com)
  └── src/            # Worker source (Stripe, email, voting, tokens, tip-aware totals)
scripts/              # Automation & reporting
  ├── dev.sh               # Start all dev services (host mode or Podman mode)
  ├── dev-podman.sh        # Rootless Podman launcher for Jekyll + Worker
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

Presione `main` para implementar la producción:
```bash
git push origin main
```

Ese flujo de trabajo de GitHub Actions ahora implementa ambos:
- el sitio de páginas de GitHub
- el trabajador de Cloudflare de `worker/wrangler.toml`

Secretos del repositorio de GitHub necesarios para la implementación automática de trabajadores:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `ADMIN_SECRET` para la verificación del diario posterior a la implementación

Reserva temporal: el flujo de trabajo también admite la autenticación heredada de Cloudflare a través de
- `CLOUDFLARE_EMAIL`
- `CLOUDFLARE_KEY`

La ruta token + ID de cuenta sigue siendo la configuración recomendada a largo plazo.

Respaldo del trabajador manual desde la raíz del repositorio:
```bash
npm run deploy:worker
```

El Trabajador tiene facultades:
- Arranque de sesión en el modo de configuración de Stripe en el sitio para el sidecar de pago propio y el modo Manage Pledge `Update Card`, con respaldo alojado aún disponible como ruta de compatibilidad
- Procesamiento de webhooks y persistencia de promesas.
- cálculo total teniendo en cuenta las propinas
- entrega de correo electrónico a seguidores mediante reenvío
- flujos de liquidación y reintento por lotes
- puntos finales de informes y recuperación de administración

---
