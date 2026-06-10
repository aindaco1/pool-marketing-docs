---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

9 de junio de 2026

Esta hoja de ruta está organizada como un historial de lanzamiento de los estados reales del proyecto que realmente utilizamos, en lugar de una lista plana de funciones completadas.

## Hito actual

**v1.0.3**

El conjunto de funciones v1.0 y el pase de endurecimiento de lanzamiento están completos. v1.0.3 agrega manejo configurable de zona horaria de plataforma, recordatorios de lanzamiento opcionales para próximas campañas, mejoras de rendimiento en páginas móviles de campaña, secretos de automatización administrativa con alcance, bloqueo de liquidación por campaña, manejo más seguro del ciclo de vida de medios del panel y menor uso estable de escrituras/listados KV.

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

Esta versión mantuvo el desarrollo de los trabajadores locales alineado con el comportamiento de implementación de producción y al mismo tiempo reforzó el material de transferencia pública que los creadores necesitan antes del lanzamiento.

Nuevo en esta versión:

- El desarrollo de Podman Worker ahora se ejecuta en el Nodo 24 para coincidir con las implementaciones de GitHub Actions
- Los scripts de host y ayuda de Podman ahora prefieren el Nodo 24 y ya no fuerzan la ruta obsoleta del Nodo 20 Wrangler.
- El desarrollo local de Wrangler 4 se ejecuta según la fecha de compatibilidad de Worker `2026-05-03`, lo que evita el antiguo fallo del polyfill en tiempo de ejecución local en el Nodo 24.
- La configuración de dependencia de Podman Worker ahora usa `npm ci` para que los inicios de contenedores locales no muten `worker/package-lock.json`
- la lista de verificación pública para creadores de campañas ahora cubre complementos de campaña, promoción de códigos de inserción, decisiones de envío alternativo/envío gratuito, expectativas impositivas, destinatarios de informes y transferencia de cumplimiento.
- Ahora existe una ruta de lista de verificación de creadores en español en `/es/creator-campaign-checklist/`.

### v1.0.0 — Plataforma de lanzamiento público

Este lanzamiento trasladó a The Pool de una infraestructura de campaña reutilizable a una plataforma con forma de producción con una superficie de operaciones de navegador privada.

Nuevo en esta versión:

- Panel de administración privado en `/admin/` y `/es/admin/` para configuraciones de plataforma con alcance de roles, edición de campañas, complementos, informes, análisis, seguidores, herramientas de marketing y usuarios.
- autenticación de administrador de enlace mágico por correo electrónico con sesiones firmadas, protecciones CSRF/origen, soporte de desafío Turnstile opcional y API de navegador seguras que no exponen `ADMIN_SECRET`
- edición del panel de control para configuraciones de campaña, bloques de contenido, niveles, elementos de soporte, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas de diario, decisiones, complementos de plataforma y configuraciones de plataforma
- Panel de control Gestión de usuarios respaldada por Worker KV en `admin-users:v1`, incluidos correos electrónicos de notificación para usuarios recién creados cuando se configura Resend
- Panel de control Herramientas de marketing para referencias y creación de URL UTM, códigos de referencia guardados, controles de creación de inserciones reutilizables y fragmentos de lanzamiento copiables.
- Vistas de análisis, informes y soportes con ámbito de función con tablas ordenables/filtrables, visualización del centavo exacto de dólar, descargas CSV y vistas previas de informes de solo lectura.
- accesibilidad al panel de control, i18n, SEO/noindex, seguridad, capacidad de respuesta para dispositivos móviles/tabletas y pases DRY UI
- verificación de la versión final en los flujos del navegador de administración, comprobaciones de regresión previas a la fusión y humo Podman local para las pestañas principales del panel

### v1.0.1: Parche de análisis y medios del panel de control

Esta versión puntual mejoró el flujo de trabajo del nuevo panel después de la versión 1.0.0 y agregó los datos analíticos necesarios para generar informes de ingresos más precisos.

Nuevo en esta versión:

- Las promesas recién cobradas capturan los ID de transacción reales de la tarifa de transacción del saldo de Stripe, neto, bruto, cargo y saldo cuando estén disponibles.
- Dashboard Analytics prefiere las tarifas reales almacenadas de Stripe cuando estén disponibles y etiqueta claramente los valores mixtos o estimados.
- Los superadministradores pueden reponer los registros de compromisos cargados más antiguos con datos de transacciones de saldo de Stripe sin escaneos de la lista KV.
- Los editores de contenido de campañas y diarios pueden organizar cargas de imágenes, videos y audio con vistas previas inmediatas y publicarlas en los directorios de activos de campaña correctos.
- Las cargas del panel conservan el origen en el Worker, mientras que las herramientas del repositorio manejan la compresión de imágenes sin pérdidas y la generación de derivados WebM.
- `npm run media:optimize`, `npm run media:optimize:check` y el flujo de trabajo de GitHub Actions "Optimizar medios del panel" admiten la canalización de medios posterior a la carga
- Los seguidores y Analytics devuelven vistas vacías de solo lectura para campañas sin índices de compromiso en lugar de bloquear paneles de campaña nuevos o vacíos.

### v1.0.2: rendimiento, uso compartido y pulido de administración

Esta versión puntual hizo que las páginas públicas fueran más livianas y predecibles, al mismo tiempo que agregó controles para compartir más seguros y una pequeña superficie de rendimiento de administración para los operadores de bifurcaciones.

Nuevo en esta versión:

- Las barras de progreso de la campaña y los marcadores de hitos representan clases estáticas de ancho y posición, por lo que la primera carga ya no espera a JavaScript para evitar diseños de marcadores colapsados.
- las páginas públicas cargan primero un cargador liviano de tiempo de ejecución de carrito y difieren la pila completa del carrito hasta que el estado persistente del carrito, el estado de recuperación o la intención clara del partidario lo requieran.
- La captura previa de documentos públicos del mismo origen sigue un pequeño modelo de intención local con listas de rutas permitidas, exclusiones de consultas confidenciales, protecciones de red, límites bajos por página y una superficie de configuración habilitada de forma predeterminada.
- Configuración -> Rendimiento avanzado expone la habilitación de captación previa de intención, el retraso y el límite de vista de página para superadministradores, con la configuración del trabajador reflejada a través de `INTENT_PREFETCH_*`
- Las páginas de producción crean CSS y JavaScript `_site` generados minify después de la salida de Jekyll, mientras que Cloudflare sigue siendo responsable de la compresión de transferencia.
- Las páginas de la campaña muestran enlaces para compartir con íconos reutilizables para Bluesky, X, Threads, Facebook, SMS y correo electrónico con URL localizadas y texto CTA con reconocimiento de estado cuando sea compatible.
- Los controles interactivos para compartir aparecen debajo de la breve propaganda en dispositivos móviles/tabletas y encima del botón de inserción solo en computadoras de escritorio.
- El inicio de sesión por correo electrónico del administrador mantiene el desafío Turnstile existente después de un intento de inicio de sesión y utiliza el estilo de mensaje de estado del panel compartido para obtener comentarios de autenticación más destacados.
- La lista de verificación pública para creadores de campañas y la lista de verificación en español describen los cambios que enfrentan los creadores desde la versión 0.9.5 hasta la v1.0.2, incluida la planificación de enlaces compartidos y la carga de medios en el panel.

### v1.0.3: zona horaria de la plataforma, recordatorios de lanzamiento y refuerzo del flujo de trabajo de medios

Este lanzamiento puntual hizo que el tiempo del ciclo de vida de la campaña fuera configurable para bifurcaciones, agregó una colección de recordatorios de lanzamiento para las próximas campañas y operaciones de medios/rendimiento más estrictas para las páginas de campañas públicas.

Nuevo en esta versión:

- Los superadministradores pueden configurar la zona horaria predeterminada de la plataforma desde las opciones de zona horaria admitidas por la IANA, con el estado de la campaña de Jekyll, las cuentas regresivas del navegador, las verificaciones de fechas límite de los trabajadores, los informes de los ejecutores de campaña, las verificaciones de liquidación y las superficies de fecha/hora de administración que comparten el mismo modelo `platform.timezone` / `PLATFORM_TIMEZONE`.
- Las próximas páginas de la campaña pueden recopilar registros de recordatorio de lanzamiento únicos a través de un formulario localizado delgado con Turnstile, limitación de velocidad, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados y trabajos de envío limitados.
- La entrega de recordatorio de lanzamiento reutiliza el módulo de correo electrónico de reenvío existente, la configuración del remitente, el catálogo de configuración regional y el ritmo en lugar de agregar una segunda integración de correo electrónico.
- el programador Worker de nivel minuto ahora persiste `cron:lastRun` cada hora en lugar de cada minuto, manteniendo visible el estado del cron sin consumir el presupuesto de escritura KV de nivel gratuito como abandono de referencia.
- `_config.local.yml` puede borrar la clave del sitio Turnstile de recordatorio para que el desarrollo local oculte el widget de manera coherente con el inicio de sesión del administrador local.
- El optimizador de medios Podman ahora incluye `optipng` y `gifsicle` para la compresión de fuentes PNG/GIF locales a través del mismo flujo de trabajo de medios del repositorio.
- La generación de imágenes responsivas ahora incluye un renglón WebP `640w` entre las variantes `480w` y `960w` existentes para páginas de campañas móviles.
- Los videos de los héroes de la campaña de YouTube muestran fachadas de carteles/juegos locales y posponen el iframe remoto hasta que el partidario tenga la intención de jugar.
- Las listas de verificación públicas para creadores ahora describen los cambios de la versión 1.0.3 para los creadores, incluidos recordatorios de lanzamiento, expectativas de zona horaria de la plataforma, incrustaciones diferidas de héroes de YouTube y variantes WebP receptivas.
- `ADMIN_SETTLEMENT_SECRET` y `ADMIN_BROADCAST_SECRET` opcionales pueden limitar el acceso a la automatización de liquidación y broadcast; las rutas con alcance rechazan el `ADMIN_SECRET` más amplio cuando el secreto más estrecho está configurado
- las rutas de liquidación programada, directa, de despacho y por lotes ahora comparten un bloqueo de objeto durable `SETTLEMENT_COORDINATOR` por campaña y claves de idempotencia determinísticas de Stripe, para que los cobros de la misma campaña no se superpongan
- los checkouts de varias campañas siguen admitidos porque el bundle de checkout se divide en registros de compromiso separados por campaña; los bloqueos y lotes de liquidación permanecen limitados a la campaña que se cobra
- los documentos de GitHub Actions y operación ahora distinguen entre secretos de runtime del Worker y secretos del repositorio, incluida la necesidad de definir secretos administrativos con alcance en ambos lugares cuando corresponda
- los documentos de despliegue y exportación de reportes de Cloudflare ahora requieren `CLOUDFLARE_ACCOUNT_ID`, recomiendan tokens de despliegue con alcance de usuario y documentan opciones más estrechas para purga de caché y tokens KV de solo lectura
- la guía de `worker/.dev.vars` ahora pide explícitamente valores solo locales en lugar de respaldos de secretos de producción
- las cargas de imagen/video del panel solicitan el optimizador de medios del repositorio con `scope=changed`, mientras que la limpieza al publicar elimina medios del panel de la misma campaña que desaparecieron del contenido escrito y no están referenciados en otro lugar
- el despacho de recordatorios de lanzamiento, los reintentos de correo de seguidores y el inventario de add-ons de plataforma ahora usan estado de cola o proyecciones de unidades vendidas para evitar listados KV innecesarios en rutas inactivas o de lectura normal

## Funciones futuras

El trabajo aún planeado después de `1.0.3` incluye:

- Trabajo adicional en la calculadora de impuestos para una cobertura más amplia en EE. UU. e internacional, una mayor profundidad de las jurisdicciones locales y flujos de trabajo de actualización de datos tributarios más claros.
- Análisis de ingresos netos después de las tarifas de procesador asignadas, utilizando datos reales de tarifas de Stripe cuando estén disponibles.
- Herramientas de marketing de campaña más completas, como la composición de anuncios y el seguimiento de carritos abandonados que tengan en cuenta el consentimiento.
- diferentes precios por variación adicional
- Páginas de vista previa de campañas protegidas por correo electrónico para superadministradores, usuarios de campañas y revisores invitados.

## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número de tarjeta de crédito, vencimiento y CVC se encuentran dentro de la interfaz de usuario segura controlada por Stripe, por lo que la compatibilidad con el autocompletado del navegador está restringida por Stripe y no por la aplicación circundante.
