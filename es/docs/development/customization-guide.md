---
title: Guía de personalización
parent: Desarrollo
nav_order: 5
render_with_liquid: false
lang: es
---

# Guía de personalización

Esta guía cubre la superficie de personalización sin código compatible para las forks de The Pool tal como existe ahora.

El objetivo es permitir que las forks cambien el nombre, el estilo y la reconfiguración de la plataforma a través de la configuración, manteniendo alineados el pago, los informes, los correos electrónicos y el trabajador.

El modelo de configuración estructurado en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) es ahora la superficie canónica orientada a la fork.

## Comience aquí

Para la mayoría de las forks, los principales archivos de personalización son:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml)
- [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml)

Utilice `./scripts/dev.sh --podman` para la verificación local después de los cambios de configuración.

Trate [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml) como un archivo de solo anulación. Mantenga la configuración de fork canónica en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) y use el archivo local solo para cosas que deberían diferir en su máquina, como las URL del host local o la visibilidad de la campaña solo local.

La ruta local normal ahora está basada en localhost:

- sitio: `http://127.0.0.1:4000`
- Trabajador: `http://127.0.0.1:8787`

El sitio estático generado ahora también excluye carpetas internas del repositorio como `worker/`, `scripts/` y `tests/`, por lo que la verificación estática se asemeja más a lo que realmente publicaría una fork.

## Áreas de configuración admitidas

La configuración del sitio está organizada en torno a estas secciones orientadas hacia la fork:

- nivel superior `title` / `description`
- `seo`
- `platform`
- `pricing`
- `shipping`
- `i18n`
- `design`
- `debug`
- `checkout`
- `cache`

### Nivel superior `title` / `description`

Utilice los metadatos de Jekyll de nivel superior para la identidad social/búsqueda predeterminada del sitio.

Teclas admitidas:

- `title`
- `description`

Estos valores alimentan:

- reserva HTML predeterminada `<title>`
- reserva de meta descripción predeterminada
- descripción alternativa de `WebSite` JSON-LD en todo el sitio

`platform.name` sigue siendo la principal superficie visible de la marca. Trate `title` / `description` de nivel superior como la línea base de SEO orientada a la fork en lugar de la interfaz principal de marca de UI.

### `platform`

Utilice `platform` para identidad, URL y activos de marca.

Teclas admitidas:

- `name`
- `version`
- `release_label`
- `company_name`
- `support_email`
- `pledges_email_from`
- `updates_email_from`
- `site_url`
- `worker_url`
- `default_creator_name`
- `logo_path`
- `footer_logo_path`
- `favicon_path`
- `default_social_image_path`

Estos valores alimentan:

- marca de encabezado/pie de página
- publicar metadatos para documentos/copia pública cuando una fork quiera mostrar su hito actual
- títulos de página y metaetiquetas
- imagen de tarjeta social predeterminada
- copia alternativa del creador de la campaña
- pago/Administrar la copia de la interfaz de usuario de Pledge y la configuración del cliente de arranque
- Marca de correo electrónico del trabajador cuando se refleja

Notas:

- `platform.*` es la superficie de marca principal.
- `platform.version` debe ser la versión canónica del producto legible por máquina para el sitio, mientras que `platform.release_label` puede seguir siendo más amigable para copias públicas como `v0.9.1`.
- `title` / `author` de nivel superior todavía existen en Jekyll, pero trátelos como metadatos/respaldo generales del sitio en lugar de la interfaz principal de personalización de la fork.
- `platform.default_social_image_path` es el valor predeterminado admitido para tarjetas OG/Twitter cuando una página o campaña no proporciona una imagen más específica.

Ejemplo:

```yml
platform:
  name: My Fork
  version: 0.9.1
  release_label: v0.9.1
  company_name: Example Studio
  support_email: support@example.com
  pledges_email_from: "My Fork <pledges@example.com>"
  updates_email_from: "My Fork <updates@example.com>"
  site_url: https://crowdfund.example.com
  worker_url: https://pledge.example.com
  default_creator_name: Example Studio
  logo_path: /assets/images/brand/logo-square.png
  footer_logo_path: /assets/images/brand/logo-footer.png
  favicon_path: /assets/images/brand/favicon.png
  default_social_image_path: /assets/images/brand/social-card.png
```

