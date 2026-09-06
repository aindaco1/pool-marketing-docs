---
title: Arquitectura
parent: Desarrollo
nav_order: 2
render_with_liquid: false
lang: es
---

# Arquitectura

## Última actualización

6 de septiembre de 2026

Esta guía está destinada a los contribuyentes que rastrean cómo encajan el sitio de The Pool, Worker, los proveedores y el estado del repositorio. Los contratos de punto final se encuentran en [Worker API](/es/docs/reference/worker-api/); Las operaciones del proveedor se encuentran en los runbooks vinculados.

## Propiedad y fuentes de la verdad

|Límite|propietario|
| --- | --- |
|Páginas públicas, rutas localizadas, plantillas y carrito de navegación|Fuentes Jekyll y `assets/`|
|Identidad de plataforma, catálogo y configuración de bifurcación admitida|`_config.yml`; `_config.local.yml` mantiene anulaciones locales|
|Texto de campaña, niveles, objetivos, diario y complementos de campaña|`_campaigns/` y medios de repositorio|
|Precios, permisos, decisiones de inventario, persistencia de aportes y liquidación.|Cloudflare Worker|
|Datos de tarjetas, métodos de pago y procesamiento de cargos|Stripe|
|Registros de aportes, proyecciones, usuarios administradores y marcadores operativos|Worker KV, con coordinadores serializados para mutaciones críticas|
|Historial de publicaciones y fuentes|Confirmaciones y acciones respaldadas por GitHub, o el asistente de repositorio local en desarrollo|

El navegador propone el estado. Worker resuelve la campaña/catálogo actual, valida la disponibilidad y calcula totales autorizados. Las ediciones normales del creador utilizan el [dashboard](/es/docs/operations/admin-dashboard/); Los cambios publicables se escriben en Git en lugar de crear un segundo catálogo de contenido en KV.

### Fundamentos compartidos

Pin de gitlinks inmutables Plataforma Dust Wave y Plantilla Dust Wave Jekyll. Los suministros de la plataforma caracterizaron Worker, administración, navegador, diseño, construcción, lanzamiento, envío, impuestos, inventario, medios, prueba y mecánica de video de producto local. La plantilla Jekyll proporciona archivos de actualización de origen vinculados al manifiesto cuyas copias en tiempo de ejecución permanecen registradas en The Pool. Ninguna dependencia sigue una rama en movimiento en el momento de la compilación.

The Pool posee modelos de campaña y aporte, rutas, políticas de almacenamiento, contenido, localización, credenciales, decisiones de proveedores, implementación y reversión. La plantilla Jekyll está excluida de la compilación pública y Worker nunca la importa. Consulte [Testing](/es/docs/operations/testing/) para ver las comprobaciones de deriva de plantilla y pin.

## Ciclo de vida de campañas y aportes

El estado de la campaña es `upcoming` → `live` → `post`. Jekyll calcula el estado inicial a partir de las fechas de la campaña; Las rutas del navegador y Worker imponen el estado efectivo utilizando la IANA `platform.timezone` / `PLATFORM_TIMEZONE` configurada, incluido el horario de verano. Las próximas campañas ofrecen recordatorios de lanzamiento. Las campañas en vivo aceptan aportes. El comportamiento posterior a la campaña utiliza el resultado de la financiación y reglas explícitas de apoyo tardío; no debe mostrar una campaña finalizada como activa.

1. El patrocinador selecciona niveles, elementos de soporte, soporte personalizado o complementos en el carrito propio.
2. `/checkout-intent/start` resuelve precios canónicos, impuestos, envío, estado de campaña y reservas de nivel limitado, luego crea una sesión Stripe en modo de configuración.
3. El sidecar de pago in situ guarda una tarjeta. Un respaldo alojado permanece disponible cuando lo requiere la configuración de pago.
4. La persistencia del webhook, con una ruta de finalización/recuperación limitada, crea un aporte por campaña. El navegador espera la persistencia antes de mostrar el éxito y luego invalida los totales de la campaña almacenados en caché.
5. Los enlaces mágicos con alcance de pedido permiten a los patrocinadores gestionar aportes activos. Los aportes vencidos se vuelven de solo lectura, excepto las actualizaciones de tarjetas elegibles.
6. Después de la fecha límite de una campaña financiada, la programación Worker envía acuerdos con el alcance de la campaña y registra los resultados de los cargos. La recuperación de pagos fallidos utiliza el flujo de actualización del método de pago existente.

