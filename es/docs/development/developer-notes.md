---
title: Notas para desarrolladores
parent: Desarrollo
nav_order: 4
render_with_liquid: false
lang: es
---

# Notas para desarrolladores

## Pila

- **Páginas de GitHub** — Jekyll 4.4.1 + sitio estático Sass
- **Tiempo de ejecución del carrito propio**: carrito propiedad del navegador, revisión del pago y flujo de pago de Stripe en el sitio
- **Cloudflare Worker**: API de backend, almacenamiento de promesas (KV), envío de correo electrónico
- **Stripe** — Sesiones de pago en modo de configuración para el paso de pago en el sitio, además de PaymentIntents para cargos posteriores
- **Reenviar**: correos electrónicos transaccionales (confirmación del colaborador, recordatorios de lanzamiento, hitos, fallas)
- **Panel de administración privado**: edición, configuración, complementos, informes, análisis, seguidores y herramientas de marketing de campañas basadas en roles

### Perillas de plano libre aptas para horquillas

Si está intentando mantener una bifurcación cómoda en el plan gratuito Cloudflare Workers, las perillas más seguras para ajustar primero son:

- `cache.live_stats_ttl_seconds`
- `cache.live_inventory_ttl_seconds`
- `performance.intent_prefetch_enabled`
- `performance.intent_prefetch_delay_ms`
- `performance.intent_prefetch_limit`
- `launch_reminders.enabled`
- `pricing.sales_tax_rate`
- `shipping.fallback_flat_rate`

Los dos primeros viven en la configuración de Jekyll y dan forma al comportamiento de lectura del navegador. Los valores de precio/envío se reflejan automáticamente en el entorno del trabajador para que el pago, los correos electrónicos, los informes y las matemáticas de liquidación permanezcan alineados.

La configuración ahora utiliza un modelo de configuración estructurado en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml):

- nivel superior `title` / `description`
- `seo`
- `platform`
- `admin`
- `pricing`
- `tax`
- `shipping`
- `reports`
- `design`
- `debug`
- `add_ons`
- `checkout`
- `launch_reminders`
- `cache`

Trate `_config.local.yml` como un archivo de anulación fino para las URL de host local y otras diferencias locales de la máquina, no como un segundo lugar para duplicar la configuración de bifurcación canónica.

El objetivo de sincronización es [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml) y los puntos de entrada de desarrollo/pruebas admitidos por el repositorio lo mantienen alineado automáticamente.

Consulte [CUSTOMIZATION.md](/es/docs/development/customization-guide/) para conocer la superficie de bifurcación sin código admitida, incluidas las configuraciones que son solo para el sitio y las que se reflejan automáticamente en el trabajador.

Valores de trabajador reflejados actuales que vale la pena tratar como parte de la superficie de personalización admitida:

- identidad, URL, zona horaria y variables SEO: `SITE_TITLE`, `SITE_DESCRIPTION`, `PLATFORM_NAME`, `PLATFORM_COMPANY_NAME`, `PLATFORM_AUTHOR`, `PLATFORM_DEFAULT_CREATOR_NAME`, `PLATFORM_TIMEZONE`, `SITE_BASE`, `WORKER_BASE`, `CANONICAL_SITE_BASE`, `CANONICAL_WORKER_BASE`, `CORS_ALLOWED_ORIGIN`, `SEO_*`
- vars de administración: producción `ADMIN_USERS_JSON`, `ADMIN_TEST_CAMPAIGNS` solo para desarrolladores y `ADMIN_BOOTSTRAP_EMAILS` solo local en `worker/.dev.vars`
- vars de pago y precios: `STRIPE_PUBLISHABLE_KEY`, `SALES_TAX_RATE`, `FLAT_SHIPPING_RATE`, `DEFAULT_PLATFORM_TIP_PERCENT`, `MAX_PLATFORM_TIP_PERCENT`
- vars de impuestos y envío: `TAX_PROVIDER`, `TAX_ORIGIN_COUNTRY`, `TAX_USE_REGIONAL_ORIGIN`, `NM_GRT_API_BASE`, `ZIP_TAX_API_BASE`, `SHIPPING_ORIGIN_ZIP`, `SHIPPING_ORIGIN_COUNTRY`, `SHIPPING_FALLBACK_FLAT_RATE`, `FREE_SHIPPING_DEFAULT`, `SHIPPING_DEFAULT_OPTION`, `USPS_*`
- vars de diseño y correo electrónico: `SUPPORT_EMAIL`, `PLEDGES_EMAIL_FROM`, `UPDATES_EMAIL_FROM`, `EMAIL_*`, `PLATFORM_FOOTER_LOGO_PATH`, `PLATFORM_FAVICON_PATH`, `PLATFORM_DEFAULT_SOCIAL_IMAGE_PATH`
- vars de campaña-runner, recordatorio de lanzamiento, caché, rendimiento y depuración: `CAMPAIGN_RUNNER_*`, `LAUNCH_REMINDERS_ENABLED`, `LIVE_STATS_CACHE_TTL_SECONDS`, `LIVE_INVENTORY_CACHE_TTL_SECONDS`, `INTENT_PREFETCH_ENABLED`, `INTENT_PREFETCH_DELAY_MS`, `INTENT_PREFETCH_LIMIT`, `DEBUG_CONSOLE_LOGGING_ENABLED`, `DEBUG_VERBOSE_CONSOLE_LOGGING`

El repositorio ahora incluye `npm run sync:worker-config`, que sincroniza esos valores reflejados de `_config.yml`/`_config.local.yml` en `worker/wrangler.toml`. Las rutas principales de desarrollo local, prueba, solo para trabajadores y previas a la fusión lo llaman automáticamente. La verificación de artefactos propios de la puerta de fusión también recurre a la ruta de compilación respaldada por Podman cuando el host Bundler/Jekyll no está disponible.

Al agregar una nueva configuración visible para el trabajador, actualice `scripts/sync-worker-config.rb` en tres lugares: `TOP_LEVEL_ORDER`, `DEV_ENV_ORDER` y `build_mirror_values`. No añadas secretos a este camino; el script de sincronización es solo para configuraciones de repositorios no secretos.

El desarrollo del trabajador local ahora apunta al Nodo 24 para que coincida con las acciones de GitHub. La imagen de Podman Worker tiene como valor predeterminado el Nodo 24, mientras que los scripts de ayuda del host prefieren el Nodo 24 y recurren al Nodo 22 en lugar de forzar la antigua ruta del Nodo 20 que Wrangler 4 ya no admite. El trabajador compartido `compatibility_date` debe moverse deliberadamente con las actualizaciones de Wrangler/tiempo de ejecución para que el comportamiento de Miniflare local y el comportamiento de los trabajadores implementados permanezcan alineados.

Los secretos de USPS OAuth, Turnstile y firma de tokens están intencionalmente separados de esa superficie de configuración reflejada. Mantenga `USPS_CLIENT_SECRET`, `TURNSTILE_SECRET_KEY`, `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY` y `LAUNCH_REMINDER_TOKEN_SECRET` en Secretos de trabajador o `worker/.dev.vars`, no en `_config.yml`.

Los fundamentos de SEO ahora siguen un modelo similar:

- Los diseños públicos utilizan inclusiones compartidas para metadatos y JSON-LD.
- `robots.txt` y `sitemap.xml` se generan a partir de la superficie estática pública.
- `/manage/`, las páginas de la comunidad de seguidores y las páginas de resultados de compromisos emiten `noindex,nofollow`
- la superficie SEO orientada a la bifurcación admitida es principalmente `title`, `description`, `seo.x_handle`, `seo.same_as`, `seo.index_public_community_hub`, `platform.name`, `platform.site_url`, `platform.default_social_image_path` y campos de contenido de página/campaña como `title`, `description`, `short_blurb` e imágenes destacadas.

El registro de la consola del navegador y del trabajador ahora utiliza asistentes de registro compartidos en lugar de llamadas ad hoc `console.*` en los tiempos de ejecución principales. Eso le da al repositorio un interruptor acotado:

- `debug.console_logging_enabled`
- `debug.verbose_console_logging`

Si `console_logging_enabled` es `false`, tanto el tiempo de ejecución del navegador como el trabajador permanecen en silencio. Si `verbose_console_logging` es `false`, el ruido de depuración/información/registro de menor gravedad se suprime mientras se pueden seguir emitiendo advertencias y errores.

Cuando están habilitados, los registradores compartidos ahora proporcionan diagnósticos más estructurados de forma predeterminada:

- Marcas de tiempo ISO en cada línea
- navegador estable/prefijos de ámbito de trabajo
- etiquetas de gravedad explícitas
- salida `Error` normalizada
- captura del navegador para errores no detectados y rechazos de promesas no controlados

Mejores prácticas de cotización de envío en la implementación actual:

- Las llamadas de USPS solo ocurren en el Trabajador
- El pago físico espera una dirección de envío completa antes de iniciar el pago seguro.
- modificar flujos solo volver a cotizar cuando cambien los insumos relevantes para el envío
- Los tokens USPS OAuth se almacenan en caché en la memoria hasta casi su vencimiento
- Las cotizaciones de envío de USPS se almacenan en caché en la memoria durante un breve TTL
- Las fallas repetidas de USPS `429`, tiempo de espera o `5xx` desencadenan un tiempo de reutilización temporal en la memoria antes de volver a intentarlo
- la ruta de cotización alternativa sigue siendo canónica para el trabajador y no agrega rotación de caché de cotizaciones de KV

