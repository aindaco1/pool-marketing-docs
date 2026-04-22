---
title: Productos complementarios
parent: Desarrollo
nav_order: 8
render_with_liquid: false
lang: es
---

# Productos complementarios

Este documento describe el sistema de producto complementario actual tal como se envía actualmente.

La plataforma admite dos ámbitos complementarios que comparten intencionalmente la misma experiencia de usuario de la tarjeta y al mismo tiempo se comportan de manera diferente en contabilidad, envío y cumplimiento:

- **Complementos de plataforma** se encuentran en el catálogo global en `add_ons` en [/_config.yml](https://github.com/your-org/your-project/blob/main/_config.yml)
- **Complementos de campaña** disponibles en el frente de la campaña en `campaign_add_ons`

Ambos alcances:

- use el mismo carrito y administre la interfaz de usuario de la tarjeta de compromiso
- Admite artículos de precio fijo y variantes simples.
- participar en totales canónicos, persistencia y seguimiento de inventario del lado de los trabajadores
- obtener escasez del estado de compromiso guardado en lugar de giros de carrito no guardados

La diferencia importante es la intención:

- Los complementos de la plataforma son productos de la plataforma y **no** cuentan para la financiación de la campaña.
- Los complementos de la campaña son productos propiedad de la campaña y **sí** cuentan para el subtotal de propiedad de la campaña/progreso de financiación.

## Principios

- Mantenga el catálogo orientado hacia la horquilla y primero variable.
- Admite productos de precio fijo y variantes simples como tallas de camisa.
- reutilizar las bases existentes de carritos, envíos, informes y cumplimiento cuando sea posible
- Evite forzar la compra al modelo anterior de artículos de soporte basado en cantidades cuando un artículo de catálogo de precio fijo es más adecuado.

## Modelo de alcance

### 1. Complementos de plataforma

Los complementos de la plataforma se configuran globalmente y están destinados a brindar soporte al operador del sitio.

Ellos:

- renderizar en la sección normal `Add-ons`
- Admite carritos de campañas múltiples.
- **no** cuentan para ningún objetivo de financiación de campaña
- se entregan como productos de plataforma en lugar de productos de campaña.
- use un envío de plataforma combinado cuando haya complementos físicos globales en el carrito

### 2. Complementos de campaña

Los complementos de campaña se definen en una campaña específica y deben comportarse como productos propiedad de la campaña con la misma interfaz de usuario que los complementos de la plataforma.

Ellos:

- renderizar en una sección separada `Campaign Add-ons` en el carrito y Administrar compromiso
- Sólo aparece cuando la campaña propietaria está presente.
- se eliminan automáticamente si el compromiso de campaña propietario abandona el carrito
- cuenta para el subtotal de propiedad de la campaña/progreso de financiación
- seguir las reglas y anulaciones de envío de la campaña propietaria
- permanecer asociado con la campaña en la generación de informes y cumplimiento

## Superficie del catálogo actual

Los productos complementarios globales se encuentran en [/_config.yml](https://github.com/your-org/your-project/blob/main/_config.yml) bajo `add_ons`.

Claves de nivel superior actuales:

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

Los complementos de campaña utilizan la misma forma de producto, pero se encuentran en el frente de la campaña:

```yml
campaign_add_ons:
  - id: smoke-editable__first-time-sexpot-poster
    name: "First Time Sexpot Poster"
    description: "18” x 24” First Time Sexpot poster."
    image_url: /assets/images/campaign-add-ons/sexpot-poster.png
    price: 35.00
    category: physical
    inventory: 10
```

Complementos físicos versus digitales:

- `category: digital` significa que el complemento nunca afecta el envío
- `category: physical` significa que el complemento participa en la misma calculadora de envío del lado del trabajador que los niveles físicos y los artículos de soporte físico.
- para complementos físicos, las bifurcaciones pueden:
  - hacer referencia a un `shipping_preset` compartido como `tshirt` o `sticker`
  - o proporcionar metadatos `shipping` explícitos en línea

Ejemplo de metadatos de envío explícitos:

```yml
add_ons:
  products:
    - id: enamel-pin
      name: "Enamel Pin"
      price: 12.00
      category: physical
      shipping:
        weight_oz: 2
        packaging_weight_oz: 0.5
        length_in: 2
        width_in: 2
        height_in: 0.5
        stack_height_in: 0.2
```

## Importación inicial de mercancías

El catálogo actual de la primera generación se muestra como un ejemplo de importación de productos desde [shop.example.com](https://shop.example.com/):

- `DUST WAVE T-Shirt` — `$25`, variantes de tamaño `XS` a `3XL`
- `DUST WAVE Sticker` — `$3`, sin variantes
- `DUST WAVE Butterfingers T-Shirt` — `$25`, variantes de tamaño `XS` a `3XL`
- `First Time Sexpot Condom Pack` — complemento de campaña en `smoke-editable`
- `First Time Sexpot Poster` — complemento de campaña en `smoke-editable`

Los primeros tres son complementos de plataforma global. Los dos últimos son complementos de campaña en Smoke Editable y se tratan como productos de campaña, no productos de plataforma.

Valores predeterminados del inventario actual:

- cada diseño de camiseta comienza con `15` unidades totales distribuidas en tallas
- Las pegatinas comienzan con `50`.
- el umbral de existencias bajas está predeterminado en `5` y está orientado hacia la bifurcación en la configuración

## Inventario y escasez

El flujo de complementos actual tiene en cuenta intencionalmente el inventario:

- El inventario puede vivir en el producto en sí o en cada variante.
- Los complementos globales leen el inventario de `add_ons`.
- complementos de campaña leer inventario de `campaign_add_ons`
- el Trabajador expone una instantánea del inventario actual en [/add-ons/inventory](https://github.com/your-org/your-project/blob/main/worker/src/index.js)
- carrito y Administrar compromiso consumen el mismo asistente compartido de estado del producto que reconoce el inventario
- Aparece un mensaje de stock bajo cuando la cantidad restante es igual o inferior a `low_stock_threshold`
- Las variantes agotadas se eliminan de la superficie compartida del estado del producto a menos que ya estén seleccionadas en un compromiso existente.
- El inventario adicional se cuenta a partir de los registros de promesas persistentes, no de los borradores del carrito en progreso.

## Modelo de interfaz de usuario

El modelo de interfaz de usuario actual es intencionalmente simple y compartido:

- una tarjeta por producto, no una tarjeta por variante
- cada tarjeta puede mostrar:
  - imagen
  - título
  - descripción
  - selector de variación cuando existen variantes
  - entrada de cantidad
  - acción de agregar/eliminar con un solo clic
- el carrito y Manage Pledge utilizan las mismas reglas de normalización del estado del producto
- la sección `Add-ons` de la plataforma les dice explícitamente a los seguidores que el merchandising apoya al administrador de la plataforma y no aumenta los totales de financiación de la campaña.
- la sección `Campaign Add-ons` usa las mismas tarjetas sin esa nota de soporte de plataforma
- en los carritos de campañas múltiples hay una sección combinada `Campaign Add-ons`, incluso cuando más de una campaña aporta complementos de campaña

## Modelo de envío

Los productos complementarios reutilizan el mismo modelo de envío que los niveles físicos y los artículos de soporte físico.

Ajustes preestablecidos actuales relevantes para la primera ola:

- `tshirt`
- `sticker`

Eso significa:

- Los complementos físicos preestablecidos pueden heredar las dimensiones de envío de `shipping.presets`.
- Los complementos físicos modelados explícitamente pueden definir `shipping.weight_oz`, `shipping.packaging_weight_oz`, `shipping.length_in`, `shipping.width_in`, `shipping.height_in` y `shipping.stack_height_in`.
- los complementos digitales quedan completamente fuera de los totales de envío

La división de envío actual es:

- **complementos de campaña** siguen las reglas de envío y anulaciones de la campaña propietaria
- **los complementos de la plataforma física** no heredan el envío de la campaña; se combinan en un envío de plataforma separado y un cargo de envío de plataforma separado
- **los complementos de la plataforma digital** no afectan el envío

## Contrato de tiempo de ejecución

El catálogo actual está expuesto a la configuración del tiempo de ejecución del navegador a través de [assets/js/pool-config.js](https://github.com/your-org/your-project/blob/main/assets/js/pool-config.js) y el inicio del tiempo de ejecución compartido incluye [/_includes/cart-runtime-foot.html](https://github.com/your-org/your-project/blob/main/_includes/cart-runtime-foot.html).

Eso significa que la interfaz de usuario del lado del carrito y de Manage Pledge puede leer una fuente de verdad estable `POOL_CONFIG.addOns` en lugar de duplicar los datos del producto en múltiples plantillas o scripts.

El trabajador ahora también tiene una fuente de catálogo estática coincidente en [/api/add-ons.json](https://github.com/your-org/your-project/blob/main/api/add-ons.json), y los manifiestos de pago pendientes pueden contener:

- `bundleAddOns`
- `bundleAddOnAnchorCampaignSlug`
- `bundleAddOnTotals`

Los complementos también persisten en el propio registro de compromiso, por lo que:

- El subtotal canónico y las matemáticas de envío los incluyen.
- los correos electrónicos de los seguidores pueden renderizarlos
- Manage Pledge puede agregarlos o restarlos más tarde
- Los informes de compromiso y cumplimiento pueden separar el valor del compromiso de la campaña del valor del merchandising de la plataforma cuando sea necesario.

Comportamiento contable actual:

- Los complementos de la plataforma **no** cuentan para la campaña `goalTrackingSubtotal`
- los complementos de campaña **sí** cuentan para la campaña `goalTrackingSubtotal`

## ¿Por qué no utilizar elementos de soporte?

Los elementos de apoyo a la campaña son actualmente:

- ámbito de campaña
- basado en cantidad
- optimizado para financiar grupos en lugar de catálogos de productos de precio fijo

Esto funciona bien para extras monetarios específicos de la campaña, pero no es una buena opción a largo plazo para:

- merchandising en toda la plataforma
- artículos de catálogo de precio fijo
- variantes estructuradas como tallas de camisa
- Mercancía propiedad de la campaña que debe compartir la misma interfaz de usuario de tarjeta de producto que la mercancía de la plataforma.

El catálogo de productos complementarios está destinado a ubicarse junto a ese sistema, no a reemplazarlo.

## Informes y cumplimiento

Los informes ahora distinguen intencionalmente entre complementos de plataforma y campaña.

En `pledge-report`:

- los complementos de campaña cuentan para `campaign_subtotal`
- los complementos de la plataforma permanecen separados como `platform_add_on_subtotal`

En `fulfillment-report`:

- Los complementos de la plataforma son gestionados por el operador de la plataforma (`site.author`)
- Los complementos de la campaña permanecen adjuntos a la campaña y la utilizan como cumplimiento.

Esto mantiene clara la propiedad operativa sin cambiar la interfaz de usuario del complemento orientada a los seguidores.
