---
title: Envíos
parent: Operaciones
nav_order: 7
render_with_liquid: false
lang: es
---

# Envíos

Este documento describe el modelo de envío actual en The Pool, incluido su flujo de precios centrado en el trabajador, la superficie de configuración orientada a la fork, el límite de integración de USPS y el árbol de reglas que ahora siguen el carrito, el pago, la gestión de promesas, los informes y los correos electrónicos.

La verificación en vivo de credenciales de USPS ahora está conectada al flujo de trabajo local. El repositorio incluye un asistente de humo de USPS dedicado además de regresiones automatizadas para los flujos de envío del carrito, el pago y la gestión de compromisos.

## Alcance recomendado

Alcance implementado actualmente:

- Clasificación en vivo de USPS para **nacionales de EE. UU.**
- Clasificación en vivo de USPS para **internacional**
- una **tarifa de envío alternativa fija** configurable cuando USPS no está disponible o no devuelve una tarifa utilizable
- un selector **opción de entrega** limitado orientado al respaldo para `Standard`, `Signature required` y `Adult signature required`, cuando corresponda
- tablas manuales explícitas de tarifas fijas nacionales para artículos calificados como `sticker` y `signed_script`
- metadatos de envío de elementos de soporte y de nivel de campaña
- un catálogo preestablecido compartido para artículos físicos comunes

Para The Pool, la tarifa alternativa es **$3,00**.

## Barandillas

### Seguridad

La calculadora de envíos debe cumplir con el modelo de seguridad vigente:

- los totales de envío permanecen calculados por el trabajador y canónicos
- el navegador nunca se convierte en la fuente de verdad para las matemáticas de envío
- Las entradas de destino/envío se validan y normalizan antes de cotizar.
- sin llamadas directas inseguras del navegador a USPS
- no hay almacenamiento de larga duración para el cliente del estado de cotización de envío sensible más allá de lo que el flujo de pago actual ya necesita
- Las fallas de USPS deben degradarse a la tasa de respaldo configurada en lugar de crear una derivación insegura o un estado de pago roto
- Cualquier respuesta nueva de los trabajadores que contenga información interna sobre cotizaciones de envío debe seguir la postura actual de respuesta privada o sin tienda, cuando corresponda.

### Accesibilidad

La función de envío debe preservar la línea base de accesibilidad actual:

- La dirección relacionada con el envío, la cotización y los estados alternativos deben ser comprensibles mediante la interacción únicamente con el teclado.
- Cualquier nuevo error o aviso debe vincularse a los campos relevantes y a las regiones en vivo de manera adecuada.
- Las actualizaciones del resumen de envío en el proceso de pago y en Administrar compromiso deben seguir siendo comprensibles para el lector de pantalla.
- no hay regresiones a la semántica de diálogo/enfoque/error existente en checkout o `Update Card`
- La cobertura de accesibilidad a nivel del navegador debe ampliarse si se introducen nuevos estados de la interfaz de usuario de envío.

### Internacionalización

La característica de envío debe ajustarse al modelo i18n actual:

- Las etiquetas de envío propiedad del sitio, los mensajes alternativos y el texto de resumen deben provenir de catálogos locales.
- Los correos electrónicos de apoyo a los trabajadores deben utilizar etiquetas/desgloses de envío localizados donde ya incluyan los totales de envío.
- no se debe introducir ninguna copia codificada únicamente en inglés en el proceso de pago, en la gestión de compromisos, en las páginas de resultados o en los correos electrónicos.
- la característica debería funcionar correctamente en rutas localizadas como `/es/manage/` y rutas de entrada de pago localizadas

## Por qué encaja este alcance

### riesgo de USPS

Las API de precios de USPS parecen utilizables sin una facturación obvia por llamada para el acceso a precios básicos, pero tienen una cuota limitada y pueden requerir solicitudes manuales de aumento de cuota.

Eso significa que el principal riesgo operativo es:

- cuota / limitación

no obviamente:

- cargos directos de USPS por solicitud

### riesgo KV

El flujo de pago actual ya utiliza Trabajador/KV para:

- manifiestos del paquete de pago
- persistencia del compromiso
- actualizaciones de estadísticas
- reservas de nivel limitado

El envío no debería agregar una huella KV nueva y grande. El diseño seguro es:

- cotizar el envío solo en puntos de alta intención
- Evite escrituras KV por cotización
- persistir solo el monto de envío final en el compromiso

## Diseño de alto nivel

### 1. Envío calculado por el trabajador

El envío debe ser calculado por el servidor, no por el navegador.

Eso significa:

- `/checkout-intent/start` calcula el envío a partir de los datos canónicos del artículo más el destino
- `/pledge/modify` recalcula el envío solo cuando cambian las entradas relevantes para el envío
- El monto final del envío se almacena en el registro de compromiso y se incluye en todos los cálculos posteriores.

### 2. Comportamiento alternativo

Si USPS no está disponible, caduca o no devuelve una tarifa utilizable:

- utilice la tarifa fija de envío alternativa configurada

Para The Pool:

- `shipping.fallback_flat_rate: 3.00`
- anulaciones opcionales de `shipping_fallback_flat_rate` a nivel de campaña para casos especiales

Esto mantiene la resiliencia del proceso de pago y evita que el envío se convierta en un obstáculo importante.

### 3. Selección de servicio

Mantenga la opción establecida intencionalmente limitada:

- `Standard`
  - predeterminado
  - elige el servicio USPS elegible más barato
- `Signature required`
  - opcional
  - solo nacional
  - Sólo se muestra cuando la campaña lo habilita.
- `Adult signature required`
  - opcional
  - solo nacional
  - Solo se muestra cuando la campaña lo habilita explícitamente.

No exponga opciones de servicios basados ​​en la velocidad en v1. Las recompensas de crowdfunding a menudo se envían mucho después de la fecha de compromiso, por lo que la velocidad de entrega no es la opción más importante para el cliente en este caso; la confirmación de entrega es.

Por lo tanto, el carrito actual y la interfaz de usuario de Manage Pledge exponen un selector de opciones de entrega limitado en lugar de un selector de clase de correo completo. El Trabajador aún elige la clase de envío válida subyacente más barata para `Standard`.

## Superficie de configuración

Agregue una sección estructurada `shipping` a [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml), por ejemplo:

```yml
shipping:
  origin_zip: "87120"
  origin_country: "US"
  fallback_flat_rate: 3.00
  default_option: standard
  quote_timeout_ms: 2500
  presets:
    sticker:
      weight_oz: 1
      packaging_weight_oz: 0.5
      length_in: 11.5
      width_in: 6.125
      height_in: 0.2
      stack_height_in: 0.05
      manual_domestic_rate: FIRST_CLASS_FLAT
      usps_domestic:
        processing_category: NON_MACHINABLE
        rate_indicator: SP
        mail_classes:
          - USPS_GROUND_ADVANTAGE
          - PRIORITY_MAIL
    tshirt:
      weight_oz: 6.5
      packaging_weight_oz: 1
      length_in: 12
      width_in: 10
      height_in: 1.5
      stack_height_in: 0.5
    poster:
      weight_oz: 5
      packaging_weight_oz: 3
      length_in: 18
      width_in: 3
      height_in: 3
      stack_height_in: 0.5
    cd:
      weight_oz: 4
      packaging_weight_oz: 2
      length_in: 6.25
      width_in: 6.25
      height_in: 1
      stack_height_in: 0.25
      usps_domestic:
        processing_category: MACHINABLE
        rate_indicator: SP
        mail_classes:
          - MEDIA_MAIL
          - USPS_GROUND_ADVANTAGE
          - PRIORITY_MAIL
    vinyl:
      weight_oz: 18
      length_in: 13
      width_in: 13
      height_in: 1
    dvd:
      weight_oz: 4
      packaging_weight_oz: 2
      length_in: 8
      width_in: 6
      height_in: 1
      stack_height_in: 0.2
      usps_domestic:
        processing_category: MACHINABLE
        rate_indicator: SP
        mail_classes:
          - MEDIA_MAIL
          - USPS_GROUND_ADVANTAGE
          - PRIORITY_MAIL
    bluray:
      weight_oz: 4
      packaging_weight_oz: 2
      length_in: 7.25
      width_in: 5.75
      height_in: 0.9
      stack_height_in: 0.2
      usps_domestic:
        processing_category: MACHINABLE
        rate_indicator: SP
        mail_classes:
          - MEDIA_MAIL
          - USPS_GROUND_ADVANTAGE
          - PRIORITY_MAIL
    signed_script:
      weight_oz: 7
      packaging_weight_oz: 1
      length_in: 11.5
      width_in: 8.5
      height_in: 0.5
      stack_height_in: 0.1
      manual_domestic_rate: FIRST_CLASS_FLAT
      usps_domestic:
        processing_category: NON_MACHINABLE
        rate_indicator: SP
        mail_classes:
          - MEDIA_MAIL
          - USPS_GROUND_ADVANTAGE
          - PRIORITY_MAIL
```

