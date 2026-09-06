---
title: Modelo de contenido de campañas
parent: Desarrollo
nav_order: 3
render_with_liquid: false
lang: es
---

# Modelo de contenido de campañas

## Última actualización

6 de septiembre de 2026

Utilice esta referencia cuando cambie el Markdown de la campaña, la validación del esquema o el editor de la campaña. La creación de rutina pertenece al [dashboard](/es/docs/operations/admin-dashboard/); los creadores pueden utilizar la [lista de verificación de lanzamiento](https://github.com/aindaco1/pool/blob/main/creator-campaign-checklist.md). Conserve los ID de campaña, nivel, producto, variante, diario y decisión existentes. La fuente del repositorio y la validación de Worker siguen siendo autorizadas.

## Campos de campaña

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
- Entre fechas → `live` (se aceptan aportes)
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
- Los valores reflejan el tiempo de construcción; El JavaScript del navegador los actualiza cuando se carga la página.

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
- `carousel`: desplazamiento horizontal con ajuste, relación de aspecto 16:9

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

### Complementos

Los productos de plataforma se encuentran bajo `add_ons` en `_config.yml`; Los productos de la campaña se encuentran bajo `campaign_add_ons` en el frente de la campaña. Comparten el editor de productos y el modelo de variante, pero solo los complementos de la campaña cuentan para el progreso de la misma. Consulte [Productos complementarios](/es/docs/development/add-on-products/) para conocer el esquema, los precios históricos, el inventario, la contabilidad y los límites de envío.

### Artículos de soporte y soporte personalizado

`support_items` representa las necesidades de campaña detalladas y utiliza campos estables `id`, `label`, `need` y dólares `target`. Los artículos físicos también especifican `category` y los mismos campos de paquete preestablecidos o explícitos de envío como niveles. Por ejemplo:

```yaml
support_items:
  - id: snack-run
    label: Snack Run
    need: coffee and meals
    target: 250
    late_support: true
```

Los ID de artículos del carrito utilizan `{campaignSlug}__support__{itemId}`. El soporte personalizado es una entrada independiente del navegador que se conserva como `customAmount`; No es un segundo catálogo de productos. Después de la fecha límite, las campañas financiadas exponen solo elementos elegibles con soporte tardío, con `late_support` en elementos/niveles y `custom_late_support` controlando el soporte personalizado. Estas banderas no dan vida a una campaña finalizada sin éxito.

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

### Decisiones comunitarias (solo para patrocinadores)

```yaml
decisions:
  - id: poster
    type: vote              # vote | poll
    title: Official Poster
    options: [A, B]
    eligible: backers       # Submissions remain supporter-only
    status: open            # open | closed
```

`vote` y `poll` utilizan la misma mecánica de envío y conteo solo para patrocinadores. Utilice `vote` cuando el resultado decida un resultado y `poll` para comentarios de asesoramiento o recopilación de preferencias. La distinción es semántica y visual; cualquier posible divergencia pertenece al [Roadmap](/es/docs/reference/roadmap/).

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

**Difusiones por correo electrónico:** Cuando se agregan e implementan entradas del diario, la acción de GitHub activa `/admin/diary/check`, que envía correos electrónicos de actualización a todos los patrocinadores de la campaña. La verificación automática envía sólo las entradas que no se han difundido antes. Las entradas del diario utilizan valores `id` estables para el seguimiento de transmisiones; el panel conserva las identificaciones existentes y el trabajador deriva las identificaciones basadas en títulos para las entradas recién agregadas. Los marcadores de fechas heredados aún se reconocen, por lo que las ediciones de entradas más antiguas no se reenvían. El extracto del correo electrónico se extrae automáticamente de los bloques de texto (primeros 200 caracteres, sin rebajas).

Consulte [Email](/es/docs/operations/email-system/) para la entrega y supresión de transmisiones, y [Deployment](/es/docs/operations/deployment/#comprobación-del-diario-posterior-a-la-implementación) para obtener credenciales de acción/Worker coincidentes y solución de problemas de reglas perimetrales.

### Financiamiento continuo (posterior a la campaña)

```yaml
ongoing_items:
  - label: Color Grade
    remaining: 4500
  - label: Sound Mix
    remaining: 6000
```

Los ejemplos de creación utilizan cantidades en dólares. Los montos en centavos persistentes y los límites de precios del catálogo de Worker siguen a [Procesador de pagos](/es/docs/operations/payment-processor/) y [Productos complementarios](/es/docs/development/add-on-products/); no aplique una regla del dólar entero a los precios de las variantes.

### Niveles apilables versus no apilables

Los niveles se pueden marcar como `stackable: false` para evitar ajustes de cantidad en el carrito.

Cómo funciona:
1. Los botones de compra transportan los metadatos del nivel/carrito a través de ganchos `poolcart-*` e ID de artículos como `{campaignSlug}__{tierId}`.
2. El proveedor propio fusiona adiciones repetidas solo para niveles apilables.
3. La aplicación no apilable ocurre en el estado del carrito propio, no a través de parches DOM del carrito alojado.

Archivos involucrados:
- `_includes/tier-card.html`
- `_includes/campaign-card.html`
- `_includes/support-items.html`
- `_includes/ongoing-funding.html`
- `_includes/production-phases.html`
