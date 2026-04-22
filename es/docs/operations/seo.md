---
title: SEO
parent: Operaciones
nav_order: 10
render_with_liquid: false
lang: es
---

# SEO

Este documento describe el modelo SEO actual de The Pool en 2026. Es intencionalmente conservador: las páginas públicas se hacen más fáciles de rastrear y comprender, mientras que los flujos tokenizados y exclusivos para seguidores permanecen fuera de la intención del índice. La implementación está diseñada en torno a metadatos reales, páginas públicas reales y datos estructurados honestos en lugar de relleno de contenido o cebo de resultados enriquecidos.

## Principios

- Fortalecer la visibilidad de páginas públicas reales y páginas de campaña.
- mantenga la superficie SEO orientada a la bifurcación pequeña y confiable
- preservar los límites de accesibilidad, privacidad y seguridad
- Evite las tácticas de SEO que crean contenido deficiente, engañoso o basura.

## Implementación actual

La línea de base actual incluye:

- Los metadatos compartidos incluyen páginas públicas y páginas de campañas públicas.
- metadatos en idiomas alternativos en páginas públicas localizadas y páginas de campaña localizadas
- URL canónicas en diseños públicos
- metadatos Open Graph con reconocimiento regional en diseños públicos
- Las páginas de campaña ahora usan `og:type=article` más marcas de tiempo de publicación/modificación de artículos delimitadas derivadas de las fechas del contenido de la campaña.
- metadatos explícitos de idioma/nombre de aplicación en diseños públicos
- descripciones a nivel de página sobre rutas públicas principales
- Metadatos de tarjetas Open Graph y Twitter
- etiquetas seguras de imágenes sociales donde la imagen de la página ya es HTTPS
- metadatos alternativos de imágenes sociales
- Títulos y descripciones sociales de campañas conscientes del estado.
- Imágenes SVG de tarjetas compartidas de campaña generadas por trabajadores para vistas previas sociales
- generado [`robots.txt`](/robots.txt)
- generado [`sitemap.xml`](/sitemap.xml)
- `noindex,nofollow` explícito en diseños tokenizados o solo para seguidores
- conservador `Organization` / `WebSite` JSON-LD
- campaña conservadora `CreativeWork` más ruta de navegación JSON-LD, ambos alineados con el idioma de la página activa donde sea compatible
- campaña `CreativeWork` JSON-LD ahora también incluye `headline`, `mainEntityOfPage`, `isPartOf` y marcas de tiempo publicadas/modificadas para que las páginas de campaña públicas se parezcan más a páginas de inicio editoriales reales que a blobs anónimos.
- un centro comunitario público que enlaza con páginas de campañas públicas en lugar de empujar a los rastreadores a rutas exclusivas para seguidores

Los principales archivos de implementación son:

- [/_includes/seo-meta.html](https://github.com/your-org/your-project/blob/main/_includes/seo-meta.html)
- [/_includes/seo-json-ld.html](https://github.com/your-org/your-project/blob/main/_includes/seo-json-ld.html)
- [/_layouts/campaign.html](https://github.com/your-org/your-project/blob/main/_layouts/campaign.html)
- [/worker/src/index.js](https://github.com/your-org/your-project/blob/main/worker/src/index.js)
- [/robots.txt](/robots.txt)
- [/sitemap.xml](/sitemap.xml)

Las vistas previas sociales de la campaña ahora utilizan una ruta de trabajador con la siguiente forma:

- `/share/campaign/{slug}.svg?lang=en`
- `/share/campaign/{slug}.svg?lang=es`

Esa ruta genera una tarjeta compartida con reconocimiento de estado a partir de datos de campaña en vivo, de modo que la imagen social se mantiene más cercana al lenguaje visual de la inserción alojada que una imagen principal sin editar por sí sola.

## Contrato de indexación

Indexable por defecto:

- casa
- acerca de
- términos
- páginas de campaña públicas
- páginas públicas posteriores a la campaña que aún tienen valor de descubrimiento
- el centro de la comunidad pública cuando `seo.index_public_community_hub` está habilitado

No indexable por defecto:

- flujos de carrito y pago
- promesa exitosa / páginas canceladas
- `/manage/`
- páginas de la comunidad de seguidores
- rutas tokenizadas y rutas de acceso a cadenas de consulta específicas del usuario

Esto se aplica mediante una combinación de:

- metaetiquetas de robots a nivel de diseño
- `robots.txt`
- reglas de inclusión del mapa del sitio
- mapa del sitio `lastmod` sugerencias para páginas públicas y campañas

## Datos estructurados

El sitio solo emite tipos de esquemas que se asignan claramente al contenido visible y a los datos reales:

- `Organization`
- `WebSite`
- `BreadcrumbList`
- nivel de campaña `CreativeWork`

La implementación intencionalmente no emite:

- esquema de preguntas frecuentes falso
- reseñas falsas o calificaciones de estrellas
- esquema de producto/oferta que exagera lo que la página realmente representa

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
- portada de página pública `title` / `description`
- Campos de contenido de campaña como `title`, `short_blurb`, `creator_name`, `category` e imágenes destacadas.

Esto mantiene el modelo de SEO variable primero sin abrir una enorme matriz de botones frágiles o sin soporte.

Los metadatos públicos también derivan algunos valores seguros automáticamente:

- `og:locale` del idioma de la página activa
- `og:locale:alternate` de los idiomas traducidos admitidos para esa página
- `language`, `application-name` y `apple-mobile-web-app-title` de la identidad de sitio/página activa
- `og:image:alt` / `twitter:image:alt` del texto alternativo de la imagen explícita cuando esté presente; de lo contrario, el título de la página
- `og:image:secure_url` cuando la imagen social elegida ya se resuelve en HTTPS
- `article:published_time` / `article:modified_time` en las páginas de la campaña cuando las fechas de la campaña estén disponibles
- Copia de vista previa de la campaña desde el estado de la campaña (`upcoming`, `live`, `funded`, `ended`)
- imágenes de vista previa de la campaña desde la ruta de la tarjeta compartida del trabajador en lugar de directamente desde la imagen principal únicamente
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
- si el centro comunitario público debe seguir siendo indexable
- Copia descriptiva de página y campaña que ya existe en el modelo de contenido.
- Entradas de vista previa de la campaña que ya existen en el modelo de contenido, como el título de la campaña, la propaganda, la categoría, el creador y las imágenes destacadas.

Las bifurcaciones no deben asumir soporte para:

- matrices de configuración SEO arbitrarias por página
- taxonomías de esquemas personalizados más allá de la superficie documentada
- indexación de flujos de seguidores privados o tokenizados

## Lista de verificación de validación

Al verificar una implementación manualmente:

- La fuente de la página para las páginas de inicio/acerca de/términos/campaña tiene el título, la descripción y las etiquetas canónicas, OG y de Twitter correctos.
- Las páginas de la campaña emiten el SVG de la tarjeta compartida del trabajador como imagen social e incluyen la ruta correcta basada en la configuración regional en la URL de esa imagen.
- `robots.txt` es accesible y solo expone las rutas de rastreo públicas previstas.
- `sitemap.xml` es accesible y solo incluye URL públicas previstas.
- las páginas privadas/tokenizadas emiten `noindex` cuando corresponda
- JSON-LD valida limpiamente
- Las páginas localizadas mantienen enlaces canónicos y alternativos coherentes.
- Las páginas de campaña localizadas mantienen enlaces canónicos y alternativos coherentes.
- Las páginas localizadas mantienen un lenguaje JSON-LD coherente y raíces de ruta de navegación
- Las adiciones de metadatos no crean regresiones de accesibilidad o rendimiento.

## Notas

Esta implementación se guió por la guía de Google Search Central sobre:

- canonicalización
- meta uso de robots
- construcción del mapa del sitio
- conceptos básicos de datos estructurados
- datos estructurados de ruta de navegación

La regla básica sigue siendo simple: los metadatos públicos deben reflejar contenido público visible, y los flujos privados/solo para seguidores deben permanecer fuera de la intención de búsqueda.