### Dinero e inventario

El progreso de la campaña incluye niveles, soporte de campaña/cantidades personalizadas y complementos de campaña. Se excluyen los complementos de plataforma, propina de plataforma, impuestos y envío. Los totales de cargos almacenados incluyen subtotal, propina, impuestos y envío. Los impuestos se resuelven a través del [proveedor de impuestos ](/es/docs/operations/tax-calculator/) configurado, y los artículos físicos utilizan la [calculadora de envío](/es/docs/operations/shipping/) compartida.

Las selecciones de productos/variantes nuevas o modificadas utilizan los precios de catálogo actuales. Un producto/variante guardado sin cambios puede conservar su `unitPrice` histórico mediante ediciones de cantidad. Mantenga los límites de monto y la división campaña/plataforma que se describen en [Productos complementarios](/es/docs/development/add-on-products/) y [Procesador de pagos](/es/docs/operations/payment-processor/).

Las reservas y reclamaciones de nivel limitado se serializan mediante un Durable Object por campaña; El inventario público sigue siendo una proyección KV. La liquidación utiliza un bloqueo del coordinador de campaña, una intención persistente y claves de idempotencia deterministas Stripe. La recuperación debe conciliar antiguos trabajos ambiguos antes de reanudarlos; Las banderas de aporte por sí solas no establecen que un cargo pueda volver a juzgarse de manera segura.

## Almacenamiento

|Estado|Rol|
| --- | --- |
|`pledge:{orderId}` en `PLEDGES`|Aporte de campaña canónica guardada, selecciones de artículos, totales, estado e historial|
|Índice de campaña, estadísticas y claves de inventario|Proyecciones reparables para lecturas locales y exhibición pública.|
|Por campaña Durable Objects|Serialización de reservas/reclamaciones y bloqueos de liquidación|
|`VOTES`|Decisiones de los patrocinadores, codificadas por campaña, decisión y correo electrónico para que los aportes múltiples no otorguen votos adicionales|
|`RATELIMIT`|Contadores de protección contra abusos necesarios|
|Usuarios administradores, borradores, acceso a vista previa y marcadores de correo/trabajo|Estado de ejecución con alcance y retención específicos de funciones|

