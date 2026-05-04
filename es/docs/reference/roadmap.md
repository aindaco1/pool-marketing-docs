---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

Esta hoja de ruta está organizada como un historial de lanzamiento de los estados reales del proyecto que realmente utilizamos, en lugar de una lista plana de funciones completadas.

## Historial de lanzamientos

### v0.5 — Lanzamiento de WME

Esta fue la primera versión utilizada para lanzar WME y probar el modelo de plataforma central en la naturaleza.

Nuevo en esta versión:

- Sitio de campaña pública Jekyll + GitHub Pages con un sistema de presentación de campaña funcional
- Backend de Cloudflare Worker para almacenamiento de promesas, estadísticas en vivo, correos electrónicos y automatización del ciclo de vida de campañas
- Lógica de campaña de todo o nada con cobro diferido en lugar de captura inmediata
- Gestión de seguidores sin cuenta a través del acceso a promesas de enlace mágico.
- Financiamiento de campañas con niveles, elementos de apoyo, montos personalizados e informes básicos posteriores al compromiso.
- Diario de producción y fundamentos de actualización de los seguidores para la comunicación de los creadores.
- Integración de Pages CMS para que el contenido de la campaña pueda editarse sin un flujo de trabajo puro de Git

### v0.6 — Estado Pre-Tecolote

Este era el estado del proyecto justo antes del lanzamiento de Tecolote. El énfasis aquí era hacer que el sistema fuera más confiable para una segunda campaña real con contenido más pesado y más casos extremos.

Nuevo en esta versión:

- preparación para múltiples campañas en lugar de una prueba de concepto de una sola campaña
- Manejo más estricto de plazos, correcciones de zonas horarias y transiciones entre estados de campaña.
- Mejoras en la reconstrucción de la implementación y la eliminación de caché en torno a los cambios de estado de la campaña.
- correcciones de confiabilidad del correo electrónico de hitos y correcciones de errores de liquidación de la experiencia WME
- comportamiento mejorado de gestión de promesas una vez que las campañas pasaron su ventana en vivo
- Se necesita mejor soporte para activos de campaña más completos, copia pública actualizada y trabajo de pulido de lanzamiento para Tecolote.

### v0.7 — Control deslizante de punta de plataforma

Esta versión introdujo el sistema opcional de punta de plataforma y lo convirtió en una parte de primera clase de la experiencia de los seguidores.

Nuevo en esta versión:

- sugerencias de plataforma opcionales de `0%` a `15%`, con `5%` como valor predeterminado
- Control deslizante de propinas y totales con reconocimiento de propinas en el carrito, en el proceso de pago y en Administrar promesa
- Actualizaciones resumidas instantáneas para que los seguidores puedan ver los cambios de subtotales, propinas y totales de inmediato.
- correos electrónicos de seguidores con información sobre sugerencias y documentación sobre el flujo de promesas
- Diseño de página de administración mejorado y capacidad de respuesta en torno a la edición de sugerencias y los intercambios de niveles.
- Mayor estabilidad de pago local y cobertura automatizada más amplia para flujos de promesas de propinas.

### v0.8: refuerzo de la seguridad

Esta versión fue el pase de endurecimiento que hizo que el proyecto pasara de ser “funcional” a “defendible”.

Nuevo en esta versión:

- Pago más estricto y verificación de tokens en torno a los flujos de compromisos propios.
- webhook, administración y fortalecimiento de la lógica empresarial en todo el Worker
- controles más estrictos de preparación para la fusión y flujos de trabajo de humo locales para rutas de compromiso sensibles
- Pruebas locales mejoradas y herramientas de desarrollo para que el trabajo de refuerzo pueda validarse repetidamente.
- automatización de implementación para el trabajador en `main`
- un alejamiento más claro de los supuestos de carritos alojados heredados y hacia el nuevo modelo de pago propio

### v0.9 — Hito local `0.9`

Este fue el gran hito local marcado por el compromiso `Version 0.9 complete` del repositorio. Representó la primera versión que parecía una plataforma ampliamente reutilizable en lugar de una implementación específica de una campaña.

Nuevo en esta versión:

- flujo de pago nativo de Stripe dentro del sitio, además del mismo patrón seguro para `Update Card`
- Desarrollo y pruebas locales respaldados por Podman
- Protección contra sobreventa de inventario limitado con un coordinador por campaña.
- Fortalecimiento de la accesibilidad en cuadros de diálogo, pestañas, controles deslizantes, regiones en vivo y flujos clave de público/partidarios.
- Rediseño del sistema de diseño compartido, pase de capacidad de respuesta móvil y limpieza más amplia del sistema de estilo.
- Personalización de primera variable para bifurcaciones a través de configuración estructurada y duplicación de trabajadores.
- Finalización de i18n en inglés/español para páginas públicas, flujos de soporte clave y copia en tiempo de ejecución compartida
- Fundamentos de SEO que incluyen metadatos canónicos, datos estructurados, manejo de mapas de sitio/robots y mejoras en las tarjetas compartidas.
- La calculadora de envío funciona con cotizaciones de USPS, comportamiento alternativo y manejo de opciones de entrega.
- complementos de plataforma, complementos de campaña, comprobaciones de deriva de proyección y madurez más amplia de informes/operaciones

### v0.9.1: uso compartido de campañas integrado

Este lanzamiento puntual fue el primer seguimiento importante después del hito más importante `0.9`. El énfasis aquí era hacer que el intercambio de campañas, las incrustaciones y el pulido posterior al pago se sintieran como parte del producto en lugar de experimentos complementarios.

Nuevo en esta versión:

- Comportamiento mejorado de confirmación de pago y entrega de correo electrónico a los seguidores.
- Widget de inserción de campaña en vivo alojado y flujo de creación de inserción más completo
- Vistas previas de tarjetas compartidas de campaña más completas y alineadas con el lenguaje de diseño integrado.
- incrustar enlaces cerrados y rutas de retorno pulidos para widgets de campaña
- Trabajo de limpieza y lanzamiento de documentos después del hito más importante `0.9`
- Limpieza del comportamiento de cuenta regresiva para que las cuentas regresivas de campañas vencidas dejen de mostrarse después de las fechas límite.

### v0.9.2 — Madurez de comercio y cumplimiento

Esta versión convirtió la plataforma de “niveles de campaña más envío básico” a un sistema de comercio y cumplimiento más completo.

Nuevo en esta versión:

- Productos complementarios para toda la plataforma con reconocimiento de inventario, manejo de existencias bajas, soporte de variantes e integración de carrito completo/Administrar compromiso
- complementos específicos de la campaña que reutilizan los mismos patrones de interfaz de usuario y al mismo tiempo cuentan para el subtotal y la lógica de financiación de la campaña propietaria.
- Trabajo de calculadora de envíos que reemplazó el antiguo modelo de tarifa física plana con cotizaciones canónicas de Worker respaldadas por USPS, comportamiento alternativo, anulaciones de envío gratuito y actualizaciones de opciones de entrega limitadas.
- cambios en los informes que mantuvieron los ingresos por promesas de campaña, los ingresos por complementos de la plataforma y la propiedad del cumplimentador más diferenciados desde el punto de vista operativo
- trabajo de seguimiento de envío en torno a una cobertura de humo real acreditada por USPS, UX en modo de estimación, datos compartidos del país de envío y un manejo más seguro para casos de correo plano/tarifa manual

### v0.9.3: Informes y fortalecimiento del operador

Esta versión se centró en hacer que la plataforma fuera más fácil de operar de forma segura una vez que la superficie comercial se volviera más compleja.

Nuevo en esta versión:

- Diagnósticos de deriva de proyección de solo lectura más herramientas de operador local para que las estadísticas, el inventario y los índices de campaña puedan verificarse antes de que el trabajo de reparación cambie algo.
- endurecimiento de denegación de servicio con `RATELIMIT` KV requerido, límites de velocidad de ruta de escritura más estrictos, rechazo más temprano de carga útil de gran tamaño y presupuesto de reintento más seguro alrededor de `checkout-intent/abandon`
- un techo `cpu_ms` conservador más resúmenes de observabilidad livianos y comprobaciones de observabilidad locales para ajustar el costo y el comportamiento de los trabajadores
- Informes del ejecutor de campaña con `runner_report_emails`, configuración limitada de `reports.campaign_runner`, correos electrónicos diarios de contabilidad de campañas en vivo y flujos de cumplimiento posteriores a la fecha límite divididos para quienes cumplen con la campaña versus la plataforma.
- un núcleo de informes compartido para que los correos electrónicos programados de los ejecutores y las exportaciones CLI locales dejen de desviarse entre sí

