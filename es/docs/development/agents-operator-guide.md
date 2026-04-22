---
title: Guía para agentes y operadores
parent: Desarrollo
nav_order: 9
render_with_liquid: false
lang: es
---

# Guía para agentes y operadores

Este documento está dirigido a personas y LLM que trabajan en bifurcaciones de **The Pool**. Es una guía práctica para el operador para realizar cambios seguros en este repositorio sin dessincronizar el sitio, el trabajador, las matemáticas de pago o el comportamiento público/localizado.

Utilice esto junto con:

- [README.md](/es/docs/overview/platform/) para ver la descripción general actual del producto y la arquitectura
- [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/) para la superficie de configuración compatible orientada hacia la bifurcación
- [docs/TESTING.md](/es/docs/operations/testing/) para verificación local y expectativas de fusión
- [docs/I18N.md](/es/docs/development/internationalization/) para reglas de traducción y enrutamiento local
- [docs/SEO.md](/es/docs/operations/seo/) para metadatos, tarjetas compartidas y comportamiento de indexación
- [docs/EMBEDS.md](/es/docs/development/campaign-embeds/) para el sistema de inserción de campaña alojado

## Forma del proyecto

The Pool es un sistema dividido:

- el sitio estático es Jekyll + Sass + navegador JavaScript, publicado desde GitHub Pages
- el lado API/pago/tiempo de ejecución es un trabajador de Cloudflare en `worker/`
- Stripe maneja el cobro de pagos y los métodos de pago guardados
- el contenido y la configuración de la campaña se encuentran principalmente en rebajas/fronteras bajo `_campaigns/`

El límite importante es:

- el sitio muestra la interfaz de usuario, el contenido de la campaña, los flujos de carritos, las páginas localizadas, las incrustaciones y los metadatos de SEO
- el Trabajador es la fuente canónica para la validación de pagos, persistencia de promesas, estadísticas en vivo, correos electrónicos, liquidaciones y generación de SVG de tarjetas compartidas.

Si un cambio afecta los precios, los totales de la campaña, la disponibilidad, el estado del compromiso, el contenido del correo electrónico o el estado de la campaña en vivo, asuma que el Trabajador está involucrado incluso si el primer síntoma está en el sitio.

## Fuente de la verdad