### `pricing`

Utilice `pricing` para los cálculos compartidos de impuestos/propinas que deben ser consistentes en todo el sitio y el trabajador.

Teclas admitidas:

- `sales_tax_rate`
- `flat_shipping_rate` (línea base de compatibilidad heredada; use `shipping.*` para el modelo actual de operador/refuerzo)
- `default_tip_percent`
- `max_tip_percent`

Ejemplo:

```yml
pricing:
  sales_tax_rate: 0.0825
  flat_shipping_rate: 4.50
  default_tip_percent: 5
  max_tip_percent: 15
```

### `i18n`

Utilice `i18n` para el modelo local admitido en el sitio estático.

Teclas admitidas:

- `default_lang`
- `supported_langs`
- `language_labels`
- `pages`

`pages` es el mapa de ruta de la página pública utilizado por los ayudantes de configuración regional compartidos. Permite que las forks agreguen un nuevo idioma mediante configuración más contenido traducido en lugar de editar la lógica de navegación a mano.

Ejemplo:

```yml
i18n:
  default_lang: en
  supported_langs:
    - en
    - es
  language_labels:
    en: English
    es: Español
  pages:
    home:
      en: /
      es: /es/
    about:
      en: /about/
      es: /es/about/
    terms:
      en: /terms/
      es: /es/terms/
```

Patrón soportado actualmente:

- La copia compartida del sistema/UI se encuentra en `_data/i18n/{lang}.yml`.
- Las páginas públicas no predeterminadas se encuentran bajo un prefijo local como `/es/`.
- Los mensajes compartidos de tiempo de ejecución/navegador se emiten a través de `assets/i18n.json`.
- Los correos electrónicos de los seguidores de los trabajadores reutilizan ese catálogo de configuración regional compartido y `preferredLang` persistente
- El cromo de la campaña, como el botón de video principal/texto de carga, el texto teaser de la comunidad de seguidores, las pestañas del diario, los controles de la fase de producción y las etiquetas de accesibilidad de la galería, ahora también provienen de `_data/i18n/{lang}.yml`.
- el conmutador de idioma del pie de página compartido es automático cuando se configura más de un idioma
- Las páginas de formato largo como `about` y `terms` deberían usar páginas fuente localizadas en lugar de intentar almacenar cada párrafo en YAML.

Qué significa esto en la práctica:

- cambiar `i18n.default_lang` solo cambia la configuración regional predeterminada en la que se resuelve el sitio
- agregar un nuevo archivo `_data/i18n/{lang}.yml` es suficiente para Chrome compartido, interfaz de usuario en tiempo de ejecución y copia del correo electrónico del asistente del trabajador.
- No es suficiente para un sitio completamente traducido por sí solo.
- El soporte completo de idiomas también necesita:
  - el nuevo idioma agregado a `i18n.supported_langs`
  - su etiqueta agregada a `i18n.language_labels`
  - rutas localizadas agregadas a `i18n.pages`
  - páginas de origen localizadas para contenido de formato largo que realmente desea traducir
- Las rutas tokenizadas de administración de promesas siguen funcionando en todas las configuraciones regionales porque el conmutador de idioma compartido conserva la cadena de consulta y el hash actuales.

Flujo de trabajo de fork recomendado:

1. Copiar `_data/i18n/en.yml` a `_data/i18n/{lang}.yml`
2. Agregue el idioma al bloque `i18n` en `_config.yml`
3. Agregue páginas de origen localizadas para rutas de formato largo como `/about/` y `/terms/`
4. Compile localmente y verifique tanto la copia de la interfaz de usuario compartida como las rutas localizadas

### superficie SEO

Los fundamentos actuales de SEO están intencionalmente limitados. Las forks deben tratarlas como perillas soportadas:

- nivel superior `title`
- nivel superior `description`
- `seo.x_handle`
- `seo.same_as`
- `seo.index_public_community_hub`
- `seo.default_social_image_alt`
- `seo.og_locale_overrides`
- `platform.name`
- `platform.site_url`
- `platform.default_social_image_path`
- página localizada `title` / `description` portada en páginas públicas
- campaña `title`, `short_blurb` e imágenes principales

Esa superficie controla actualmente:

- URL canónicas
- meta descripciones
- Vistas previas de Open Graph y Twitter
- generación de URL del mapa del sitio
- en todo el sitio `Organization` / `WebSite` JSON-LD
- campaña `CreativeWork` / ruta de navegación JSON-LD
- texto alternativo de imagen social alternativa
- Cadenas de configuración regional de Open Graph

La implementación es deliberadamente limitada:

- Los flujos privados/tokenizados/solo para seguidores están marcados `noindex`
- `robots.txt` y `sitemap.xml` solo anuncian la superficie pública
- no existe una matriz gigante de configuración de SEO por página más allá de los campos de contenido que el sitio ya admite

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

### `debug`

Utilice `debug` para el tiempo de ejecución compartido del navegador y el registro de la consola de trabajo.

Teclas admitidas:

- `console_logging_enabled`
- `verbose_console_logging`

Qué hacen:

- `console_logging_enabled: false` suprime la salida del navegador y del trabajador `console` en el carrito compartido, la campaña, la comunidad, las estadísticas en vivo, la gestión de promesas, el webhook, el administrador y los tiempos de ejecución de las tareas programadas.
- `verbose_console_logging: false` mantiene el registrador activo pero suprime el ruido de depuración/información/registro de menor gravedad y al mismo tiempo permite advertencias y errores.

Estos valores predeterminados son intencionalmente `true` en `_config.yml`, por lo que las forks comienzan con diagnósticos completos disponibles y pueden desactivar el registro más tarde sin cambios de código.

Cuando están habilitados, los registradores compartidos ahora emiten:

- marcas de tiempo ISO
- Prefijos consistentes de navegador/ámbito de trabajo
- etiquetas de gravedad como `LOG`, `WARN` y `ERROR`
- cargas útiles `Error` normalizadas
- captura del navegador para errores no detectados y rechazos de promesas no controlados

### `shipping`

Utilice `shipping` para la configuración de envío de origen y de reserva, además del catálogo preestablecido para productos físicos comunes.

Claves admitidas hoy:

- `origin_zip`
- `origin_country`
- `fallback_flat_rate`
- `free_shipping_default`
- `default_option`
- `usps.enabled`
- `usps.client_id`
- `usps.api_base`
- `usps.timeout_ms`
- `usps.quote_cache_ttl_seconds`
- `usps.failure_cooldown_seconds`
- `usps.rate_limit_cooldown_seconds`
- `presets`

Opcionalmente, las campañas también pueden establecer `shipping_fallback_flat_rate` al frente. Cuando está presente, esa reserva específica de la campaña anula el `shipping.fallback_flat_rate` global si la cotización de USPS no está disponible.

Opcionalmente, las campañas también pueden establecer `shipping_options` al frente para optar por el conjunto de políticas de envío limitado para patrocinadores:

- `signature_required`
- `adult_signature_required`

`standard` siempre está disponible implícitamente y no es necesario incluirlo en la lista.

Cuando una promesa califica para múltiples opciones de entrega, el carrito compartido y las UI de Administrar promesa muestran el mismo selector localizado y el Trabajador mantiene la opción seleccionada como parte del total de envío canónico.

Límite secreto importante:

- mantener `shipping.usps.client_id` en `_config.yml`
- mantenga el compañero `USPS_CLIENT_SECRET` en Secretos del trabajador o `worker/.dev.vars`
- no guardes el secreto en la configuración de Jekyll