### v0.9.4: Pago con reconocimiento de impuestos

Este lanzamiento convirtió el proceso de pago con conocimiento de impuestos en una parte de primera clase de la plataforma y completó el trabajo de pulido necesario para que el proyecto se sintiera más en forma de producción.

Nuevo en esta versión:

- cálculo de impuestos impulsado por el proveedor a través de los modos `flat`, `offline_rules`, `nm_grt` y `zip_tax` en lugar de un solo supuesto de tasa fija
- UX de impuesto provisional en el carrito y en el proceso de pago para que el navegador pueda mostrar `--` hasta que el Trabajador tenga suficientes detalles de facturación o destino de envío para devolver una respuesta real
- Conexión del destino final del impuesto en el carrito, pago personalizado, gestión de compromiso, datos de compromiso almacenados y correos electrónicos de apoyo para que las matemáticas de impuestos se mantengan consistentes en todas partes.
- un camino gratuito primero en Nuevo México a través de un conjunto de datos inicial proporcionado más un refinamiento EDAC opcional, junto con una mejor cobertura de humo local para configuraciones de impuestos impulsadas por el proveedor
- Se ha compartido el pulido de la marca de la bifurcación, por lo que la misma superficie de configuración ahora presenta temas en el sitio Stripe Elements, correos electrónicos de soporte y más de la capa de metadatos localizados.
- trabajo de seguimiento localizado, como resúmenes de los botones del carrito, copia auxiliar de ubicación de impuestos en el proceso de pago y metadatos públicos con reconocimiento regional/JSON-LD para que los flujos con reconocimiento de impuestos aún se lean claramente en inglés y español.

### v0.9.5: Paridad de tiempo de ejecución local y transferencia de lanzamiento del creador

Este es el hito de lanzamiento local actual reflejado en la aplicación y los documentos. El objetivo era mantener el desarrollo de los trabajadores locales alineado con el comportamiento de implementación de la producción y, al mismo tiempo, reforzar la transferencia pública de material que los creadores necesitan antes del lanzamiento.

Nuevo en esta versión:

- El desarrollo de Podman Worker ahora se ejecuta en el Nodo 24 para coincidir con las implementaciones de GitHub Actions
- Los scripts de host y ayuda de Podman ahora prefieren el Nodo 24 y ya no fuerzan la ruta obsoleta del Nodo 20 Wrangler.
- El desarrollo local de Wrangler 4 se ejecuta según la fecha de compatibilidad de Worker `2026-05-03`, lo que evita el antiguo fallo del polyfill en tiempo de ejecución local en el Nodo 24.
- La configuración de dependencia de Podman Worker ahora usa `npm ci` para que los inicios de contenedores locales no muten `worker/package-lock.json`
- la lista de verificación pública para creadores de campañas ahora cubre complementos de campaña, promoción de códigos de inserción, decisiones de envío alternativo/envío gratuito, expectativas impositivas, destinatarios de informes y transferencia de cumplimiento.
- Ahora existe una ruta de lista de verificación de creadores en español en `/es/creator-campaign-checklist/`.

## Próximo

El trabajo aún planeado después de `0.9.5` incluye:

- un panel de administración y herramientas de operador más sólidas en torno a la campaña, la plataforma y los datos de los seguidores
- una historia de editor de contenido más sólida que la configuración actual de Pages CMS
- Trabajo adicional en la calculadora de impuestos para una cobertura más amplia en EE. UU. e internacional, una mayor profundidad de las jurisdicciones locales y flujos de trabajo de actualización de datos tributarios más claros.
- soporte de precios más flexible para variantes complementarias

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número de tarjeta de crédito, vencimiento y CVC se encuentran dentro de la interfaz de usuario segura controlada por Stripe, por lo que la compatibilidad con el autocompletado del navegador está restringida por Stripe y no por la aplicación circundante.
