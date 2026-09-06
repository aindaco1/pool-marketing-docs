---
title: Cómo contribuir
parent: Desarrollo
nav_order: 1
render_with_liquid: false
lang: es
---

# Contribuyendo a The Pool

## Última actualización

6 de septiembre de 2026

Esta guía cubre la incorporación, el flujo de trabajo de contribución y los patrones de desarrollo compartidos. Comience con [AGENTS](/es/docs/development/agents-operator-guide/) y el [índice de documentación](/es/docs/development/) para identificar la guía propietaria de su cambio.

## Configuración de desarrollo

Utilice la versión de Node.js en [.nvmrc](https://github.com/aindaco1/pool/blob/main/.nvmrc), Git y Podman para la ruta local estándar. El host Jekyll también necesita Ruby y Bundler; Stripe CLI es opcional para el reenvío de webhooks en modo de prueba real.

Desde la raíz del repositorio:

```bash
git submodule update --init --recursive
npm ci
npm run setup:deploy -- --mode=local
npm run podman:doctor
./scripts/dev.sh --podman
```

Consulte [Podman](/es/docs/operations/podman-local-dev/) para conocer la configuración del contenedor, los hosts admitidos, la supervisión del servicio, los requisitos de recursos y los registros. Utilice [Testing](/es/docs/operations/testing/) para la carga de datos de prueba, el pago manual y las pruebas del navegador; el arnés del navegador automatizado sirve a un sitio estático creado.

`npm run secrets:dev` crea/actualiza `worker/.dev.vars` ignorado en el ejemplo, genera secretos de sesión/firma local y solicita claves de proveedor opcionales sin imprimirlas. El acceso de arranque del administrador local utiliza `ADMIN_BOOTSTRAP_EMAILS`; el panel muestra solo el estado de las credenciales. [Security](/es/docs/operations/security/) define límites secretos y [Deployment](/es/docs/operations/deployment/) posee la configuración del espacio de nombres/cuenta alojada.

La configuración canónica pertenece a `_config.yml`. `_config.local.yml` solo realiza anulaciones locales. Los scripts de desarrollo/prueba compatibles sincronizan `worker/wrangler.toml`; después de cambios de configuración directos, reinicie la pila o ejecute `npm run sync:worker-config`. Consulte [Personalización](/es/docs/development/customization-guide/).

### Alternativa en el host

Instale las dependencias del host bloqueado desde la raíz del repositorio:

```bash
bundle install
npm ci --prefix worker
```

Luego use el lanzador existente:

```bash
./scripts/dev.sh
```

Para el inicio manual del servicio, ejecútelos en terminales independientes desde la raíz del repositorio:

```bash
bundle exec jekyll serve --config _config.yml,_config.local.yml --port 4000
```

```bash
npm --prefix worker run dev
```

Configure un único oyente Stripe y su secreto de webhook local correspondiente mediante [Payment Processor](/es/docs/operations/payment-processor/). La configuración del proveedor es opcional para verificaciones basadas en dispositivos; Los pagos en modo de prueba real necesitan las credenciales de prueba correspondientes. Si los estilos están obsoletos, `bundle exec jekyll clean` borra el sitio/caché generado.

## Flujo de trabajo de contribución

1. Inspeccionar `git status`; preservar las ediciones no relacionadas e inicializar las dependencias compartidas registradas.
2. Lea la implementación, las pruebas cercanas, [Arquitectura](/es/docs/development/architecture/) y la guía de dominio relevante antes de cambiar el comportamiento.
3. Utilice las rutas de persistencia, validación, representación y configuración compartidas existentes.
4. Ejecute la verificación significativa más limitada y luego la puerta `npm run test:premerge` completa para cambios sustanciales o de lanzamiento. [Testing](/es/docs/operations/testing/) posee los comandos y [Merge Smoke](/es/docs/operations/merge-smoke-checklist/) posee la aprobación del operador.
5. Actualice la guía autorizada cuando cambie el comportamiento, registre los cambios completados en No publicado en [Changelog](/es/docs/reference/changelog/) y mantenga el trabajo potencial en [Roadmap](/es/docs/reference/roadmap/).
6. Abra un PR enfocado usando la [plantilla de PR](/es/docs/reference/pull-request-template/), con información relevante de validación y reversión.

Utilice nombres de rama `feat/`, `fix/` o `docs/` y prefijos de confirmación convencionales como `feat`, `fix`, `docs`, `chore` o `infra`. Problemas relacionados con enlaces. Incluya capturas de pantalla renderizadas para cambios en la interfaz de usuario, incluidas vistas de escritorio/tableta/móvil y de administrador en español cuando esas superficies cambien.

Revise [Ethical Risk](/es/docs/development/ethical-risk-review/) para conocer cambios en el dinero, los datos de los patrocinadores, los mensajes, los análisis, el poder administrativo, la visibilidad o la automatización. El trabajo del panel también requiere los contratos pertinentes de [Accesibilidad](/es/docs/operations/accessibility/), [I18N](/es/docs/development/internationalization/), [Seguridad](/es/docs/operations/security/) y [SEO](/es/docs/operations/seo/).

## Patrones de desarrollo

El tema y la marca de correo electrónico/pago utilizan la superficie `design.*` / `platform.*` en [Personalización](/es/docs/development/customization-guide/). Jekyll compila `assets/main.scss` y los parciales The Pool bajo `assets/partials/` más los estilos de diseño de plataforma anclados; agregue estilos al componente existente o a la página parcial. Las hojas de estilo de fuentes se cargan desde el encabezado del documento. La minificación de activos generados pertenece a [Performance](/es/docs/operations/performance/).

### Liquid Incluye y colecciones

Dentro de una inclusión, lea los valores pasados ​​a través de `include`, por ejemplo `{{ include.pledged }}` para `{% include progress.html pledged=campaign.pledged_amount %}`. Una matriz YAML vacía es verdadera en Liquid; use una verificación de tamaño:

```liquid
{% if page.support_items and page.support_items.size > 0 %}
  <!-- Render the collection -->
{% endif %}
```

Cite cadenas YAML que contengan caracteres especiales y guarde la división por cero antes de calcular el progreso. [El modelo de contenido](/es/docs/development/content-model/) posee ejemplos de campos de campaña y límites de cuenta regresiva.

### Carro y capas móviles

La interfaz de usuario compartida se comunica con `window.PoolCartProvider` a través de scripts e inclusiones de tiempo de ejecución del carrito existentes. Stripe es propietario del iframe de pago. No introduzca una segunda ruta de carrito ni parches DOM de carrito alojado.

El menú móvil para alternar obtiene un apilamiento elevado solo mientras `.is-open`; su estado cerrado debe permanecer debajo de la superposición del carrito. Reutilice `_includes/header.html` y el patrón anclado de Plataforma `shared/dust-wave-platform/packages/design-core/styles/_layout.scss` al cambiar la navegación o los cuadros de diálogo. Las actualizaciones de código compartido siguen los límites inmutables de la Plataforma; no parchee el submódulo en su lugar.

### Ayudantes de accesibilidad y localización

Utilice `.sr-only` para admitir texto, controles etiquetados, estado SVG decorativo y el comportamiento de enfoque/regiones en vivo existentes. `_includes/a11y.html` suministra los patrones `sr-text` y `external-link`. Las imágenes significativas requieren texto alternativo; Las imágenes decorativas intencionadas utilizan el estado decorativo explícito.

Las cadenas compartidas utilizan `_includes/t.html`, con interpolación y reserva de configuración regional. Los enlaces públicos utilizan los ayudantes locales; La preservación de token/consulta/hash es parte del contrato de esos ayudantes. Consulte [Accessibility](/es/docs/operations/accessibility/) y [I18N](/es/docs/development/internationalization/) para conocer los requisitos de verificación y comportamiento mantenido.