La lista de destinos de pago ahora está intencionalmente separada de esas perillas. Mantenga los países de envío permitidos actualmente en [`_data/shipping_countries.yml`](https://github.com/your-org/your-project/blob/main/_data/shipping_countries.yml) en lugar de editar el código de ejecución del navegador.

Ejemplo:

```yml
shipping:
  origin_zip: "87120"
  origin_country: "US"
  fallback_flat_rate: 3.00
  free_shipping_default: false
  default_option: standard
  usps:
    enabled: true
    client_id: "your-usps-client-id"
    api_base: ""
    timeout_ms: 5000
    quote_cache_ttl_seconds: 600
    failure_cooldown_seconds: 300
    rate_limit_cooldown_seconds: 1800
  presets:
    poster:
      weight_oz: 5
      packaging_weight_oz: 3
      length_in: 18
      width_in: 3
      height_in: 3
      stack_height_in: 0.5
    vinyl:
      weight_oz: 18
      packaging_weight_oz: 4
      length_in: 13
      width_in: 13
      height_in: 1
```

Qué permite esto:

- un origen de envío USPS a nivel de implementación
- un valor predeterminado de envío gratuito a nivel de implementación que las campañas aún pueden anular
- una tasa de reserva configurada si la cotización del operador en vivo no está disponible
- una superficie de política de cotización de USPS orientada a la fork para tiempos de espera, reutilización de cotizaciones de corta duración y tiempos de reutilización temporales después de fallas repetidas o limitación de tarifas
- una superficie de selección de opciones de entrega compartida en el carrito y Administrar compromiso sin abrir opciones arbitrarias de velocidad del transportista
- nombres `shipping_preset` reutilizables en niveles de campaña para que las forks no necesiten repetir dimensiones comunes de merchandising
- sugerencias de perfil de USPS de nivel preestablecido opcionales para tipos de artículos que necesitan una forma de cotización nacional diferente
- pedido opcional de clases de correo nacional de nivel preestablecido para productos que califican para clases de USPS más económicas como Media Mail

Los metadatos preestablecidos y anulados pueden incluir:

- `weight_oz`
- `packaging_weight_oz`
- `length_in`
- `width_in`
- `height_in`
- `stack_height_in`
- `manual_domestic_rate`
- `usps_domestic.processing_category`
- `usps_domestic.rate_indicator`
- `usps_domestic.destination_entry_facility_type`
- `usps_domestic.price_type`
- `usps_domestic.mail_classes`

`weight_oz` es el peso del artículo. `packaging_weight_oz` es una asignación de embalaje única para esa línea de pedido, y `stack_height_in` permite apilar niveles físicos de varias cantidades de manera más realista que el simple `height * qty`.

El patrón más seguro es codificar deliberadamente un orden válido más barato por valor preestablecido en lugar de intentar inferir la elegibilidad "letra" o "plana" a partir de dimensiones sin procesar en tiempo de ejecución. El sitio actual ahora usa:

- `sticker`
  - `manual_domestic_rate: FIRST_CLASS_FLAT`
  - luego, un perfil USPS nacional de una sola pieza más económico si el envío ya no califica para pisos
- `signed_script`
  - `manual_domestic_rate: FIRST_CLASS_FLAT`
  - luego `MEDIA_MAIL`
  - luego `USPS_GROUND_ADVANTAGE`
  - luego `PRIORITY_MAIL`
- `cd`, `dvd`, `bluray`
  - `MEDIA_MAIL`
  - `USPS_GROUND_ADVANTAGE`
  - `PRIORITY_MAIL`

Si un producto no califica de manera confiable para una clase más barata, déjelo en la ruta de paquete predeterminada. También tenga en cuenta que la ruta actual de la API de precios de USPS no expone directamente la calificación plana o de carta de primera clase nacional, por lo que la lógica de "sobre grande" se implementa aquí como una tabla manual explícita (`FIRST_CLASS_FLAT`), no como una cotización API de USPS en vivo.

### `add_ons`

Utilice `add_ons` para un catálogo global de productos o ventas adicionales a nivel de plataforma que no esté vinculado a `support_items` de una sola campaña.

La ruta de trabajo actual los trata como selecciones a nivel de paquete. Los manifiestos de pago pendientes también pueden almacenar una campaña ancla, de modo que los carritos de múltiples campañas sigan siendo compatibles mientras que los flujos posteriores de liquidación y administración siguen siendo compatibles con la campaña.

Claves admitidas hoy:

- `enabled`
- `low_stock_threshold`
- `products`

Actualmente, cada producto admite:

- `id`
- `name`
- `description`
- `image_url`
- `price`
- `category`
- `inventory`
- `shipping_preset`
- `shipping`
- `source_url`
- `variant_option_name`
- `variants`

Ejemplo:

```yml
add_ons:
  enabled: true
  low_stock_threshold: 5
  products:
    - id: dust-wave-tshirt
      name: "DUST WAVE T-Shirt"
      description: "Our official t-shirt. 100% cotton."
      price: 25.00
      category: physical
      shipping_preset: tshirt
      source_url: "https://shop.example.com/"
      variant_option_name: Size
      variants:
        - { id: xs, label: XS, inventory: 1 }
        - { id: s, label: S, inventory: 2 }
        - { id: m, label: M, inventory: 4 }
```

Esto está destinado a artículos de catálogo de precio fijo y variantes simples, como tallas de camisa. Es independiente de la campaña `support_items`, que sigue teniendo el alcance de la campaña y la cantidad.

Comportamiento de envío de complementos:

- `category: digital` significa que el complemento nunca contribuye al envío.
- `category: physical` significa que el complemento participa en la misma calculadora de envío utilizada para los niveles físicos y los artículos de soporte físico.
- Los complementos físicos pueden:
  - hacer referencia a un `shipping_preset` compartido
  - o proporcione `shipping.weight_oz`, `shipping.packaging_weight_oz`, `shipping.length_in`, `shipping.width_in`, `shipping.height_in` y `shipping.stack_height_in` explícitos

Comportamiento actual del inventario de complementos:

- `inventory` puede vivir del producto en sí o de cada variante.
- `low_stock_threshold` controla cuándo la interfaz de usuario de administración/carro compartido muestra mensajes de escasez
- Las variantes agotadas se eliminan de la superficie compartida del estado del producto, a menos que el colaborador ya posea esa variante exacta en un compromiso existente.
- Tanto el carrito como Manage Pledge utilizan el mismo modelo de tarjeta de producto adicional compartido, por lo que las forks no necesitan diseñar ni configurar dos sistemas de merchandising diferentes.
- el encabezado de la sección complementaria y la nota de soporte se localizan a través de los archivos i18n de tiempo de ejecución normal, y la nota de soporte interpola automáticamente el nombre del autor del sitio configurado.

Las campañas también pueden definir complementos con alcance de campaña directamente en el frente de la campaña en `campaign_add_ons`.

Ese catálogo propiedad de la campaña utiliza la misma forma de producto que las entradas globales `add_ons.products`, pero se comporta de manera diferente en dos formas importantes:

- los complementos de la campaña se muestran en una sección separada `Campaign Add-ons` en el carrito y en Administrar compromiso
- Los complementos de la campaña cuentan para el subtotal de propiedad de la campaña/el progreso de financiación y siguen las reglas de envío de esa campaña.

Por el contrario, los `add_ons.products` globales siguen siendo productos de plataforma:

- se renderizan bajo la sección normal `Add-ons`
- no cuentan para los totales de financiación de la campaña
- Los complementos físicos globales se combinan en un cargo de envío/envío de plataforma independiente.

### `design`

Utilice `design` para anulaciones seleccionadas del sistema de diseño que no requieren ediciones de Sass.

Estos valores se emiten en la hoja de estilo generada [assets/theme-vars.css](https://github.com/your-org/your-project/blob/main/assets/theme-vars.css), que mantiene el puente de variables de diseño compatible con el estricto CSP del sitio. Las forks no necesitan editar Sass solo para cambiar los tokens admitidos.

Claves admitidas actualmente:

- tipografía:
  - `font_body`
  - `font_display`
- diseño:
  - `layout_max_width`
- radio:
  - `radius_sm`
  - `radius_chip`
  - `radius_md`
  - `radius_lg`
  - `radius_xl`
- texto:
  - `color_text`
  - `color_text_strong`
  - `color_text_muted`
  - `color_text_soft`
- superficies:
  - `color_page_background`
  - `color_surface_base`
  - `color_surface_subtle`
  - `color_surface_soft`
  - `color_surface_strong`
  - `color_page_background_overlay`
  - `color_surface_base_overlay`
  - `color_surface_subtle_overlay`
- fronteras:
  - `color_border`
  - `color_border_strong`
  - `color_border_soft`
- primario/énfasis:
  - `color_primary`
  - `color_primary_soft`
  - `color_primary_border`
  - `color_primary_hover`
  - `color_primary_focus_ring`
  - `color_progress`
- comentarios / tintes:
  - `color_success`
  - `color_danger_soft`
  - `color_danger_softer`
  - `surface_tint_softer`
  - `surface_tint_soft`
  - `surface_tint_medium`
  - `surface_tint_hover`
  - `surface_tint_strong`

Ejemplo:

```yml
design:
  font_body: '"Source Sans 3", sans-serif'
  font_display: '"Space Grotesk", sans-serif'
  layout_max_width: 1080px
  radius_md: 12px
  radius_xl: 18px
  color_text: "#1f2430"
  color_page_background: "#f6f3ee"
  color_surface_base: "#ffffff"
  color_border: "#d9d2c7"
  color_primary: "#111111"
  color_primary_hover: "#000000"
  color_progress: "#111111"
```

### `checkout`

La sección `checkout` es intencionadamente estrecha.

Clave admitida hoy:

- `stripe_publishable_key`

El tiempo de ejecución del carrito propio y el flujo de pago personalizado en el sitio se tratan como un comportamiento integrado en la plataforma, no como cambios de modo orientados hacia la fork.

### `cache`

Utilice `cache` para ajustar el almacenamiento en caché público del navegador de lectura en vivo.

Teclas admitidas:

- `live_stats_ttl_seconds`
- `live_inventory_ttl_seconds`

## Configuraciones de solo sitio versus configuraciones reflejadas por trabajadores

Algunas configuraciones solo afectan la compilación de Jekyll y la interfaz de usuario propiedad del navegador. Otros también se reflejan automáticamente en el entorno del trabajador.

### Cambios seguros solo en el sitio

Estos se pueden cambiar en `_config.yml` sin cambiar la configuración del trabajador ni preocuparse por el paso de sincronización:

- `i18n.*`
- `design.*`
- `checkout.stripe_publishable_key`
- `platform.default_creator_name`
- `platform.logo_path`
- `platform.footer_logo_path`
- `platform.favicon_path`
- `platform.default_social_image_path`
- `cache.*`

Estos son los botones de “generación/marca/localización de sitios” más seguros sin impacto matemático del lado del trabajador o del correo electrónico. Cambian el sitio generado, la carga útil de inicio del navegador o la capa del tema, pero no es necesario reflejarlos en el entorno del trabajador.

### Reflejado automáticamente al trabajador

Estos valores de configuración del sitio también se reflejan en los valores del entorno del trabajador en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml):

- `platform.name` -> `PLATFORM_NAME`
- `platform.company_name` -> `PLATFORM_COMPANY_NAME`
- `platform.support_email` -> `SUPPORT_EMAIL`
- `platform.pledges_email_from` -> `PLEDGES_EMAIL_FROM`
- `platform.updates_email_from` -> `UPDATES_EMAIL_FROM`
- `platform.site_url` -> `SITE_BASE`
- `platform.worker_url` -> `WORKER_BASE`
- `pricing.sales_tax_rate` -> `SALES_TAX_RATE`
- `pricing.flat_shipping_rate` -> `FLAT_SHIPPING_RATE`
- `pricing.default_tip_percent` -> `DEFAULT_PLATFORM_TIP_PERCENT`
- `pricing.max_tip_percent` -> `MAX_PLATFORM_TIP_PERCENT`
- `shipping.origin_zip` -> `SHIPPING_ORIGIN_ZIP`
- `shipping.origin_country` -> `SHIPPING_ORIGIN_COUNTRY`
- `shipping.fallback_flat_rate` -> `SHIPPING_FALLBACK_FLAT_RATE`
- `shipping.free_shipping_default` -> `FREE_SHIPPING_DEFAULT`
- `shipping.usps.enabled` -> `USPS_ENABLED`
- `shipping.usps.client_id` -> `USPS_CLIENT_ID`
- `shipping.usps.api_base` -> `USPS_API_BASE`
- `shipping.usps.timeout_ms` -> `USPS_TIMEOUT_MS`
- `shipping.usps.quote_cache_ttl_seconds` -> `USPS_QUOTE_CACHE_TTL_SECONDS`
- `shipping.usps.failure_cooldown_seconds` -> `USPS_FAILURE_COOLDOWN_SECONDS`
- `shipping.usps.rate_limit_cooldown_seconds` -> `USPS_RATE_LIMIT_COOLDOWN_SECONDS`

El repositorio mantiene esos valores alineados automáticamente a través de las rutas principales locales/de desarrollo/prueba. Después de cambiarlos, reinicie la pila local para que tanto el sitio como el trabajador recojan los nuevos valores:

```bash
./scripts/dev.sh --podman
```

Para mayor comodidad, el repositorio ahora incluye:

```bash
npm run sync:worker-config
```

Ese comando sincroniza los valores reflejados por el trabajador en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml) de `_config.yml` y `_config.local.yml`.

