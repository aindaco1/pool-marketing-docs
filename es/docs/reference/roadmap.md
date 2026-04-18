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

### v0.9.1: Estado actual de la aplicación local

Este es el estado local actual de la aplicación. Es la versión reflejada en la configuración local y representa el trabajo completado después del hito `0.9` en lugar de una versión pública implementada por separado.

Nuevo en esta versión:

- Comportamiento mejorado de confirmación de pago y entrega de correo electrónico a los seguidores.
- Widget de inserción de campaña en vivo alojado y flujo de creación de inserción más completo
- Vistas previas de tarjetas compartidas de campaña más completas y alineadas con el lenguaje de diseño integrado.
- incrustar enlaces cerrados y rutas de retorno pulidos para widgets de campaña
- Trabajo de limpieza y lanzamiento de documentos después del hito más importante `0.9`
- Limpieza del comportamiento de cuenta regresiva para que las cuentas regresivas de campañas vencidas dejen de mostrarse después de las fechas límite.

## Próximo

El trabajo aún planeado después de `0.9.1` incluye:

- herramientas de administración de solo lectura o ligeramente interactivas para operadores
- una historia de editor de contenido más sólida que la configuración actual de Pages CMS
- reemplazar la lógica del impuesto sobre las ventas de tasa fija por un modelo de cálculo de impuestos más sólido
- trabajo adicional de defensa por denegación de servicio
- soporte de precios más flexible para variantes complementarias

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número de tarjeta de crédito, vencimiento y CVC se encuentran dentro de la interfaz de usuario segura controlada por Stripe, por lo que la compatibilidad con el autocompletado del navegador está restringida por Stripe y no por la aplicación circundante.