La puerta de fusión ahora divide deliberadamente sus rutas de humo locales:

- `scripts/test-worker.sh` sigue siendo un humo de contrato más ligero a nivel de anfitrión
- `scripts/smoke-pledge-management.sh` se ejecuta a través de la pila respaldada por Podman durante la activación de fusión, por lo que la ruta de modificación/cancelación mutable utiliza un estado de servicio local aislado.

El arnés Playwright ahora construye un `_site` estático limpio y lo sirve desde un servidor HTTP liviano para comprobaciones del navegador sin cabeza, en lugar de depender de `jekyll serve`.

Nota: el carrito/tiempo de ejecución propios y la interfaz de usuario de pago en el sitio personalizada ahora se tratan como comportamiento integrado de la plataforma, no como opciones de configuración orientadas a la bifurcación. El espacio de nombres de configuración `checkout` ahora es principalmente para configuraciones verdaderamente variables como la clave publicable de Stripe.

## Sistema de diseño

El lenguaje visual predeterminado aún comienza con el aspecto editorial más tranquilo de Dust Wave, pero el repositorio actual ya no está limitado a un tema de marca codificado:

- **Tokens de tema**: `design.*` en `_config.yml` alimenta variables CSS generadas en `assets/main.css`; `assets/theme-vars.css` sigue siendo un artefacto de compatibilidad
- **Estilo de pago**: el sidecar Stripe Elements en el sitio ahora lee la misma superficie simbólica para colores, radio y fuente del cuerpo.
- **Marca de correo electrónico del colaborador**: un subconjunto seleccionado de `platform.*` + `design.*` se refleja en el entorno del trabajador para que el estilo del logotipo/fuente/color/botón permanezca alineado en el correo electrónico.
- **Espaciado**: el sistema Sass todavía utiliza internamente un ritmo de diseño basado en 8px
- **Puntos de interrupción**: 724 px (xsm), 1000 px (sm/ms)

## Estructura descarada

```
assets/
├── main.scss              # Entry point with generated theme vars and Sass partial imports
├── partials/              # 14 active modular partials
│   ├── _variables.scss    # Colors, spacing, typography tokens
│   ├── _mixins.scss       # Breakpoints, button patterns
│   ├── _base.scss         # Reset, typography, links
│   ├── _layout.scss       # Page structure, grid, header
│   ├── _buttons.scss      # Button variants
│   ├── _forms.scss        # Form elements
│   ├── _cards.scss        # Campaign cards, tier cards
│   ├── _progress.scss     # Progress bars, stats
│   ├── _modal.scss        # Modal dialogs
│   ├── _campaign.scss     # Campaign page specifics
│   ├── _community.scss    # Community/voting pages
│   ├── _manage.scss       # Pledge management page
│   ├── _content-blocks.scss # Rich content rendering
│   ├── _utilities.scss    # Helper classes
└── js/
    ├── cart.js            # Pledge flow integration (tip UI, shipping/tax totals, checkout summary preview)
    ├── buy-buttons.js     # Button event handlers
    ├── campaign.js        # Phase tabs, toasts, interactive elements
    ├── live-stats.js      # Real-time stats, inventory, tier unlocks, late support
    └── cart-provider.js   # First-party cart/runtime provider
```

Jekyll compila `main.scss` → `main.css` automáticamente. Las hojas de estilo de fuentes externas se vinculan desde el encabezado del documento en lugar de importarse desde Sass, por lo que se descubren sin encadenar a través de `main.css`.

## Jekyll incluye Gotcha

**IMPORTANTE**: ¡Utilice siempre el prefijo `include.` al acceder a los parámetros en inclusiones!

❌ **Incorrecto**:
```liquid
{% include progress.html pledged=campaign.pledged_amount %}
<!-- In progress.html: -->
{{ pledged }}  <!-- Will be empty! -->
```

✅ **Correcto**:
```liquid
{% include progress.html pledged=campaign.pledged_amount %}
<!-- In progress.html: -->
{{ include.pledged }}  <!-- Works! -->
```

Esto se aplica a TODOS los parámetros de inclusión. Sin `include.`, Jekyll no puede resolver correctamente las variables.

## Gotcha de matriz vacía líquida

**IMPORTANTE**: ¡En Jekyll, una matriz YAML vacía `[]` es verdadera! Agregue siempre un cheque `.size > 0`.

❌ **Incorrecto**:
```liquid
{% if page.support_items %}
  <!-- Renders even when support_items: [] -->
{% endif %}
```

✅ **Correcto**:
```liquid
{% if page.support_items and page.support_items.size > 0 %}
  <!-- Only renders when there are actual items -->
{% endif %}
```

Esto se aplica a `support_items`, `decisions`, `stretch_goals`, `diary` y cualquier otro campo de matriz.

## Edición del panel de administración

El panel privado en `/admin/` ahora es el editor y la superficie de operaciones basados ​​en navegador compatibles. Lee de `_config.yml`, `_campaigns/*.md`, índices de compromiso de Worker KV y configuraciones de tiempo de ejecución de Worker, luego escribe a través de la ruta de persistencia correcta para cada flujo de trabajo.

- La configuración respaldada por GitHub y el contenido de la campaña se publican a través de la validación del trabajador y la ruta normal de reconstrucción/implementación.
- Los usuarios guardan directamente en Worker KV en `admin-users:v1`.
- Los códigos de referencia de marketing se guardan en KV con ámbito de campaña.
- El borrador del contenido se guarda en el navegador hasta su publicación.
- Los secretos permanecen en Secretos del trabajador o se ignoran `.dev.vars`; el panel solo muestra el estado configurado/faltante.
- Los informes, los análisis, la exploración de los asistentes, las vistas previas de contenido, el filtrado de tablas y las descargas de CSV son flujos del panel de solo lectura y no deben agregar escrituras KV.
- Las cargas de imágenes/vídeo/audio utilizan los directorios de activos existentes, normalizan los nombres de archivos y luego publican a través de la misma ruta respaldada por GitHub que el campo que actualizan.
- La optimización de los medios está deliberadamente fuera del Trabajador. Use `npm run media:optimize` localmente, `npm run media:optimize:podman` cuando falten optimizadores nativos del host, `npm run media:optimize:check` o `npm run media:optimize:check:podman` antes de fusionar cuando los medios cargados cambiaron, o deje que el flujo de trabajo de GitHub Actions `Optimize dashboard media` se ejecute después de que las cargas del panel lleguen a `main`. El flujo de trabajo se puede enviar manualmente con `scope=all` para reprocesar los medios existentes.

Consulte [DASHBOARD.md](/es/docs/operations/admin-dashboard/) para obtener la referencia completa del panel.

## Minificación de activos generados

Las implementaciones de páginas de producción mantienen legibles las fuentes del repositorio y minimizan solo el sitio generado. El flujo de trabajo de implementación ejecuta Jekyll y luego ejecuta:

```bash
npm run assets:minify
```

Ese script reescribe archivos `_site/assets/**/*.css` y `_site/assets/**/*.js` más pequeños antes de que se cargue el artefacto de GitHub Pages. La minificación de JavaScript es intencionalmente conservadora: elimina los espacios en blanco y simplifica la sintaxis, pero no altera las propiedades ni reescribe los identificadores. CSS se minimiza por completo después de que Sass ya haya producido una salida comprimida.

Utilice esta verificación después de una compilación local de Jekyll cuando cambie la tubería de minificación:

```bash
npm run assets:minify:check
```

Cloudflare sigue siendo responsable de la compresión de transferencia en el borde. Mantenga Cloudflare Auto Minify desactivado para que el comportamiento de producción provenga de este paso de compilación controlado por el repositorio en lugar de reescribirlo en el momento del borde.

## Modelo de contenido de campaña

Cada campaña vive en `_campaigns/<slug>.md`.

### Campos obligatorios

```yaml
layout: campaign
title: "CAMPAIGN NAME"
slug: campaign-slug
start_date: 2025-01-15   # Campaign goes live at midnight in the platform timezone
goal_amount: 25000
goal_deadline: 2025-12-20  # Campaign ends at 11:59:59 PM in the platform timezone
charged: false
# pledged_amount not needed - live-stats.js fetches from KV and enables late support dynamically
hero_image: /assets/images/hero.jpg
short_blurb: "Brief description"
long_content:
  - type: text
    body: "Full description with **markdown**"
```

**El estado se calcula automáticamente** a partir de `start_date` y `goal_deadline`:
- Antes de `start_date` → `upcoming` (botones deshabilitados)
- Entre fechas → `live` (se aceptan promesas)
- Después de `goal_deadline` → `post` (campaña cerrada)

El complemento `_plugins/campaign_state.rb` establece el estado en el momento de la compilación. El programador de trabajadores activa una reconstrucción del sitio cuando las fechas cruzan la medianoche en la zona horaria de la plataforma configurada.

**Cumplimiento de la zona horaria de la plataforma**: el complemento Jekyll, las cuentas regresivas del navegador y la lógica de fecha límite del trabajador usan `platform.timezone`, reflejado en el trabajador como `PLATFORM_TIMEZONE`. Debe ser una zona horaria compatible con IANA y el valor predeterminado es `America/Denver` para compatibilidad.

### Zona horaria del temporizador de cuenta regresiva

El temporizador de cuenta regresiva de la página de la campaña utiliza la zona horaria configurada de la plataforma con manejo automático del horario de verano:
- **Próximas campañas**: cuenta regresiva hasta la medianoche (00:00:00) en `start_date`
- **Campañas en vivo**: cuenta regresiva hasta las 11:59:59 p.m. en `goal_deadline`