No escribe secretos de los trabajadores. Los secretos de USPS OAuth todavía pertenecen a `wrangler secret` o `worker/.dev.vars`.

Las principales rutas de validación local/de desarrollo ya llaman a esa sincronización automáticamente:

- `./scripts/dev.sh --podman`
- `./scripts/dev.sh`
- `./scripts/test-worker.sh`
- `./scripts/test-checkout.sh`
- `cd worker && npm run dev`
- `cd worker && npm run deploy`
- `npm run test:premerge`

## Lo que todavía requiere código

La plataforma ahora admite una gran personalización sin código personalizado, pero aún no todo es configurable intencionalmente.

Todavía a nivel de código hoy:

- agregar nuevos proveedores de pago o modos de pago
- cambiar proveedores de inserción compatibles
- ampliar las listas permitidas de CSP para hosts externos arbitrarios
- cambiar el estilo de los campos propiedad de Stripe más allá de la API de apariencia compatible de Stripe
- introducir estructuras de diseño, plantillas de página o bloques de contenido completamente nuevos
- cambiar el comportamiento del alojamiento de fuentes/CSP más allá de las pilas de fuentes actualmente admitidas

Tenga en cuenta también:

- no todas las fichas de Sass están expuestas a propósito
- no todas las variables de entorno de trabajador pertenecen a `_config.yml`
- la superficie de soporte está curada para evitar regresiones de seguridad y mantenimiento