El [modelo de datos de pago](/es/docs/operations/payment-processor/#modelo-de-datos) posee campos de aporte, unidades de artículos, semántica histórica y metadatos financieros Stripe. [`config/pool-data-inventory.json`](https://github.com/aindaco1/pool/blob/main/config/pool-data-inventory.json) es el inventario de familia de claves, clasificación, retención y recuperación legible por máquina. Utilice [Copia de seguridad y restauración](/es/docs/operations/backup-restore/) cuando agregue una familia de estados duraderos.

Las lecturas normales prefieren `campaign-pledges:{slug}` a los escaneos completos del espacio de nombres. El recálculo de estadísticas y inventario puede reparar un índice de campaña obsoleto; Las verificaciones de proyección de solo lectura permiten a los operadores inspeccionar la deriva antes de elegir la reparación. Esas proyecciones no deben reemplazar la verdad subyacente sobre aportes/pagos.

## Acceso de patrocinadores

Los enlaces mágicos llevan una orden firmada por HMAC, un correo electrónico, una campaña y una carga útil de vencimiento. Cada lectura protegida verifica la firma y el vencimiento, luego verifica la prenda real en KV. Un token válido autoriza únicamente su propio pedido; un aporte faltante devuelve `404`. El formato del token, la duración, la revocación, las sesiones de administración y la protección contra abusos son propiedad de [Security](/es/docs/operations/security/).

## Páginas de inicio

### `/campaigns/:slug/`
Detalle de campaña con botones de nivel → cajón del carrito propio

### `/campaigns/:slug/pledge-success/`
Página de éxito posterior a la persistencia con confirmación + enlace de administración

### `/campaigns/:slug/pledge-cancel/`
El usuario abandonó el paso de pago antes de completarlo (no el aporte en sí)

### `/manage/`
Página de inicio del enlace mágico para la gestión de aportes:
- Lee el token `?t=...`
- Obtiene detalles del aporte del trabajador
- Muestra tarjetas de aporte con interfaz de usuario dependiente del estado.
- Agrupa proyectos en secciones **Activo** y **Cerrado**
- Ordena las tarjetas activas primero con las campañas más recientes
- Muestra el desglose completo: subtotal, propina The Pool opcional, impuesto calculado por Worker y monto de envío almacenado para el aporte, más el total.
- Lee etiquetas de precios y tarifas de la configuración compartida para que la interfaz de usuario del carrito, los totales de trabajadores, los correos electrónicos y los informes permanezcan alineados para las bifurcaciones.

**Estados de la tarjeta de aporte:**

|Estado|Tratamiento de la IU|
|--------|-------------|
|`active`|Controles de edición completos (selección de niveles, elementos de soporte, botón cancelar)|
|`active` + fecha límite pasada|Insignia bloqueada + aviso bloqueado, controles de contribución de solo lectura, solo "Tarjeta de actualización"|
|`charged`|Tarjeta silenciada, aviso " ✓ Cargado exitosamente el {fecha}"|
|`payment_failed`|Aviso de advertencia con el botón "Actualizar método de pago"|
|`cancelled`|Aviso "Este aporte ha sido cancelado"|

**Envío en flujo de modificación:** Cuando un colaborador cambia niveles o artículos de soporte físico, la página de administración recalcula dinámicamente el envío. Las selecciones físicas pueden utilizar cotizaciones en vivo respaldadas por USPS, tarifas alternativas configuradas, anulaciones de envío gratuito y actualizaciones limitadas de opciones de firma nacionales. El modal de confirmación muestra el envío actualizado y el total antes de que el usuario confirme.

**Sugerencia para modificar el flujo:** La página de administración muestra el mismo control deslizante de propina del 0% al 15%. Durante las campañas en vivo, los patrocinadores pueden ajustarlo y ver la actualización del subtotal/propina/impuestos/envío/total inmediatamente. Una vez que pasa la fecha límite, el control deslizante de propinas pasa a ser de solo lectura junto con el resto de los controles de contribución.

**Modo de desarrollo:** Agregue `?dev` a la URL para realizar pruebas simuladas de datos de aporte

### `/community/:slug/`
Página de la comunidad exclusiva para patrocinadores:
- Siempre verifica con Worker API (no confía únicamente en las cookies)
- En caso de éxito: establece una cookie `supporter_{slug}` no confidencial para la optimización de UX y almacena el token de portador sin formato solo en `sessionStorage`.
- En caso de error (aporte cancelado, token caducado): borra el estado del token de sesión, muestra acceso denegado CTA
- Muestra decisiones de votación/encuesta exclusivas de los patrocinadores.
- La API `/votes` devuelve 403 para aportes cancelados (acceso de doble verificación)
- `/votes` solo acepta ID de decisión definidos por la campaña y valores de opciones definidos por la campaña.
- Las decisiones cerradas siguen siendo legibles pero rechazan nuevos votos
- Los votos se ingresan por **correo electrónico** (no por ID de pedido): los patrocinadores con múltiples aportes aún obtienen un voto por decisión.

---

## Programación, entrega y recuperación

El Worker tiene un controlador programado a nivel de minutos. Drena el correo electrónico limitado y el trabajo de recordatorios, verifica los informes de los ejecutores de la campaña y dirige el trabajo diario del ciclo de vida de la campaña a la zona horaria configurada de la plataforma. Los marcadores de estado de cola inactivo evitan exploraciones repetidas del espacio de nombres; los latidos del corazón y los marcadores de trabajo respaldan el diagnóstico. El programador activa la reconstrucción de páginas para las transiciones de estado de la campaña.

Las campañas financiadas utilizan lotes de liquidación autoencadenados con un bloqueo de coordinador por campaña y agrupación de cargos de campaña/patrocinador. La liquidación manual utiliza la misma maquinaria de pago. El protocolo exacto, el manejo de fallas, la conciliación y las reglas de reintento pertenecen a [Procesador de pagos](/es/docs/operations/payment-processor/#liquidación).

GitHub Actions crea y publica páginas estáticas y realiza comprobaciones diarias posteriores a la implementación. El flujo de trabajo **Implementar producción** también implementa Worker; Las ejecuciones de rutina **Actualizar páginas de producción** no lo hacen. Consulte [Implementación](/es/docs/operations/deployment/).

Los efectos secundarios de las notificaciones de producción utilizan la bandeja de salida de correo electrónico duradera compartida. El renderizado se congela en el primer intento; Los fallos del proveedor reintentan independientemente del estado del aporte canónico. El inicio de sesión de administrador y los envíos de prueba explícitos siguen siendo inmediatos. El correo de la campaña verifica el consentimiento/supresión antes de la entrega. Consulte [Email](/es/docs/operations/email-system/) para conocer el proveedor y el contrato de la bandeja de salida.

El árbol de activos del repositorio sigue siendo la fuente de verdad de los medios. Las rutas de carga y edición del panel reutilizan el optimizador del repositorio y el selector de medios de solo lectura. [Performance](/es/docs/operations/performance/) posee optimización y almacenamiento en caché; [Copia de seguridad y restauración](/es/docs/operations/backup-restore/) posee la clasificación estatal, la retención, el pedido de restauración y la conciliación de pagos antes de que se reanude la recuperación.

## Mapa de código

|Ubicación|Responsabilidad|
| --- | --- |
|`_campaigns/`|Fuente de la campaña; ver [Modelo de contenido](/es/docs/development/content-model/)|
|`_layouts/`, `_includes/`, `_plugins/`|Páginas Jekyll, renderizado compartido, localización, estado de campaña y API generadas|
|`_data/i18n/`|UI compartida, tiempo de ejecución y copia de correo electrónico|
|`assets/main.scss`, `assets/partials/`|Variables de tema y Sass compartido/específico de página|
|`assets/js/cart-provider.js`, `assets/js/cart.js`, `assets/js/cart-runtime-loader.js`|Estado del carrito propio, carga diferida y transferencia de pago|
|`assets/js/live-stats.js`|Totales en vivo, inventario, puertas de nivel y actualización de campaña|
|`assets/js/admin-dashboard.js`|Editores de paneles privados y flujos operativos.|
|`worker/src/index.js`|Rutas y programador Worker|
|`worker/src/campaigns.js`, `checkout-intent.js`, `stripe.js`|Validación de campaña, integridad de pago y adaptador de pago|
|`worker/src/checkout-intent-do.js`, `tier-inventory-do.js`, `settlement-do.js`|Coordinación de pago, inventario y liquidación serializada|
|`worker/src/email.js`, `email-outbox.js`, `launch-reminders.js`|Plantillas, entrega duradera y trabajos de recordatorio|
|`worker/src/stats.js`, `reports.js`|Proyecciones y exportaciones compartidas de aportes/cumplimiento|
|`worker/src/token.js`, `routes/votes.js`|Acceso y votación de los patrocinadores|
|`scripts/`, `tests/`, `.github/workflows/`|Desarrollo, auditorías, verificación e implementación.|

Para cambios relacionados con dinero, datos, mensajes, automatización, visibilidad o poder administrativo, utilice [Ethical Risk](/es/docs/development/ethical-risk-review/) junto con la guía técnica correspondiente.
