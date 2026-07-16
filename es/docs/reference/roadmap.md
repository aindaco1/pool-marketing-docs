---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

16 de julio de 2026

## Terminado

**Preparación para búsqueda y rastreo de Google**

- [x] Mapa del sitio y verificación de rastreo en vivo
  - Los valores del mapa del sitio `lastmod` ahora provienen únicamente de fechas de contenido reales en lugar de cambiar para cada compilación.
  - La colección implícita de Jekyll, `date`, está excluida del mapa del sitio y de los metadatos de la campaña SEO, por lo que las marcas de tiempo de implementación no pueden aparecer como fechas de publicación o modificación del contenido.
  - `/sitemap.txt` se genera a partir del mismo selector de elementos públicos que `/sitemap.xml`, y las auditorías posteriores a la implementación y del sitio generado automáticamente requieren que las dos listas de URL coincidan exactamente.
  - La auditoría SEO generada rechaza XML con formato incorrecto, URL duplicadas, fechas futuras o no válidas, rutas privadas y datos estructurados incoherentes.
  - Las implementaciones de producción comparan las respuestas de los mapas de sitio ordinarios y de Google Inspection, requieren tipos de contenido XML/robots correctos y recuperan cada URL pública enviada con reintentos de propagación limitados.
  - Los análisis de Cloudflare confirmaron que las solicitudes de inspección en vivo de Search Console llegaron desde Google ASN 15169 con el agente de usuario oficial `Google-InspectionTool` y no se mitigaron, lo que descarta el firewall The Pool y la denegación de origen como el error genérico observado en la prueba en vivo.

**Preparación para comprar y actualización de políticas públicas**

- [x] Páginas de productos destacados con recompensas
  - El soporte de Campaign Shopping reutiliza el `featured_tier_id` existente, los datos de recompensa, el modelo de ruta localizado, el botón del carrito, la identidad del vendedor y la política comercial en lugar de crear un segundo catálogo.
  - La habilitación no se cierra a menos que la recompensa destacada sea física y tenga un precio, una imagen, una descripción y una fecha de disponibilidad exacta positivos después de la fecha límite de la campaña y dentro de un año.
  - Las páginas de productos enfocadas exponen datos visibles de pedidos anticipados, disponibilidad, envío y venta final con datos alineados de Open Graph y `Product` / `Offer` / ruta de navegación; Las ofertas de campaña vencidas o próximas se convierten en `OutOfStock`.
  - El actual candidato de Their Love sigue discapacitado; La disponibilidad exacta, la configuración de Merchant Center, la configuración de feed/destino y la activación de Shopping se rastrean como características futuras en lugar de reclamos de liberación.
- [x] Políticas públicas y contenidos bilingües
  - Los términos ahora incluyen anclajes de envío estable y sin devoluciones, un valor predeterminado de venta final claro, una guía de informes de problemas de cumplimiento de siete días, verificación de registros del transportista, revisión de buena fe sin seguimiento, soluciones disponibles y lenguaje de derechos no renunciables.
  - Acerca de y Términos utilizan los valores de autor/empresa y de correo electrónico de soporte de `_config.yml`, evitan copias obsoletas y mantienen la paridad de las secciones inglés/español.
  - La interfaz de usuario y la documentación compartidas están dirigidas al español neutral de Estados Unidos y América Latina; el propietario completó la revisión fluida final para la versión 1.1.2 el 14 de julio de 2026, además de las verificaciones de integridad automatizadas
  - Brand & SEO expone el país de la política de devolución de compras y mantiene el tipo de no devoluciones en modo de solo lectura para que el estado del panel, los términos públicos y JSON-LD no puedan divergir silenciosamente.

**Precios adicionales específicos de cada variante**

- [x] Contrato de precio compartido y contabilidad histórica
  - Los complementos de plataforma `_config.yml` y la campaña `campaign_add_ons` aceptan la variante opcional `price`; el espacio en blanco hereda el precio del producto y el cero explícito sigue siendo una anulación válida
  - Los tiempos de ejecución del navegador comparten `resolveAddOnUnitPriceCents`, el carrito heredado/Administrar respaldos implementa la misma regla y el estado del producto variante lleva `priceCents`
  - Los selectores Carrito y Administrar aporte muestran diferentes precios de variantes y actualizan el estado de la tarjeta/subtotal a través del flujo de selección existente.
  - Worker rechaza la autoridad de precios del navegador, canonicaliza selecciones nuevas o modificadas del catálogo actual y conserva `unitPrice` persistente para líneas de aporte históricas sin cambios.
  - Los editores de administración de plataforma/campaña exponen precios de variantes opcionales localizadas, rechazan valores negativos, mal formados o por encima del límite máximo y serializan `price` solo para anulaciones reales; Worker aplica de forma independiente el límite máximo de cantidad canónico de `$1,000,000`
  - Los complementos existentes no requieren migración porque las variantes sin `price` continúan heredando el precio del producto.

**Puertas de calidad de producción y fortalecimiento de operaciones administrativas**

- [x] Revisión de transferencia de versión de Store v1.0.8
  - The Pool v1.1.0/v1.1.1 ya contiene los segmentos de precio compartido, medios, Stripe, conciliación y bandeja de salida de correo electrónico aplicables.
  - Se transfirió la corrección de recuperación de AWS CLI del ejecutor alojado; El filtro de pedidos multiprocesador de Store no se aplica porque The Pool es solo Stripe y tiene alcance de campaña.
  - La preparación de Store, la caché de Workers, el marketing de catálogo global, el producto/SKU, el cupón, el ticket, el pedido, la descarga y las superficies R2 permanecen excluidas o asignadas a los controles nativos de The Pool existentes.
- [x] Puertas de liberación alineadas con Store adaptadas a The Pool
  - Una configuración de presupuesto de rendimiento controla los límites de JavaScript/CSS generados, las categorías de Lighthouse/Web Vitals/límites de recursos específicos de la ruta, el panel ejecutable/objetivos de tiempo Worker, la política de evidencia de caché Workers y los objetivos de caché públicos/privados.
  - Lighthouse Scriptable y evidencia de políticas de caché cubren rutas principales públicas, campañas, shell de tiempo de ejecución, administración, JSON generado, activos estáticos y privadas Worker; Las pruebas unitarias del evaluador se ejecutan sin credenciales de proveedor en vivo.
  - Los histogramas de tiempo Worker limitados existentes ahora muestran el resumen del panel y las lecturas de configuración, p50/p95/p99/max y resúmenes de ruta lenta en Configuración -> Diagnóstico en tiempo de ejecución, y alimentan una auditoría de lanzamiento de p95 autenticada y redactada sin un segundo almacén de telemetría ni cargas útiles de cliente/solicitud.
  - Los fondos de las tarjetas de campaña de la página de inicio reutilizan derivados WebP responsivos y carga diferida, lo que reduce la transferencia de inicio medida de aproximadamente 4,0 MB a 1,5 MB y el LCP acelerado repetido de aproximadamente 20,3 segundos a 5,4-6,6 segundos.
  - Tanto las auditorías de producción como las de dependencia total pasan después de fijar la versión limpia y compatible de Lighthouse.
  - La revisión y revocación de sesión/dispositivo The Pool v1.0.9, los filtros de auditoría con capacidad de búsqueda/CSV, la preparación completa del proveedor/seguridad, las comprobaciones de deriva de la postura de producción, los paquetes de localización, los flujos de trabajo de implementación fijados y la cobertura programada de Podman siguen siendo la base de operaciones de administración compartida
  - La caché Workers permanece deshabilitada hasta que la evidencia representativa de The Pool demuestre al menos la mejora configurada del 40 % de p95, coincidiendo con la decisión de Store en lugar de habilitarla de manera especulativa.
  - Las comprobaciones automatizadas de accesibilidad/i18n/SEO siguen siendo puertas de liberación; VoiceOver humano/NVDA y revisión en español nativo son pruebas opcionales documentadas.
  - Los productos exclusivos Store, SKU, ticket/RSVP, descarga firmada y sistemas de abuso de descarga R2 permanecen intencionalmente excluidos

**Vistas previas de campañas protegidas y creación de nuevas campañas**

- [x] Páginas de vista previa protegidas
  - Las páginas de vista previa se encuentran en `/campaigns/:slug/preview/` y equivalentes localizados, pero permanecen en `noindex,nofollow,noarchive`, referencia de origen estricto con alcance para medios integrados, sin almacenamiento, salida de mapa de sitio público externo y excluida de la captación previa de intención pública.
  - Los superadministradores autenticados y los usuarios de campaña asignados pueden obtener cargas útiles de vista previa a través de la sesión de administración existente y las comprobaciones del alcance de la campaña.
  - Los administradores de publicaciones reciben un enlace de vista previa firmado visible en el panel de control, los correos electrónicos de revisores invitados explícitamente reciben enlaces de vista previa firmados que caducan en 24 horas y la copia del correo electrónico lo dice claramente.
  - El acceso a la vista previa valida el tipo de token, la caducidad, el slug de campaña y el correo electrónico permitido con una lista permitida de KV de trabajador `campaign-preview-reviewers:<slug>` de 24 horas en lugar de almacenar listas de revisores en la portada de campaña respaldada por GitHub o en JSON de campaña pública.
  - Las campañas nuevas/solo de vista previa permanecen invisibles en `/campaigns/:slug/` públicas, listas de páginas de inicio, páginas de campañas localizadas, páginas comunitarias, `/api/campaigns.json`, catálogos complementarios, tarjetas para compartir y resultados de mapas del sitio hasta su lanzamiento.
- [x] Creación de nueva campaña
  - Los superadministradores pueden crear una campaña de solo vista previa desde el panel de Campañas con solo un título obligatorio.
  - Opcionalmente, el flujo puede asignar uno o más usuarios de campaña existentes y, opcionalmente, crear uno o más usuarios de campaña nuevos con los nombres y correos electrónicos requeridos.
  - La fuente de la campaña se crea localmente en desarrollo o a través de la ruta de publicación `_campaigns/<slug>.md` existente respaldada por GitHub en producción, la reconstrucción normal se activa cuando los usuarios nuevos/asignados respaldados por GitHub se guardan en `admin-users:v1` y se registra un evento de auditoría de administrador.
  - Los usuarios de campaña asignados reciben correos electrónicos impulsados por Resend con el enlace del panel de administración cuando se asignan usuarios