## Flujo de trabajo seguro para forks

1. Actualización `_config.yml`.
2. Ejecute `npm run sync:worker-config` si está editando configuraciones fuera de los puntos de entrada normales y desea actualizar `worker/wrangler.toml` inmediatamente.
3. Ejecutar:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

4. Verificar:

- marca de encabezado/pie de página
- metaimagen / favicon
- respaldo del creador de campañas
- Las páginas sensibles a CSP aún se cargan sin infracciones de CSP de la consola
- totales del carrito/pago
- Gestionar compromiso
- correos electrónicos de seguidores

5. Ejecute las comprobaciones pertinentes:

```bash
npx vitest run tests/unit/config-boot.test.ts tests/unit/cart-provider.test.ts tests/unit/manage-page.test.ts tests/unit/worker-business-logic.test.ts
./scripts/podman-self-check.sh
```

## Orientación para futuras incorporaciones

Al agregar nuevas perillas de personalización, prefiera este orden:

1. ponga el valor orientado al sitio en `_config.yml`
2. reflejarlo en el entorno del trabajador solo si el proceso de pago, los informes o los correos electrónicos lo necesitan
3. documentarlo aquí
4. Mantenga la superficie soportada seleccionada en lugar de exponer cada detalle de implementación.

Esto mantiene la personalización flexible sin convertir la plataforma en un motor de temas inestable de forma libre.
