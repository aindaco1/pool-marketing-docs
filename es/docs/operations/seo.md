---
title: SEO
parent: Operaciones
nav_order: 14
render_with_liquid: false
lang: es
---

# SEO

## Última actualización

25 de agosto de 2026

Este documento describe el modelo SEO actual de The Pool en 2026. Es intencionalmente conservador: las páginas públicas se hacen más fáciles de rastrear y comprender, mientras que los flujos tokenizados y exclusivos para patrocinadores permanecen fuera de la intención del índice. La implementación está diseñada en torno a metadatos reales, páginas públicas reales y datos estructurados honestos en lugar de relleno de contenido o cebo de resultados enriquecidos.

## Principios

- Fortalecer la visibilidad de páginas públicas reales y páginas de campaña.
- mantenga la superficie SEO orientada a la bifurcación pequeña y confiable
- preservar los límites de accesibilidad, privacidad y seguridad
- Evite las tácticas de SEO que crean contenido deficiente, engañoso o basura.
- aplicar la [revisión de riesgos éticos](/es/docs/development/ethical-risk-review/) antes de cambiar metadatos, compartir tarjetas, indexación pública o distribución social de manera que pueda indicar erróneamente el estado de la campaña, la escasez, los plazos o el acceso privado

## Implementación actual

La línea de base actual incluye:

- Los metadatos compartidos incluyen páginas públicas y páginas de campañas públicas.
- metadatos en idiomas alternativos en páginas públicas localizadas y páginas de campaña localizadas
- URL canónicas en diseños públicos
- metadatos Open Graph con reconocimiento regional en diseños públicos
- Las páginas de campaña utilizan `og:type=article` más marcas de tiempo de publicación/modificación de artículos delimitadas derivadas de las fechas del contenido de la campaña.
- metadatos explícitos de idioma/nombre de aplicación en diseños públicos
- descripciones a nivel de página sobre rutas públicas principales
- Metadatos de tarjetas Open Graph y Twitter
- etiquetas seguras de imágenes sociales donde la imagen de la página ya es HTTPS
- metadatos alternativos de imágenes sociales
- Títulos y descripciones sociales de campañas conscientes del estado.
- Texto de intención de enlace compartido de campaña consciente del estado para plataformas que aceptan copia de mensajes, mientras que Facebook y otros destinos que priorizan la tarjeta siguen confiando en la URL de la página y los metadatos de Open Graph.
- Los enlaces hash del diario de campaña pública activan la pestaña de fase del diario coincidente antes de desplazarse, por lo que los anclajes en paneles ocultos como `#diary-production` siguen siendo objetivos válidos para compartir/correo electrónico.
- PNG de tarjetas compartidas de campaña generadas por los trabajadores para metadatos sociales públicos, con SVG retenido para herramientas internas de vista previa/depuración
- generado [`robots.txt`](/robots.txt)
- generado [`sitemap.xml`](/sitemap.xml)
- diagnóstico generado [`sitemap.txt`](https://github.com/your-org/your-project/blob/main/sitemap.txt), no anunciado intencionalmente como un segundo mapa del sitio canónico en `robots.txt`
- selección de mapa de sitio público compartido en [`_includes/seo-sitemap-items.liquid`](https://github.com/your-org/your-project/blob/main/_includes/seo-sitemap-items.liquid), con representación XML y alternativas `xhtml:link` localizadas en [`_includes/seo-sitemap-url.xml`](https://github.com/your-org/your-project/blob/main/_includes/seo-sitemap-url.xml)
- valores `lastmod` del mapa del sitio creados solo a través de `last_modified_at`; La colección implícita de Jekyll, `date` y el tiempo de compilación, nunca se tratan como cambios de contenido.
- Publicación de artículos de campaña y metadatos de modificación derivados de `published_at`, `last_modified_at` explícitos o la fecha de inicio de la campaña en lugar de la fecha de recopilación del tiempo de implementación de Jekyll.
- una auditoría SEO del sitio generado en [`scripts/audit-seo.mjs`](https://github.com/your-org/your-project/blob/main/scripts/audit-seo.mjs), expuesta como `npm run test:seo` y conectada a la puerta de merge
- una auditoría de punto final de rastreo en vivo en [`scripts/audit-crawl-endpoints.mjs`](https://github.com/your-org/your-project/blob/main/scripts/audit-crawl-endpoints.mjs) que compara las respuestas ordinarias y de inspección de Google para ambos formatos de mapas de sitio, requiere listas de URL de texto/XML idénticas, valida el estado de los mapas de sitio/robots y los tipos de contenido, y recupera cada URL pública enviada después de la implementación de producción.
- `noindex,nofollow` explícito en diseños tokenizados o solo para patrocinadores
- `noindex,nofollow,noarchive`, `sitemap: false` explícitos, robots no permitidos y metadatos sociales deshabilitados en el panel de administración privado
- shells de vista previa de campaña protegidos con `noindex,nofollow,noarchive`, sin metadatos sociales, sin JSON-LD, sin inclusión de mapa de sitio público y sin elegibilidad de captación previa pública
- conservador `Organization` / `WebSite` JSON-LD
- contacto de la organización y datos de la política `MerchantReturnNotPermitted` vinculados a la política de Términos visible
- campaña conservadora `CreativeWork` más ruta de navegación JSON-LD, ambos alineados con el idioma de la página activa donde sea compatible
- campaña `CreativeWork` JSON-LD también incluye `headline`, `mainEntityOfPage`, `isPartOf` y marcas de tiempo publicadas/modificadas para que las páginas de campaña públicas se parezcan más a páginas de inicio editoriales reales que a blobs anónimos.
- un centro comunitario público que enlaza con páginas de campañas públicas en lugar de empujar a los rastreadores a rutas exclusivas para patrocinadores
- páginas de productos localizadas y de suscripción para la recompensa física destacada de una campaña, con información visible sobre pedidos anticipados, disponibilidad, envío y venta final, además de datos coincidentes de `Product` / `Offer`

Los principales archivos de implementación son:

- [/_includes/seo-meta.html](https://github.com/your-org/your-project/blob/main/_includes/seo-meta.html)
- [/_includes/seo-json-ld.html](https://github.com/your-org/your-project/blob/main/_includes/seo-json-ld.html)
- [/_includes/seo-sitemap-items.liquid](https://github.com/your-org/your-project/blob/main/_includes/seo-sitemap-items.liquid)
- [/_layouts/campaign.html](https://github.com/your-org/your-project/blob/main/_layouts/campaign.html)
- [/_plugins/campaign_shopping_product_pages.rb](https://github.com/your-org/your-project/blob/main/_plugins/campaign_shopping_product_pages.rb)
- [/_includes/campaña-compra-producto.html](https://github.com/your-org/your-project/blob/main/_includes/campaign-shopping-product.html)
- [/worker/src/index.js](https://github.com/your-org/your-project/blob/main/worker/src/index.js)
- [/scripts/audit-seo.mjs](https://github.com/your-org/your-project/blob/main/scripts/audit-seo.mjs)
- [/scripts/audit-crawl-endpoints.mjs](https://github.com/your-org/your-project/blob/main/scripts/audit-crawl-endpoints.mjs)
- [/robots.txt](/robots.txt)
- [/sitemap.xml](/sitemap.xml)
- [/sitemap.txt](https://github.com/your-org/your-project/blob/main/sitemap.txt)

Las vistas previas sociales de la campaña tienen de forma predeterminada un PNG generado por los trabajadores y compatible con rastreadores que utiliza el progreso de la campaña en vivo. Una campaña aún puede anular eso con `social_image` cuando necesita una imagen rasterizada estática fija, idealmente JPEG o PNG en `1200 x 630`.

La ruta pública de Open Graph es:

- `/share/campaign/{slug}.png?lang=en`
- `/share/campaign/{slug}.png?lang=es`

Esa ruta genera una tarjeta SVG con reconocimiento de estado a partir de datos de campaña en vivo, luego la rasteriza a PNG para que los enlaces compartidos permanezcan seguros para los rastreadores y al mismo tiempo muestren el total comprometido, el progreso de los objetivos, el estado de la campaña y el cuadrado `hero_image` de la campaña con el estilo de tarjeta compartida más rico. El trabajador también mantiene la versión SVG en `/share/campaign/{slug}.svg?lang={lang}` para herramientas internas de vista previa/depuración, pero SVG no es el valor predeterminado de metadatos públicos porque algunos rastreadores externos lo rechazan.

Los enlaces para compartir páginas de la campaña mantienen la misma separación de preocupaciones:

- Los metadatos de Open Graph y Twitter controlan las vistas previas del rastreador y las imágenes de tarjetas compartidas.
- Las URL compartidas de plataforma incluyen texto de intención más completo y con reconocimiento de estado solo cuando el destino admite texto de mensaje.
- Las URL compartidas conservan solo parámetros de consulta UTM/referencia seguros y no agregan URL de imágenes ni estados privados a la URL compartida.

## Contrato de indexación

Indexable por defecto:

- casa
- acerca de
- términos
- páginas de campaña públicas
- páginas públicas posteriores a la campaña que aún tienen valor de descubrimiento
- el centro de la comunidad pública cuando `seo.index_public_community_hub` está habilitado
- una página de recompensas destacadas enfocada cuando su campaña habilita explícitamente una configuración completa del producto de Shopping

No indexable por defecto:

- flujos de carrito y pago
- aporte exitosa / páginas canceladas
- `/manage/`
- `/admin/`
- `/es/admin/`
- páginas de vista previa de campaña protegidas como `/campaigns/:slug/preview/`
- páginas de la comunidad de patrocinadores
- rutas tokenizadas y rutas de acceso a cadenas de consulta específicas del usuario

Esto se aplica mediante una combinación de:

- metaetiquetas de robots a nivel de diseño
- `robots.txt`
- reglas de inclusión del mapa del sitio
- mapa del sitio `lastmod` sugerencias para páginas públicas y campañas
- enlaces alternativos `hreflang` del sitemap para pares de páginas/campañas localizadas
- validación de salida generada mediante `npm run test:seo`
- validación de origen posterior a la implementación a través de `npm run test:crawl-endpoints -- --base=https://site.example.com`

Contrato del panel de administración:

- [admin.md](https://github.com/your-org/your-project/blob/main/admin.md) y [es/admin/index.html](https://github.com/your-org/your-project/blob/main/es/admin/index.html) deben conservar `indexable: false` y `sitemap: false`
- [/_layouts/admin.html](https://github.com/your-org/your-project/blob/main/_layouts/admin.html) debe llamar a `seo-meta.html` con `indexable=false` y `social=false`
- [`robots.txt`](/robots.txt) debe rechazar `/admin/` y `/es/admin/`
- [`sitemap.xml`](/sitemap.xml) no debe incluir rutas de administración
- el diseño del administrador no debe emitir metadatos de vista previa social JSON-LD o Open Graph/Twitter; el panel es una superficie de aplicación privada, no un resultado de búsqueda público ni un objetivo compartido

Contrato de vista previa de campaña protegida:

- `/_layouts/campaign-preview.html` debe conservar `indexable=false` y `social=false`
- las páginas de vista previa no deben aparecer en `sitemap.xml`
- Las campañas de solo vista previa no deben generar páginas públicas `/campaigns/:slug/`, páginas de campañas públicas localizadas, entradas JSON de campañas públicas, entradas de catálogos complementarios, metadatos de tarjetas compartidas ni destinos de inserción públicos hasta su lanzamiento.
- Las páginas de vista previa deben obtener contenido protegido a través del Trabajador en el momento de la solicitud en lugar de incrustar títulos de campaña o borradores de cargas útiles en HTML estático.
- la captación previa pública debe rechazar `/campaigns/:slug/preview/` y cadenas de consulta de token como `?t=...`

## Datos estructurados

El sitio solo emite tipos de esquemas que se asignan claramente al contenido visible y a los datos reales:

- `Organization`
- `WebSite`
- `BreadcrumbList`
- nivel de campaña `CreativeWork`
- `MerchantReturnPolicy` con una política de venta final visible
- `Product` y `Offer` solo en una página de recompensa física enfocada y habilitada explícitamente

La implementación intencionalmente no emite:

- esquema de preguntas frecuentes falso
- reseñas falsas o calificaciones de estrellas
- esquema de producto/oferta en páginas de inicio de campaña, recompensas digitales, servicios, participación creativa o registros de pedidos anticipados incompletos

## Páginas destacadas de compras con recompensas

El soporte de compras reutiliza deliberadamente el `featured_tier_id` existente de una campaña. La página del producto generada obtiene su nombre, descripción, imagen, precio, categoría, comportamiento del carrito, campaña, identidad del vendedor y SKU estable de fuentes existentes en lugar de crear un catálogo paralelo.

Para ser elegible, el nivel destacado seleccionado debe ser físico y tener un precio, una imagen y una descripción positivos. La campaña también debe inscribirse con una fecha de disponibilidad prevista exacta:

```yml
featured_tier_id: physical-poster
shopping:
  enabled: true
  availability_date: 2027-01-31
```

El generador falla la construcción si la fecha no es válida, precede a la fecha límite de la campaña o es más de un año después de la fecha de construcción. Mientras la campaña esté activa, la oferta estará marcada como `PreOrder`; fuera de la ventana de la campaña en vivo, sigue siendo una página de producto útil, pero cambia a `OutOfStock`. La página del producto explica visiblemente el cobro de todo o nada, la disponibilidad esperada, el tratamiento de envío y la política de no devoluciones.

El panel de la campaña expone el cambio de habilitación y la fecha de disponibilidad junto con el nivel destacado. Mantén el interruptor apagado hasta que el creador confirme la fecha exacta y el cronograma visible de la campaña coincida.

Los datos estructurados del producto pueden hacer que una página sea elegible para las experiencias de productos de Google, pero por sí solos no garantizan la ubicación en la pestaña Compras de Google. Una cuenta de Merchant Center, un sitio web verificado, una fuente de datos del producto, la configuración de envío, la configuración de la política de devoluciones, la elegibilidad del destino y la revisión de Google son requisitos de lanzamiento separados. Cuando se agrega un feed, debe usar la misma página, SKU, precio, disponibilidad, imagen y datos de política; no cree un segundo catálogo de productos en el generador de feeds.

## Superficie de configuración SEO compatible

La superficie SEO orientada hacia la bifurcación está delimitada intencionalmente. Las configuraciones admitidas actualmente incluyen:

- nivel superior `title`
- nivel superior `description`
- `platform.name`
- `platform.site_url`
- `platform.default_social_image_path`
- `seo.x_handle`
- `seo.same_as`
- `seo.index_public_community_hub`
- `seo.default_social_image_alt`
- `seo.og_locale_overrides`
- `seo.merchant_return_policy.applicable_country`
- `seo.merchant_return_policy.return_policy_category`
- portada de página pública `title` / `description`
- Campos de contenido de campaña como `title`, `short_blurb`, `creator_name`, `category` e imágenes destacadas.
- campaña `featured_tier_id` más `shopping.enabled` / `shopping.availability_date`

Esto mantiene el modelo de SEO variable primero sin abrir una enorme matriz de botones frágiles o sin soporte.

Los metadatos públicos también derivan algunos valores seguros automáticamente:

- `og:locale` del idioma de la página activa
- `og:locale:alternate` de los idiomas traducidos admitidos para esa página
- `language`, `application-name` y `apple-mobile-web-app-title` de la identidad de sitio/página activa
- `og:image:alt` / `twitter:image:alt` del texto alternativo de la imagen explícita cuando esté presente; de lo contrario, el título de la página
- `og:image:secure_url` cuando la imagen social elegida ya se resuelve en HTTPS
- `article:published_time` / `article:modified_time` en las páginas de la campaña cuando las fechas de la campaña estén disponibles
- Copia de vista previa de la campaña desde el estado de la campaña (`upcoming`, `live`, `funded`, `ended`)
- imágenes de vista previa de campaña de `social_image` cuando están configuradas; de lo contrario, la ruta de tarjeta compartida PNG generada por el trabajador
- `WebSite.availableLanguage`, raíces de ruta de navegación localizadas y campaña `CreativeWork.inLanguage` del modelo local configurado

Las bifurcaciones pueden anular parte de ese comportamiento de forma limitada:

- `seo.default_social_image_alt` proporciona el texto alternativo alternativo para imágenes sociales predeterminadas
- `seo.og_locale_overrides` asigna códigos de idioma a cadenas de configuración regional explícitas de Open Graph

Ejemplo:

```yml
seo:
  x_handle: dustwave
  same_as:
    - https://www.instagram.com/dustwave
    - https://www.youtube.com/@dustwave
  index_public_community_hub: true
  default_social_image_alt: "Social card for your deployment"
  og_locale_overrides:
    en: en_US
    es: es_ES
```

## ¿Qué horquillas se pueden cambiar de forma segura?

Las horquillas se pueden personalizar de forma segura:

- identidad del sitio y metadatos predeterminados
- enlaces de perfil social de la organización
- si el centro comunitario público sigue siendo indexable
- Copia descriptiva de página y campaña que ya existe en el modelo de contenido.
- entradas de vista previa de la campaña que ya existen en el modelo de contenido, como el título de la campaña, el primer bloque de texto de contenido extenso utilizado para las descripciones sociales, la categoría, el creador, una marca `funded: true` para los metadatos posteriores a la campaña exitosos antes de la liquidación y la imagen principal cuadrada utilizada dentro de las tarjetas compartidas generadas.

El modelo actual no admite:

- matrices de configuración SEO arbitrarias por página
- taxonomías de esquemas personalizados más allá de la superficie documentada
- indexación de flujos de patrocinadores privados o tokenizados

## Lista de verificación de validación

Al verificar una implementación manualmente:

- La fuente de la página para las páginas de inicio/acerca de/términos/campaña tiene el título, la descripción y las etiquetas canónicas, OG y de Twitter correctos.
- Las páginas de campaña emiten un `social_image` compatible con rastreadores cuando se configuran; de lo contrario, la ruta PNG de la tarjeta compartida del trabajador.
- Los enlaces visibles para compartir de la campaña utilizan la URL canónica de la campaña y no reemplazan el contrato de tarjeta social basado en metadatos.
- `robots.txt` es accesible y solo expone las rutas de rastreo públicas previstas.
- `sitemap.xml` es accesible y solo incluye URL públicas previstas.
- `sitemap.txt` es accesible, contiene una URL absoluta por línea y coincide exactamente con la lista de URL del mapa del sitio XML.
- `npm run test:seo` pasa contra un `_site` recién generado
- las páginas privadas/tokenizadas emiten `noindex` cuando corresponda
- `/admin/` y `/es/admin/` emiten `noindex,nofollow,noarchive`, no aparecen en `sitemap.xml` y no emiten vista previa social ni metadatos JSON-LD.
- `/campaigns/:slug/preview/` emite `noindex,nofollow,noarchive`, no aparece en `sitemap.xml` y no emite vista previa social ni metadatos JSON-LD.
- JSON-LD valida limpiamente
- Las páginas localizadas mantienen enlaces canónicos y alternativos coherentes.
- Las páginas de campaña localizadas mantienen enlaces canónicos y alternativos coherentes.
- Las páginas localizadas mantienen un lenguaje JSON-LD coherente y raíces de ruta de navegación
- un producto de compras habilitado genera rutas coherentes en inglés/español, datos de pedidos anticipados visibles, `og:type=product`, `Product` / `Offer` / datos de ruta de navegación y alternativas de mapas del sitio
- `npm run test:crawl-endpoints -- --base=https://site.example.com` confirma que ambos formatos de mapas de sitio implementados y que cada URL enviada se puede recuperar directamente sin un intersticial HTML.
- Las adiciones de metadatos no crean regresiones de accesibilidad o rendimiento.

## No metas

El modelo actual SEO evita explícitamente:

- Contenido de relleno generado por IA
- páginas de entrada
- texto oculto o relleno de palabras clave
- Preguntas frecuentes falsas o esquema de revisión
- indexación de flujos de acceso exclusivos para patrocinadores, vinculados a sesiones o tokenizados
- Tratar el panel de administración o las vistas previas de campañas protegidas como páginas de destino públicas, objetivos para compartir o superficies de documentación rastreables.

Los metadatos potenciales, la distribución y el trabajo de Shopping se rastrean en el
[Hoja de ruta](/es/docs/reference/roadmap/).

## Notas

Esta implementación se guió por la guía de Google Search Central sobre:

- canonicalización
- meta uso de robots
- construcción del mapa del sitio
- conceptos básicos de datos estructurados
- datos estructurados de ruta de navegación

La regla básica sigue siendo simple: los metadatos públicos reflejan contenido público visible y los flujos privados/solo para patrocinadores permanecen fuera de la intención de búsqueda.