El temporizador utiliza `Intl.DateTimeFormat` con `platform.timezone` para convertir límites de campaña de solo fecha en instantes absolutos. Esto funciona desde cualquier zona horaria de usuario y sigue las reglas de horario de verano de la zona horaria seleccionada sin codificar fechas de transición.

El trabajador (`worker/src/index.js` y `worker/src/campaigns.js`) utiliza el mismo enfoque basado en `Intl` para el cumplimiento de los plazos y el calendario de liquidación.

### Pre-renderizado de cuenta regresiva

Para evitar que aparezca "00 00 00 00" antes de que se cargue JavaScript:

**Páginas de campaña (`_layouts/campaign.html`):**
- Jekyll calcula los valores iniciales de la cuenta regresiva en el momento de la construcción usando filtros líquidos
- Utiliza `date: '%s'` para obtener marcas de tiempo de época, luego `divided_by` y `modulo` para días/horas/minutos/segundos.
- Los valores están ligeramente obsoletos (desviados por segundos desde la compilación) pero JS los corrige inmediatamente

**Administrar página (`_layouts/manage.html`):**
- La función `renderCountdown()` calcula valores en línea al generar HTML
- Sin marcadores de posición "00": los valores se calculan antes de la inserción del DOM

Entrecomilla cadenas con caracteres especiales para evitar problemas de análisis de YAML.

### Campos multimedia

- **`hero_image`** (obligatorio): Imagen cuadrada/vertical para vistas previas de tarjetas de la página de inicio
- **`hero_image_wide`** (opcional): Imagen ancha para la página de detalles de la campaña (vuelve a `hero_image`)
- **`hero_video`** (opcional): vídeo WebM para detalles de la campaña (utiliza la imagen principal como póster)
- **`creator_image`** (opcional): imagen cuadrada para el creador (círculo de 48 píxeles en la barra lateral)
- **Nivel `image`** (opcional): Imagen ancha mostrada encima del nombre del nivel

**Requisitos de video:** Se prefiere WebM para los videos de campaña cargados; se recomienda 16:9 y un máximo de 1920 x 1080. El panel de administración acepta cargas de videos destacados de hasta 100 MB o URL de YouTube/Vimeo, y obtiene una vista previa de archivos de video existentes o incrustaciones a través de la misma política de seguridad de contenido que la página de campaña pública. Los bloques de vídeo de contenido local pueden especificar un `poster` opcional; cuando se omiten, las vistas del editor público/administrador generan un póster transitorio desde el primer fotograma del vídeo y mantienen el vídeo reproducible cargado de forma diferida hasta su reproducción.

**Rutas de carga del panel:** El panel escribe los recursos cargados en el modelo de activos estáticos actual:

- Imágenes/vídeos de campaña: `assets/images/campaigns/<slug>/` y `assets/videos/campaigns/<slug>/`.
- Nivel/soporte/diario/imágenes de decisión: el directorio de activos de la campaña propietario, a menos que ya exista una ruta más específica.
- complementos de plataforma: `assets/images/add-ons/`
- complementos de campaña: `assets/images/campaign-add-ons/`

Mantenga el manejo de carga sin pérdidas siempre que sea posible. La optimización de imágenes reduce los bytes solo cuando el resultado optimizado es más pequeño y genera variantes WebP responsivas para plantillas públicas sin reescribir las referencias de las imágenes de origen. El conjunto derivado de imágenes públicas actual es `320w`, `480w`, `640w`, `960w` y `1600w`; Los derivados responsivos generados se omiten durante la optimización de la fuente para que la canalización no vuelva a codificar recursivamente sus propios activos del navegador. La conversión de vídeo genera derivados WebM de alta calidad junto al archivo fuente cargado y reescribe las referencias literales de campaña/configuración a la ruta WebM después de que exista el derivado; Los vídeos de origen permanecen en el repositorio para revertirlos o volverlos a codificar en el futuro.

### Nivel destacado

- **`featured_tier_id`** (opcional): ID de nivel para resaltar en la tarjeta de la página de inicio

### Límites de caracteres

- `short_blurb`: Máximo 80 caracteres (2 líneas en tarjetas)
- `title`: Máximo 30 caracteres
- Nombre del nivel destacado: máximo 40 caracteres

### Bloques de contenido largos

```yaml
long_content:
  - type: text
    body: "Markdown text"
  - type: image
    src: /assets/images/photo.jpg
    alt: "Description"
  - type: video
    provider: youtube
    video_id: "abc123"
    caption: "Behind the scenes"
  - type: video
    provider: local
    src: /assets/videos/campaigns/example/proof.webm
    caption: "Proof of concept"
  - type: gallery
    layout: grid
    images:
      - src: /assets/images/photo1.jpg
        alt: "Still 1"
```

Reglas de comportamiento/seguridad de contenido largo:
- Los bloques de texto admiten Markdown.
- Los enlaces de Markdown externos se procesan con `target="_blank"` y `rel="noopener noreferrer"` automáticamente.
- Se conserva un pequeño subconjunto HTML en línea por motivos de compatibilidad: `<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`.
- Otras etiquetas HTML sin formato se escapan en el momento de la representación y `scripts/audit-campaign-content.mjs` las rechaza.

**Diseños de galería:**
- `grid` (predeterminado): cuadrícula de 2 columnas, relación de aspecto 4:3 (1 columna en dispositivos móviles)
- `logos`: cuadrícula de 2 columnas, relación de aspecto automática con `object-fit: contain` (altura máxima de 200 píxeles): ideal para logotipos de patrocinadores/socios
- `carousel`: Desplazamiento horizontal con ajuste, relación de aspecto 16:9

### Metas extendidas

```yaml
stretch_goals:
  - threshold: 35000
    title: Extra Sound Design
    description: More Foley layers.
    status: locked
```

### Niveles

```yaml
tiers:
  - id: frame-slot
    name: Buy 1 Frame
    price: 5
    description: Sponsor a frame.
    category: physical       # physical | digital (default: digital)
    fields:
      - { name: "Preferred frame number", type: "text", required: true }

  - id: creature-cameo
    name: Creature Cameo
    price: 250
    description: Name the practical creature.
    requires_threshold: 35000  # Unlocks when pledged >= $35,000
```

**Control de niveles**: agregue `requires_threshold` (entero, dólares) para bloquear un nivel hasta que la campaña alcance ese nivel de financiación. Cuando las estadísticas en vivo se actualizan y `pledgedAmount >= requires_threshold`, el nivel se anima a "¡Desbloqueado!" estado con una insignia. La animación respeta `prefers-reduced-motion`.

**Niveles físicos**: configure `category: physical` para activar la recopilación de la dirección de envío durante el paso de pago de Stripe en el sitio. Las bases actuales de la calculadora de envíos también respaldan:

- `shipping_preset` para bienes físicos comunes como `tshirt`, `poster`, `cd`, `vinyl`, `dvd`, `bluray` y `signed_script`.
- `shipping.weight_oz`, `shipping.packaging_weight_oz`, `shipping.length_in`, `shipping.width_in`, `shipping.height_in` y `shipping.stack_height_in` para anulaciones explícitas por nivel
- `shipping_fallback_flat_rate` opcional a nivel de campaña cuando una campaña específica necesita un respaldo plano diferente al predeterminado de implementación global
- `shipping_options` opcional a nivel de campaña para el conjunto de políticas de envío limitado para patrocinadores (`signature_required`, `adult_signature_required`)

En el panel de administración, los ID de nivel son de solo lectura para los editores: los ID heredados se conservan, mientras que los ID de nivel nuevos se derivan del nombre. `shipping_preset` se oculta para niveles digitales. Si un nivel físico no tiene un valor preestablecido, se muestran campos explícitos de peso/dimensión del paquete.

