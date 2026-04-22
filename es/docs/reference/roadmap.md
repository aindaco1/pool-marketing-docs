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
- Personalización de primera variable para forks a través de configuración estructurada y duplicación de trabajadores.
- Finalización de i18n en inglés/español para páginas públicas, flujos de soporte clave y copia en tiempo de ejecución compartida
- Fundamentos de SEO que incluyen metadatos canónicos, datos estructurados, manejo de mapas de sitio/robots y mejoras en las tarjetas compartidas.
- La calculadora de envío funciona con cotizaciones de USPS, comportamiento alternativo y manejo de opciones de entrega.
- complementos de plataforma, complementos de campaña, comprobaciones de deriva de proyección y madurez más amplia de informes/operaciones

### v0.9.1 — Compartir campañas e embeds

Esta versión fue el primer gran seguimiento después del hito `0.9`. El foco estuvo en hacer que los embeds, las vistas compartidas de campaña y el pulido posterior al checkout se sintieran como parte del producto y no como experimentos laterales.

Nuevo en esta versión:

- comportamiento mejorado de confirmación de checkout y entrega de emails para supporters
- widget alojado de embed de campaña en vivo y un flujo más completo para construir embeds
- vistas previas de share cards de campaña más ricas y alineadas con el lenguaje visual del embed
- pulido de enlaces de cierre y rutas de retorno para widgets de campaña
- limpieza de documentación y trabajo de release polish después del gran hito `0.9`
- limpieza del comportamiento de countdown para que las campañas vencidas dejen de mostrar cuentas regresivas después del deadline

### v0.9.2 — Madurez de comercio y fulfillment

Esta versión convirtió la plataforma en algo más completo que “tiers de campaña más un shipping básico”.

Nuevo en esta versión:

- add-ons globales de plataforma con inventario consciente, manejo de low stock, variantes y soporte completo en cart y Manage Pledge
- add-ons específicos de campaña que reutilizan la misma UI pero siguen contando para el subtotal y la lógica de financiación de la campaña propietaria
- calculadora de shipping que reemplazó el viejo modelo plano para recompensas físicas con cotización canónica del Worker, soporte USPS, fallbacks, free shipping y upgrades limitados de entrega
- cambios en reportes para mantener más claramente separados los ingresos de pledges de campaña, los add-ons de plataforma y la responsabilidad de fulfillment
- seguimiento de shipping con smoke tests reales contra USPS, UX de modo estimado, datos compartidos de países de envío y mejor manejo para casos de tarifa manual o correo plano

### v0.9.3 — Hardening operativo y reportes

Esta versión se enfocó en que la plataforma fuera más fácil de operar de forma segura a medida que crecía la superficie de comercio.

Nuevo en esta versión:

- diagnósticos de projection drift en modo solo lectura y herramientas locales de operador para revisar stats, inventario e índices de campaña antes de ejecutar reparaciones
- hardening contra denegación de servicio con `RATELIMIT` KV obligatorio, límites más estrictos en rutas de escritura, rechazo más temprano de payloads sobredimensionados y presupuestos de reintento más seguros para `checkout-intent/abandon`
- un límite conservador de `cpu_ms`, resúmenes livianos de observabilidad y verificaciones locales para ajustar costo y comportamiento del Worker
- reportes para campaign runners con `runner_report_emails`, configuración acotada en `reports.campaign_runner`, emails diarios de ledger para campañas en vivo y flujos separados de fulfillment para campaign fulfillers y platform fulfillers
- un núcleo compartido de reportes para que los emails programados y las exportaciones locales por CLI no se desalineen

### v0.9.4 — Estado local actual de la aplicación

Este es el hito de release local actual reflejado en la app y en la documentación. El gran tema aquí fue la madurez del checkout con impuestos y la última ronda de pulido para forks.

Nuevo en esta versión:

- cálculo de impuestos por proveedor mediante los modos `flat`, `offline_rules`, `nm_grt` y `zip_tax` en lugar de depender solo de una tasa fija
- UX provisional de impuestos en cart y checkout para que el navegador pueda mostrar `--` hasta que el Worker tenga suficiente información de facturación o envío
- plomería completa del destino fiscal entre cart, custom checkout, Manage Pledge, datos persistidos y emails para supporters para mantener la matemática de impuestos alineada en todas partes
- una ruta gratuita centrada en Nuevo México con dataset vendorizado más refinamiento opcional por EDAC, junto con mejor cobertura local para pruebas bajo proveedores de impuestos por ubicación
- más pulido de branding para forks, de modo que la misma superficie de configuración ahora tematiza Stripe Elements en sitio, emails para supporters y más partes de la capa de metadata localizada
- trabajo de localización adicional como resúmenes de botones del carrito, copy auxiliar sobre ubicación fiscal en checkout y metadata pública / JSON-LD por locale para que los flujos con impuestos sigan leyéndose bien en inglés y español

## Próximo

El trabajo aún planeado después de `0.9.4` incluye:

- un dashboard de administración y herramientas operativas más fuertes para datos de campaña, plataforma y supporters
- una historia de edición de contenido más sólida que la configuración actual de Pages CMS
- más trabajo en la calculadora de impuestos para una cobertura más amplia en EE. UU. e internacional, mejor profundidad jurisdiccional y flujos más claros para refrescar datos fiscales
- trabajo adicional de defensa ante denegación de servicio y de observabilidad de la plataforma
- soporte de precios más flexible para variantes de add-ons

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número de tarjeta de crédito, vencimiento y CVC se encuentran dentro de la interfaz de usuario segura controlada por Stripe, por lo que la compatibilidad con el autocompletado del navegador está restringida por Stripe y no por la aplicación circundante.