- [x] Archivado de campañas
  - La subpestaña Campañas -> Configuración muestra Archivar campaña debajo de los campos en segundo plano solo para superadministradores cuando la campaña no está activa actualmente.
  - El trabajador valida el rol, CSRF, la existencia de la campaña y el estado efectivo, luego archiva localmente en desarrollo o envía `.github/workflows/archive-campaign.yml` en producción.
  - La medida de archivo mantiene la fuente de la campaña y los medios propiedad de la campaña en `archive/campaigns/<slug>/`, escribe un manifiesto de archivo y deja los medios a los que todavía hacen referencia otras campañas activas en su lugar.
- [x] Publicar protección contra conflictos
  - El contenido de la campaña y las publicaciones preliminares incluyen una revisión base/SHA del archivo GitHub cuando esté disponible
  - Las publicaciones obsoletas se rechazan con una respuesta de conflicto específica para que los borradores locales del navegador permanezcan intactos y los usuarios puedan recargar antes de publicar.

**Análisis y operaciones del panel de administración**

- [x] Administración de configuración alineada con Store
  - La configuración sigue el orden Store para las secciones compartidas y al mismo tiempo conserva los controles específicos de The Pool.
  - Las sesiones de administración con privacidad minimizada de The Pool y las API de registro de auditoría con capacidad de búsqueda se exponen a través de vistas responsivas y localizadas con revocación de sesión, filtrado de campañas, acciones/objetivos/estados legibles por humanos y exportación privada de CSV.
  - El inicio de sesión con enlace mágico de desarrollo local presenta un enlace directo al panel de superadministrador sin exponer el token sin formato como texto para mostrar.
- [x] Análisis de ingresos brutos y netos
  - Los ingresos de la campaña y los ingresos de la plataforma siguen siendo totales brutos de la categoría, mientras que las columnas netas de tarjetas/tabla restan la participación de las tarifas de procesador asignadas a cada categoría.
  - Los cargos exitosos del patrocinador almacenan la tarifa de transacción de saldo de Stripe, ID de transacción neta, bruta, de cargo y de saldo cuando estén disponibles
  - Analytics utiliza valores de tarifas de Stripe reales almacenados para aportes cobradas y el modelo de tarifa estimada existente para aportes activos o registros cobrados más antiguos sin datos de saldo de Stripe.
  - Una ruta de reabastecimiento protegida por CSRF, solo para superadministradores, recupera datos históricos de transacciones de saldo de Stripe de los índices de aportes de campaña sin escaneos de listas KV.
  - Las etiquetas de tarjetas y tablas mantienen los valores brutos y netos distintos para la conciliación
- [x] Rastreador de uso del plan
  - Los superadministradores pueden cargar el uso de cuota de Cloudflare Workers/KV y Resend desde Configuración -> Planificar uso automáticamente cuando se abre la sección
  - El rastreador muestra nombres de planes, barras de progreso, texto `used of limit`, umbrales críticos/de advertencia y enlaces de administración de planes.
  - Los tokens API del proveedor permanecen en el lado del servidor; el navegador recibe solo métricas de uso desinfectadas y mensajes de estado
  - Las cargas tienen un alcance de actualización de página y son de solo lectura, sin escrituras de KV ni operaciones de lista.

**Base de plataforma**

- [x] Branding y andamiaje i18n
  - La marca de la plataforma Pool / Dust Wave
  - complemento de formato de dinero
  - ayuda de traducción, `en.yml` y plantillas de ejemplo
- [x] Automatización y backend de los trabajadores
  - Almacenamiento de aportes, estadísticas, inventario, correos electrónicos, liquidación automática, cobro agregado a los patrocinadores y transiciones automáticas de estado de campaña.
  - El estado de la campaña, las cuentas regresivas del navegador, las fechas límite de los trabajadores, los informes programados, las comprobaciones de liquidación y las superficies de fecha y hora del administrador comparten el mismo modelo `platform.timezone` / `PLATFORM_TIMEZONE`.
  - el programador Worker de nivel minuto persiste `cron:lastRun` cada hora en lugar de cada minuto, manteniendo visible el estado del cron sin la rotación de escritura KV de nivel libre de referencia
- [x] Desarrollo local de Podman
  - `./scripts/dev.sh --podman`, dramaturgo sin cabeza en contenedores, ayudantes de informes/humo compatibles con Podman, `podman:doctor` y `podman:self-check`
  - El desarrollo de host y Podman Worker utiliza Node 24 para coincidir con las implementaciones de GitHub Actions y evitar la ruta obsoleta de Node 20 Wrangler.
  - El desarrollo local de Wrangler 4 se ejecuta según la fecha de compatibilidad de Worker `2026-05-03`, lo que evita el antiguo fallo del polyfill en tiempo de ejecución local en el Nodo 24.
  - La configuración de dependencia de Podman Worker utiliza `npm ci` para que los inicios de contenedores locales no muten `worker/package-lock.json`
  - El optimizador de medios Podman incluye `optipng` y `gifsicle` para la compresión de fuentes PNG/GIF locales a través del mismo flujo de trabajo de medios del repositorio.
- [x] Configurar e implementar ayuda
  - `npm run setup:deploy` / `scripts/setup-deploy.mjs` se envía como una CLI de nodo libre de dependencias para configuración local, simulacros de producción, sincronización de configuración, creación/actualización de Cloudflare KV, escrituras de secretos de trabajo, escrituras de secretos de repositorio de GitHub, ayudantes de autenticación para `gh`/`wrangler`/CLI de Stripe opcional y `wrangler deploy` opcional.
  - El asistente mantiene en mente la idempotencia de la configuración de producción y la confirmación del operador, al mismo tiempo que evita la complejidad del contenedor de aplicaciones hasta que el flujo de trabajo basado en el script sea estable.
  - La configuración de producción ahora detecta y reutiliza los enlaces/recursos de espacios de nombres existentes de Cloudflare KV antes de planificar la creación, incluida la salida de prueba que distingue la reutilización de la creación.
  - Las comprobaciones de preparación de solo lectura pueden llamar a las API de proveedores en vivo de Cloudflare, GitHub, Stripe, Resend, Turnstile, USPS y ZIP.TAX durante la configuración/ejecuciones de prueba, con `--skip-readiness` disponible cuando los operadores necesitan una verificación local más específica.
  - Las pruebas de subproceso auxiliar de configuración ejercitan la ejecución en seco, la generación de secretos locales de repositorio temporal, la planificación de creación/reutilización de KV de producción, las escrituras de secretos de trabajo generadas y las pruebas de preparación con CLI de proveedores falsos para que la cobertura no dependa de las credenciales activas.
- [x] Runbook de copia de seguridad, restauración y recuperación ante desastres
  - Límites clasificados de Git, `PLEDGES`, `VOTES`, `RATELIMIT`, Stripe y Durable Object en `config/pool-data-inventory.json`, con aporte/votación/administración de cuatro horas de RPO/RTO y retención aprobada de 7 días/5 semanas/12 meses/liberación.
  - Se agregaron metadatos e instantáneas cifradas de valores capturados, sumas de verificación, prueba de descifrabilidad, poda de retención segura, copias fuera del dispositivo solo para agregar y verificaciones de preparación sin exportación de valores secretos.
  - Se agregaron planes de restauración de producción/vista previa/local basados en clasificación, validación de valor autorizado, reconstrucciones de estado derivado, exclusiones de cuarentena, limpieza de vista previa exacta, verificación de lectura y puertas de producción de pago/mantenimiento/aprobación explícitos.
  - Orden de restauración documentada, política de no importación Durable Object, conciliación de proveedores, reconocimientos de producción y comprobaciones posteriores a la restauración en `docs/BACKUP_RESTORE.md`

**Campaña y experiencia pública**

- [x] Presentación de la página de la campaña
  - clasificación de campaña
  - tarjetas de campaña uniformes con vista previa del nivel destacado
  - diseño de campaña de dos columnas
  - imagen principal / imagen ancha / variantes de video
  - pre-renderizado de cuenta regresiva
  - imágenes de nivel e imágenes de creador
  - Las barras de progreso de la campaña y los marcadores de hitos representan clases estáticas de ancho/posición, por lo que la primera carga ya no espera a JavaScript para evitar diseños de marcadores colapsados.
  - La generación de imágenes responsivas incluye un renglón WebP `640w` entre las variantes `480w` y `960w` existentes para páginas de campañas móviles.
  - Los videos de los héroes de la campaña de YouTube muestran fachadas de carteles/juegos locales y posponen el iframe remoto hasta que el patrocinador tenga la intención de jugar.
- [x] Financiamiento y características comunitarias
  - Fases de producción con elementos registrales.
  - decisiones comunitarias/votación
  - diario de producción
  - financiación continua
  - niveles con objetivos extendidos y animaciones de desbloqueo
  - Lanzamiento de la producción de Hand Relations
- [x] Recordatorios de lanzamiento
  - Las próximas páginas de la campaña pueden recopilar registros de recordatorio de lanzamiento únicos a través de un formulario localizado delgado con Turnstile, limitación de velocidad, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados y trabajos de envío limitados.
  - La entrega de recordatorio de lanzamiento reutiliza el módulo de correo electrónico Resend existente, la configuración del remitente, el catálogo local y el ritmo en lugar de agregar una segunda integración de correo electrónico.
  - Las colas de reintento de envío de recordatorios de lanzamiento y confirmación de soporte mantienen pequeños marcadores de estado de cola para que los ticks programados inactivos omitan los escaneos de la lista de espacios de nombres KV, con comprobaciones de compatibilidad cada hora para trabajos heredados insertados manualmente.
  - `_config.local.yml` puede borrar la clave del sitio Turnstile de recordatorio para que el desarrollo local oculte el widget de manera coherente con el inicio de sesión del administrador local.

**Gestión de donaciones y patrocinadores**

- [x] Gestión de patrocinadores sin cuenta
  - arquitectura de enlace mágico
  - aporte exitosa / páginas canceladas
  - Panel de control `/manage/`
  - acceso `/community/:slug/` solo para patrocinadores con tokens de colaborador con ámbito de sesión
  - seguimiento del historial de aportes
