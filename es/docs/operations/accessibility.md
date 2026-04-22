---
title: Accesibilidad
parent: Operaciones
nav_order: 9
render_with_liquid: false
lang: es
---

# Accesibilidad

Este documento rastrea la línea base de accesibilidad actual de The Pool, las superficies de interacción de mayor riesgo que verificamos activamente y el trabajo de seguimiento restante necesario para pasar de una "postura de accesibilidad fuerte" hacia un cumplimiento de accesibilidad más completo.

## Prioridades actuales

Las prioridades actuales de accesibilidad son:

- preservar los patrones de interfaz de usuario y el lenguaje visual establecidos del sitio
- mejorar la semántica de ARIA y el comportamiento del teclado en superficies interactivas
- Evite introducir regresiones de seguridad, especialmente en torno al flujo de pago de Stripe en el sitio.
- agregue controles automatizados para viajes críticos en lugar de depender únicamente de la revisión manual

## Línea de base actual

El sitio ya incluye:

- soporte para saltar enlace
- Puntos de referencia ARIA (`main`, `contentinfo`, regiones activas cuando corresponda)
- estados de enfoque visibles a través del sistema de diseño existente
- Utilidades auxiliares del lector de pantalla
- anclajes `main-content` estables en los shells públicos principales para que los enlaces de salto y el enfoque del teclado aterricen de manera consistente
- Etiquetado de activación del carrito que refleja tanto el recuento de artículos como el total mostrado para tecnología de asistencia en lugar de exponer solo el ícono cromado.

El reciente pase de refuerzo de accesibilidad agregó:

- semántica de diálogo, manejo de escape, captura de enfoque e intentos de restauración de enfoque para:
  - el carrito / sidecar de caja
  - el modal de confirmación de compromiso de gestión
  - el modal `Update Card`
- mejores relaciones entre campo y error en el proceso de pago en el sitio y en los flujos `Update Card`
- Comportamiento de la pestaña del teclado estilo APG para:
  - pestañas del diario de producción
  - pestañas de la fase de producción
- Comportamiento de la galería en carrusel compatible con teclado en páginas de campañas públicas:
  - regiones de desplazamiento enfocables
  - FlechaIzquierda / FlechaDerecha navegación
  - Inicio / Finalizar atajos de desplazamiento
- Semántica de control deslizante más sólida para controles de punta de plataforma:
  - etiquetas descriptivas
  - `aria-describedby`
  - dinámico `aria-valuetext`
- región activa y semántica de alertas para superficies clave de estado/error
- Posibilidades de pantalla pequeña más seguras para flujos con gran cantidad de dispositivos móviles:
  - objetivos de cierre/eliminación más grandes en el sidecar del carrito
  - Superposiciones de navegación y carrito con reconocimiento de área segura
  - mejor comportamiento de ajuste para texto de acción localizado y filas de resumen
- semántica de la página de campaña y pulido del teclado para:
  - Enfoque la transferencia desde el CTA de soporte móvil a la sección de niveles.
  - Texto de estado de cuenta regresiva del lector de pantalla que refleja el estado del temporizador visual.
  - Semántica de carga y agrupación de videos de héroes más clara.
  - Ajuste de pantalla pequeña más seguro para mosaicos de cuenta regresiva, metadatos de creadores y acciones de avance de la comunidad.

## Superficies críticas

La interfaz de usuario sensible a la accesibilidad más importante en la aplicación en este momento es:

1. Carrito/sidecar de caja
2. Gestionar compromiso confirmar modal
3. Administrar compromiso modal `Update Card`
4. Pestañas de fase de campaña y pestañas de diario
5. Deslizadores de punta de plataforma
6. Medios de página de campaña pública y bloques de contenido de formato largo

Estas superficies son más importantes porque combinan una interfaz de usuario personalizada, cambios de estado dinámicos y acciones de usuario de alto valor.

## Barandillas

Los cambios de accesibilidad deben preservar estas limitaciones:

- no mueva los campos de pago fuera de la interfaz de usuario segura propiedad de Stripe solo para obtener control de estilo o semántica
- no agregue persistencia de navegador de larga duración para el estado de accesibilidad
- no debilite el CSP ni el endurecimiento del proceso de pago para respaldar el comportamiento de conveniencia
- prefiera elementos nativos y mejoras semánticas de bajo riesgo a los widgets personalizados

## Cobertura automatizada

La cobertura automatizada actual relacionada con la accesibilidad incluye:

- Cobertura de unidades para semántica de diálogo y manejo de teclado en:
  - `tests/unit/cart-provider.test.ts`
  - `tests/unit/manage-page.test.ts`
- Cobertura unitaria para enlaces de salto de shell público y puntos de referencia principales en:
  - `tests/unit/layout-accessibility.test.ts`
- Cobertura unitaria para etiquetas accesibles con activación por carrito y estado ampliado en:
  - `tests/unit/cart-icon.test.ts`
- Cobertura unitaria para pestañas de teclado en:
  - `tests/unit/diary-tabs.test.ts`
  - `tests/unit/campaign-tabs.test.ts`
- Verificaciones de superficies críticas con hacha en:
  - `tests/unit/accessibility-critical-surfaces.test.ts`
- La semántica de la página de la campaña se verifica en:
  - `tests/unit/campaign-page.test.ts`
