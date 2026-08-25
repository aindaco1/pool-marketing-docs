---
title: Guía para agentes y operadores
parent: Desarrollo
nav_order: 10
render_with_liquid: false
lang: es
---

# Guía para agentes y operadores

## Última actualización

25 de agosto de 2026

Esta es la guía operativa para personas y agentes de codificación que trabajan en **The Pool**. Úselo para realizar cambios seguros sin desincronizar el sitio estático, Cloudflare Worker, las matemáticas de pago, la administración privada o el comportamiento localizado.

Léelo junto a:

- [README.md](/es/docs/development/platform-readme/) para ver la descripción general del producto y la arquitectura
- [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/) para conocer la superficie de configuración orientada hacia la horquilla admitida
- [docs/PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) para Stripe, pago canónico, webhooks, liquidación y conciliación
- [docs/TAX_CALCULATOR.md](/es/docs/operations/tax-calculator/) para proveedores de impuestos, cotizaciones canónicas, configuración reflejada y verificación
- [docs/ADD_ON_PRODUCTS.md](/es/docs/development/add-on-products/) para conocer los precios de complementos específicos de la plataforma, la campaña y la variante
- [docs/DASHBOARD.md](/es/docs/operations/admin-dashboard/) para administración y edición privadas
- [docs/PERFORMANCE.md](/es/docs/operations/performance/) para presupuestos, Lighthouse, almacenamiento en caché y observabilidad en tiempo de ejecución
- [docs/SECURITY.md](/es/docs/operations/security/) para conocer los límites de seguridad y los controles de liberación
- [docs/BACKUP_RESTORE.md](/es/docs/operations/backup-restore/) para respaldo, restauración y recuperación ante desastres
- [docs/TESTING.md](/es/docs/operations/testing/) para verificación local y puertas de fusión
- [docs/ROADMAP.md](/es/docs/reference/roadmap/) solo para trabajos potenciales
- [CHANGELOG.md](/es/docs/reference/changelog/) y [docs/release-evidence/](https://github.com/your-org/your-project/tree/main/docs/release-evidence) para ver el historial de versiones completo y los registros de verificación

## Forma del proyecto

The Pool es un sistema dividido:

- Jekyll, Sass y JavaScript del navegador crean el sitio estático publicado a través de GitHub Pages.
- El Cloudflare Worker en `worker/` posee API, validación de pago canónico, persistencia de aportes, correos electrónicos, estadísticas en vivo, liquidación, tarjetas compartidas y administración privilegiada.
- Stripe recopila pagos y almacena métodos de pago.
- La configuración de la campaña se encuentra principalmente en `_campaigns/`; La configuración de la plataforma y los productos se encuentran en `_config.yml`.
- El panel privado es la superficie del navegador compatible con configuraciones, complementos, campañas, informes, análisis, patrocinadores, enlaces de marketing, diagnósticos y usuarios.

Si un cambio afecta el precio, la disponibilidad, el progreso de la campaña, el estado del aporte, el contenido del correo electrónico o el estado de la campaña activa, suponga que tanto el sitio como Worker están involucrados incluso cuando el síntoma aparezca en un solo lado.

## fuentes de verdad

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml): configuración canónica de plataforma orientada hacia la horquilla
- [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml): solo anulaciones locales de la máquina
- [`_campaigns/`](https://github.com/your-org/your-project/tree/main/_campaigns): contenido de la campaña, niveles, objetivos, datos del diario y complementos de la campaña
- [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n): interfaz de usuario localizada compartida, tiempo de ejecución y copia por correo electrónico
- [`_data/media-optimization-manifest.json`](https://github.com/your-org/your-project/blob/main/_data/media-optimization-manifest.json): metadatos de medios del repositorio reconstruibles; Los archivos fuente siguen siendo autorizados.
- [`_layouts/`](https://github.com/your-org/your-project/tree/main/_layouts) y [`_includes/`](https://github.com/your-org/your-project/tree/main/_includes): páginas públicas, páginas de campaña, incrustaciones, SEO y ayudantes locales
- [`assets/`](https://github.com/your-org/your-project/tree/main/assets): tiempo de ejecución del navegador, Sass, temas y recursos localizados generados
- [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src): pago autorizado, webhooks, estadísticas, correos electrónicos, liquidación, administración e informes
- [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml): cableado del entorno Worker y valores predeterminados reflejados
- [`config/performance-budgets.json`](https://github.com/your-org/your-project/blob/main/config/performance-budgets.json): umbrales de rendimiento del ejecutable público y del tiempo de ejecución
- [`config/pool-data-inventory.json`](https://github.com/your-org/your-project/blob/main/config/pool-data-inventory.json): inventario de clasificación, retención y recuperación de datos
- [`tests/`](https://github.com/your-org/your-project/tree/main/tests): unidad, seguridad, accesibilidad y contratos de extremo a extremo
- [`scripts/`](https://github.com/your-org/your-project/tree/main/scripts): desarrollo local, puertas de liberación, pruebas de humo, auditorías y sincronización
- [`docs/release-evidence/`](https://github.com/your-org/your-project/tree/main/docs/release-evidence): registros de verificación específicos de la versión

## Flujo de trabajo seguro

Inspeccione `git status` antes de editar. Los cambios existentes pertenecen al usuario a menos que la tarea los incluya explícitamente; no los sobrescriba, los descarte ni los incluya silenciosamente en una confirmación.

Para un desarrollo local normal:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Utilice la prueba enfocada más específica que demuestre un cambio, luego ejecute la puerta previa a la fusión completa para un cambio sustancial o de lanzamiento:

```bash
npm run test:premerge
```

Los controles enfocados útiles incluyen:

- `bundle exec jekyll build --quiet`
- `npx vitest run <targeted test files>`
- `node --check <changed JavaScript file>`
- `npx playwright test tests/e2e/admin-dashboard.spec.ts --project=chromium`
- `npm run test:performance:budgets`
- `npm run test:performance:lighthouse`
- `npm run test:performance:runtime -- --input=<redacted-observability.json>`
- `npm run test:cache-policy`
- `npm run production:posture -- --no-dev-vars`
- `npm run release:smoke -- --evidence-file <path>`

Los resultados de la postura de producción, el caché y la liberación de humo solo se completan cuando las credenciales y secretos de proveedor requeridos estaban disponibles. Registre las omisiones explícitamente en la evidencia de divulgación.

## Caminos de cambio comunes

### Campañas

Utilice la pestaña **Campañas** del panel para realizar ediciones normales. Las fuentes subyacentes son `_campaigns/<slug>.md` y `assets/images/campaigns/<slug>/`.

Verifique la financiación y los cálculos de objetivos ampliados, el inventario de niveles, el envío de recompensas físicas, el enrutamiento localizado, las incorporaciones y comparta vistas previas.

### Marca, configuración y productos.

Utilice el panel **Configuración** y **Complementos** para realizar ediciones normales. Las configuraciones publicadas y los complementos de la plataforma finalmente escriben en `_config.yml` a través de la ruta GitHub controlada por Worker. Los usuarios administradores y los códigos de referencia de marketing guardados son excepciones de tiempo de ejecución almacenadas en Worker KV.

Cuando la configuración reflejada cambie, reinicie la pila local o ejecute:

```bash
npm run sync:worker-config
```

El precio adicional a nivel de producto es el predeterminado. Una variante puede heredarla o publicar su propia anulación entre `$0` y el techo canónico `$1,000,000`. Mantenga alineadas la normalización del panel, la visualización del carrito público, la validación de Worker y la documentación.

### Gestión de pagos y aportes

Comience con el código del navegador en `assets/js/`, las plantillas en `_includes/` y `_layouts/`, el código Worker en `worker/src/` y [docs/PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/).

Mantenga alineados el subtotal, las anulaciones de precios de variantes, las propinas, los impuestos, los envíos, las contribuciones a la campaña, los datos de aportes persistentes, los correos electrónicos y los informes. El navegador propone estado; el Worker resuelve productos y precios y decide totales canónicos.

### Comunicación por correo electrónico y con los patrocinadores

Verifique la lógica de correo Worker, `_data/i18n/`, la configuración del remitente y [docs/EMAIL.md](/es/docs/operations/email-system/). Preservar la alineación del dominio, `reply_to`, la salida de texto sin formato, las URL de medios alojados, el comportamiento de idempotencia/bandeja de salida duradera, la supresión global/de campaña y el límite entre el contenido transaccional y promocional. El inicio de sesión de administrador y los envíos de prueba explícitos siguen siendo inmediatos.

### Medios de comunicación

El árbol de activos del repositorio tiene autoridad. Reconstruir `_data/media-optimization-manifest.json` con `npm run media:manifest`; no cree un catálogo de medios respaldado por KV. Utilice el envío del optimizador GitHub existente para reparar todos los cambios o todos los cambios, preservar los archivos de origen y los derivados más grandes omitidos intencionalmente, requerir texto alternativo para imágenes significativas y usar el estado de imagen decorativa explícito para el texto alternativo vacío.

### Inserta, SEO y comparte tarjetas

Verifique el código de tarjeta compartida `embed/`, `_layouts/campaign-embed.html`, `assets/js/campaign-embed.js`, `assets/partials/_embed.scss`, Worker, `_includes/seo-meta.html` y los documentos de inserción/SEO. Mantenga alineados conceptualmente el estado de la página de la campaña, la inserción y la vista previa.

### Localización

Las cadenas de sistema compartidas pertenecen a `_data/i18n/<lang>.yml`; El contenido de campaña escrito por el creador normalmente sigue siendo contenido de campaña. Las nuevas rutas y flujos públicos deben tener en cuenta los asistentes locales, la generación de campañas localizadas y el conmutador de idioma del pie de página.

## Invariantes a proteger

1. **`_config.yml` es canónico.** No cree una segunda fuente de verdad del producto en la configuración local o en el estado del navegador.
2. **La configuración reflejada de Worker permanece sincronizada.** Los precios, las URL, la identidad del remitente y otros valores reflejados deben coincidir con el sitio.
3. **Los totales de pago están verificados por el servidor.** Las selecciones de productos/variantes nuevos o modificados utilizan los precios del catálogo actual; un producto/variante guardado sin cambios puede conservar su `unitPrice` histórico. Los montos del catálogo y de los centavos persistentes deben permanecer dentro del límite de monto de Worker.
4. **El progreso de la campaña tiene un límite preciso.** Los niveles, el apoyo directo a la campaña, los montos de las campañas personalizadas y los complementos de la campaña cuentan. Los complementos de plataforma, propina de plataforma, impuestos y envío no lo hacen.
5. **Las rutas localizadas son un contrato público.** Preservar el enrutamiento local y el comportamiento de token/consulta.
6. **Los flujos privados permanecen privados.** La administración, el resultado del aporte, la vista previa protegida, el administrador autenticado y las respuestas de observabilidad del rendimiento deben permanecer no indexables y usar controles de caché privados/sin almacenamiento cuando corresponda. Las listas permitidas de vista previa pertenecen solo a Worker KV de corta duración.
7. **Las campañas finalizadas no se comportan como activas.** El comportamiento de cuenta regresiva, aporte, inserción y vista previa debe utilizar el estado de campaña efectivo.
8. **Los umbrales de rendimiento son ejecutables.** Un valor en la configuración no es una puerta hasta que una prueba o auditoría lo consume. Distinga la línea de base medida del umbral de publicación, utilice presupuestos públicos específicos de la ruta y mantenga la evidencia autenticada en tiempo de ejecución libre de secretos y datos personales.
9. **Los hallazgos de dependencia tienen un alcance y se resuelven deliberadamente.** Ejecute la auditoría de producción y la auditoría completa. Fijar o reemplazar herramientas de liberación vulnerables cuando exista una versión compatible segura; documentar cualquier hallazgo aceptado solo para desarrolladores.
10. **La revisión ética viaja con los cambios de productos.** Revise el dinero, los datos, los mensajes, los análisis, la automatización, el poder administrativo, la visibilidad y la capacidad de compartir mientras la implementación sigue siendo fácil de cambiar.
11. **La recuperación del pago no debe inventar un segundo cargo.** Persistir en la intención de liquidación antes de que llame Stripe, reutilizar la idempotencia determinista dentro de la ventana del proveedor y detener el trabajo antiguo y ambiguo para la conciliación. No agregue la recuperación manual de movimiento de dinero sin operadores distintos de creador/comprobador.
12. **La entrega de correo electrónico es independiente de la verdad del aporte.** Los efectos secundarios de las notificaciones de producción pasan por la bandeja de salida compartida; La falla del proveedor no debe revertir ni mutar el estado de aporte canónico.

## Mapa de documentación

- Configuración de bifurcación: [docs/CUSTOMIZATION.md](/es/docs/development/customization-guide/)
- Historial de versiones: [CHANGELOG.md](/es/docs/reference/changelog/)
- Trabajo prospectivo: [docs/ROADMAP.md](/es/docs/reference/roadmap/)
- Pagos y liquidación: [docs/PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/)
- Cálculo de impuestos: [docs/TAX_CALCULATOR.md](/es/docs/operations/tax-calculator/)
- Productos complementarios y precios de variantes: [docs/ADD_ON_PRODUCTS.md](/es/docs/development/add-on-products/)
- Correo electrónico: [docs/EMAIL.md](/es/docs/operations/email-system/)
- Pruebas: [docs/TESTING.md](/es/docs/operations/testing/)
- Podman: [docs/PODMAN.md](/es/docs/operations/podman-local-dev/)
- Localización: [docs/I18N.md](/es/docs/development/internationalization/)
- SEO y vistas previas: [docs/SEO.md](/es/docs/operations/seo/)
- Inserciones de campaña: [docs/EMBEDS.md](/es/docs/development/campaign-embeds/)
- Envío: [docs/SHIPPING.md](/es/docs/operations/shipping/)
- Panel de control: [docs/DASHBOARD.md](/es/docs/operations/admin-dashboard/)
- Rendimiento: [docs/PERFORMANCE.md](/es/docs/operations/performance/)
- Seguridad: [docs/SECURITY.md](/es/docs/operations/security/)
- Copia de seguridad y recuperación: [docs/BACKUP_RESTORE.md](/es/docs/operations/backup-restore/)
- Riesgo ético: [docs/ETHICAL_RISK.md](/es/docs/development/ethical-risk-review/)
- Fusionar y liberar comprobaciones: [docs/MERGE_SMOKE_CHECKLIST.md](/es/docs/operations/merge-smoke-checklist/)

## Estilo de trabajo para agentes codificadores.

- Lea la implementación y las pruebas cercanas antes de proponer cambios estructurales.
- Prefiere ediciones pequeñas y locales que preserven los patrones establecidos y permanezcan SECO.
- Actualice las pruebas y los documentos del operador cada vez que cambien el comportamiento o las expectativas de lanzamiento.
- Considere en conjunto las consecuencias del sitio público, Worker, correo electrónico, localización, accesibilidad, seguridad, rendimiento y recuperación.
- Reutilice una superficie de configuración o ayuda existente antes de inventar otra.
- Nunca descarte silenciosamente el comportamiento local, incrustado, de vista previa compartida, de caché privada o de precios históricos.
- Conserve los cambios de usuario no relacionados y organice solo los archivos dentro del alcance.
- Mantenga los documentos del estado actual en tiempo presente y basados ​​en comportamientos verificados. Coloque las propuestas y el trabajo diferido solo en la hoja de ruta y coloque el historial de lanzamientos completo solo en el registro de cambios o en la evidencia de lanzamiento.

Cuando no esté seguro, realice el cambio más pequeño que mantenga alineados el sitio y Worker, pruébelo con la prueba significativa más estrecha y ejecute la puerta más amplia cuando esté justificado.