- [x] Aportes flexibles
  - artículos de soporte y cantidades personalizadas que fluyen carrito → Trabajador → KV → estadísticas
  - seguimiento de estadísticas de elementos de soporte en vivo
  - soporte de aporte de varios niveles a través de `additionalTiers`
  - soporte de niveles no apilables
  - post/live Administrar reglas de visualización de elementos de soporte de aporte
- [x] Envío de recompensa física
  - detección propia de elementos físicos
  - envío de nivel físico
  - pago con autocompletar y soporte para dirección de envío
- [x] Recordatorios de pago abandonado
  - Los recordatorios de pago abandonado recopilan una suscripción explícita de un solo recordatorio, se ponen en cola solo después de que la creación de la sesión propia de Stripe sea exitosa, se eliminan cuando se completa la persistencia del aporte, suprimen las audiencias duplicadas/sin suscripción y se envían a través del módulo de correo electrónico compartido Resend.
  - Los enlaces de recordatorio firmados restauran un borrador de pago del navegador desinfectado para el mismo contexto de carrito/contacto abandonado e inician una nueva sesión de Stripe sin colocar secretos de Stripe en las URL.
  - La programación utiliza `abandoned-cart-queue:v1`, límites de retención, marcadores de envío/supresión y lotes limitados para que los cronómetros inactivos eviten escaneos de listas KV
  - Los administradores de campañas pueden ver el estado de los recordatorios de pago abandonado en el ámbito de la campaña desde los contadores agregados de colas/resultados sin enumerar los espacios de nombres KV, y las filas de supresión creadas por el administrador muestran el correo electrónico suprimido para que se puedan borrar de la tabla.
  - Los controles de supresión en el ámbito de la campaña son mutaciones administrativas explícitas con CSRF, eventos de auditoría, identificadores de correo electrónico con hash y ninguna acción de carrito abandonado específica de reintento.

**Pagos, inventario e informes**

- [x] Refuerzo de la integridad de los pagos
  - Los nuevos registros de pago y pago contienen moneda USD explícita más tiempo de valor, tiempo de reserva Worker y tiempo de disponibilidad del procesador donde Stripe lo expone; Los registros heredados se establecen de manera segura en USD durante las lecturas.
  - Las llamadas a la API Stripe fijan una versión explícita, normalizan los errores del proveedor, usan idempotencia determinista para escrituras seguras y emiten un diario `processor-event:v1:*` delimitado y redactado sin datos de tarjeta, cargas útiles de webhook sin procesar ni direcciones de correo electrónico de soporte.
  - Los webhooks utilizan una concesión de procesamiento antes de los efectos secundarios y retienen los marcadores procesados durante 35 días, por lo que la entrega simultánea genera un conflicto que se puede volver a intentar mientras el trabajo obsoleto se puede reanudar de forma segura.
  - La liquidación persiste en el estado `settlement-group:v1:*` antes de la carga, reanuda los objetos del procesador exitosos, reutiliza claves seguras dentro de la ventana de idempotencia de 24 horas de Stripe y se detiene para revisión del operador en lugar de volver a intentar ciegamente el trabajo ambiguo después de esa ventana.
  - Los trabajos de liquidación persisten en los puntos de control de lotes actuales, detectan trabajos obsoletos, conservan el estado operativo durante 400 días y no marcan las campañas cargadas mientras permanecen los aportes de clientes faltantes, fallidos o de necesidades de atención.
  - La conciliación programada y activada por el superadministrador compara la verdad del aporte indexado con Stripe PaymentIntents y trabajos de liquidación, luego almacena registros `reconciliation-break:v1:*` abiertos/resueltos explícitos sin escaneos de espacio de nombres
  - Los efectos secundarios del correo electrónico de producción comparten una ruta `email-outbox:v1:*` duradera con cargas útiles congeladas, idempotencia determinista Resend, reintentos limitados, arrendamientos fallidos, webhooks de entrega de proveedores, supresión permanente de rebotes/quejas y evidencia de entrega mínima de 400 días.
  - Los correos electrónicos de diario, hitos y anuncios ahora incluyen manejo de cancelación de suscripción con un solo clic RFC 8058 firmado y con alcance de campaña; La semántica de transacciones, inicio de sesión de administrador y correo electrónico de prueba sigue siendo distinta.
  - La recuperación manual de dinero ambiguo permanece deshabilitada porque actualmente no están disponibles dos operadores superadministradores distintos; la recuperación idempotente automatizada y las interrupciones de conciliación explícitas son el camino admitido

- [x] Pago de Stripe y actualizaciones de tarjetas
  - Paso de pago nativo de Stripe en el sitio en el segundo sidecar de pago
  - `Update Card` usando el mismo patrón seguro
  - Cobertura E2E de pago totalmente automatizado
  - manejo de actualización de inventario/estadísticas en vivo posteriores a la persistencia
  - Reforzamiento del proceso de compra en torno al almacenamiento, el almacenamiento en caché, las comprobaciones de origen y los reintentos de recuperación.
- [x] Inventario y contabilidad de campañas
  - API de estadísticas en vivo
  - seguimiento de inventario de nivel limitado
  - Protección contra sobreventa duradera respaldada por objetos para niveles escasos
  - soporte de recálculo de estadísticas para `additionalTiers`
  - El inventario complementario de la plataforma utiliza una proyección duradera de recuento de ventas que crea, modifica y cancela la actualización de rutas de aporte, por lo que las lecturas normales del inventario ya no reconstruyen los recuentos de ventas enumerando todos los aportes después del arranque.
- [x] Correos electrónicos e informes de patrocinadores
  - notificaciones de hitos
  - Correos electrónicos con información sobre propinas con desgloses completos de subtotales, propinas, impuestos y envío.
  - Informes de aportes estilo libro mayor y exportaciones CSV de cumplimiento
  - envío incluido en el informe
  - Las transmisiones automáticas del diario utilizan ID de entrada estables para que las entradas del diario editadas no se reenvíen como nuevas actualizaciones.
- [x] Herramientas de integridad de proyección
  - comprobaciones de deriva de solo lectura para el estado de proyección por campaña y para todas las campañas
  - Envoltorio del operador `./scripts/check-projections.sh` para comprobaciones locales y respaldadas por Podman
  - La cobertura de humo de aporte mutable verifica que las campañas mantengan la proyección limpia después de la configuración, modificación y cancelación.
  - Orientación más clara para el operador sobre la desviación de la proyección frente a las diferencias entre los informes del estado actual y del libro mayor.
- [x] Conciliación de recuperación
  - Se agregó conciliación de intención de pago Stripe de solo lectura para que la evidencia de recuperación pueda comparar la verdad del aporte restaurado con el estado del procesador sin crear ni modificar pagos.
- [x] Productos complementarios
  - Los complementos de la plataforma admiten el primer catálogo de productos de Dust Wave (`DUST WAVE T-Shirt`, `DUST WAVE Sticker` y `DUST WAVE Butterfingers T-Shirt`), precios fijos, variantes simples, inventario, umbrales de existencias bajas, filtrado de productos agotados y tarjetas de productos compartidas.
  - Las campañas pueden definir `campaign_add_ons` al principio; El carrito y Administrar aporte los muestran con los mismos patrones de tarjetas adicionales en una sección propiedad de la campaña.
  - Los carritos de campañas múltiples utilizan un modelo de campaña ancla y al eliminar un aporte de campaña también se eliminan los complementos de campaña vinculados a esa campaña.
  - Los complementos de la campaña cuentan para el subtotal y el objetivo de la campaña propietaria, heredan las reglas de envío de esa campaña y se distinguen de los complementos de la plataforma en los informes y la propiedad de cumplimiento.
  - Los complementos de la plataforma utilizan una contabilidad separada de ingresos y cumplimiento de la plataforma, incluido un cargo de envío físico/envío separado para los complementos globales.
  - El accesorio Smoke Editable cubre complementos de campaña importados desde su tienda de productos para cobertura de navegador, envío y informes.
- [x] Opciones de envío y entrega
  - La calificación nacional/internacional respaldada por USPS reemplazó el antiguo modelo de tarifa física plana, con envío alternativo de implementación, anulaciones de campaña opcionales y controles de envío gratuito de implementación/campaña.
  - Los niveles físicos y los elementos de soporte definen metadatos de envío con ajustes preestablecidos compartidos; Los artículos deterministas con tarifa manual como `sticker` y `signed_script` pueden omitir el USPS cuando sean elegibles, y los ajustes preestablecidos de disco prueban clases válidas más baratas como `MEDIA_MAIL` antes de los servicios de paquetería.
  - Los totales de envío canónicos de los trabajadores fluyen a través del proceso de pago, gestión de aportes, correos electrónicos, informes y exportaciones de cumplimiento.
  - Las opciones de entrega admiten `standard`, `signature_required` y `adult_signature_required` en el carrito, el pago, la gestión de aportes, los totales guardados y los correos electrónicos de los patrocinadores.
  - Los datos del país de pago provienen de una referencia del país de envío, las campañas con anulaciones de tarifa fija omiten el USPS y los carritos permanecen en modo de estimación hasta que sea posible obtener una cotización en vivo.
  - La cobertura de humo verifica la calificación nacional/internacional real de USPS, el comportamiento de respaldo y los flujos de opciones de firma

**Herramientas y contenido para creadores**