Cuando necesite comprender o cambiar un comportamiento, comience aquí:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml): configuración canónica orientada hacia la horquilla
- [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml): solo anulaciones locales
- [`_campaigns/`](https://github.com/your-org/your-project/tree/main/_campaigns): contenido de la campaña, niveles, objetivos, datos del diario, enlaces comunitarios, productos relacionados con la campaña
- [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n): UI compartida/tiempo de ejecución/copia de correo electrónico por idioma
- [`_layouts/`](https://github.com/your-org/your-project/tree/main/_layouts) y [`_includes/`](https://github.com/your-org/your-project/tree/main/_includes): páginas públicas, páginas de campaña, incrustaciones, SEO, ayudas de enrutamiento localizado
- [`assets/`](https://github.com/your-org/your-project/tree/main/assets): tiempo de ejecución de JS, parciales de Sass compartidos, variables de tema, carga útil i18n generada
- [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src): pago, webhooks, estadísticas en vivo, envío de correo electrónico, vistas previas de acciones, liquidación, lógica de administración/informe
- [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml): Cableado del entorno del trabajador reflejado desde la configuración del sitio más los valores predeterminados locales/de desarrollo
- [`tests/`](https://github.com/your-org/your-project/tree/main/tests): unidad, seguridad y expectativas E2E
- [`scripts/`](https://github.com/your-org/your-project/tree/main/scripts): desarrollo local, puerta de fusión, pruebas de humo, informes y asistentes de sincronización

## Flujo de trabajo seguro

Para un desarrollo normal, prefiera:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Esa ruta mantiene el sitio y el trabajador funcionando junto con los valores predeterminados esperados del repositorio.

Para la verificación final, use el comando más limitado que pruebe el cambio, luego ejecute la puerta más amplia antes de fusionar cuando el cambio sea sustancial:

```bash
./scripts/pre-merge-regression.sh
```

Comprobaciones útiles y enfocadas:

- `bundle exec jekyll build --quiet`
- `npx vitest run <targeted test files>`
- `node --check <js file>`
- `./scripts/test-worker.sh --podman`
- `./scripts/test-e2e.sh --podman`

## Tareas comunes

### Agregar o editar una campaña

Comience con:

- [`_campaigns/<slug>.md`](https://github.com/your-org/your-project/tree/main/_campaigns)
- activos de campaña en [`assets/images/campaigns/<slug>/`](https://github.com/your-org/your-project/tree/main/assets/images/campaigns)
- documentos de soporte en [docs/CMS.md](/es/docs/reference/cms-integration/)

Controlar:

- meta de financiación y matemáticas de meta ambigua
- inventario por niveles y cantidades limitadas
- Configuración de envío para recompensas físicas.
- enrutamiento localizado/público si la página de la campaña debe funcionar limpiamente en `/es/`
- Comportamiento de vista previa de inserción/compartición si se cambia la imagen principal, la propaganda, el título o el estado en vivo

### Cambiar la configuración de la marca o del producto

Comience con:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- [docs/PERSONALIZACIÓN.md](/es/docs/development/customization-guide/)

No coloque configuraciones de bifurcación canónicas en `_config.local.yml`. Conserve ese archivo para anulaciones locales de la máquina, como URL de host local y marcas solo locales.

Si cambia los valores que se reflejan en el trabajador, reinicie la pila local o ejecute:

```bash
npm run sync:worker-config
```

### Cambiar el comportamiento de pago, totales o gestión de promesas

Comience con:

- tiempo de ejecución del sitio en [`assets/js/`](https://github.com/your-org/your-project/tree/main/assets/js)
- campaña/carrito/administrar plantillas en [`_includes/`](https://github.com/your-org/your-project/tree/main/_includes) y [`_layouts/`](https://github.com/your-org/your-project/tree/main/_layouts)
- Lógica de pago del trabajador en [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)

Suponga siempre que hay una pieza del lado del sitio y una pieza del lado del trabajador.

Cosas que deben permanecer alineadas:

- matemáticas subtotales
- consejo de matemáticas
- impuesto sobre las ventas
- envío
- complementos
- reglas de contribución de objetivos de campaña
- compromiso/correo electrónico/informar totales

Si solo cambia un lado, probablemente tengas un error.

### Cambiar correos electrónicos o comunicación con los seguidores

Comience con:

- Lógica de correo del trabajador en [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)
- copia de traducción en [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n)
- identidad de contacto/remitente en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)

Si toca el comportamiento sensible a la capacidad de entrega, también verifique la cordura:

- Alineación del dominio `from`
- `reply_to`
- generación de cuerpo de texto plano
- mezcla de contenido transaccional versus promocional

### Cambiar incrustaciones o vistas previas enriquecidas

Comience con:

- incrustar rutas y diseño en [`embed/`](https://github.com/your-org/your-project/tree/main/embed) y [`_layouts/campaign-embed.html`](https://github.com/your-org/your-project/blob/main/_layouts/campaign-embed.html)
- incrustar cliente/tiempo de ejecución en [`assets/js/campaign-embed.js`](https://github.com/your-org/your-project/blob/main/assets/js/campaign-embed.js)
- incrustar estilos en [`assets/partials/_embed.scss`](https://github.com/your-org/your-project/blob/main/assets/partials/_embed.scss)
- Tarjetas de acciones de trabajadores en [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)
- Metadatos SEO en [`_includes/seo-meta.html`](https://github.com/your-org/your-project/blob/main/_includes/seo-meta.html)
- orientación en [docs/EMBEDS.md](/es/docs/development/campaign-embeds/) y [docs/SEO.md](/es/docs/operations/seo/)

Mantenga alineados conceptualmente el estado de inserción, el estado de vista previa compartida y los metadatos de la página de la campaña incluso cuando las superficies renderizadas difieran.

### Agregar o ampliar un idioma

Comience con:

- [Bloque `_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) `i18n`
- [`_data/i18n/<lang>.yml`](https://github.com/your-org/your-project/tree/main/_data/i18n)
- páginas localizadas de formato largo como [`es/about.md`](/es/docs/overview/about-the-pool/) y [`es/terms.md`](/es/docs/overview/terms-and-guidelines/)
- ayudantes locales en [`_includes/localized-url.html`](https://github.com/your-org/your-project/blob/main/_includes/localized-url.html)
- páginas de campaña localizadas generadas en [`_plugins/localized_campaign_pages.rb`](https://github.com/your-org/your-project/blob/main/_plugins/localized_campaign_pages.rb)

Las cadenas de sistema compartidas pertenecen a `_data/i18n/{lang}.yml`.
El contenido de la campaña creado por creadores normalmente debe seguir siendo contenido de la campaña, no trasladarse a YAML traducido.

## Invariantes para proteger

Estos son los lugares más fáciles para que las bifurcaciones o los LLM provoquen deriva accidentalmente.

### 1. `_config.yml` es canónico

No trate a `_config.local.yml` como una segunda fuente de verdad.

### 2. Las configuraciones reflejadas por los trabajadores deben permanecer sincronizadas

Si cambia los precios, las URL del sitio, la identidad del remitente u otras configuraciones reflejadas, asegúrese de que el trabajador vea los mismos valores.

### 3. Los totales de pago están verificados por el servidor

El navegador puede sugerir un estado del carrito. El Trabajador decide los totales canónicos y la forma de prenda persistente.

### 4. El progreso de la campaña excluye algunos dólares de pago

El envío, los impuestos y la propina de la plataforma no cuentan para los totales de financiación de la campaña. Tenga cuidado al cambiar el idioma de visualización o los informes para no dar a entender lo contrario.

### 5. Las rutas localizadas forman parte del contrato público

Si agrega una nueva página pública, ruta de inserción o flujo específico de la campaña, verifique si los asistentes de configuración regional y el selector de idioma del pie de página necesitan saberlo.

### 6. Los flujos tokenizados/privados no deberían volverse indexables

`/manage/`, las páginas de resultados de compromiso y las rutas privadas/con token deben permanecer fuera de la indexación de búsqueda y deben preservar el comportamiento de token/consulta al cambiar de idioma.

### 7. Las campañas finalizadas no deben comportarse como las activas.

Las cuentas regresivas, los controles de promesas y el estado de inserción/compartición previa deben respetar el estado efectivo de la campaña, especialmente después de las fechas límite.

## Los mejores documentos para trabajos específicos

- Configuración y marca de la bifurcación: [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/)
- Desarrollo local y verificación de fusión: [docs/TESTING.md](/es/docs/operations/testing/)
- Configuración y límites de Podman: [docs/PODMAN.md](/es/docs/operations/podman-local-dev/)
- Modelo de localización: [docs/I18N.md](/es/docs/development/internationalization/)
- SEO y compartir metadatos: [docs/SEO.md](/es/docs/operations/seo/)
- Inserciones de campaña: [docs/EMBEDS.md](/es/docs/development/campaign-embeds/)
- Comportamiento de envío y USPS: [docs/SHIPPING.md](/es/docs/operations/shipping/)
- Modelo de producto complementario: [docs/ADD_ON_PRODUCTS.md](/es/docs/development/add-on-products/)
- Flujo de CMS/editor: [docs/CMS.md](/es/docs/reference/cms-integration/)
- Postura de seguridad y barandillas: [docs/SECURITY.md](/es/docs/operations/security/)
- Mentalidad de lista de verificación de liberación/fusión: [docs/MERGE_SMOKE_CHECKLIST.md](/es/docs/operations/merge-smoke-checklist/)

## Buen comportamiento de LLM en este repositorio

Si eres un LLM y estás ayudando con este código base:

- Lea la implementación existente antes de proponer cambios estructurales.
- Prefiere ediciones pequeñas y locales que preserven los patrones establecidos.
- actualizar las pruebas cuando el comportamiento cambie
- Tenga en cuenta juntas las consecuencias del sitio público, del trabajador, del correo electrónico y de i18n.
- Evite inventar nuevas superficies de configuración cuando una existente ya encaja.
- prefiera enlaces de documentación relacionados con el repositorio, no rutas específicas de la máquina
- no abandone silenciosamente el soporte local, el comportamiento de inserción o el comportamiento de vista previa compartida mientras cambia las páginas de la campaña

En caso de duda, realice el cambio más pequeño que mantenga alineados al sitio y al trabajador, luego verifíquelo con la prueba significativa más estrecha más la puerta más amplia cuando sea necesario.