**Productos complementarios de plataforma**: los productos globales o los artículos de venta adicional ahora tienen una ruta de configuración separada en `add_ons` en [/_config.yml](https://github.com/your-org/your-project/blob/main/_config.yml). Ese catálogo está destinado a productos de precio fijo en toda la plataforma con variantes simples, como tallas de camisa, y no debe modelarse como la campaña `support_items`. The Worker refleja el catálogo a través de [/api/add-ons.json](https://github.com/your-org/your-project/blob/main/api/add-ons.json), expone una instantánea del inventario actual a través de `/add-ons/inventory`, incluye selecciones de complementos a nivel de paquete más una campaña ancla durante el proceso de pago, conserva esos complementos vinculados al ancla en el compromiso sin contarlos para los totales de objetivos de campaña y ahora los expone por separado en las exportaciones de compromiso y cumplimiento. Tanto Cart como Manage Pledge consumen la misma lógica de estado del producto que tiene en cuenta el inventario, incluidos mensajes de stock bajo y filtrado de variantes agotadas.

- Los complementos `category: digital` nunca contribuyen al envío
- Los complementos `category: physical` participan en la misma calculadora de envío que se utiliza para los niveles físicos y los artículos de soporte físico.
- Los complementos físicos pueden usar `shipping_preset` para ajustes preestablecidos compartidos como `tshirt` y `sticker`.
- o pueden definir `shipping.weight_oz`, `shipping.packaging_weight_oz`, `shipping.length_in`, `shipping.width_in`, `shipping.height_in` y `shipping.stack_height_in` explícitos.

El carrito propio todavía lleva la categoría física a través de la carga útil de intención de pago, y las cotizaciones de envío del lado del trabajador utilizan las medidas de envío preestablecidas o explícitas en lugar de una suposición de tarifa fija codificada. El panel utiliza el mismo editor de productos para complementos de plataforma y complementos de campaña, conserva los ID heredados, deriva nuevos ID de productos/variantes a partir de nombres/etiquetas y muestra campos de paquete solo para productos físicos sin ajustes preestablecidos.

### Fases de producción

```yaml
phases:
  - name: Pre-Production
    registry:
      - id: location-scouting
        label: Location Scouting
        need: travel + permits
        target: 1000
        # current: 900  # Optional: live-stats.js fetches from KV
```

### Decisiones comunitarias (solo para partidarios)

```yaml
decisions:
  - id: poster
    type: vote              # vote | poll
    title: Official Poster
    options: [A, B]
    eligible: backers       # backers | public
    status: open            # open | closed
```

`vote` y `poll` actualmente utilizan la misma mecánica de envío y conteo solo para seguidores. Utilice `vote` cuando el resultado esté destinado a decidir un resultado, y utilice `poll` cuando el resultado sea una retroalimentación de asesoramiento o una recopilación de preferencias. La distinción es intencionalmente semántica/visual por ahora; Las versiones futuras pueden superponer diferentes flujos de trabajo de copia pública, informes o resultados sobre los mismos datos almacenados.

### Diario de producción

Las entradas del diario admiten bloques de contenido enriquecido (igual que `long_content`):

```yaml
diary:
  - date: 2026-01-15T09:00:00-07:00  # ISO 8601 with timezone offset
    title: "Day 14 — Principal Photography"
    phase: production  # fundraising | pre-production | production | post-production | distribution
    content:
      - type: text
        body: |
          Desert wrap. Wind, dust, and a miraculous sunset.
          
          **The footage looks unreal.**
      - type: image
        src: /assets/images/campaigns/my-film/bts-sunset.jpg
        alt: "Behind the scenes sunset shot"
      - type: quote
        text: "This is the one."
        author: "The Director"
```

**Formato de fecha:** Utilice ISO 8601 con desplazamiento de zona horaria para una clasificación adecuada:
- Ejemplo de invierno: `2026-01-15T09:00:00-07:00`
- Ejemplo de verano: `2025-10-15T14:00:00-06:00`

Las entradas sin un componente de tiempo (`2026-01-15`) solo muestran la fecha. Entradas con visualización de la hora "15 de enero de 2026 · 9:00 a. m.".

**Formato heredado:** Las cadenas `body` sin formato todavía se admiten para compatibilidad con versiones anteriores:
```yaml
diary:
  - date: 2025-10-27
    title: "Quick update"
    phase: production
    body: "Simple text without rich content."
```

**Difusiones por correo electrónico:** Cuando se agregan e implementan entradas del diario, la acción de GitHub activa `/admin/diary/check`, que envía correos electrónicos de actualización a todos los partidarios de la campaña. La verificación automática envía sólo las entradas que no se han difundido antes. Las entradas del diario utilizan valores `id` estables para el seguimiento de transmisiones; el panel conserva las identificaciones existentes y el trabajador deriva las identificaciones basadas en títulos para las entradas recién agregadas. Los marcadores de fechas heredados aún se reconocen, por lo que las ediciones de entradas más antiguas no se reenvían. El extracto del correo electrónico se extrae automáticamente de los bloques de texto (primeros 200 caracteres, sin rebajas).

**Configuración requerida:** Agregue `ADMIN_SECRET` como secreto del repositorio de GitHub (Configuración → Secretos → Acciones). Debe coincidir con el `ADMIN_SECRET` del trabajador. Sin él, las transmisiones diarias por correo electrónico fallarán silenciosamente.

### Financiamiento continuo (posterior a la campaña)

```yaml
ongoing_items:
  - label: Color Grade
    remaining: 4500
  - label: Sound Mix
    remaining: 6000
```

Todos los valores monetarios deben ser números enteros (sin centavos).

## Integración de carrito propio

### Tiempo de ejecución del carrito

El sitio ahora utiliza un tiempo de ejecución de carrito propio expuesto a través de `window.PoolCartProvider`. El código de interfaz de usuario compartido se comunica con ese proveedor en lugar de depender de un asistente de carrito alojado por separado.

Archivos clave:
- `assets/js/cart-provider.js`: estado del carrito propiedad del navegador, representación del cajón, vista previa del pago, recuperación de éxito/cancelación
- `assets/js/cart.js`: arranque del flujo de promesas compartidas y comportamientos del carrito a nivel de página
- `_includes/cart-runtime-head.html` / `_includes/cart-runtime-foot.html`: arranque en tiempo de ejecución propio

### Niveles apilables versus no apilables

Los niveles se pueden marcar como `stackable: false` para evitar ajustes de cantidad en el carrito.

Cómo funciona ahora:
1. Los botones de compra transportan los metadatos del nivel/carrito a través de ganchos `poolcart-*` e ID de artículos como `{campaignSlug}__{tierId}`.
2. El proveedor propio fusiona adiciones repetidas solo para niveles apilables.
3. La aplicación no apilable ocurre en el estado del carrito propio, no a través de parches DOM del carrito alojado.

Archivos involucrados:
- `_includes/tier-card.html`
- `_includes/campaign-card.html`
- `_includes/support-items.html`
- `_includes/ongoing-funding.html`
- `_includes/production-phases.html`

## Flujo de compromiso

El flujo de compromiso ahora es de principio a fin hasta Stripe:

1. **El usuario agrega un nivel al carrito** → se abre el cajón del carrito propio
2. **Compromiso de reseñas de usuarios** → el cajón muestra niveles, elementos de soporte, soporte personalizado, sugerencias y precios inmediatos
3. **El usuario hace clic en "Pagar"** → `cart-provider.js` publica artículos canónicos del carrito en el trabajador `/checkout-intent/start`
4. **El trabajador crea una sesión de configuración de Stripe** → el segundo sidecar de pago monta la interfaz de usuario de pago segura de Stripe en el sitio y guarda la tarjeta sin cobrar
5. **El usuario completa el paso de pago en el sitio** → el cliente espera la confirmación persistente del backend antes de considerar el compromiso como exitoso
6. **Se activa el webhook de Stripe** → El trabajador almacena un compromiso por campaña en KV, actualiza las estadísticas y envía correos electrónicos a sus seguidores.

Puntos clave:
- Los pedidos de carritos alojados ya no forman parte del tiempo de ejecución.
- Los ID de pedido son valores `pool-intent-*` emitidos por el trabajador vinculados al nonce de pago.
- Stripe recopila detalles reales de pago y envío
- El impuesto se calcula en el lado del servidor a partir del `pricing.sales_tax_rate` configurado en `_config.yml` y el entorno de trabajo reflejado.
- opcional La propina del grupo tiene un valor predeterminado del 5%, se puede configurar entre 0% y 15% y se incluye en los totales de cargos finales, pero se excluye del progreso de financiación de la campaña.
- los totales de la vista previa del pago se representan inmediatamente desde la lógica de precios compartida

### Artículos de soporte y montos personalizados

El carrito puede incluir:
- **Niveles** — `{campaignSlug}__{tierId}`
- **Artículos de soporte** — `{campaignSlug}__support__{itemId}`
- **Cantidad personalizada**: estado de soporte personalizado propiedad del navegador que se convierte en `customAmount`

Flujo de datos:
1. `cart-provider.js` crea la carga útil del carrito propio y la envía a `/checkout-intent/start`.
2. El trabajador canonicaliza la contribución y almacena metadatos desbordados en KV temporal (`pending-extras:{orderId}`, `pending-tiers:{orderId}`)
3. El trabajador almacena `tipPercent` y metadatos de integridad en metadatos de sesión de Stripe
4. En el webhook, el trabajador obtiene extras del KV temporal y los fusiona en el compromiso final
5. El trabajador llama a `updateSupportItemStats()` para actualizar las estadísticas en vivo de los elementos de soporte

Administrar la visualización de la página:
- Durante campañas **en vivo**: todos los elementos de soporte se muestran para su modificación
- Durante campañas de **publicación**: solo se muestran los artículos con `late_support: true` (y solo si están financiados)
- El resumen de la promesa muestra el subtotal, la propina opcional de The Pool, los impuestos, el envío y el total.
- La modificación de niveles recalcula dinámicamente el envío según el nivel `category`
- Los compromisos activos se agrupan por separado de los compromisos cerrados; Los compromisos activos que vencieron la fecha límite se muestran como bloqueados y pasan a ser de solo lectura, excepto la "Tarjeta de actualización".

## Desarrollo Local

### Requisitos previos

Cuentas requeridas:
- [Stripe](https://dashboard.stripe.com) — procesamiento de pagos (modo de prueba)
- [Cloudflare](https://dash.cloudflare.com) — Trabajador + almacenamiento KV
- [Resend](https://resend.com): correo electrónico transaccional (el nivel gratuito es muy útil)

Herramientas necesarias:
```bash
ruby --version   # 3.x recommended
node --version   # 20.x recommended
npm install -g wrangler
wrangler login
brew install stripe/stripe-cli/stripe
stripe login
```

### 1. Instalar dependencias

```bash
bundle install
npm install
```

### 2. Configurar los secretos de los trabajadores

Crea `worker/.dev.vars` para el desarrollo local:

```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY_TEST=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
CHECKOUT_INTENT_SECRET=random-32-char-string-for-hmac
MAGIC_LINK_SECRET=random-32-char-string-for-hmac
RESEND_API_KEY=re_...
ADMIN_SECRET=local-admin-secret
```

Generar secretos:
```bash
openssl rand -base64 32
```

### 3. Configurar espacios de nombres KV

Si aún no ha creado espacios de nombres KV:

```bash
cd worker
wrangler kv:namespace create "VOTES"
wrangler kv:namespace create "VOTES" --preview
wrangler kv:namespace create "PLEDGES"
wrangler kv:namespace create "PLEDGES" --preview
```

Actualice `worker/wrangler.toml` con los ID devueltos.

### 5. Iniciar el desarrollo

**Opción A: pila local de Podman primero (recomendado)**

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Esto comienza:
- **Jekyll** en http://127.0.0.1:4000 (con anulaciones de `_config.local.yml`)
- **Trabajador** en http://127.0.0.1:8787, ejecutándose en el nodo 24 en el contenedor de desarrollo
- **Stripe CLI** reenvía webhooks al trabajador local cuando esté disponible
- dependencias en contenedores locales para la ruta de desarrollo/prueba de Podman compatible

El script actualiza automáticamente `worker/.dev.vars` con el secreto del webhook de Stripe CLI cuando Stripe CLI está disponible.
Utiliza la misma instancia de escucha de Stripe tanto para el reenvío como para la captura de secretos, lo que evita la discrepancia del webhook local que puede ocurrir si inicia un escucha para imprimir un secreto y otro para reenviar eventos.
También borra los oyentes obsoletos en los puertos locales estándar antes de comenzar, de modo que la pila local coincida con el arnés de prueba/humo automatizado.

> **Nota:** La simulación KV local se utiliza de forma predeterminada para una iteración rápida y compatibilidad con `scripts/seed-all-campaigns.sh`. Los datos de KV se restablecen cuando el trabajador se reinicia. Utilice `--remote` si necesita datos persistentes o para ver promesas reales.

**Opción B: solo herramientas de host (inicio manual)**

```bash
# Terminal 1: Jekyll
bundle exec jekyll serve --config _config.yml,_config.local.yml --port 4000

# Terminal 2: Worker (local KV simulation)
cd worker && npx wrangler dev --env dev --port 8787

# Terminal 3: Stripe webhooks
stripe listen --forward-to 127.0.0.1:8787/webhooks/stripe
```

**Solución de problemas: promesas faltantes**

Si se completa un pago de Stripe pero el compromiso no aparece:
1. Verifique la salida de Stripe CLI: ¿reenvió el webhook?
2. Utilice el punto final de recuperación para crear manualmente el compromiso:
   ```bash
   curl -X POST http://127.0.0.1:8787/admin/recover-checkout \
     -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
     -H 'Content-Type: application/json' \
     -d '{"sessionId": "cs_test_..."}'
   ```

**Comprobaciones locales útiles después del inicio**

```bash
npm run test:secrets
./scripts/test-worker.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/test-e2e.sh --podman
```

**Solución de problemas: errores de Stripe Webhook (no coinciden los modos)**

Si Stripe muestra fallas de webhook ("otros errores") para el punto final de producción:
- El trabajador de producción recibe webhooks en **modo de prueba** pero no puede verificarlos (diferentes secretos de firma)
- El trabajador ahora realiza una **detección en modo temprano**: analiza el campo `livemode` del evento antes de la verificación de la firma.
- Los eventos de prueba enviados a un trabajador activo (o viceversa) se reconocen con `200 OK` y se omiten, lo que evita errores de firma.
- No se necesita configuración; esto se maneja automáticamente

### 6. Pruebe el flujo de promesas

1. Visita http://127.0.0.1:4000
2. Haga clic en una campaña → Agregar un nivel al carrito
3. Revise la vista previa del pago propio → Haga clic en "Pagar"
4. Complete el paso de pago de Stripe en el sitio con la tarjeta de prueba: `4242 4242 4242 4242`
5. Consulte los registros de trabajadores para confirmar el compromiso
6. Comprobar correo electrónico (si está configurado Reenviar)

### Tarjetas de prueba de rayas

|Tarjeta|Escenario|
|------|----------|
|`4242 4242 4242 4242`|Éxito|
|`4000 0000 0000 3220`|Se requiere 3D Secure|
|`4000 0000 0000 9995`|Rechazado (fondos insuficientes)|

### Borrar caché

Si los estilos no se actualizan:
```bash
bundle exec jekyll clean
```

## Siembra de datos de prueba

Semillas de prueba se comprometen en KV local para su prueba:

```bash
./scripts/seed-all-campaigns.sh
```

**Qué hace:**
1. Borra los datos de compromiso existentes del KV local antes de la siembra
2. Promesas de semillas para todas las campañas con escenarios realistas:
   - **hand-relations**: Financiamiento parcial y finalizado (~$8,200 / $25,000)
   - **sunder**: Financiamiento anticipado y en vivo (~$650 / $2500)
   - **tecolote**: Finalizado, financiamiento parcial (~$1,550 / $2,000)
   - **peor película de todos los tiempos**: Terminada, financiación parcial (~$1,290 / $2,500)
3. Incluye diversos estados de compromiso:
   - Promesas activas
   - Promesas cargadas (para campañas financiadas)
   - Promesas canceladas (con historial de cancelaciones adecuado y deltas negativos)
   - Pago de promesas fallidas
   - Promesas modificadas (actualizaciones/bajas con deltas de seguimiento del historial)
4. Vuelve a calcular las estadísticas de la campaña y el inventario de niveles a través de la API del trabajador.

**Requisitos:**
- El trabajador debe ejecutarse localmente (`wrangler dev --env dev` en el puerto 8787)
- `worker/.dev.vars` debe tener `ADMIN_SECRET` configurado
- El KV local se reinicia cuando el trabajador se reinicia, así que vuelva a ejecutar este script después del reinicio

**Formato del historial de promesas:**
Los compromisos incluyen una matriz `history` que rastrea todos los cambios:

```json
{
  "history": [
    { "type": "created", "subtotal": 10000, "tax": 788, "amount": 10788, "tierId": "prop", "tierQty": 1, "customAmount": 5, "at": "..." },
    { "type": "modified", "subtotalDelta": -5000, "taxDelta": -394, "amountDelta": -5394, "tierId": "dialogue", "tierQty": 1, "customAmount": 10, "at": "..." }
  ]
}
```

Campos de entrada del historial:
- `type` — Tipo de evento: `created`, `modified` o `cancelled`
- `subtotal` / `subtotalDelta`: monto antes de impuestos (completo para creado, delta para modificado/cancelado)
- `tax` / `taxDelta` — Importe del impuesto (total o delta)
- `amount` / `amountDelta` — Total con impuestos (completo o delta)
- `tierId`: ID de nivel actual después de este evento
- `tierQty` — Cantidad de nivel actual después de este evento
- `additionalTiers`: conjunto de niveles adicionales (modo de varios niveles)
- `customAmount`: Monto de soporte personalizado en dólares (si está presente)
- `at` — Marca de tiempo ISO

Tipos de historia:
- `created` — Promesa inicial con montos completos
- `modified`: cambios de nivel/cantidad con valores delta (positivo para actualizaciones, negativo para degradaciones)
- `cancelled` — Cancelación con importes negativos (se resta del total de la campaña)

## Informes de compromiso

Genere informes CSV de promesas de Cloudflare KV:

```bash
# Remote production/dev reports require Wrangler auth.
cd worker && npx wrangler login

# Or, for non-interactive shells and Podman-backed report runs:
export CLOUDFLARE_API_TOKEN="your-token"

# All pledges, production KV
./scripts/pledge-report.sh

# Single campaign
./scripts/pledge-report.sh worst-movie-ever

# Dev/preview KV
./scripts/pledge-report.sh --env dev

# Save to file
./scripts/pledge-report.sh worst-movie-ever > pledges.csv
```

Para informes remotos respaldados por Podman, coloque `CLOUDFLARE_API_TOKEN` en el shell del host o en un archivo env local ignorado como `.env.local`, `.env.cloudflare` o `worker/.dev.vars`; los envoltorios de informes pasan los valores de autenticación de Cloudflare a `podman exec`.

Configuración de bifurcación para informes de producción:

1. En Cloudflare, vaya a **Mi perfil -> Tokens API -> Crear token**.
2. Cree un token de usuario con **Cuenta/Almacenamiento KV de trabajadores/Lectura** con alcance para la cuenta propietaria del espacio de nombres KV `PLEDGES` de esta bifurcación.
3. Guárdelo en `worker/.dev.vars` u otro archivo env ignorado:

```bash
CLOUDFLARE_API_TOKEN=your-token
```

4. Ejecute exportaciones de producción a través del mismo entorno de trabajo de Podman utilizado por las pruebas locales:

```bash
./scripts/pledge-report.sh --podman --env production --remote > ~/Desktop/pool-pledge-report.csv
./scripts/fulfillment-report.sh --podman --env production --remote > ~/Desktop/pool-fulfillment-report.csv
```

El progreso se escribe en stderr, mientras que los datos CSV se escriben solo en stdout, por lo que las redirecciones de archivos se mantienen limpias.

**Formato de salida:** Una fila por entrada del historial (estilo libro mayor). Esto significa:
- Nuevas promesas: 1 fila (creada)
- Promesas modificadas: más de 2 filas (creadas + deltas de modificación)
- Promesas canceladas: 2 filas (creadas + canceladas con montos negativos)

**Columnas de salida:** correo electrónico, campaña, artículos, subtotal, porcentaje_propina, propina, impuestos, envío, total, estado, cobrado, creado_en, id_pedido

**Valores de estado:**
- `created`: creación de compromiso inicial (los elementos muestran la lista de niveles completa)
- `modified`: cambio de nivel/cantidad de compromiso (los elementos muestran diferencias: `+Added Tier`, `-Removed Tier`)
- `cancelled` — Compromiso cancelado (muestra montos negativos)
- `active` — Compromiso heredado sin historia
- `charged` — Promesa cargada heredada sin historia
- `failed` — Compromiso fallido heredado sin historia

**Formato de elementos de fila modificado:**
```
(modified) +Line of Dialogue; -Writer Credit x2; +Custom Support $5.00
```
- `+Tier` o `+Tier xN`: se agregó un nivel (o se aumentó la cantidad)
- `-Tier` o `-Tier xN`: se eliminó el nivel (o se redujo la cantidad)
- `+Custom Support $X` o `-Custom Support $X`: se agregó o eliminó soporte personalizado
- `; tip updated to N%`: la propina cambió durante la misma modificación, incluso si otros campos de contribución también cambiaron
- Los niveles sin cambios no aparecen en la diferencia

**Soporte personalizado en artículos:**
Cuando un compromiso incluye soporte personalizado, aparece como `Custom Support $X.XX` en la columna de elementos (por ejemplo, `Line of Dialogue; Custom Support $25.00`).

**Formato de fila cancelada:**
Las filas canceladas muestran importes negativos (subtotal, propina, impuestos, envío, total), de modo que la suma de todas las filas da el total correcto de la campaña. Los elementos tienen el prefijo `-` para indicar su eliminación.

**Asignación de nombres de niveles:**
El informe convierte los ID de nivel en nombres legibles por humanos (por ejemplo, `frame` → `One Frame`, `dialogue` → `Line of Dialogue`).

**La suma de subtotales** le brinda el monto del progreso de la campaña (las modificaciones y cancelaciones se reflejan como deltas). **La suma de los totales** proporciona el monto, incluida la propina, que realmente se cobrará.

## Informes de cumplimiento

Genere informes agregados que muestren el **estado actual** del compromiso de cada patrocinador (para fines de cumplimiento):

```bash
# All pledges, production KV
./scripts/fulfillment-report.sh

# Single campaign
./scripts/fulfillment-report.sh worst-movie-ever

# Dev/preview KV
./scripts/fulfillment-report.sh --env dev

# Save to file
./scripts/fulfillment-report.sh worst-movie-ever > fulfillment.csv
```

**Formato de salida:** Una fila por combinación única de correo electrónico + campaña. Se agregan varias promesas del mismo patrocinador.

**Columnas de salida:** correo electrónico, campaña, artículos, subtotal, porcentaje_propina, propina, impuestos, envío, total, dirección_envío

**Diferencias clave con promesa-report.sh:**
- Muestra **estado de nivel actual** (no el historial)
- **Agrega** múltiples compromisos por patrocinador en una fila
- **Excluye** promesas canceladas
- **Excluye** soporte personalizado (solo muestra artículos entregables)
- **No** columnas de estado, creada_en o id_pedido
- Los artículos muestran las cantidades finales (por ejemplo, si el patrocinador se modifica desde el cuadro → diálogo, solo aparece el diálogo)
- Incluye `shipping_address` para el cumplimiento del nivel físico
- `total` es el monto del cargo final, incluida la propina opcional de The Pool.

**Casos de uso:**
- Hojas de cálculo de cumplimiento (qué recompensas entregar a cada patrocinador)
- El patrocinador cuenta por nivel
- Seguimiento de entregables

## Ruta del navegador heredado

La sucursal ya no envía los antiguos recursos auxiliares del carrito alojado como archivos de navegador separados. La ruta del navegador ahora inicia solo el tiempo de ejecución del carrito propio.

**Limitaciones:**
- Los campos de la tarjeta de crédito (número, vencimiento, CVV) están en el iframe de Stripe; no se puede acceder a ellos por razones de seguridad.

## Arquitectura del trabajador

Cloudflare Worker (`worker/src/`) es el backend de The Pool:

```
worker/src/
├── index.js              # Route handlers (main entry point)
├── campaigns.js          # Fetch/validate campaigns from Jekyll API
├── checkout-intent.js    # Checkout snapshot hashing/signing helpers
├── checkout-intent-do.js # Durable Object nonce coordinator
├── tier-inventory-do.js  # Durable Object coordinator for scarce tier claims
├── email.js              # Resend email templates
├── launch-reminders.js   # Campaign-scoped reminder signup, unsubscribe, dispatch jobs
├── turnstile.js          # Shared Cloudflare Turnstile verification helper
├── github.js             # Trigger GitHub Pages rebuilds
├── provider-config.js    # Runtime/provider flags
├── stats.js              # KV-based stats + inventory cache, milestones
├── stripe.js             # Stripe API client + webhook signature verification
├── token.js              # HMAC magic link token generation/verification
└── routes/
    └── votes.js          # Community voting endpoints
```

### Puntos finales clave

|Punto final|Propósito|
|----------|---------|
|`POST /checkout-intent/start`|Cree la sesión de configuración de Stripe utilizada por el paso de pago en el sitio|
|`POST /webhooks/stripe`|Manejar eventos de Stripe, almacenar promesas, enviar correos electrónicos|
|`GET /pledge?token=...`|Obtenga detalles de la promesa para la página de administración|
|`POST /pledge/cancel`|Cancelar una contribución activa|
|`POST /pledge/modify`|Cambiar nivel/cantidad|
|`POST /launch-reminders`|Guarde un recordatorio de suscripción para una próxima campaña|
|`GET /launch-reminders/unsubscribe?t=...`|Suprimir un recordatorio de lanzamiento relacionado con la campaña|
|`GET /stats/:slug`|Totales de compromisos en vivo para una campaña|
|`POST /admin/settle/:slug`|Cargar manualmente todas las promesas financiadas|

### Activador cron (establecimiento automático)

El trabajador utiliza un activador programado a nivel de un minuto. Las tareas individuales verifican la zona horaria de la plataforma configurada y los marcadores de idempotencia antes de realizar un trabajo duradero:

```toml
# wrangler.toml
[triggers]
crons = ["* * * * *"]
```

**Qué hace:**
1. Drena los trabajos de envío de recordatorios de lanzamiento en cola en lotes locales
2. Enumera todas las campañas con `goal_deadline` y `goal_amount`.
3. Pone en cola el envío de un recordatorio de lanzamiento único cuando se activa una próxima campaña.
4. Para cada campaña en la que haya pasado la fecha límite en la zona horaria de la plataforma y se haya cumplido el objetivo:
   - Comprueba si hay promesas activas no cargadas
   - Si es así, ejecuta la misma lógica de liquidación que `/admin/settle/:slug`.
5. Agrega promesas por correo electrónico dentro de cada campaña para que cada partidario reciba UN cargo por campaña.
6. Envía correos electrónicos de pago exitoso/pago fallido según corresponda

**Nota sobre la zona horaria:** El programador se ejecuta cada minuto, pero el trabajo del ciclo de vida se limita a una pequeña ventana de medianoche en la zona horaria de la plataforma y se reclama una vez por fecha local. Los trabajos de envío de recordatorios de lanzamiento pueden agotarse en cualquier tic programado después de que se reclame la transición en vivo, y los reintentos de correo electrónico de apoyo aún se ejecutan cada 15 minutos dentro del mismo controlador programado.

### Módulo de fichas

```js
import { generateToken, verifyToken } from './token.js';

const token = await generateToken(env.MAGIC_LINK_SECRET, {
  orderId: 'pledge-123',
  email: 'backer@example.com',
  campaignSlug: 'hand-relations'
}, 90); // 90 days expiry

const payload = await verifyToken(env.MAGIC_LINK_SECRET, token);
// null if invalid/expired
```

## Seguridad

Los secretos viven en las variables de entorno de Cloudflare Worker. Nunca te comprometas:

|Secreto|Propósito|
|--------|---------|
|`STRIPE_SECRET_KEY`|API Stripe (o variantes `_TEST`/`_LIVE`)|
|`STRIPE_WEBHOOK_SECRET`|Verificar las firmas del webhook de Stripe|
|`CHECKOUT_INTENT_SECRET`|Firmar instantáneas de pago propias|
|`MAGIC_LINK_SECRET`|Firma HMAC para tokens de gestión de promesas|
|`RESEND_API_KEY`|Enviar correos electrónicos de apoyo/hito/fallidos|
|`ADMIN_SECRET`|Proteger los puntos finales de administración (liquidar, reconstruir, etc.)|

## Mejores prácticas de correo electrónico

### Alojamiento de imágenes

**Aloja siempre imágenes de correo electrónico en tu propio dominio** (por ejemplo, `site.example.com/assets/images/`). Las CDN de terceros activan los filtros de spam de Gmail y provocan que las imágenes se bloqueen con advertencias de "las imágenes a continuación son de remitentes desconocidos".

El ícono de CTA de Instagram está alojado en `/assets/images/instagram-white.png`.
En el desarrollo local, las plantillas de correo electrónico aún resuelven los recursos de imágenes incrustados en la base pública `https://site.example.com` en lugar de `127.0.0.1`, por lo que las vistas previas de la bandeja de entrada no se interrumpen en las URL de solo host local.

### SVG en línea

Gmail no muestra SVG en línea en los correos electrónicos. Utilice imágenes PNG/JPEG en su lugar.

## Patrones de interfaz de usuario móvil

### Menú de hamburguesa vs superposición de carrito

El menú de hamburguesas móvil para alternar necesita un manejo cuidadoso del índice z para evitar la superposición con el cajón del carrito/modal.

**Patrón**: solo aplique el índice z elevado cuando el menú esté realmente abierto:

```scss
// In _layout.scss
&__menu-toggle {
  @include xsm {
    position: relative;
    // No z-index here — cart overlay covers it naturally
  }
}

// Only elevate when menu is open
&__menu-toggle.is-open {
  z-index: 101; // Above nav overlay (z-index: 100)
}
```

**Por qué esto funciona:**
- Cuando el menú está cerrado: sin índice z, por lo que la superposición del carrito cubre el botón
- Cuando el menú está abierto: índice z: 101 coloca el botón encima de la superposición de navegación para el ícono X

**Archivos involucrados:**
- `assets/partials/_layout.scss` — Estilo del botón de hamburguesa
- `_includes/header.html`: el script de alternancia agrega la clase `.is-open`

---

## Preguntas frecuentes

**¿Por qué necesitamos un Trabajador si el sitio es estático?**
Los webhooks Stripe SetupIntents + requieren secretos del lado del servidor y un punto final HTTPS. El trabajador también almacena datos de compromiso en Cloudflare KV y envía correos electrónicos mediante Resend.

**¿Podemos saltarnos al Trabajador?**
No. El trabajador maneja las sesiones de pago de Stripe, el procesamiento de webhooks, el almacenamiento de promesas (KV), las estadísticas en vivo, el inventario de niveles, los correos electrónicos de hitos y la liquidación de campañas. Es el backend central.

**¿Dónde se almacenan los datos de las promesas?**
Cloudflare KV. Patrones clave:
- `pledge:{orderId}`: datos completos del compromiso (correo electrónico, monto, nivel, ID de Stripe, estado)
- `email:{email}`: conjunto de ID de pedido para ese correo electrónico
- `stats:{campaignSlug}` — Totales agregados (pledgedAmount, promesaCount, tierCounts)
- `tier-inventory:{campaignSlug}` — Recuento de reclamos de niveles para niveles limitados

**¿Qué papel juega el carrito del navegador?**
El carrito propio proporciona revisión de promesas y estado de transferencia de pago en el navegador. Los datos del compromiso final se almacenan en KV después de la confirmación del webhook de Stripe.

**¿Esto almacena PII?**
Las direcciones de correo electrónico se almacenan en KV para la gestión de promesas. Stripe almacena datos de tarjetas; almacenamos los ID de clientes/métodos de pago de Stripe.

**¿Cómo desbloquean los objetivos ambiciosos los niveles?**
Utilice `requires_threshold` en el nivel; la plantilla lo oculta hasta `pledged_amount >= threshold`.

**¿Qué pasa con las campañas de larga duración?**
Los Stripe SetupIntents (métodos de pago guardados) no caducan como las retenciones de tarjetas de 7 días, por eso los usamos.

**¿Cómo se cobran las campañas cuando se financian?**
El trabajador liquida automáticamente las campañas a través del controlador programado una vez por día local después de la medianoche en la zona horaria de la plataforma. Cuando transcurre el plazo de una campaña y ésta ha cumplido su objetivo, el Trabajador:
1. Agrega todas las promesas activas **por correo electrónico dentro de una campaña** (un cargo por partidario por campaña, no por fila de promesa)
2. Utiliza el método de pago actualizado más recientemente para cada partidario
3. Crea un Stripe PaymentIntent por partidario para el monto total de su campaña.
4. Envía un correo electrónico de cargo por seguidor para esa campaña.
5. Marca todas las promesas subyacentes como `charged`

Las promesas canceladas nunca se cobran. También puede activar la liquidación manualmente a través de `POST /admin/settle/:slug`.

**¿En qué zona horaria están las fechas límite?**
Todos los plazos utilizan la zona horaria configurada de la plataforma. Una campaña con `goal_deadline: 2025-12-20` finaliza a las 23:59:59 de esa fecha en `platform.timezone`. El valor predeterminado es `America/Denver`, por lo que las bifurcaciones existentes mantienen el comportamiento anterior hasta que un superadministrador cambia la zona horaria.

---

## Accesibilidad (a11 años)

El sitio incluye infraestructura de accesibilidad para el cumplimiento de WCAG 2.1 AA.

### Utilidades

**Texto sólo para lector de pantalla:**
```html
<span class="sr-only">Opens in new tab</span>
```

**Omitir enlace** (automático en `default.html`):
```html
<a href="#main-content" class="skip-link">Skip to main content</a>
```

**Indicador de carga accesible:**
```html
<div class="loading" role="status" aria-live="polite">
  <span class="sr-only">Loading...</span>
  <span class="loading__spinner" aria-hidden="true"></span>
</div>
```

### Puntos de referencia de ARIA

El diseño predeterminado incluye puntos de referencia adecuados:
- `<header role="banner">` - Encabezado del sitio
- `<main role="main" id="main-content">` - Contenido principal
- `<nav role="navigation" aria-label="...">` - Navegación
- `<footer role="contentinfo">` - Pie de página del sitio
- `<div aria-live="polite">` - Región en vivo para anuncios

### Estados de enfoque

Todos los elementos interactivos tienen estados `:focus-visible` visibles:
- Enlaces: contorno de 2px con desplazamiento
- Botones: contorno de 3px con sombra sutil
- Entradas de formulario: cambio de color del borde

### Mejores prácticas

**Botones:**
```html
<button type="button" aria-label="Close menu" aria-expanded="false">
  <svg aria-hidden="true">...</svg>
</button>
```

**Entradas de formulario:**
```html
<label for="amount" class="sr-only">Amount in dollars</label>
<input id="amount" type="number" aria-describedby="amount-help">
<p id="amount-help">Enter any amount from $1 to $10,000</p>
```

**Imágenes:**
```html
<!-- Decorative (hidden from screen readers) -->
<img src="logo.png" alt="" aria-hidden="true">

<!-- Informative -->
<img src="chart.png" alt="Funding progress: 75% of $25,000 goal">
```

**Iconos:**
```html
<!-- Icon-only button -->
<button aria-label="Add to cart">
  <svg aria-hidden="true" focusable="false">...</svg>
</button>

<!-- Icon with visible text (icon is decorative) -->
<button>
  <svg aria-hidden="true">...</svg>
  Add to cart
</button>
```

### Movimiento y contraste

- Se respeta `prefers-reduced-motion` (animaciones deshabilitadas)
- Se admite el modo `forced-colors` (alto contraste)
- Los estados deshabilitados tienen una opacidad de 0,6 (contraste suficiente)

### Incluir ayudante

Utilice `_includes/a11y.html` para patrones comunes:

```liquid
{% include a11y.html type="sr-text" text="Opens in new tab" %}
{% include a11y.html type="external-link" href="https://..." text="Documentation" %}
```

---

## Internacionalización (i18n)

El sitio ahora tiene una base local real a través de páginas públicas compartidas, flujos de seguidores y copia en tiempo de ejecución propiedad del sitio. El inglés sigue siendo la configuración regional predeterminada y el español es la primera configuración regional secundaria.

### Estructura

```
_data/
└── i18n/
    ├── en.yml     # English translations (default)
    └── es.yml     # Spanish seed locale
```

La configuración regional estructurada se encuentra en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml):

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
    manage:
      en: /manage/
      es: /es/manage/
    community_index:
      en: /community/
      es: /es/community/
```

### Uso

Utilice la inclusión `t.html` para buscar traducciones:

```liquid
{% include t.html key="buttons.pledge" %}
{% include t.html key="states.opens" date="Jan 15" %}
{% include t.html key="progress.of_goal" goal="$25,000" %}
{% include t.html key="buttons.view_campaign" lang="es" %}
```

El asistente admite la interpolación con marcadores de posición `%{variable}`:

```yaml
# In _data/i18n/en.yml
states:
  opens: "Opens %{date}"
```

Ahora también admite:

- Anulación de `lang=`
- recurrir a la configuración regional predeterminada cuando falta una clave en la configuración regional actual
- marcadores de claves faltantes en el tiempo de desarrollo en lugar de fallar silenciosamente

Utilice los ayudantes locales para el enrutamiento de páginas:

```liquid
{% include localized-url.html lang=page.lang translation_key="about" %}
{% include language-switcher.html position="footer" %}
```

Los mensajes en tiempo de ejecución para los flujos JS propiedad del sitio se emiten a través de [`assets/i18n.json`](https://github.com/your-org/your-project/blob/main/assets/i18n.json) y se inician en `POOL_CONFIG.i18n.messages`, por lo que los flujos de carrito, pago, comunidad de seguidores y Administrar compromiso pueden usar el mismo catálogo local sin una capa de traducción estilo SPA.

Las plantillas de campañas públicas ahora también obtienen más Chrome compartido de los mismos datos locales, incluido el texto de carga/reproducción de videos de héroes, texto de adelanto de la comunidad de seguidores, etiquetas de pestañas del diario y estados vacíos, etiquetas/CTA de la fase de producción y etiquetas de accesibilidad de la galería.

Los correos electrónicos de soporte de los trabajadores también consumen el catálogo de configuración regional compartido y el `preferredLang` persistente adjunto para pagar y administrar los flujos, por lo que los correos electrónicos de soporte localizados y los enlaces `/manage/` / `/community/:slug/` localizados permanecen alineados con el modelo de configuración regional del sitio.

El conmutador de idioma de pie de página compartido también conserva la cadena de consulta y el hash actuales, lo cual es importante para rutas tokenizadas como `/manage/?t=...` y enlaces de comunidad de seguidores.

Límite importante:

- un archivo YAML de configuración regional es la fuente principal para Chrome del sitio compartido, copia de la interfaz de usuario en tiempo de ejecución y copia del correo electrónico del asistente del trabajador.
- No es un cambio mágico de traducción de sitio completo por sí solo.
- Las páginas de formato largo y otras rutas con mucho contenido aún necesitan archivos fuente localizados cuando desea una copia de la página traducida real.

### Agregar un idioma

1. Agregue el nuevo código de idioma a `i18n.supported_langs`
2. Agregue su etiqueta de visualización a `i18n.language_labels`
3. Agregar rutas de páginas públicas localizadas a `i18n.pages`
4. Copiar `_data/i18n/en.yml` a `_data/i18n/{lang}.yml`
5. Traducir los valores compartidos de UI/sistema
6. Agregue páginas de origen localizadas bajo el prefijo local para contenido de formato largo como `/about/`, `/terms/`, `/manage/`, `/community/` o páginas de índice de la comunidad seleccionadas cuando sea necesario.

Regla general manual:

- Si el texto es cromo de interfaz de usuario compartido, texto de botón, texto de estado, copia de pago/administración/tiempo de ejecución de la comunidad o copia de correo electrónico de soporte del trabajador, normalmente debería residir en `_data/i18n/{lang}.yml`.
- Si el texto es contenido de una página real escrito en prosa, normalmente debería estar en una página fuente localizada.

### Categorías de traducción

- `nav` - Etiquetas de navegación
- `buttons`: texto del botón (promesa, cancelación, votación, etc.)
- `states`: estados de la campaña (activa, finalizada, próxima)
- `progress` - Etiquetas de progreso de financiación
- `pledge`: copia del flujo de compromiso
- `manage` - Administrar página de compromiso
- `status` - Etiquetas de estado
- `community` - Página de votación/comunidad
- `tiers`: etiquetas relacionadas con niveles
- `dates` - Formatos de fecha
- `misc` - Palabras comunes
- `home`: títulos de índice de campañas y etiquetas de cejas
- `campaign` / `diary` / `production_phases`: Chrome de página de campaña compartida y etiquetas de sección interactivas

---

## Pruebas

El proyecto utiliza un enfoque de prueba de dos niveles:

### Pruebas unitarias (Vitest)

Pruebas rápidas y aisladas para funciones JS. Ubicado en `tests/unit/`.

```bash
npm run test:unit          # Run once
npm run test:unit:watch    # Watch mode
npm run test:unit:coverage # With coverage report
```

**La cobertura de la prueba incluye:**
- `formatMoney()`: formato de moneda con sufijo k
- `updateProgressBar()`: ancho de la barra de progreso y actualizaciones de texto
- `updateMarkerState()` - Clases CSS de marcador de hitos/metas
- `checkTierUnlocks()`: desbloqueo de nivel cerrado cuando se alcanzan los umbrales
- `checkLateSupport()`: soporte tardío que permite la posfinanciación
- `updateSupportItems()`: progreso del elemento de soporte y estados "financiados"
- `updateTierInventory()`: visualización de inventario y estados "Agotado"
- Burla de recuperación de API: manejo de puntos finales de inventario y estadísticas

### Pruebas E2E (Dramaturgo)

Pruebas basadas en navegador para flujos de usuarios completos. Ubicado en `tests/e2e/`.

```bash
npm run test:e2e           # Full suite (starts Jekyll server)
npm run test:e2e:quick     # Headed mode (requires running server)
npm run test:e2e:headless  # CI mode
npm run test:e2e:ui        # Interactive UI mode
```

**La cobertura de la prueba incluye:**
- Botones de navegación y niveles de campaña
- Pestañas del panel de administración, visibilidad de configuración/campaña con alcance de función, comportamiento del editor de contenido, configuración de medios, cargas, análisis/informes/partidarios/vistas de marketing, menús responsivos para tabletas/móviles y cobertura de ruta en español
- Entrada de monto personalizado → sincronización del precio del carrito propio
- Entrada de artículos de soporte → sincronización de precios de carritos propios
- Estados deshabilitados en campañas no activas
- integración de tiempo de ejecución/carro propio

### Ejecutando todas las pruebas

```bash
npm test  # Runs unit tests, then E2E tests
```

### Agregar pruebas

**Pruebas unitarias:** Agregar a `tests/unit/` con la extensión `.test.ts`. Las pruebas deben ser rápidas (sin red, sin DOM real).

**Pruebas E2E:** Agregar a `tests/e2e/` con la extensión `.spec.ts`. Utilice `expect()` de Playwright para afirmaciones.

---

## Borrar datos de KV (depuración)

Al depurar flujos de promesas, es posible que necesite borrar los datos de Worker KV.

### KV local (desarrollador de Wrangler)

```bash
# Nuclear option - delete all local KV state
rm -rf worker/.wrangler/state/

# Or list/delete specific keys
cd worker
npx wrangler kv key list --binding PLEDGES --local
npx wrangler kv key delete --binding PLEDGES --local "pledge:example-key"
```

### Vista previa de KV (espacio de nombres de desarrollo remoto)

```bash
cd worker

# List all keys
npx wrangler kv key list --binding PLEDGES --preview

# Delete all preview pledges
npx wrangler kv key list --binding PLEDGES --preview | jq -r '.[].name' | while read key; do
  yes | npx wrangler kv key delete --binding PLEDGES --preview "$key"
done
```

### Fijaciones KV

|Vinculante|Propósito|
|---------|---------|
|`PLEDGES`|Registros de promesas, estadísticas y asignaciones de correo electrónico|
|`VOTES`|Datos de votación de la comunidad (codificados por correo electrónico para evitar el abuso de votos de promesas múltiples)|
|`RATELIMIT`|Contadores de limitación de velocidad|

**Vota las claves KV:**
- `vote:{campaignSlug}:{decisionId}:{email}` — Elección de voto del usuario
- `results:{campaignSlug}:{decisionId}` — Recuentos de votos agregados

## Arquitectura del asentamiento

El flujo de liquidación utiliza **invocaciones por lotes autoencadenadas** para mantenerse dentro del límite de 50 subsolicitudes de Cloudflare Worker:

1. **Programador** (`scheduled()`) solicita una ejecución diaria después de la medianoche en la zona horaria de la plataforma y luego envía el trabajo de liquidación
2. **Envío** lee el índice de promesas de campaña y procesa 6 promesas por lote a través de `/admin/settle-batch`
3. **Cada lote** es una invocación de trabajador separada con su propio presupuesto de solicitud secundaria
4. **Se autoencadena** hasta que se procesen todas las promesas, luego establece el marcador `campaign-charged:{slug}`

**Claves KV utilizadas por liquidación:**

|Llave|Propósito|
|-----|---------|
|`campaign-pledges:{slug}`|Matriz de ID de pedido por campaña (se mantiene al crear/cancelar)|

Ese índice sigue siendo la vía rápida preferida para informes, liquidaciones y lecturas administrativas, pero las estadísticas y el recálculo de inventario ahora lo tratan como un estado de proyección reparable en lugar de una verdad intocable. Si se desvía de los registros de compromiso activos subyacentes, la ruta de reconstrucción lo reescribe automáticamente.
|`settlement-job:{slug}`|Seguimiento del progreso del lote (cursor, totales)|
|`campaign-charged:{slug}`|Marcador de finalización de la liquidación (evita la reubicación)|
|`cron:lastRun`|Latido del programador cada hora: última marca de tiempo de ejecución cron persistente|
|`cron:lastError`|Detalles del último error cron (TTL de 7 días)|

**Comprobaciones de deriva de proyección:**

- `POST /stats/:slug/check` compara las proyecciones almacenadas de `campaign-pledges:{slug}`, `stats:{slug}` y `tier-inventory:{slug}` con la verdad del compromiso activo sin mutar nada.
- `POST /admin/projections/check` realiza la misma comparación en todas las campañas.
- `./scripts/check-projections.sh` es el contenedor local fácil de usar para esos cheques.

**Puntos finales de administración para la liquidación:**

|Punto final|Propósito|
|----------|---------|
|`POST /admin/settle-dispatch/:slug`|Iniciar/reanudar liquidación por lotes|
|`POST /admin/settle-batch`|Cobrar promesas específicas (máximo 6 por llamada)|
|`POST /admin/settle/:slug`|Liquidación monolítica heredada (puede alcanzar los límites de solicitudes secundarias)|
|`POST /admin/campaign-index/rebuild/:slug`|Reconstruir el índice de compromiso de campaña de KV|
|`POST /stats/:slug/check`|Comprobación de deriva de proyección de solo lectura para una campaña|
|`POST /admin/projections/check`|Comprobación de deriva de proyección de solo lectura para todas las campañas|
|`POST /admin/backfill-customers/:slug`|Crear clientes de Stripe para las promesas que les faltan|
|`POST /admin/analytics/stripe-financials/backfill`|Rellene la tarifa de transacción/valores netos del saldo real de Stripe para las promesas cobradas utilizando índices de promesas de campaña|
|`GET /admin/cron/status`|Comprobar el latido del cron|

**Comprobando el estado del cron:**
```bash
curl -s https://worker.example.com/admin/cron/status \
  -H 'Authorization: Bearer YOUR_ADMIN_SECRET'
```

---