- [x] Flujo de trabajo de optimización y usabilidad de la biblioteca multimedia
  - El repositorio existente sigue siendo el único almacén de medios; un `_data/media-optimization-manifest.json` reconstruible determinista describe las fuentes de campaña/imagen compartida, vídeo y audio, además de derivados, hashes, dimensiones, duración, tamaño, referencias y advertencias generados.
  - La exploración de medios de campaña ahora admite búsqueda, pestañas de imagen/vídeo/audio, clasificación reciente/nombre, miniaturas y metadatos, alcance compartido/campaña, estado fuente/derivado, ubicaciones de referencia, estado de optimización y advertencias de referencia rota.
  - Los creadores pueden elegir imágenes de campaña, videos/pósteres locales y audio sin pegar rutas, reemplazar de forma segura una fuente de la misma campaña usando su GitHub SHA actual y enviar el flujo de trabajo de optimización existente, modificado o completo, según el alcance del rol.
  - Las imágenes significativas requieren texto alternativo, mientras que las imágenes decorativas explícitas persisten en texto alternativo vacío; Las imágenes alternativas vacías heredadas siguen siendo compatibles con una advertencia.
  - Los presupuestos de ubicación compartida advierten sobre héroes, galerías, niveles, Blast y medios de póster de gran tamaño sin crear una segunda política de bloqueo o procesador del lado Worker.
  - Los archivos de imagen/vídeo responsivos generados se ocultan como opciones de selección independientes, mientras que los derivados más grandes omitidos intencionalmente permanecen registrados para que no se informen erróneamente como faltantes.
  - La cobertura de unidades protege la clasificación de manifiestos, los presupuestos de ubicación, el filtrado de selectores, el comportamiento del editor y la semántica de accesibilidad; la verificación del optimizador nativo existente sigue teniendo autoridad para la generación de derivados

- [x] Panel de administración
  - Shells privados `/admin/` y `/es/admin/` con manejo sin índice y copia localizada del panel
  - inicio de sesión con enlace mágico, acceso de superadministrador y usuario de campaña con alcance de rol, comprobaciones de origen/CSRF, manejo seguro de cookies y comprobaciones de sesión de solo lectura
  - La compatibilidad con el desafío Turnstile de Cloudflare protege el envío de inicio de sesión por correo electrónico del administrador antes de la entrega del correo electrónico con enlace mágico
  - Vistas de configuración, complementos, campañas, análisis, informes, soporte, marketing, usuarios, secretos y credenciales y diagnóstico en tiempo de ejecución
  - Los superadministradores pueden configurar la zona horaria predeterminada de la plataforma desde un menú de selección lleno de opciones de zona horaria compatibles con la IANA.
  - Configuración -> Los usuarios guardan directamente en Worker KV en `admin-users:v1` y envían por correo electrónico las instrucciones de inicio de sesión a los usuarios recién creados cuando se configura el correo electrónico; Secretos y credenciales siguen siendo solo de estado
  - Los informes, análisis, soportes, cargas/vistas previas de contenido, generación de enlaces de marketing y filtros de tablas evitan las escrituras de KV en rutas de lectura normales.
  - Los patrocinadores y Analytics devuelven vistas de campaña vacías de solo lectura para campañas sin índices de aporte en lugar de bloquear paneles de campaña nuevos/vacíos.
  - La edición de contenido WYSIWYG basada en bloques utiliza un esquema de bloques polimórfico para el contenido de la campaña y las entradas del diario.
  - La edición del diario conserva los ID de entrada estables, los ID basados en títulos para las nuevas entradas y el espaciado de énfasis en línea para que los correos electrónicos automáticos se envíen solo para entradas genuinamente nuevas.
  - esquema de campaña completo para niveles, complementos de campaña, objetivos ambiciosos, elementos de soporte, diario y decisiones
  - Las cargas de medios del panel utilizan directorios de activos basados en convenciones, conservan los ID existentes cuando sea necesario, derivan nuevos ID a partir de nombres/etiquetas y ofrecen optimización de imágenes sin pérdidas, variantes WebP responsivas y derivados de vídeo WebM con `scope=changed`.
  - las publicaciones de contenido y diario limpian los medios propiedad del panel de control de la misma campaña a los que ya no se hace referencia; Las cargas de audio se mantienen en origen.
  - Los enlaces hash del diario abren la pestaña de la fase de coincidencia antes de desplazarse a anclajes como `#diary-production`.
  - Los editores de productos físicos exponen ajustes preestablecidos de envío o metadatos explícitos del paquete, mientras que los productos digitales ocultan campos de solo envío.
  - Configuración -> Rendimiento avanzado expone el estado habilitado de captación previa de intención, el retraso y el límite de vista de página para superadministradores, con la configuración del trabajador reflejada a través de `INTENT_PREFETCH_*`
  - El inicio de sesión por correo electrónico del administrador mantiene el desafío Turnstile existente después de un intento de inicio de sesión y utiliza el estilo de mensaje de estado del panel compartido para obtener comentarios de autenticación más destacados.
  - Las recargas del panel restauran la última pestaña de nivel superior permitida, la sección Configuración, la campaña Campañas seleccionada y la subpestaña Campañas desde el estado local del navegador sin agregar escrituras de trabajador o KV.
  - responsive, accesibilidad, seguridad/noindex, español i18n, navegador, unidad y cobertura de presupuesto de escritura KV cubren los flujos del panel
- [x] Herramientas de marketing de campaña
  - Campañas -> El marketing se mantiene centrado en la generación de enlaces de campaña, códigos de referencia guardados, códigos QR PNG/SVG descargables y el creador de inserciones de campaña sin agregar otra superficie de panel de nivel superior.
  - Los códigos de referencia guardados almacenan únicamente el registro de referencia explícito relacionado con la campaña; Las vistas previas/descargas de QR son locales del navegador y no leen ni escriben KV
  - La generación de QR de campaña se adaptó del enfoque del generador de QR con licencia del MIT en `1612elphi/delphitools` para el creador de URL de esta pila, los enlaces de referencia guardados y las necesidades de descarga de PNG/SVG.
  - Los borradores de marketing compartido utilizan un registro KV con alcance de campaña con vencimiento de 7 días, controles explícitos de carga/guardado/borrado, protección contra conflictos de revisión y una escritura limitada solo al guardar/borrar el usuario.
- [x] Informes de atribución de Analytics
  - Analytics reutiliza el índice de aporte de campaña existente y las etiquetas de referencia guardadas para mostrar referencias y agregados de fuente/medio/campaña/contenido UTM sin escaneos de listas KV ni una superficie de informes de pestaña de Marketing duplicada.
- [x] Blasts de correos electrónicos de patrocinadores
  - Campañas -> Blast permite a los usuarios de campaña asignados y a los superadministradores enviar mensajes masivos de correo electrónico a los patrocinadores indexados de la campaña utilizando los campos compartidos del editor WYSIWYG, el asunto, la etiqueta del botón de CTA y la URL del botón de CTA.
  - Los borradores de Blast siguen siendo locales del navegador; Los ensayos automáticos se ejecutan antes de los envíos de prueba/en vivo, los envíos de prueba van solo al administrador que ha iniciado sesión, los envíos en vivo requieren el hash de ensayo correspondiente y el historial de envíos se muestra en modo de solo lectura debajo del editor.
  - Las cargas masivas de imágenes reutilizan la ruta de optimización/carga de medios de la campaña para que las imágenes de correo electrónico se alojen en el sitio en `assets/images/campaigns/<slug>/`; Los bloques de YouTube/Vimeo se muestran como enlaces seguros para correo electrónico en lugar de reproductores integrados
  - Los borradores compartidos de Blast utilizan el mismo modelo explícito de borrador compartido de 7 días que Marketing, incluidos conflictos de revisión y sin escrituras automáticas en segundo plano.
- [x] Selección de medios WYSIWYG
  - Los bloques de imágenes de contenido de campaña, diario y Blast pueden elegir imágenes de campaña existentes desde un cuadro de diálogo de biblioteca multimedia con alcance en lugar de requerir rutas `/assets/...` pegadas.
  - Los superadministradores también pueden seleccionar imágenes compartidas/predeterminadas; Los usuarios de campañas solo ven los medios de las campañas que administran.
  - El selector es de solo lectura, está respaldado por el directorio de GitHub y no agrega ningún estado KV nuevo ni índice de medios duplicado.
- [x] Documentos y runbooks del creador
  - La lista de verificación pública para creadores de campañas y la lista de verificación en español cubren complementos de campaña, promoción de códigos de inserción, decisiones de envío alternativo/envío gratuito, expectativas fiscales, destinatarios de informes, transferencia de cumplimiento, planificación de enlaces compartidos, carga de medios en el panel, recordatorios de lanzamiento, expectativas de zona horaria de la plataforma, incrustaciones diferidas de héroes de YouTube y variantes WebP receptivas.
  - Existe una ruta de lista de verificación de creadores en español en `/es/creator-campaign-checklist/`.

**Sistema de calidad, accesibilidad y diseño**

- [x] Controles de calidad
  - Cobertura de unidad Vitest, cobertura Playwright E2E, controles de entrada de fusión y cobertura de humo local
  - La cobertura del navegador del panel de administración abarca `/admin/`, `/es/admin/`, configuración, complementos, campañas, análisis, informes, soporte, marketing y usuarios.
  - Las comprobaciones de cordura de Merge-gate cubren la sintaxis del script de lanzamiento más `release:smoke`, evidencia del proveedor y superficies de comando de humo de pago sin enviar correo electrónico.
- [x] Liberación de automatización de pruebas
  - `npm run release:smoke` envuelve la prefusión, el ensayo de preparación para la configuración/implementación, Podman E2E cuando esté disponible, evidencia de accesibilidad enfocada, evidencia de transcripción del lector de pantalla opcional, evidencia i18n/SEO renderizada, evidencia de aporte/informe, preparación del proveedor y preparación para el humo de pago.
  - Los comandos enfocados cubren accesibilidad, i18n/SEO renderizado, aporte/informe, preparación del proveedor, humo de pago y evidencia de transcripción opcional de VoiceOver/Whisper.
  - el flujo de trabajo de GitHub Actions de Release Provider Evidence proporciona evidencia estricta de la API de DNS de Cloudflare a través de secretos de lectura de DNS dedicados.
  - `POOL_EMAIL_DRY_RUN` / `RESEND_EMAIL_DRY_RUN` permiten que la evidencia de publicación represente cargas útiles de correo electrónico sin llamar a Resend