- cobertura más amplia de hacha de página pública en:
  - `tests/e2e/accessibility-public-pages.spec.ts`
  - esto cubre actualmente:
    - la pagina de inicio
    - una página de campaña en vivo
    - una página de campaña no activa
    - una página posterior a la campaña
    - una página de campaña de artículo físico
    - una página de campaña de formato largo y con mucha comunidad
    - la página Acerca de
    - la página de términos
    - la página de promesa de éxito
    - la página de compromiso cancelado
    - la página de índice de la comunidad
    - la página denegada de la comunidad de seguidores
    - la página de contenido de la comunidad de seguidores
  - El barrido de accesibilidad de páginas públicas respaldado por Podman es la verificación final preferida cuando las sucursales cambian contenido público, páginas públicas respaldadas por documentos o Chrome de páginas de campaña sin necesidad de host Bundler/Jekyll.
- Cobertura instantánea de ARIA en Playwright para:
  - regiones principales de la página pública clave
  - el cuadro de diálogo de carrito/pago durante los flujos de solo teclado
  - Estas afirmaciones ayudan a fijar la estructura de árbol de accesibilidad que consumen las tecnologías de asistencia.
- aserciones de pago solo con teclado en:
  - `tests/e2e/campaign-checkout.spec.ts`
  - estos verifican que la ruta de pago propia se puede avanzar mediante el teclado a través del paso de guardar en el sitio
- aserciones de flujo de administración solo de teclado en:
  - `tests/e2e/manage-flows.spec.ts`
  - estos verifican que la modificación del compromiso, la cancelación y la actualización del método de pago sigan siendo utilizables sin necesidad de ingresar un puntero
- afirmaciones de la comunidad de seguidores solo con teclado en:
  - `tests/e2e/community-flows.spec.ts`
  - estos verifican que la CTA de estado denegado, la navegación hacia atrás del partidario y la votación sigan siendo utilizables sin la entrada del puntero.
- aserciones de control de página pública secundaria de solo teclado en:
  - `tests/e2e/public-page-controls.spec.ts`
  - estos verifican que la navegación por la pestaña del diario, la navegación por la galería en carrusel, la entrada de cantidades personalizadas, la entrada de elementos de soporte y la activación del avance de la comunidad de seguidores sigan siendo utilizables sin necesidad de ingresar un puntero.

Ejecute el segmento de accesibilidad enfocado con:

```bash
./node_modules/.bin/vitest run \
  tests/unit/accessibility-critical-surfaces.test.ts \
  tests/unit/cart-provider.test.ts \
  tests/unit/manage-page.test.ts \
  tests/unit/campaign-page.test.ts \
  tests/unit/diary-tabs.test.ts \
  tests/unit/campaign-tabs.test.ts
```

Para la puerta local más amplia, utilice:

```bash
./scripts/pre-merge-regression.sh
```

Para una sección más amplia de accesibilidad del navegador, utilice:

```bash
./scripts/podman-playwright-run.sh npx playwright test \
  tests/e2e/accessibility-public-pages.spec.ts \
  tests/e2e/manage-flows.spec.ts \
  tests/e2e/community-flows.spec.ts \
  tests/e2e/public-page-controls.spec.ts \
  tests/e2e/campaign-checkout.spec.ts \
  --project=chromium \
  --grep "Public Page Accessibility|keyboard-only|Community Flows|Public Page Keyboard Controls"
```

Para un barrido de accesibilidad de página pública más limitado respaldado por Podman que evita la configuración del host Bundler/Jekyll, utilice:

```bash
npm run test:e2e:headless:podman -- tests/e2e/accessibility-public-pages.spec.ts --project=chromium
```

Para la pila de desarrollo local recomendada, prefiera:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

## Comprobaciones manuales

Las comprobaciones automáticas ayudan, pero estas comprobaciones de accesibilidad manuales siguen siendo importantes antes de fusionarlas para realizar cambios significativos en la interfaz de usuario:

- El cajón del carrito se puede abrir, navegar y cerrar solo con el teclado.
- El disparador del carrito anuncia una etiqueta útil y un estado expandido/contraído para tecnología de asistencia.
- El sidecar de pago mantiene estable el comportamiento de enfoque mientras Stripe monta y valida los campos.
- El modal `Update Card` se puede utilizar solo con el teclado.
- Las interfaces de campaña con pestañas responden correctamente a la navegación con el teclado.
- Los controles secundarios de la página de campaña, como las pestañas del diario y las galerías de carrusel, siguen siendo utilizables solo con el teclado.
- Los widgets de campañas públicas, como cantidades personalizadas, elementos de apoyo y avances de la comunidad de seguidores, siguen siendo utilizables solo con el teclado.
- Las galerías de carrusel permanecen enfocables con el teclado y se desplazan correctamente con las teclas de flecha y Inicio/Fin.
- Los controles deslizantes de punta siguen siendo utilizables con ajustes repetidos de las teclas de flecha.
- La votación comunitaria sigue siendo operativa con interacción solo con teclado.
- Los mensajes de error son comprensibles y aparecen cerca de los campos correctos.

## Límites aceptados

Algunos límites de accesibilidad son inherentes al modelo de seguridad:

- Los campos de la tarjeta de crédito se muestran dentro de la interfaz de usuario segura propiedad de Stripe.
- El autocompletado del navegador y la semántica a nivel de campo dentro de los iframes de Stripe están controlados en parte por Stripe, no por The Pool.
- Podemos mejorar las etiquetas circundantes, el flujo y el manejo de errores, pero no podemos reescribir directamente el DOM interno de Stripe.
