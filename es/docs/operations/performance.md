---
title: Rendimiento
parent: Operaciones
nav_order: 11
render_with_liquid: false
lang: es
---

# Rendimiento

## Última actualización

3 de junio de 2026

The Pool es una plataforma de financiación colectiva estática con un trabajador de Cloudflare para mutaciones, lecturas en vivo y operaciones administrativas. El trabajo de rendimiento debe preservar esa forma: las páginas públicas deben ser rápidas desde HTML estático, el código de aplicación pesado debe cargarse sólo cuando un usuario lo necesita y el trabajo especulativo debe ser lo suficientemente conservador como para nunca hacer que los flujos de pago, administración o soporte sean menos confiables.

Esta guía cubre el modelo de rendimiento de la plataforma actual, los mandos que las horquillas pueden ajustar y la validación esperada antes de que cambie el rendimiento del envío.

## Principios

- mantenga la primera pintura y la acción principal de la campaña utilizables antes de que finalice el código de tiempo de ejecución opcional
- prefiera la salida estática de Jekyll, el almacenamiento en caché perimetral de Cloudflare y el almacenamiento en caché del navegador antes de agregar complejidad al cliente
- Evite cargar el código de pago, carrito, administrador o administración hasta que el usuario exprese su intención.
- mantenga las páginas públicas rastreables y funcionales sin depender de JavaScript para el contenido principal
- nunca especules sobre rutas privadas, tokenizadas, de pago, de administración o de apoyo
- hacer que las características de rendimiento sean configurables desde `_config.yml` y el panel de administración donde las bifurcaciones pueden necesitar diferentes compensaciones de tráfico
- medir los cambios en comparación con los activos reales construidos, no solo con los archivos fuente

## Objetivos

Utilícelos como objetivos prácticos en lugar de afirmar que cada prueba local los alcanzará:

- LCP bajo `2.5s` en páginas de campañas públicas representativas
- INP bajo `200ms` para interacciones de campaña, carrito, pago, administración y administración
- CLS bajo `0.1`, con barras de progreso, medios de héroe, tarjetas de nivel y estadísticas en vivo que reservan espacio estable
- no hay una pila de carritos llenos de ganas en una primera carga pública anónima
- no se realizan precargas de documentos públicos en rutas privadas, tokenizadas, de pago, de administración, de administración o de la comunidad de seguidores
- Los activos CSS/JS generados pasan `npm run assets:minify:check`
- Cloudflare ofrece recursos de texto con compresión de transferencia y sin Auto Minify

## Modelo de plataforma

Jekyll genera el sitio público y lo implementa como salida de GitHub Pages. El trabajador maneja inquietudes dinámicas como la intención de pago, estadísticas en vivo, inventario, gestión de promesas, publicación administrativa, informes y observabilidad.

Superficies de repositorio importantes:

- [`_layouts/default.html`](https://github.com/your-org/your-project/blob/main/_layouts/default.html): diseño público compartido
- [`_layouts/campaign.html`](https://github.com/your-org/your-project/blob/main/_layouts/campaign.html): diseño de detalle de la campaña
- [`_includes/cart-runtime-foot.html`](https://github.com/your-org/your-project/blob/main/_includes/cart-runtime-foot.html): cargador de carro liviano incluido
- [`_includes/page-prefetch.html`](https://github.com/your-org/your-project/blob/main/_includes/page-prefetch.html): inclusión de captación previa de documentos públicos
- [`assets/js/cart-runtime-loader.js`](https://github.com/your-org/your-project/blob/main/assets/js/cart-runtime-loader.js): arranque del tiempo de ejecución del carrito diferido
- [`assets/js/page-prefetch.js`](https://github.com/your-org/your-project/blob/main/assets/js/page-prefetch.js): tiempo de ejecución de captación previa de documentos basado en intención
- [`scripts/minify-site-assets.mjs`](https://github.com/your-org/your-project/blob/main/scripts/minify-site-assets.mjs): minificación CSS/JS generada
- [`scripts/sync-worker-config.rb`](https://github.com/your-org/your-project/blob/main/scripts/sync-worker-config.rb): duplicación de configuración de sitio a trabajador

## Representación crítica

Las páginas de campañas públicas deben evitar cambios de diseño y recursos críticos descubiertos tardíamente.

Barandillas actuales:

- Las barras de progreso y las posiciones de los marcadores representan clases de utilidad estáticas de ancho/izquierda en la salida de Jekyll para que no comiencen colapsadas mientras se carga JavaScript.
- Las imágenes principales de la campaña se emiten con precarga y alta prioridad de recuperación donde el diseño conoce el activo LCP probable.
- Los videos de los héroes de la campaña de YouTube muestran primero un póster local o una fachada de reproducción y cargan el iframe de YouTube solo después de la intención de reproducción.
- Los scripts comunes usan `defer` o carga dinámica diferida en lugar de etiquetas de script que bloquean el analizador.
- Las superficies privadas/administradoras permanecen `noindex` y no deben heredar el comportamiento de captación previa pública.

Al cambiar el Chrome de la campaña, verifique:

- la barra de progreso no parpadea con todas las marcas y etiquetas en el borde izquierdo
- La imagen LCP se puede descubrir al principio del documento.
- El texto y los controles no cambian después de las estadísticas en vivo o la hidratación del inventario.
- La falla de JavaScript aún deja legibles el contenido de la campaña, la copia de nivel y los enlaces principales

## Carga en tiempo de ejecución

El tiempo de ejecución del carrito se divide intencionalmente. Las páginas públicas cargan primero un cargador pequeño y luego recuperan la pila de carritos más pesados ​​solo cuando es necesario.

El cargador debería activarse en:

- interacción del botón agregar al carrito
- Estado del carrito persistente que necesita restauración.
- estado de recuperación de pago
- Intención de la interfaz de usuario del carrito, como abrir el carrito

Los archivos de carros pesados ​​no deben ser parte de una primera carga pública ordinaria a menos que esté presente uno de esos estados:

- [`assets/js/cart-provider.js`](https://github.com/your-org/your-project/blob/main/assets/js/cart-provider.js)
- [`assets/js/cart.js`](https://github.com/your-org/your-project/blob/main/assets/js/cart.js)
- [`assets/js/buy-buttons.js`](https://github.com/your-org/your-project/blob/main/assets/js/buy-buttons.js)
- sidecars de pago y complementos compartidos/ayudantes de envío

Al cambiar el carrito o la carga del carrito, verifique con las herramientas de red del navegador que una vista anónima de la página de la campaña no descargue con entusiasmo la pila completa del carrito.

## Minificación de activos generados

Los archivos fuente del repositorio siguen siendo legibles. La producción implementa la salida generada minificada después de que Jekyll escribe `_site`.

El flujo de trabajo de implementación se ejecuta:

```bash
npm run assets:minify
```

Ese comando reescribe archivos `_site/assets/**/*.css` y `_site/assets/**/*.js` más pequeños antes de cargar el artefacto de GitHub Pages. La minificación de JavaScript es conservadora: elimina los espacios en blanco y simplifica la sintaxis, pero no altera las propiedades ni reescribe los identificadores. CSS se minimiza después de que Sass ya haya emitido una salida comprimida.

Utilice esta verificación después de una compilación local cuando cambie el manejo de activos generados:

```bash
npm run assets:minify:check
```

La verificación de artefactos de compilación previa a la fusión también minimiza `_site` y falla si el CSS/JS generado todavía tiene ahorros de minificación.

## Compresión de Cloudflare

Cloudflare debería manejar la compresión de transferencia en el borde. Se ha verificado la implementación en vivo que ofrece recursos de texto comprimido con gzip, Brotli y Zstandard según la solicitud `Accept-Encoding` y el comportamiento del borde.

Mantenga estas responsabilidades separadas:

- compilación de repositorio: minimizar CSS/JS generado
- Borde de Cloudflare: compresión de transferencia estándar gzip/Brotli/Z
- control de fuente: archivos fuente legibles, copias minimizadas generadas no confirmadas

Cloudflare Auto Minify debería permanecer deshabilitado. Reescribe las respuestas en el borde, lo que hace que el comportamiento de producción sea más difícil de reproducir localmente y de probar en CI. Prefiera el paso de activos generados controlados por repositorios.

Mantenga Rocket Loader y la ofuscación de direcciones de correo electrónico desactivadas para este sitio. Rocket Loader reescribe etiquetas de script en el borde, mientras que la ofuscación de direcciones de correo electrónico inyecta `/cdn-cgi/scripts/*/cloudflare-static/email-decode.min.js`; Ambos hacen que las páginas con CSP estricto sean más difíciles de reproducir localmente y pueden aparecer como bloqueo de procesamiento o diagnóstico de ruido de consola en PageSpeed ​​Insights.

Si Cloudflare Web Analytics está habilitado, las páginas de la campaña deben permitir el script de análisis de Cloudflare y el punto final de baliza en el CSP de la campaña. Las superficies privadas/administrativas deben ser más estrictas a menos que exista una decisión explícita de análisis/privacidad para incluirlas.

Las hojas de estilo de fuentes se vinculan desde el encabezado del documento en lugar de importarse desde `assets/main.css`. Esto permite al navegador descubrir CSS de fuentes y conexiones de fuentes sin esperar en la hoja de estilo principal y al mismo tiempo preservar el comportamiento intencional de carga de fuentes.

Las variables CSS del token de diseño generadas se incluyen en `assets/main.css`; `assets/theme-vars.css` sigue estando disponible como artefacto de compatibilidad, pero los diseños públicos no deberían solicitarlo como una hoja de estilo de bloqueo de renderizado independiente.

## Captura previa basada en intención

El grupo incluye un tiempo de ejecución de búsqueda previa de documentos del mismo origen opcional para enlaces de navegación públicos. Está inspirado en el modelo de intención de desplazamiento/toque de instant.page, pero la implementación es local, pequeña y deliberadamente conservadora.

El tiempo de ejecución se encuentra en [`assets/js/page-prefetch.js`](https://github.com/your-org/your-project/blob/main/assets/js/page-prefetch.js). Se carga en superficies de páginas públicas de forma predeterminada y permanece fuera de los diseños de aplicaciones privadas.

### Configuración

La inclusión compartida es [`_includes/page-prefetch.html`](https://github.com/your-org/your-project/blob/main/_includes/page-prefetch.html). Emite el tiempo de ejecución sólo cuando esta configuración está habilitada:

```yml
performance:
  intent_prefetch_enabled: true
  intent_prefetch_delay_ms: 90
  intent_prefetch_limit: 3
```

La inclusión está conectada a superficies de páginas públicas:

- [`_layouts/default.html`](https://github.com/your-org/your-project/blob/main/_layouts/default.html)
- [`_layouts/campaign.html`](https://github.com/your-org/your-project/blob/main/_layouts/campaign.html)

Los diseños de aplicaciones privadas no cargan el tiempo de ejecución de captación previa.

Estos campos también están expuestos en el panel de administración privado en **Configuración -> Rendimiento avanzado**. Cambiarlos publica `_config.yml` y requiere la reconstrucción normal del sitio antes de que las páginas estáticas reflejen los nuevos valores.

### Comportamiento

Cuando está habilitado, el tiempo de ejecución escucha:

- `pointerover` después de `performance.intent_prefetch_delay_ms`
- `focusin` después de `performance.intent_prefetch_delay_ms`
- `touchstart` inmediatamente

Agrega una sugerencia de baja prioridad por cada URL elegible:

```html
<link rel="prefetch" as="document" href="/campaigns/example/">
```

El tiempo de ejecución deduplica las URL normalizadas, elimina fragmentos y se detiene después de que `performance.intent_prefetch_limit` realice capturas previas exitosas por página vista.

### Rutas elegibles

La lista de permitidos es intencionalmente estrecha. Las rutas elegibles actuales son:

- `/`
- rutas locales localizadas como `/es/`
- `/about/`
- `/terms/`
- `/creator-campaign-checklist/`
- páginas de detalles de campañas públicas como `/campaigns/hand-relations/`
- rutas de campaña públicas localizadas cuando se generan con el mismo modelo de ruta

El tiempo de ejecución rechaza cualquier enlace que no sea un documento de navegación `http:` o `https:` del mismo origen.

### Exclusiones

El tiempo de ejecución rechaza enlaces cuando cualquiera de estos es verdadero:

- el enlace es de origen cruzado
- el enlace utiliza un protocolo que no es HTTP
- el enlace tiene `download`
- el enlace tiene `rel="nofollow"`
- el enlace tiene un `target` distinto de `_self`
- el enlace tiene `data-no-prefetch`
- los puntos de navegación en el documento actual, incluidos los enlaces de solo fragmentos
- la URL contiene parámetros de consulta confidenciales como `token`, `publicToken`, `adminToken`, `orderId`, `email` o `session`.
- la ruta está en `/admin`, `/manage`, `/community`, `/cart`, `/checkout`, `/checkout-intent`, `/pledge-success`, `/pledge-cancelled`, `/api` o `/worker`.
- la ruta no está en la lista pública permitida

Utilice `data-no-prefetch` para exclusiones únicas en enlaces públicos que de otro modo serían elegibles.

### Guardias de red

La captación previa se omite cuando:

- el navegador no informa soporte para `rel=prefetch`
- `document.visibilityState` no es `visible`
- `navigator.connection.saveData` es cierto
- `navigator.connection.effectiveType` es `slow-2g` o `2g`
- el límite de captación previa por página configurado ya se ha alcanzado

### Habilitación segura

El valor predeterminado está habilitado porque el tiempo de ejecución solo especula sobre enlaces de documentos públicos del mismo origen después de la intención explícita del usuario. Deshabilítelo con `performance.intent_prefetch_enabled: false` si una bifurcación tiene reglas de navegación inusuales o quiere ejecutarse sin solicitudes de documentos especulativos.

Validación recomendada después de cambiar la configuración:

1. Habilite `performance.intent_prefetch_enabled: true` en una configuración provisional.
2. Confirme que los enlaces de tarjetas de campaña públicas creen `link[rel="prefetch"][as="document"]` después de pasar el cursor o centrarse.
3. Confirme que los enlaces de administración, gestión, pago, resultados de compromiso, comunidad, tokenizados, externos y `target="_blank"` no se precargan.
4. Verifique DevTools Network con condiciones de estilo de limitación y guardado de datos.
5. Mantenga bajo el límite por página. El valor predeterminado es `3`.

## Almacenamiento en caché y lecturas de trabajadores

La plataforma intenta mantener el tráfico de lectura pública barato y receptivo.

Perillas actuales relacionadas con el caché:

```yml
cache:
  live_stats_ttl_seconds: 300
  live_inventory_ttl_seconds: 300
```

Las páginas de campaña almacenan en caché las estadísticas en vivo y el inventario en el almacenamiento del navegador para esos TTL. The Worker también expone lecturas en vivo combinadas para que las páginas públicas puedan hidratar las estadísticas y el inventario de la campaña sin dividirse en más solicitudes de las necesarias.

Al cambiar lecturas en vivo:

- prefiera una lectura pública combinada a varias lecturas independientes
- invalidar las cachés del navegador después de una persistencia exitosa del compromiso
- mantenga el comportamiento de recuperación obsoleto privado para el navegador y evite el almacenamiento confidencial de larga duración
- use `GET /admin/observability/performance` para inspeccionar tiempos de trabajo de muestra en entornos locales o implementados

## Presupuesto de lista KV

Las solicitudes de lista KV de trabajadores son un presupuesto de nivel gratuito independiente de las lecturas y escrituras. Las rutas normales públicas y de panel deben evitar escaneos de espacios de nombres y preferir proyecciones, índices o marcadores explícitos de estado de cola.

Barandillas actuales:

- los informes de campaña, la navegación de los seguidores, los acuerdos y las rutas de reparación prefieren los índices `campaign-pledges:{slug}` a los escaneos de espacios de nombres de promesas.
- Las lecturas de inventario adicionales de la plataforma utilizan `add-on-inventory-sold:v1` después del primer arranque de proyección de recuento de ventas.
- El envío de recordatorio de lanzamiento utiliza `launch-reminder-dispatch-queue:v1`, por lo que los ticks programados inactivos no aparecen en la lista `launch-reminder-dispatch:*`.
- El reintento por correo electrónico de confirmación del colaborador utiliza `supporter-email-retry-queue:v1`, por lo que el reintento de sondeo omite los análisis `supporter-email-retry:*` mientras está inactivo o antes de que venza el siguiente intento.
- Los marcadores de estado de cola inactivo caducan cada hora, lo que mantiene la compatibilidad con los trabajos insertados manualmente sin volver al sondeo del espacio de nombres a nivel de minutos.

En condiciones normales de tráfico sin colas, se esperan aproximadamente `48-75` solicitudes de lista KV durante 24 horas. Los lotes de recordatorios de lanzamiento activos y los reintentos de correo electrónico de los colaboradores aún muestran sus prefijos de cola limitada cuando el trabajo real está pendiente.

## Optimización de medios

Las cargas del panel preservan el origen. El trabajador valida las cargas y las confirma, luego solicita el flujo de trabajo **Optimizar medios del panel** para cargas de imágenes/videos. Todavía no ejecuta optimizadores de imágenes nativos ni el propio FFmpeg.

Utilice la canalización de medios del repositorio para los medios de origen:

```bash
npm run media:optimize
npm run media:optimize:check
```

Si la máquina host no tiene instalados los optimizadores nativos, utilice en su lugar los contenedores respaldados por Podman:

```bash
npm run media:optimize:podman
npm run media:optimize:check:podman
```

La imagen del sitio Podman incluye `ffmpeg`, `optipng`, `libjpeg-turbo-progs`, `gifsicle` y `webp`, por lo que la compresión de imágenes local y la generación de derivados responsivos utilizan la misma cadena de herramientas nativa que el flujo de trabajo multimedia de GitHub. Reconstruya la imagen con `PODMAN_REBUILD=1` después de cambiar los requisitos del paquete contenedor.

Para regresiones implementadas con muchos medios, ejecute manualmente el flujo de trabajo **Optimizar medios del panel** de GitHub Actions con `scope=all` para que los activos de campaña existentes se optimicen mediante el mismo canal en lugar de editarlos una sola vez.

Si PageSpeed ​​marca imágenes de campaña de gran tamaño que ya fluyen a través de `responsive-image.html`, primero confirme si existen los derivados correspondientes de `-320.webp`, `-480.webp`, `-640.webp`, `-960.webp` y `-1600.webp`. Los derivados que faltan deben ser producidos por `npm run media:optimize` localmente o mediante el flujo de trabajo con `scope=all`, no mediante ediciones de imágenes manuales únicas.

El canal de medios:

- comprime imágenes cuando el resultado optimizado es más pequeño
- genera variantes WebP responsivas en `320w`, `480w`, `640w`, `960w` y `1600w` para plantillas de imágenes públicas cuando la imagen de origen es más grande que esa variante
- omite la reoptimización de `cwebp` para derivados animados de WebP porque `cwebp` no puede decodificar archivos WebP animados
- genera derivados WebM para videos subidos
- reescribe referencias literales `_campaigns` / `_config.yml` de videos fuente subidos a derivados WebM generados
- mantiene los vídeos originales disponibles para revertirlos o recodificarlos en el futuro

Para páginas de campaña, prefiera:

- dimensiones de imagen explícitas o relaciones de aspecto CSS estables
- Imágenes destacadas optimizadas que coinciden con el recorte renderizado.
- imágenes de origen cercanas a las dimensiones de destino documentadas; Las variantes responsivas reducen el tamaño de la transferencia, pero no sustituyen la elección del cultivo adecuado.
- WebM para vídeo de fondo/héroe cuando sea práctico
- carga diferida para medios plegados por debajo
- texto alternativo significativo para imágenes informativas

## Administrador y superficies privadas

Las rutas de administración, gestión, pago, resultados de compromiso, comunidad y tokenizadas deben optimizarse para lograr corrección y privacidad antes que la velocidad especulativa.

Reglas para superficies privadas:

- no cargar la búsqueda previa de documentos públicos
- no precargar enlaces que contengan tokens o pedidos
- mantenga las respuestas de autenticación, pago y recuperación privadas y sin caché
- mantenga visibles los mensajes de estado y error sin necesidad de una recarga completa
- Evite enviar secretos, datos exclusivos de administrador o tokens de apoyo a páginas generadas estáticamente.

La configuración de rendimiento del administrador se encuentra actualmente en **Configuración -> Rendimiento avanzado**:

- `performance.intent_prefetch_enabled`
- `performance.intent_prefetch_delay_ms`
- `performance.intent_prefetch_limit`

## Medición de cambios

Utilice controles locales para regresiones y controles similares a los de producción para obtener confianza final.

Validación local:

```bash
bundle exec jekyll build --config _config.yml,_config.local.yml --quiet
npm run assets:minify
npm run assets:minify:check
npm run test:unit
```

Validación enfocada del navegador para cambios en la interfaz de usuario pública:

```bash
python3 -m http.server 4100 --bind 127.0.0.1 --directory _site
```

Luego, en otro shell:

```bash
PLAYWRIGHT_EXTERNAL_SERVER=1 PLAYWRIGHT_BASE_URL=http://127.0.0.1:4100 \
  npx playwright test tests/e2e/public-page-controls.spec.ts --project=chromium
```

Validación de fusión completa:

```bash
npm run test:premerge
```

La validación de producción o puesta en escena debe comparar:

- LCP, INP, CLS, FCP y TTFB
- recuento total de solicitudes y bytes transferidos en la primera carga
- si los scripts pesados de carrito/administración/administración se cargan solo en las rutas o intenciones previstas
- Estado de caché de Cloudflare y codificación de contenido para HTML, CSS y JS
- Observaciones del desempeño de los trabajadores para el pago, la publicación administrativa, los informes y las lecturas en vivo.
- solicitar cambios de volumen después de habilitar la captación previa

## Lista de verificación de cambios

Utilice esta lista de verificación antes de fusionar cambios de rendimiento:

- Las páginas de origen aún muestran contenido significativo antes de que finalice JavaScript.
- no se precarga ninguna ruta privada, tokenizada, de pago o de administración
- los activos generados `_site` pasan `npm run assets:minify:check`
- La compresión de Cloudflare permanece habilitada y Auto Minify permanece deshabilitada
- La primera carga pública evita archivos pesados de carrito/tiempo de ejecución a menos que el estado del carrito o la intención del usuario los requieran.
- Las barras de progreso, los medios de héroe y los controles de campaña no cambian después de la hidratación.
- los cambios de medios pasan `npm run media:optimize:check` cuando los medios cargados o agregados manualmente cambian
- Las pruebas relevantes de unidades y navegadores se comparan con los activos creados.