Esa configuración debe permanecer controlada por el sitio y reflejar automáticamente cualquier valor requerido por el trabajador en [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml).

Las sugerencias de envío opcionales de nivel preestablecido también pueden incluirse dentro de los metadatos preestablecidos. La implementación actual admite:

- `manual_domestic_rate`
- `usps_domestic.processing_category`
- `usps_domestic.rate_indicator`
- `usps_domestic.destination_entry_facility_type`
- `usps_domestic.price_type`
- `usps_domestic.mail_classes`

Actualmente, `manual_domestic_rate` es solo nacional y admite `FIRST_CLASS_FLAT`, utilizando el precio minorista de sobres grandes (planos) de correo de primera clase para minoristas del Aviso 123 de USPS. Sólo se aplica cuando todo el envío todavía califica para correo plano por peso y dimensiones; de lo contrario, el sistema pasa a la ruta USPS en vivo.

Las sugerencias específicas de USPS solo se aplican cuando todo el envío físico se corresponde con el mismo perfil de USPS de estilo preestablecido; Los envíos mixtos recurren al modelo de cotización de paquetes predeterminado.

Eso significa que puede codificar un orden conservador de “clase válida más barata primero” por ajuste preestablecido sin intentar inferirlo sobre la marcha únicamente a partir de dimensiones sin procesar. El sitio actual utiliza ese patrón en dos lugares:

- `sticker`
  - utiliza la tarifa nacional manual `FIRST_CLASS_FLAT` cuando el envío aún califica
  - de lo contrario, se pasa a un perfil de paquete USPS de una sola pieza más económico
- `signed_script`
  - utiliza la tarifa nacional manual `FIRST_CLASS_FLAT` cuando el envío aún califica
  - de lo contrario, pasa a `MEDIA_MAIL`, luego a `USPS_GROUND_ADVANTAGE` y luego a `PRIORITY_MAIL`.
- `cd`, `dvd` y `bluray`
  - prueba `MEDIA_MAIL` primero
  - luego pasa a `USPS_GROUND_ADVANTAGE`
  - luego `PRIORITY_MAIL`

Intencionalmente no aplicamos automáticamente la verdadera lógica de "letra" o "plana". La ruta API de precios de USPS actual que utilizamos no expone directamente la calificación plana o de cartas de primera clase nacionales, por lo que los precios de correo plano se manejan como una tabla manual explícita, no como una cotización de USPS en vivo.

## Cambios en el modelo de contenido

### Niveles

Agregue metadatos de envío opcionales a los niveles físicos:

```yml
tiers:
  - id: tshirt
    category: physical
    shipping_preset: tshirt
```

O anulaciones explícitas:

```yml
tiers:
  - id: deluxe-box
    category: physical
    shipping:
      weight_oz: 32
      packaging_weight_oz: 4
      length_in: 12
      width_in: 10
      height_in: 4
      stack_height_in: 1
```

### Artículos de soporte

Permitir los mismos metadatos de envío en artículos de soporte físico si admitimos complementos físicos allí.

## Estrategia de embalaje

No cree una cartonización completa en v1.

Utilice una heurística más simple:

- sumar los pesos de los artículos entre artículos físicos y cantidades
- agregar cualquier asignación única `packaging_weight_oz` de los perfiles de nivel/elemento de soporte seleccionados
- utilice el `length_in` / `width_in` seleccionado más grande
- use `height_in + stack_height_in * (qty - 1)` para niveles físicos de múltiples cantidades
- pasar el paquete resultante a la calificación de USPS

Esto es aproximado, pero mucho más realista que la tarifa fija actual y mucho menor que construir un motor de embalaje real.

## Estrategia de uso de USPS

### Instrucciones para las credenciales de USPS

Para esta plataforma, **no** necesitas las API de etiquetas para cotizar el envío. La implementación de envío actual dThe Pool solo necesita:

- OAuth
- Precios nacionales
- Precios internacionales
- Opciones de envío

Estos son parte del producto de aplicación predeterminado de USPS que se describe en el flujo de introducción oficial de USPS.

A partir del 14 de abril de 2026, la ruta práctica de configuración es:

1. Cree o inicie sesión en una cuenta comercial de USPS a través del Portal de incorporación de clientes (COP) de USPS.
2. En COP, abra `My Apps` y cree una aplicación.
3. En la sección `Credentials` de esa aplicación, copie lo:
   - `Consumer Key`
   - `Consumer Secret`
4. Úselos como credenciales de cliente OAuth:
   - `Consumer Key` -> `client_id`
   - `Consumer Secret` -> `client_secret`

En este repositorio, eso se asigna a:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
  - `shipping.usps.client_id`
  - `shipping.usps.enabled`
  - opcional `shipping.usps.api_base` si necesita apuntar explícitamente a TEM
  - Perillas de comportamiento USPS opcionales como `timeout_ms`, `quote_cache_ttl_seconds` y configuraciones de enfriamiento
- Secretos del trabajador/entorno del trabajador local
  - `USPS_CLIENT_SECRET`
  - opcional `USPS_API_BASE`

**No** confirme el secreto del cliente USPS en la configuración de Jekyll.

Para una configuración local de estilo de producción normal, los valores mínimos que necesita este repositorio son:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) o [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml)
  - `shipping.usps.enabled: true`
  - `shipping.usps.client_id: "<your Consumer Key>"`
- [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars)
  - `USPS_CLIENT_SECRET=<your Consumer Secret>`

Si desea realizar pruebas con USPS TEM con las mismas credenciales de producción que describe USPS, configure también:

- `shipping.usps.api_base: "https://apis-tem.usps.com"` en configuración
o
- `USPS_API_BASE=https://apis-tem.usps.com` en entorno de trabajador

Para pruebas locales:

- configure `shipping.usps.client_id` en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) o su ruta de anulación local
- establezca `USPS_CLIENT_SECRET=...` en [`worker/.dev.vars`](https://github.com/your-org/your-project/blob/main/worker/.dev.vars)
- ejecutar:

```bash
npm run sync:worker-config
./scripts/dev.sh --podman
```

Para una verificación rápida de la credencial de USPS y de la cotización en vivo sin iniciar toda la pila, ejecute:

```bash
npm run test:usps
```

Ese ayudante ejercita el módulo de envío de trabajadores real contra una pequeña matriz de humo:

- nivel físico nacional
- opción nacional con firma requerida
- nivel físico internacional
- envío solo del complemento de la campaña
- Envío solo de complemento de plataforma

USPS también dice que puede realizar pruebas con sus credenciales de producción en el entorno de prueba para anuncios publicitarios cambiando la URL base de `apis.usps.com` a `apis-tem.usps.com`.

El producto de aplicación USPS predeterminado actualmente incluye las API que necesita esta función:

- OAuth
- Precios nacionales
- Precios internacionales
- Opciones de envío

Si necesita acceso adicional o un aumento de cuota, USPS indica a los desarrolladores que envíen una solicitud de servicio a través de su flujo de soporte `Email Us`.

Lo que puedes ignorar con seguridad para este repositorio ahora mismo:

- API de etiquetas
- Inscripción de barco/EPA
- cualquier configuración de etiqueta de devolución o franqueo de compra

Estos solo son necesarios si este proyecto pasa de cotizar a generar etiquetas USPS reales.

Nota operativa práctica para esta plataforma:

- USPS documenta `429` como una condición de cuota por hora excedida
- Por lo tanto, esta implementación de envío utiliza:
  - Llamadas de USPS solo para trabajadores
  - reutilización de cotizaciones cortas en memoria
  - tiempos de reutilización temporales después de `429`, tiempo de espera o fallas repetidas de USPS
  - envío alternativo fijo cuando USPS no está disponible

Esto mantiene la plataforma alineada con el modelo de cuotas de USPS sin convertir las cotizaciones de envío en un subsistema con muchos KV.

Llame únicamente a USPS en momentos de alta intención:

- inicio de pago
- Modificación del compromiso cuando cambian las selecciones físicas o el destino.

No llame a USPS:

- al cargar la página de la campaña pública
- en cada carrito renderizado
- en cada pulsación de tecla de cantidad/propina en el navegador

### Almacenamiento en caché

Evite el almacenamiento en caché del historial de cotizaciones respaldado por KV en v1.

Si es necesario, utilice un caché de estilo de caché de plataforma/en memoria de corta duración codificado por:

- origen ZIP
- país de origen
- código postal de destino
- país de destino
- peso del paquete
- dimensiones del paquete

La regla importante es:

- no convierta las cotizaciones de envío en un subsistema KV de alta escritura

El selector de país de pago ahora se alimenta desde [`_data/shipping_countries.yml`](https://github.com/your-org/your-project/blob/main/_data/shipping_countries.yml), lo que mantiene el mantenimiento del destino de USPS en una fuente dedicada en lugar de ocultarlo en el código de ejecución del navegador.

## Puntos de contacto entre trabajadores y frontend

### Obrero

Las costuras lógicas principales ya existen en:

- [trabajador/src/index.js](https://github.com/your-org/your-project/blob/main/worker/src/index.js)
- [trabajador/src/proveedor-config.js](https://github.com/your-org/your-project/blob/main/worker/src/provider-config.js)

El flujo de envío actual ahora:

- detecta elementos físicos
- construye una estimación de envío
- solicita una cotización de USPS
- recurre a `shipping.fallback_flat_rate` si es necesario

### Interfaz

La interfaz de usuario de carrito/administración puede permanecer estructuralmente similar:

- mostrar el envío en filas de resumen
- Continuar recopilando la dirección de envío para pedidos físicos.
- no hay nueva interfaz de usuario del operador orientada al usuario en v1

## Estrategia de prueba

La cobertura automatizada actual incluye:

- Cobertura unitaria para agregación de forma de envío.
- cobertura de unidad para el comportamiento de reserva de USPS
- cobertura de unidades para cálculos de envío físico sensibles a la cantidad
- Las pruebas de contrato de trabajo para caja inician/modifican con:
  - éxito doméstico
  - éxito internacional
  - Tiempo de espera de USPS/retroceso de falla
- Cobertura E2E para:
  - ruta de cotización de pago físico
  - recálculo de envío de promesa de modificación
- Cobertura de regresión de accesibilidad para cualquier nuevo estado de UI de solo envío
- Cobertura de ruta localizada para garantizar que los resúmenes de envío y los errores permanezcan traducidos en las configuraciones regionales iniciales.

## Actualizaciones de documentación y políticas

Documentos actuales que deberían mantenerse alineados con el comportamiento de envío:

- [README.md](/es/docs/overview/platform/)
- [docs/PERSONALIZACIÓN.md](/es/docs/development/customization-guide/)
- [docs/DEV_NOTES.md](/es/docs/development/developer-notes/)
- [docs/TESTING.md](/es/docs/operations/testing/)
- [términos.md](/es/docs/overview/terms-and-guidelines/)

Los términos deberían dejar de prometer una tarifa fija de envío físico y, en su lugar, describir las reglas de envío configuradas para la implementación, incluidas cotizaciones calificadas por el transportista y tarifas alternativas cuando corresponda.

Es posible que la redacción de privacidad también necesite una pequeña actualización si los detalles del destino se envían a USPS para el cálculo de la cotización.

## Árbol de reglas actual

### 1. Construya primero los contenedores de envío

El Trabajador no cita ciegamente un carro gigante. Primero divide el carro en depósitos de envío operativos:

- Cada envío de campaña sigue las reglas de envío de esa campaña.
- Los complementos de campaña se unen al envío de campaña propietario y heredan las anulaciones de esa campaña.
- los complementos globales físicos **no** toman prestado el envío de la campaña; se combinan en un envío de plataforma separada
- Los artículos digitales nunca crean un envío por sí solos.

Es por esto que un carrito mixto legítimamente puede tener:

- una o más cotizaciones de envío de campaña
- más una cotización de envío de plataforma para complementos físicos globales

### 2. Envío determinista de cortocircuito ante USPS

El Trabajador se salta el USPS en vivo cuando ya se conoce el resultado:

- una campaña con un `shipping_fallback_flat_rate` explícito utiliza esa anulación de campaña directamente para el envío de esa campaña.
- Los ajustes preestablecidos nacionales `manual_domestic_rate` calificados utilizan la tabla manual explícita directamente

En este momento esa ruta manual se usa para:

- `sticker`
- `signed_script`

Esos artículos solo utilizan la mesa plana manual cuando el envío completo aún califica por peso y dimensiones. De lo contrario, el Trabajador pasa a la ruta de USPS en vivo.

### 3. Si aún necesita una cotización, pruebe con el pedido de clase válido más barato del preestablecido.

Cuando un envío aún no está determinado por una tabla manual o de anulación, el Trabajador utiliza los metadatos preestablecidos para probar primero la clase defendible más barata.

Ordenamiento implementado actualmente:

- `sticker`
  - manual `FIRST_CLASS_FLAT`
  - perfil USPS nacional de una sola pieza, de lo contrario más barato
  - de lo contrario, ruta de cotización de paquete normal
- `signed_script`
  - manual `FIRST_CLASS_FLAT`
  - de lo contrario `MEDIA_MAIL`
  - de lo contrario `USPS_GROUND_ADVANTAGE`
  - de lo contrario `PRIORITY_MAIL`
- `cd`, `dvd`, `bluray`
  - `MEDIA_MAIL`
  - luego `USPS_GROUND_ADVANTAGE`
  - luego `PRIORITY_MAIL`
- todo lo demás
  - ruta de cotización predeterminada estilo paquete USPS en vivo

Si un envío combina perfiles preestablecidos incompatibles, el Trabajador recurre intencionalmente al modelo de paquete predeterminado más seguro en lugar de intentar ser demasiado inteligente y cotizar menos.

### 4. Las opciones de entrega de USPS se superponen a la cotización base

El selector orientado hacia atrás es intencionalmente estrecho:

- `Standard`
- `Signature required`
- `Adult signature required`

Normas:

- `Standard` utiliza de forma predeterminada la opción de envío elegible más barata
- las opciones de firma son solo nacionales
- el selector solo se muestra cuando el envío aún necesita una cotización de USPS activa y el envío subyacente admite esas opciones
- la opción de entrega seleccionada se mantiene y se reutiliza en Manage Pledge, los totales guardados, los informes y los correos electrónicos de los seguidores.

### 5. El respaldo solo se aplica cuando la ruta de cotización realmente falla

El respaldo de implementación sigue siendo:

- `shipping.fallback_flat_rate: 3.00`

Pero ese respaldo sólo debería aparecer cuando:

- USPS no está disponible
- USPS no devuelve ninguna tarifa utilizable
- el envío no tiene una anulación válida más específica o una ruta de tabla manual

La plataforma no debería mostrar el respaldo `$3.00` como una estimación falsa cuando simplemente aún no lo hemos cotizado.

## Comportamiento del carrito y del pago

### Visibilidad del campo ZIP

El carrito solo solicita un código postal cuando al menos un envío aún necesita una cotización en vivo.

Oculte el campo ZIP cuando:

- cada envío físico en el carrito está cubierto por anulaciones explícitas de tarifa plana de campaña
- o cada envío físico en el carrito está cubierto por artículos de tarifa plana manual deterministas como `sticker` / `signed_script`

Muestra el campo ZIP cuando:

- cualquier envío de campaña aún necesita una calificación de USPS activa
- o el envío de la plataforma para complementos físicos globales aún necesita una calificación de USPS en vivo

### Modo de estimación

Cuando se requiere un ZIP pero aún no se ha ingresado completamente, la interfaz de usuario debe permanecer en modo de estimación:

- `Estimated shipping`
- `--`
- `Estimated total`
- subtotal + propina + impuestos solamente

Esto se aplica tanto en el sidecar del carrito como en la vista previa de pago alojada/en el sitio.

La entrada postal parcial también debería permanecer en modo estimación. El carrito no debe mostrar brevemente el respaldo plano mientras el usuario todavía está escribiendo.

### Estados de envío conocidos en la interfaz de usuario

La interfaz debe distinguir entre estos estados:

- envío a tanto alzado conocido
  - sin campo ZIP si no se necesita cotización en vivo
  - monto de envío mostrado inmediatamente
- envío con cotización en vivo sin entrada postal completa
  - modo de estimación
- envío con cotización en vivo y entrada postal completa
  - Se muestra la cotización del trabajador
  - Selector de opciones de entrega opcional que se muestra cuando es compatible.
- falla de USPS
  - Se muestra el respaldo configurado en lugar de bloquear el proceso de pago.

## Estado de aceptación actual

La implementación del envío está en buen estado cuando:

- Las promesas físicas nacionales e internacionales pueden usar la calificación en vivo de USPS a través del Trabajador
- La tarifa plana de campaña anula el cortocircuito de USPS para esos envíos de campaña.
- Los artículos calificados con tarifa manual como `sticker` y `signed_script` omiten USPS y utilizan la tabla plana documentada.
- Los complementos de campaña heredan las reglas de envío y las anulaciones de la campaña propietaria.
- Los complementos globales físicos se combinan en un envío de plataforma separado en lugar de tomar prestado el envío de la campaña.
- Los cambios de cantidad afectan las matemáticas del envío correctamente.
- el pago, la gestión de promesas, los totales de promesas guardadas, los correos electrónicos, los informes y las exportaciones de cumplimiento permanecen alineados con el monto de envío almacenado
- Los carritos que requieren código postal permanecen en modo de estimación hasta que se completa el código postal
- no se introducen regresiones de seguridad en el proceso de pago ni en la modificación del compromiso
- no se introducen regresiones de accesibilidad en los estados de pago/administración relacionados con el envío
- no se introduce ninguna nueva copia de envío propiedad del sitio únicamente en inglés en rutas localizadas