- [x] Paridad entre repositorios y documentos como código
  - [MERGE_SMOKE_CHECKLIST.md](/es/docs/operations/merge-smoke-checklist/), [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/), [TESTING.md](/es/docs/operations/testing/) y [release-evidence/](https://github.com/your-org/your-project/tree/main/docs/release-evidence) documentan la disciplina de liberación de The Pool.
  - Las reglas de paridad The Pool/Store tratan el trabajo compartido como primitivos transferibles y al mismo tiempo preservan los sustantivos, los límites de almacenamiento, el pago, los aportes, las campañas, la administración, el inventario y el comportamiento de SEO específicos de The Pool.
  - Las notas de la versión The Pool se rastrean en [../CHANGELOG.md](/es/docs/reference/changelog/), mientras que esta hoja de ruta mantiene el inventario de capacidades actual y el plan de funciones futuras.
- [x] Automatización de recuperación ante desastres
  - Se agregó una verificación previa de poco tráfico, ensayos sintéticos semanales y un simulacro de vista previa trimestral de datos capturados protegido por opción con lectura de archivos fuera de la cuenta verificada por bytes.
- [x] Actuación pública
  - las páginas públicas cargan primero un cargador liviano de tiempo de ejecución de carrito y difieren la pila completa del carrito hasta que el estado persistente del carrito, el estado de recuperación o la intención clara del patrocinador lo requieran.
  - La captura previa de documentos públicos del mismo origen sigue un pequeño modelo de intención local con listas de rutas permitidas, exclusiones de consultas confidenciales, protecciones de red, límites bajos por página y una superficie de configuración habilitada de forma predeterminada.
  - Las páginas de producción crean minify CSS/JS generado por minify después de la salida de Jekyll, mientras que Cloudflare sigue siendo responsable de la compresión de transferencia gzip/Brotli/Zstandard y Auto Minify permanece deshabilitado.
- [x] Accesibilidad
  - Semántica de diálogo, pestaña, control deslizante de sugerencias, error y región activa
  - Cobertura de superficies críticas con respaldo de hacha.
  - Cobertura más amplia de accesibilidad del navegador en los estados de campaña, comunidad, resultado de aporte, Acerca de y Términos.
  - los shells públicos compartidos mantienen enlaces de omisión y anclajes `main-content` estables, y el activador del carrito expone etiquetas accesibles más claras y un estado ampliado.
  - La evidencia de publicación verifica el orden de enfoque del aporte de campaña, actualizaciones de estado en vivo de recordatorio de lanzamiento, superficies de carrito de campaña con movimiento reducido, comportamiento de zoom alto, rutas de teclado y desbordamiento móvil.
- [x] Sistema de diseño y diseño responsivo
  - tokens compartidos, tipografía, botones, campos, carcasas de tarjetas, secciones apiladas, superficies responsivas, listas de pestañas, estados de píldora, cuadrículas de objetos multimedia, controladores de cantidad y botones de acción principal
  - Las páginas públicas, las páginas de campaña, el carrito/pago, la gestión de aportes, la tarjeta de actualización, las páginas de la comunidad y el contenido de formato largo utilizan el mismo diseño y patrones de respuesta en lugar de estilos paralelos.
  - La cobertura móvil incluye desbordamiento, capacidad de desplazamiento, acciones primarias accesibles, superposiciones de navegación/carrito con reconocimiento de áreas seguras, resumen en pantalla pequeña y objetivos más grandes para eliminar/cerrar toques.
  - Las tarjetas complementarias y los controles de gestión de aportes están normalizados en los puntos de interrupción de computadoras de escritorio, tabletas y teléfonos pequeños.
  - Se reparó la compatibilidad de prueba del nodo 25 para la cadena de herramientas local predeterminada
- [x] Personalización de la horquilla
  - configuraciones canónicas `platform`, `pricing`, `design`, `checkout` y `cache`
  - Duplicación de trabajadores sincronizada automáticamente desde `_config.yml` / `_config.local.yml` a `worker/wrangler.toml`
  - Puente de variable de tema CSS curado emitido en `assets/main.css`
  - activos de marca centrales configurables y superficie de personalización documentada sin código
  - Los elementos de marca Stripe y los correos electrónicos de los patrocinadores siguen la superficie de diseño/configuración compartida en lugar de una ruta separada del tema de pago/correo electrónico.
- [x] Localización en español
  - `_config.yml` posee idiomas admitidos, etiquetas de idiomas y rutas de páginas públicas localizadas y seleccionadas.
  - Existen rutas en inglés + español para `/`, `/about/`, `/terms/`, `/pledge-success/`, `/pledge-cancelled/`, `/manage/`, `/community/` y páginas de la comunidad de patrocinadores.
  - un conmutador de idioma de pie de página más silencioso y asistentes de ruta compartidos que preservan las cadenas de consulta y los hashes para rutas tokenizadas como `/manage/?t=...`
  - etiquetas compartidas de campaña pública/comunidad, carrito de propiedad del sitio/comunidad/cadenas de tiempo de ejecución de aporte de administración, cuenta regresiva de campaña/galería/copia de estadísticas en vivo y correos electrónicos de apoyo de los trabajadores leídos desde datos locales más `preferredLang` persistente
  - Los resúmenes de los botones del carrito, la copia auxiliar de ubicación de impuestos de pago y los metadatos públicos localizados siguen el mismo modelo de configuración regional compartida.
- [x] SEO y metadatos estructurados
  - Los metadatos compartidos cubren títulos, descripciones, canónicos, etiquetas OG/Twitter e imágenes sociales predeterminadas en diseños públicos.
  - `robots.txt`, `sitemap.xml` y el manejo explícito de `noindex,nofollow` mantienen los flujos privados/tokenizados/solo para patrocinadores fuera de la intención de búsqueda.
  - las páginas públicas emiten `Organization` / `WebSite` JSON-LD conservador, y las páginas de campaña emiten `CreativeWork` conservador más JSON-LD de ruta de navegación
  - el centro de la comunidad pública dirige a las personas a las páginas públicas de la campaña en lugar de dirigir a los rastreadores a rutas exclusivas para los patrocinadores.
  - La puerta de fusión y la cobertura de unidades protegen los metadatos en idiomas alternativos, la inclusión de mapas del sitio y la superficie de rastreo pública.
  - La configuración de SEO delimitada hacia la bifurcación cubre `seo.x_handle`, `seo.same_as`, `seo.default_social_image_alt`, `seo.og_locale_overrides` y si el centro de la comunidad pública debe permanecer indexable.
  - El navegador estructurado y el registro de depuración de trabajadores se envían como una ayuda para desarrolladores basada en la configuración con marcas de tiempo, etiquetas de gravedad, prefijos de alcance y captura de errores globales del navegador.
  - Los metadatos públicos emiten sugerencias de idioma/nombre de aplicación, etiquetas de imágenes sociales seguras cuando sea posible y raíces de ruta de navegación/idioma JSON-LD con reconocimiento local.
  - La representación de la URL del mapa del sitio se comparte a través de `_includes/seo-sitemap-url.xml`, incluidas las alternativas localizadas de `xhtml:link` para páginas públicas localizadas y páginas de campaña.
  - `npm run test:seo` valida archivos de rastreo creados, canónicos, alternativas de hreflang, metadatos sociales y JSON-LD como parte de la puerta de fusión.
  - Liberar muestras de evidencia de i18n/SEO, páginas públicas en inglés y español, metadatos de campaña activa, shells sin índice de ruta privada, mapas de sitio alternativos, límites de robots y copia de ruta.
- [x] Incrustar y compartir vistas previas
  - Las páginas de la campaña se vinculan a un generador de incrustaciones alojado con reconocimiento regional que genera código iframe de copiar y pegar con opciones de diseño, tema, medios y CTA.
  - el widget de inserción utiliza un estado de campaña en vivo respaldado por los trabajadores, cambia de tamaño automáticamente después de pegar y admite enlaces de retorno localizados además de copia localizada en tiempo de ejecución/generador
  - La vista previa de inserción de marketing del administrador mantiene el progreso, los hitos, el marcador de objetivos y las etiquetas de objetivos ampliados contenidos para las campañas dirigidas por vídeo.
  - Las páginas de la campaña emiten metadatos sociales más ricos y conscientes del estado, además de imágenes de tarjetas compartidas PNG generadas por los trabajadores, con SVG retenido para herramientas internas de vista previa/depuración.
  - Las rutas de campaña localizadas, las rutas de inserción localizadas y las URL de tarjetas compartidas con reconocimiento regional mantienen las incrustaciones y las vistas previas enriquecidas alineadas en inglés y español.
  - Las páginas de campaña muestran enlaces compartidos de íconos reutilizables para Bluesky, X, Threads, Facebook, SMS y correo electrónico, utilizando URL localizadas, íconos PNG alternativos para casos extremos de SVG en línea y texto CTA con reconocimiento de estado donde las plataformas permiten el texto del mensaje.
  - Los controles interactivos para compartir aparecen debajo de la breve propaganda en dispositivos móviles/tabletas y encima del botón de inserción solo en computadoras de escritorio.
- [x] Sitio web externo y preguntas frecuentes
  - `thepool.fund` aloja el sitio de marketing de la plataforma y las preguntas frecuentes para desarrolladores derivadas de la documentación interna.
- [x] Protección contra denegación de servicio
  - `RATELIMIT` KV es un requisito estricto, con un comportamiento de cierre fallido cuando falta el enlace
  - los puntos finales de lectura pública mantienen intencionalmente espacio para la viralidad de la campaña, mientras que el pago, la gestión de aportes y las mutaciones administrativas utilizan límites de tasa específicos y límites de tamaño de solicitud.
  - El análisis del cuerpo de la solicitud rechaza antes las cargas útiles con formato incorrecto o obviamente sobredimensionadas en la superficie del trabajador.
  - `/checkout-intent/abandon` utiliza un presupuesto de reintento con alcance de orden en lugar de un limitador ingenuo por IP
  - Los trabajadores estándar/pagados desplegados declaran un tope conservador `cpu_ms = 100` como salvaguarda de denegación de billetera
  - Los puntos finales de observabilidad solo para administradores y `scripts/check-observability.sh` exponen resúmenes de resultados de webhooks y tiempos de mutación de muestra para su ajuste.
- [x] UX de impuestos y pago
  - Costura de trabajador/proveedor, interfaz de usuario de impuestos provisionales y carrito de cobertura de plomería de destino final de impuestos, pago, gestión de aportes, datos de aportes almacenados y correos electrónicos de apoyo
  - La experiencia del usuario del navegador mantiene los impuestos en `--` hasta que el pago tenga suficientes datos de destino, en lugar de inventar un valor preciso falso demasiado pronto.
  - El pago personalizado recopila la ubicación del impuesto de facturación para los carritos solo digitales, mientras que los carritos físicos/mixtos mantienen la dirección primero y admiten el autocompletado del navegador nuevamente.
  - Existe una ruta gratuita para Nuevo México a través de un conjunto de datos inicial suministrado más un refinamiento EDAC opcional.
  - Las instalaciones de humo locales y la cobertura de puertas de entrada funcionan con proveedores de impuestos que reconocen la ubicación en lugar de asumir un impuesto fijo.
- [x] Informes del ejecutor de campaña
  - El frente de la campaña admite `runner_report_emails`, con vacío/faltante, lo que significa que no hay informes de corredores para esa campaña.
  - `_config.yml` expone una superficie de personalización `reports.campaign_runner` limitada para habilitación, hora de envío de zona horaria de plataforma, resúmenes, archivos adjuntos y prefijo de asunto.
  - El trabajador envía correos electrónicos diarios del libro mayor de aportes relacionados con la campaña a la hora de envío local configurada para campañas activas y divide los correos electrónicos de cumplimiento posteriores a la fecha límite para los que cumplen la campaña frente a los que cumplen la plataforma.
  - La pestaña Informes del panel muestra una vista previa de las filas de aportes/cumplimiento y descarga archivos CSV sin enviar correos electrónicos ni escribir marcadores de enviados.
  - Los puntos finales de informes de secreto compartido permanecen separados para los flujos de trabajo de script/operador que envían informes intencionalmente.
  - Las exportaciones CLI locales y los correos electrónicos programados de los trabajadores comparten el mismo núcleo de informes JS para evitar la deriva de CSV.

## Funciones futuras

- [ ] Lanzamiento de Google Shopping para la recompensa destacada Their Love
  - Mantenga `shopping.enabled: false` hasta que se confirme la fecha exacta prevista de disponibilidad del cartel destacado y el cronograma visible de la campaña pueda publicar la misma fecha honesta.
  - Cree y verifique Merchant Center, luego configure el feed y el destino de Shopping desde la campaña existente/fuente de nivel destacado antes de esperar la ubicación en la pestaña Shopping; no crear un segundo catálogo de productos
  - Una vez que se cumplan esos requisitos previos, habilite el producto de Shopping existente a través del panel o la fuente de campaña canónica y verifique la oferta presentada, la aceptación del feed, el estado del destino y la ubicación pública de Shopping.
- [ ] Configuración guiada del contenedor TUI
  - Cree una interfaz de usuario de terminal delgada y atractiva alrededor del núcleo de configuración `scripts/setup-deploy.mjs` existente en lugar de crear una aplicación de escritorio separada o duplicar la lógica del proveedor.
  - Tome las indicaciones de la interfaz de las herramientas modernas de terminal, como [Hermes Agent CLI](https://hermes-agent.nousresearch.com/docs/user-guide/cli) y [Amp CLI](https://ampcode.com/manual): área de estado clara, progreso responsivo, navegación fácil de usar con el teclado, salida de tareas en streaming, posibilidades de interrupción/reintento y una sensación pulida de paleta de comandos
  - Mantenga intacto el contrato de script primero: cada acción de TUI debe asignarse a un modo de configuración existente o una pequeña extensión de ese modo, y los usuarios CI/no interactivos aún deben poder usar la CLI subyacente directamente.
  - Respalde las rutas locales y de producción actuales: generación de secretos locales, ejecución en seco de producción, comprobaciones de preparación del proveedor, planificación de creación/reutilización de KV, escrituras de secretos de trabajadores, escrituras de secretos de GitHub, implementación opcional y guía de preparación de Podman.
  - Muestre un tablero de preparación paso a paso con el estado del proveedor, las credenciales requeridas, las mutaciones planificadas, las comprobaciones omitidas, los secretos locales generados y borre las siguientes acciones antes de cualquier mutación activa.
  - Mantenga los secretos privados en la interfaz de usuario: entradas enmascaradas, sin eco de terminal, sin registros que contengan valores secretos y recordatorios explícitos de que los secretos de producción no se copian en `worker/.dev.vars`
  - Proporcione comandos de respaldo copiables para cada paso fallido para que los operadores puedan volver a Wrangler, GitHub CLI, Stripe CLI o el script de configuración existente sin perder el contexto.
  - Agregue exportación de transcripción/registro que redacte secretos y capture decisiones de configuración, estados de proveedores, versiones de comandos y motivos de falla para soporte sin crear un nuevo backend de telemetría.
  - Agregue atajos de prueba de humo después de la configuración, como `podman:doctor`, `./scripts/dev.sh --podman`, `./scripts/test-checkout.sh --podman`, `npm run test:secrets` y `npm run test:i18n`, sin dejar la orquestación de prueba real en los scripts existentes.
  - Mantenga la implementación pequeña y multiplataforma: prefiera una capa Node TUI sobre el núcleo de configuración actual, evite el empaquetado Electron/nativo hasta que el contenedor del terminal resulte útil y documente cualquier limitación del terminal específica de la plataforma.
- [ ] Ampliación de la calculadora de impuestos y refuerzo del cumplimiento
  - Comience desde la línea base implementada actualmente: `worker/src/tax.js` ya proporciona los modos de proveedor `flat`, `offline_rules`, `nm_grt` y `zip_tax`; `_config.yml` refleja la configuración no secreta de `tax.*` en `worker/wrangler.toml`; `/tax/quote`, pago, gestión de aporte, aporte almacenado `taxDetails`, correos electrónicos, análisis e informes ya utilizan totales de impuestos calculados por el trabajador; y el navegador mantiene el impuesto provisional como `--` hasta que tenga suficientes detalles de destino
  - Mantenga la arquitectura actual SECO: el Trabajador sigue siendo la única autoridad tributaria, el carrito y Administrar Aporte siguen solicitando cotizaciones en lugar de duplicar las matemáticas de impuestos, `_config.yml` posee configuraciones de proveedor no secretas, los secretos del Trabajador poseen claves de proveedor y los informes/análisis continúan leyendo `tax` / `taxDetails` persistentes en lugar de volver a calcular las obligaciones históricas del catálogo actual o los datos de tarifas.
  - Dar prioridad primero a la experiencia estadounidense y luego tratar el cumplimiento del IVA/GST internacional como una fase posterior; El trabajo a corto plazo debe centrarse en una cobertura estatal, de condado, municipal, de distrito especial, del Distrito de Columbia y del territorio de EE. UU. confiable antes de agregar el registro transfronterizo, la facturación o el comportamiento de cobro revertido.
  - Aclare el modelo impositivo antes de ampliar el alcance: documente qué montos están sujetos a impuestos hoy (`subtotal`, incluidos niveles, artículos de soporte, complementos de campaña y complementos de plataforma), cuáles no están sujetos a impuestos actualmente (`tipAmount` y la mayoría de los envíos a menos que una respuesta del proveedor marque el envío como sujeto a impuestos) y si cada categoría de producto futura debe estar sujeta a impuestos, estar exenta, tener una tasa reducida, ser digital, ser una admisión, ser similar a una donación o estar sujeta a impuestos por envío.
  - Agregue clasificación de impuestos a nivel de artículo sin dividir el modelo de pago: introduzca un generador de líneas de impuestos compartidas que convierta niveles, artículos de soporte, soporte personalizado, complementos de campaña, complementos de plataforma y envíos en líneas imponibles escritas con ID estables, códigos de categoría, montos, cantidad, propiedad de campaña/plataforma e indicadores de exención, luego permita que los proveedores agreguen esas líneas cuando solo admitan cotizaciones a nivel de subtotal.
  - Preservar la experiencia de usuario actual del colaborador mientras se mejora la corrección: mantenga la visualización provisional de `--` cuando el destino esté incompleto, pero haga explícitos los estados de cotización (`needs_input`, `quoted`, `provider_unavailable`, `fallback_used`) para que el carrito, el pago, la gestión de aporte y los diagnósticos del administrador puedan distinguir la dirección faltante de una falla del proveedor o una alternativa deliberada.
  - Resuelva la discrepancia en la documentación/comportamiento de `/tax/quote`: decida si el punto final debe continuar devolviendo `400`/`503` por falla de destino/proveedor faltante, o devolver una respuesta provisional estructurada que coincida con la copia del navegador en `worker/README.md`; actualice las pruebas y los documentos de la ruta del trabajador de cualquier manera
  - Termine primero la ruta de Nuevo México porque coincide con la implementación actual: amplíe el conjunto de datos iniciales de GRT suministrado más allá de las cinco ubicaciones de referencia actuales, agregue metadatos para la fecha/fuente/período efectivo de generación, mejore los diagnósticos de coincidencia de ciudades/correos/calles y agregue un flujo de trabajo de actualización repetible con diferencias revisables en lugar de una deriva silenciosa de la tasa en vivo
  - Agregue un flujo de trabajo de vigilancia de tasas impositivas mensual de GitHub Actions con activadores `schedule` y `workflow_dispatch` que verifica los cambios en las tasas de EE. UU. en los niveles de estado, condado, municipio y distrito especial, ejecuta la actualización inicial de Nuevo México, muestra cotizaciones ZIP.TAX para accesorios configurados, compara resultados con instantáneas registradas y abre una solicitud de extracción o problema con diferencias revisables en lugar de cambiar el comportamiento de producción silenciosamente.
  - Agregue controles de estado del proveedor para búsquedas en vivo: tiempos de espera, reintentos limitados donde el almacenamiento en caché de cotizaciones es seguro y de corta duración codificado por destino/proveedor/versión de tarifa normalizada, comportamiento de límite de velocidad/disyuntor para ZIP.TAX y EDAC, registro de errores redactado y diagnósticos de administrador/tiempo de ejecución que muestran la preparación del proveedor sin exponer las claves API
  - Combine la solución específica de Nuevo México con ZIP.TAX en una estrategia integral de EE. UU.: use datos de EDAC/proveedor de NM donde sean más sólidos y gratuitos, use ZIP.TAX como proveedor de tarifas locales generales para todos los demás estados, D.C. y territorios de EE. UU., y mantenga un contrato de adaptador de proveedor para que al realizar el pago, administrar el aporte, los informes y las pruebas no les importe qué fuente produjo la cotización.
  - Decida la política de respaldo explícitamente por proveedor y etapa de pago: mantenga el respaldo de tarifa plana configurado existente como una opción disponible, pero defina cuándo las vistas previas pueden usar el respaldo, cuándo debe bloquearse el pago de producción, cuándo se puede usar una tarifa de respaldo aprobada por el operador y si alguna vez se permiten cotizaciones sin impuestos cuando ZIP.TAX o EDAC no están disponibles.
  - Fortalecer el comportamiento internacional más adelante: tratar a `offline_rules` como una vista previa/alternativa conservadora, luego decidir si el IVA/GST internacional debe seguir siendo suministrado, pasar a una ruta respaldada por el proveedor o permanecer deshabilitado de forma predeterminada hasta que se conozcan las obligaciones de registro/nexo; agregar accesorios de normalización y prueba de país/estado/provincia para los países de lanzamiento previstos antes de permitir la recopilación
  - Agregue funciones de impuestos para empresas/clientes solo después de aprobar el alcance: captura y validación de ID de IVA, manejo de reversión de cargos, certificados de exención, precios con impuestos incluidos, reglas B2B/B2C, requisitos de evidencia de destino y copia localizada de facturas/recibos deben estar detrás de la configuración explícita, los documentos administrativos y las pruebas en lugar del comportamiento de pago implícito.
  - Mejore la privacidad y la retención de los destinos fiscales: revise si el `taxDetails.destination` persistente debe conservar la dirección postal completa para siempre, si las pruebas fiscales almacenadas se pueden minimizar o aplicar hash después de las ventanas de liquidación/informe, y cómo esto interactúa con las direcciones de cumplimiento que ya requieren retención de PII.
  - Agregue soporte de conciliación y remesas: cree exportaciones de obligaciones tributarias agrupadas por proveedor, fuente, jurisdicción, código de ubicación, tasa efectiva, subtotal imponible, envío sujeto a impuestos, impuestos recaudados, propiedad de campaña/plataforma y deltas de reembolso/cancelación/modificación; Asegúrese de que los informes conserven los detalles históricos de impuestos almacenados incluso después de que cambien la configuración del proveedor o las categorías del catálogo.
  - Amplíe las pruebas en las capas correctas: pruebas unitarias para la construcción de líneas de impuestos y adaptadores de proveedores, pruebas de fijación para el inicio de NM/respaldo de API y la tributación de envío ZIP.TAX, pruebas de trabajadores para el pago y administración de deltas de impuestos de aporte, pruebas de navegador para estados de IU provisionales/de error/de respaldo, pruebas de informes para exportaciones de obligaciones tributarias y pruebas de configuración para el manejo de credenciales/preparación del proveedor.
  - Actualice los documentos después de la implementación: `docs/CUSTOMIZATION.md`, `docs/WORKFLOWS.md`, `docs/TESTING.md`, `docs/SECURITY.md`, `worker/README.md`, `docs/PAYMENT_PROCESSOR.md`, las listas de verificación del creador y el texto de ayuda del panel deben explicar la selección de proveedores, la política alternativa, la cadencia de actualización, el comportamiento de las categorías de impuestos, la evidencia almacenada y lo que los operadores deben verificar con un profesional de impuestos.
- [] Integración de inventario con el sistema POS Stripe
  - Trate esto como inventario compartido entre The Pool, Store y [Pago por Stripe](https://paymentforstripe.com/), no como una afirmación de que los productos Stripe o el pago por el stock propio de Stripe cuentan. The Pool y Store siguen teniendo autoridad sobre el contenido de sus propios productos, precios en línea, envío, impuestos, contabilidad de campañas y valores históricos de pedidos/aportes; Un libro de contabilidad de existencias compartido limitado adquiere autoridad solo para el inventario físico finito vinculado o la capacidad de eventos, incluidos los complementos físicos The Pool y los productos físicos, de boletos y de confirmación de asistencia con seguimiento de inventario Store.
  - Agregue una configuración de superadministrador **Inventario compartido y POS** a ambos paneles de administración, respaldada por la configuración canónica y el estado Worker reflejado, con `enabled: false` como repositorio, desarrollo local y nueva bifurcación predeterminada. Mantenga la prueba y la activación en vivo separadas, muestre la preparación configurada o faltante para el coordinador compartido, las credenciales Stripe, el webhook, el programador y la versión del esquema, y ​​requiera una verificación previa exitosa de solo lectura más una confirmación explícita antes de la habilitación en vivo.
  - Cuando la función nunca se haya habilitado, mantenga el comportamiento de inventario independiente The Pool/Store actual y oculte o deshabilite los controles de creación/adjunción de Stripe. Desactivar la función debe detener los nuevos enlaces y la sincronización del proveedor, pero no debe descartar asignaciones, reservas, cursores o historial de eventos ni copiar silenciosamente un conteo compartido en dos conteos locales; requerir una migración de referencia o desvinculación revisada para cada elemento vinculado, o colocar los elementos vinculados no resueltos en un estado de pausa seguro que bloquee cantidades nuevas o aumentadas hasta que se vuelva a habilitar la integración o se complete la migración.
  - Comience con un pico de integración en modo de prueba que registre los objetos Stripe reales y la secuencia de webhooks producida por el pago de las ventas del catálogo Stripe, reembolsos, cancelaciones, propinas/impuestos, envío retrasado/fuera de línea y su flujo de facturas `payment://cart`. Solo una venta por catálogo exitosa cuyas líneas de pedido se resuelvan con ID de precio Stripe conocidos puede cambiar el inventario; ignorar o marcar cargos de monto de formato libre que no se pueden atribuir a un artículo asignado
  - Defina un contrato de artículo compartido versionado con un `shared_inventory_id` estable, SKU, referencias propias/equivalentes de The Pool y Store, y asignaciones de precio y producto Stripe de prueba/en vivo por separado. Cada producto o variante local puede asignarse como máximo a un artículo compartido, cada precio Stripe puede pertenecer solo a un artículo compartido y los registros The Pool/Store equivalentes se unen intencionalmente a través de esa identificación compartida en lugar de una coincidencia de nombres difusa.
  - Modele un artículo sin variante como un Producto Stripe más un Precio único activo. Variantes de modelo como un Producto Stripe con un Precio activo por variante vendible, porque el Pago por Stripe muestra múltiples Precios Stripe como opciones de producto separadas; Exigir que cada variante rastreada por el inventario tenga su propio SKU, artículo compartido y asignación de precios en lugar de agrupar tamaños u opciones accidentalmente. Cuando cambia un precio en persona, conserve los ID de precio anteriores como alias históricos del mismo artículo compartido, de modo que los webhooks retrasados, los reembolsos y la conciliación fuera de línea aún se resuelvan en la identidad de inventario correcta.
  - Amplíe la creación de complementos físicos The Pool y la creación de productos físicos, de tickets y de confirmación de asistencia con seguimiento de inventario Store con tres opciones explícitas: **Crear producto Stripe**, **Adjuntar producto Stripe existente** o **No vincular**. No muestre el flujo de trabajo de enlace de inventario para complementos digitales The Pool o productos Store sin inventario/capacidad finitos. El flujo de adjuntar debe buscar y validar el catálogo de cuenta/modo activo, mostrar claramente la identidad del Producto y el Precio, rechazar asignaciones de inventario duplicadas/en conflicto y permitir que un artículo desvinculado intencionalmente mantenga el comportamiento del inventario local actual.
  - Permitir a los usuarios de campañas crear, adjuntar, reemplazar o eliminar asignaciones solo para complementos en las campañas que se les hayan asignado; Permita que los superadministradores administren asignaciones entre complementos de campaña, complementos de la plataforma The Pool y productos/complementos Store. Mantenga las correcciones de stock compartido, la importación masiva, la conciliación forzada, la promoción de prueba/en vivo y la resolución de conflictos entre productos solo como superadministrador, con verificaciones de rol/alcance y eventos de auditoría aplicados por Worker.
  - Cuando se selecciona **Crear producto Stripe**, use el elemento The Pool/Store como semilla inicial: copie su nombre actual, descripción, imagen, moneda y precio de producto/variante resuelto en el nuevo Producto Stripe y Precio único; inicializar la línea de base disponible compartida a partir de su inventario/capacidad efectiva actual en la misma operación revisada; y agregue metadatos de fuente estable/elemento compartido. Stripe no tiene un campo de recuento de existencias, por lo que el valor del inventario genera el libro mayor compartido en lugar de pretender que Stripe posee el inventario.
  - Si el producto equivalente se vincula posteriormente desde la otra aplicación, adjúntelo al `shared_inventory_id` existente y al saldo compartido actual en lugar de generar o agregar su inventario local por segunda vez. Muestre tanto las líneas de base locales como el recuento compartido actual, requiera la identidad exacta de SKU/variante y haga que un operador elija o ingrese la cantidad disponible físicamente contada siempre que los valores preexistentes The Pool y Store no coincidan.
  - Después de la creación inicial, sincronice solo el inventario. Precios en línea de The Pool/Store y precios en persona de Stripe pueden diferir intencionalmente en cualquier dirección; las ediciones posteriores en un lado no deben actualizar el otro lado, las diferencias de precios no deben tratarse como una variación del inventario y los pedidos históricos de aportes The Pool/Store mantienen sus precios unitarios almacenados. Debido a que el monto del Precio Stripe es inmutable, cambiar el precio en persona crea y asigna un Precio de reemplazo revisado mientras se conserva la asignación de precios anterior para eventos e historial retrasados.
  - Introduzca un coordinador de inventario serializado y compartido utilizado por ambos Workers para los artículos vinculados en lugar de intentar reflejar eventualmente las líneas base independientes The Pool y Store. Acciones de establecimiento/reabastecimiento/reinicio vinculadas a rutas, reservas de pago Store, reservas de aporte The Pool, aportes de venta de POS, lanzamientos y correcciones a través deltas idempotentes atómicos; asigne a cada mutación aceptada una revisión monótona por elemento y devuelva el saldo resultante para que los reintentos y los eventos concurrentes converjan de manera determinista; mantener el inventario configurado de cada repositorio como evidencia de semilla/recuperación y conservar el comportamiento de coordinación/proyección local existente para elementos no vinculados
  - Utilice una sincronización híbrida basada en eventos más reconciliación: The Pool y Store reservan/confirman/liberan directamente contra el coordinador compartido antes de reconocer mutaciones sensibles al inventario; Los webhooks Stripe firmados aplican el pago atribuible por las ventas de Stripe tan pronto como Stripe las informe; actualizaciones de proyecciones públicas/administrativas de corta duración mediante revisión compartida; y reparaciones de conciliación superpuestas programadas, eventos de POS perdidos, tardíos o fuera de línea. No utilice copias periódicas de última escritura ganadora entre tres contadores separados
  - Defina la disponibilidad vinculada como disponible compartida menos las reservas activas de aporte The Pool, las reservas de pago Store en vuelo, las ventas confirmadas de Store, el pago confirmado por las ventas del catálogo Stripe y un buffer de seguridad POS explícito opcional por artículo, además de lanzamientos/reabastecimientos revisados. El buffer mantiene una cantidad visible fuera de la disponibilidad en línea cuando los operadores esperan ventas presenciales activas o fuera de línea; Ponlo en cero de forma predeterminada, nunca lo cambies mediante una predicción opaca y muestra su efecto en ambos paneles. Ambas UI públicas pueden mostrar proyecciones, pero The Pool checkout/Manage Pledge y Store cart/checkout deben revalidar contra el coordinador compartido antes de aceptar una cantidad nueva o aumentada.
  - Reserve acciones de The Pool cuando el aporte persista, ajústela atómicamente cuando cambie la cantidad de un complemento o variante y libérela cuando el aporte se cancele o su campaña finalice sin financiación. Mantenga las existencias reservadas después de una liquidación fallida solo durante un período de gracia de la Tarjeta de actualización configurable y documentado; Después del lanzamiento, un reintento de pago debe volver a adquirir existencias antes de cobrar en lugar de prometer inventario que otro canal puede haber vendido.
  - Conserve el ciclo de vida de reserva antes de pago y aporte/liberación de Store, pero mueva los SKU vinculados al coordinador compartido para que los aportes de The Pool, los pagos de Store, los ajustes de administración, los reintentos de webhook y los eventos de POS simultáneos no puedan aplicarse dos veces. No debilite la veracidad del pedido Store actual, la veracidad del aporte The Pool, la preservación histórica del precio unitario ni los límites de idempotencia de pago existentes de cualquiera de los sistemas.
  - Agregue una ruta de ingestión de webhook Stripe dedicada y firmada para la actividad del catálogo atribuible a POS sin redirigir el aporte The Pool o el manejo de pago de pedidos Store. Verifique las firmas Stripe, distinga los PaymentIntents propiedad de The Pool/Store del pago para las ventas Stripe, deduplica por evento Stripe más venta/identidad de línea, tolere la entrega fuera de orden y almacene un diario de eventos de inventario minimizado de solo agregar, suficiente para explicar cada delta de existencias sin retener cargas útiles sin procesar del proveedor o PII del cliente.
  - Resuelva colisiones de canales simultáneos por tipo de evento, no por orden de llegada: las reservas atómicas The Pool/Store no pueden reclamar la misma unidad disponible, mientras que una venta de POS completada se registra como un reserva de existencias física incluso si su webhook retrasado/fuera de línea llega después de las reservas en línea. Si eso crea un déficit, no cancele silenciosamente una orden pagada de Store, un aporte activo de The Pool o la venta de POS; establezca la disponibilidad en cero, marque el artículo compartido afectado y las reservas como **en riesgo**, bloquee cantidades nuevas/aumentadas y la liquidación The Pool que no puede volver a adquirir stock, y requiera un reabastecimiento auditado, una liberación de reservas o una decisión de cumplimiento
  - Defina la política de reversión de manera conservadora: las transacciones de POS fallidas, canceladas o anuladas no consumen stock; un reembolso por sí solo no prueba automáticamente que se haya devuelto el stock físico. Exponga las cantidades reembolsadas para que las revise el operador y requiera un reabastecimiento explícito a menos que se habilite y audite deliberadamente un flujo de trabajo de devolución futuro que tenga en cuenta la cantidad.
  - Ejecute una conciliación periódica limitada en los modos de prueba y en vivo de Stripe, utilizando un cursor duradero y una ventana superpuesta para encontrar pagos perdidos, retrasados ​​y sincronizados fuera de línea para las ventas de Stripe sin volver a escanear todo el historial. Agregue superadministrador **Sincronizar ahora** y controles de prueba que informen deltas/conflictos esperados antes de la mutación, reparen solo eventos atribuibles de forma idempotente y nunca inventen stock a partir de un total Stripe inexplicable; use reintentos exponenciales limitados para fallas transitorias, muestre errores de mapeo permanentes inmediatamente y avance el cursor duradero solo después de que todos los eventos en la página se apliquen o se pongan explícitamente en cuarentena
  - Importe asignaciones existentes a través de una herramienta de vista previa que puede coincidir con el SKU exacto o los metadatos compartidos/Stripe preexistentes, nunca solo el nombre del producto. Informar variantes faltantes, SKU duplicados, un precio vinculado a artículos de la competencia, discrepancias de prueba/en vivo, objetos inactivos/archivados y desacuerdos de referencia The Pool/Store; mostrar las diferencias de precios en línea versus en persona como un contexto informativo esperado en lugar de un conflicto de bloqueo, y requerir una resolución explícita solo para la ambigüedad de identidad, modo o inventario antes de permitir la aplicación compartida
  - Exponga el estado de la conexión por artículo en el administrador The Pool y Store: estado vinculado/desvinculado, SKU compartido, modo Stripe/Producto/precio activo y alias de precio histórico, recuentos disponibles/reservados/comprometidos por canal, último webhook, última conciliación exitosa, riesgo fuera de línea pendiente, estado de error/derivación del inventario y deltas minimizados recientes. Muestre claramente los precios independientes en línea y en persona sin etiquetar una diferencia como deriva. Haga que la desvinculación no sea destructiva de forma predeterminada, conserve las asignaciones/eventos históricos y bloquee la desvinculación o la reasignación, mientras que las reservas no resueltas harían que la propiedad de las acciones sea ambigua.
  - Error cerrado para cantidades vinculadas nuevas o mayores cuando el coordinador compartido no está disponible, su modo/cuenta Stripe no coincide o la sincronización es anterior a una antigüedad máxima configurada; preservar la veracidad de los aportes/órdenes ya guardadas y brindar a los operadores orientación sobre reintentos, conciliación y soporte. No recurra silenciosamente a un recuento independiente de The Pool o Store porque eso reintroduciría la sobreventa.
  - Utilice el Pago para los metadatos de Producto/Precio `payment_hidden=true` de Stripe como un control de visibilidad agotado del mejor esfuerzo y elimínelo después de un reabastecimiento auditado, mientras documenta que la aplicación actualiza la visibilidad del catálogo solo en su siguiente carga de producto, las URL ocultas del carrito aún pueden funcionar y las transacciones fuera de línea pueden llegar más tarde. Por lo tanto, la primera versión reduce y detecta la sobreventa entre canales, pero no puede exigir una aplicación estricta del inventario en los puntos de venta.
  - Mantenga las claves secretas de Stripe y las credenciales de servicio compartido en secretos de Worker, nunca en la configuración del navegador o del repositorio; utilice la autenticación de servidor a servidor entre The Pool, Store y el coordinador compartido; validar cuenta y modo en vivo en cada mapeo/evento; mutaciones de administrador/proveedor de límite de velocidad; devolver respuestas de administrador privadas/sin tienda; y agregue las nuevas familias de mapeo, diario de eventos, cursor y reserva a los planes de inventario de datos, copia de seguridad, restauración, retención y respuesta a incidentes.
  - Agregue un contrato de repositorio cruzado y una secuencia de lanzamiento para que The Pool y Store rechacen una versión de esquema de inventario compartido no compatible en lugar de desviarse. Cubra la configuración predeterminada, preparación y activación de prueba/en vivo, desactivación/migración segura, elegibilidad por tipo de cumplimiento/inventario, inventario inicial y siembra de precios, prevención de línea de base duplicada, divergencia intencional de precios en línea/en persona, reemplazo e identidad de precios históricos, normalización de mapeo, simultaneidad atómica entre canales revisada, amortiguadores de seguridad de POS, déficits de colisión y reservas en riesgo, deltas del ciclo de vida de aportes/pedidos, webhooks duplicados/fuera de pedido, reembolsos, Ventas fuera de línea/retrasadas, comportamiento de cierre fallido de proveedor obsoleto, aislamiento de prueba/en vivo, conflictos de importación, reparación de conciliación, alcance de roles, resultados de auditoría, accesibilidad, localización y comportamiento de panel responsivo en la unidad, Worker, integración y capas de navegador.
  - Actualice la documentación del operador de The Pool y Store después de la implementación, incluidos sus archivos README, guías de productos/complementos, referencias de configuración/personalización, panel de control, procesador de pagos, flujos de trabajo, seguridad, pruebas, copia de seguridad/restauración, inventarios de datos, registros de riesgos éticos y evidencia de liberación. Explique la habilitación y preparación predeterminada, la desactivación/migración segura, el límite compartido de la fuente de la verdad, la identidad del mismo producto en tres canales, el pago por el requisito de venta por catálogo de Stripe y las limitaciones fuera de línea, el inventario local más la inicialización de precios en línea en la creación de productos Stripe, precios independientes en persona después de la creación, reemplazo Historial de precios, sincronización revisada basada en eventos, amortiguadores de seguridad de POS, respuesta ante colisiones/déficit, conciliación continua, pagos fallidos retenciones, política de reembolso/reabastecimiento, recuperación manual y reversión segura al inventario local no vinculado


## Problemas conocidos

**Autocompletar de tarjeta de crédito**: los campos de número CC, vencimiento y CVV están dentro del iframe de Stripe para cumplir con PCI; no son accesibles para nuestros scripts de autocompletar.
