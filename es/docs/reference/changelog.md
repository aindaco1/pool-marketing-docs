---
title: Registro de cambios
parent: Referencia
nav_order: 1
render_with_liquid: false
lang: es
---

# Registro de cambios

## Última actualización

6 de septiembre de 2026

## Inédito

### Mantenimiento de dependencia

- Se agregaron verificaciones de auditoría completa/producción raíz explícita y Worker a Merge Smoke,
separado de la instalación y las pruebas. Las fallas transitorias de npm se han limitado
reintentos; La evidencia faltante no pasa la verificación en lugar de parecer limpia.
- Se actualizó Vitest y su proveedor de cobertura V8 a 4.1.11, Vite a 8.2.2 y
axe-core a 4.13.0.
- Se mantuvieron las herramientas compartidas de compilación/lanzamiento en el esbuild 0.28.1 y revisado de la plataforma.
smol-toml 1.7.1, hizo que los requisitos de raíz sean exactos y agregó cobertura de regresión
para alineación de manifiesto/archivo de bloqueo y exclusiones de Dependabot de solo versión.

### Postura de producción

- URL de vista previa de Cloudflare Worker deshabilitadas explícitamente y faltantes o habilitadas
Vista previa de URL: un error en la postura de producción.

### Documentación

- Se actualizaron las páginas Acerca de y Términos en inglés y español para que coincidan con el complemento guardado
precios, plazos de cancelación, reintentos inmediatos de pago fallido después de un
actualización de tarjetas, preferencias de correo electrónico de campaña e independencia de aporte/correo electrónico.
La revisión de la copia cubre las expectativas de pago, la privacidad, el acceso y la mensajería;
Los recursos de cumplimiento existentes y las protecciones de derechos legales permanecen intactos.
- Se agregó un índice de documentación basado en tareas y se consolidó la descripción general.
flujo de trabajo y guías de notas para desarrolladores sobre arquitectura, contenido de campaña,
y referencias de API Worker. Configuración, implementación, generación de informes y verificación
los procedimientos ahora viven con sus propias guías; Los archivos README raíz y Worker son
puntos de entrada concisos.
- Se corrigió la implementación obsoleta de Worker, los impuestos de proveedores y la contabilidad de informes.
descripciones manteniendo el estado actual, la hoja de ruta y el historial de lanzamientos
límites.
- Se excluyó la documentación del mantenedor del artefacto público Jekyll y se agregó
una verificación de artefactos previa a la fusión, preservando las páginas raíz y localizada del sitio web.
- Comportamiento actual separado, trabajo prospectivo e historial de lanzamientos en todo el mundo.
README, guías prácticas, hoja de ruta, registro de cambios y evidencia de lanzamiento.
- Se eliminaron instantáneas de proveedores fechadas, hojas de ruta de trabajo completado, específicas de la versión.
libros de estado y listas duplicadas de trabajos futuros de guías del estado actual.
- Se movió la guía de la calculadora de impuestos a The Pool para que el comportamiento, configuración y
la resolución de problemas y la verificación tienen una fuente de documentación ascendente.

### Verificación local

- Se preservó la selección de Ruby/Bundler y Nodo de la persona que llama en el host previo a la fusión
fases. Los shells de inicio de sesión anteriormente podían pasar controles de dependencia bajo rbenv,
luego cambie al sistema macOS Ruby para la compilación y retroceda innecesariamente
a Podman. Se agregó cobertura de regresión para el host y el envío de compilación Podman.

## v1.2.20 - 2026-08-06

### Flujo de trabajo de vídeo de producto reutilizable

- Avanzó el pin de plataforma inmutable a `v0.32.0`
(`85165a16ac6923b438514bdce0a9957c1804db5f`) y adoptado
Vídeo del producto Core `0.1.0`.
- Se reemplazó el obsoleto motor de árbol de trabajo local con un adaptador delgado The Pool que
conserva el inicio de vista previa de Jekyll, los dispositivos/selectores de `smoke-editable`,
capturar CSS de presentación, tiempo editorial, destino de marketing opcional,
medios generados y autoridad de publicación.
- Se agregaron comandos de captura/renderización de duración de producción más una breve interfaz real
flujo de humo, caracterización del consumidor, cobertura de sintaxis y pago limpio
Inicio de `_config.test.yml`.

### Seguridad, rendimiento y reversión

- La captura permanece en bucle invertido únicamente desde The Pool, del mismo origen y declarativa; salida
está confinado debajo de `tmp/product-video`, las ejecuciones existentes se conservan y no
la limpieza recursiva seleccionada por la persona que llama permanece. FFmpeg/FFprobe se ejecuta sin
El shell y la captura fallan cuando la velocidad de fotogramas efectiva no alcanza su configuración
piso. Cada renderizado completado también debe decodificar un plano alfa antes de su
La evidencia de FFprobe puede informar el éxito.
- Capture CSS se inyecta sólo en el marco local Playwright y no se
vinculado desde plantillas de producción, por lo que la función no agrega ninguna solicitud de producción
o tiempo de ejecución del navegador. Jekyll y la puerta de liberación excluyen y rechazan el
árbol `tmp` generado completo para cuadros locales, renderizados y vistas previas anidadas
No se puede ingresar un artefacto de Pages. The Pool puede revertir la plataforma exacta gitlink y local
adaptador de forma independiente sin afectar Store, Podcast o Dust Wave.
- El inicio del servidor web Playwright ahora conserva el rbenv seleccionado por la persona que llama y
Cadena de herramientas del Nodo 24 en lugar de abrir un shell de inicio de sesión al que podría recurrir
Sistema macOS Ruby antes de ejecutar cualquier prueba del navegador.
- La representación predeterminada de todos los formatos está cubierta en macOS Bash 3.2 y en la versión moderna
conchas; Las listas de formato vacío en modo estricto ya no se cancelan antes de que se inicie FFmpeg.

## v1.2.19 - 2026-08-06

### Contrato de proyecto dorado Jekyll versionado por separado

- Fijado `dust-wave-jekyll-template` `v0.1.0`
(`351281a5aec60fa85653a3d23391e66fb860aae6`) como actualización de fuente independiente
submódulo junto con la plataforma v0.31.0.
- Enlazado con 15 Liquid exactos y dos complementos Ruby exactos en un manifiesto,
resumen y CLI de verificación/escritura explícita mientras se preserva el byte idéntico de The Pool.
copias registradas en tiempo de ejecución.
- Se agregó pin, versión, resumen, comando de deriva y exclusión de salida generada.
regresiones. La puerta de lanzamiento completa ahora falla antes de compilar la plantilla
deriva y falla después de la compilación si se publica el submódulo de actualización de código fuente.
- La plantilla no agrega ninguna solicitud de navegador, byte implementado, ruta, código Worker o
credencial. The Pool conserva rutas, datos, localización, contenido, configuración,
pruebas, autoridad de implementación y reversión independiente de un solo aporte.

### Mantenimiento y documentación posteriores al lanzamiento

- Estabilizó el presupuesto de preparación del tablero para que mida la navegación en frío.
cadena de solicitud de aplicación a través de las primeras solicitudes de resumen/configuración mientras
conservar las aserciones del panel visible, el cambio de pestañas y la tabla de apoyo;
El sondeo de aserciones del lado del host ya no crea una falla de rendimiento falsa.
- Instalación de dependencia en frío dividida Podman Worker desde la preparación en tiempo de ejecución: a
El período de gracia de instalación limitado y verificado mediante lock-hash evita que el `npm ci` sea lento.
las descargas sean eliminadas y reiniciadas por el Worker existente de 60 segundos
presupuesto de salud, mientras que los volúmenes cálidos continúan de inmediato.
- Hizo que el contrato estático del navegador `POOL_CONFIG` esperara a que DOM estuviera listo en lugar de
que la finalización de recursos de página completa no relacionados, eliminando el único problema
resulta en la puerta completa del navegador de 113 pruebas sin debilitar su configuración
afirmaciones.
- Se limitó la limpieza del árbol de procesos previo a la fusión Worker/Jekyll y se agregó una obstinada
regresión infantil, evitando que permanezca una puerta alojada que pasa por completo
vivo hasta que se agotó el tiempo de espera del flujo de trabajo porque un servidor ignoró la terminación.
- Concilió la raíz, Worker, pruebas, desarrollador, rendimiento, panel de control,
i18n, hoja de ruta y documentación de la lista de verificación del creador en inglés/español con el
Plataforma activa `v0.31.0`, Jekyll Plantilla `v0.1.0`, The Pool `v1.2.19`, Nodo 24,
y Wrangler 4.118 contratos sin cambiar creador o implementación
autoridad.

## v1.2.18 - 2026-08-06

### Minificación de activos de navegador compartido incluidos en la lista permitida

- Avanzó el pin de plataforma inmutable a `v0.31.0`
(`5ca8ee6d0ff8912ccfdc27c8459a5ef72f8c0579`) y adoptó Build Core `0.2.0`.
- Se extendió el paso de construcción de activos generados para minimizar solo `_site/assets` y el
generó copias de las fuentes de Site Shell ancladas a través de mensajes explícitos y
raíces transversales seguras.
- Se agregó caracterización del consumidor para la selección de raíz, fuente Worker intacta,
salida multi-root y los comandos exactos de escritura/verificación utilizados por las páginas locales y
construye.
- Los seis scripts de Site Shell generados disminuyen de 15.573 a 9.531 bytes, ahorrando
6.042 bytes sin procesar (38,8%); el modo de verificación posterior a la escritura no reporta ningún ahorro adicional
en los 32 activos generados seleccionados.
- Esto no cambia ninguna ruta, recuento de solicitudes, identidad global, comportamiento de pago o
activo fuente. The Pool conserva los presupuestos, la orquestación, la autoridad de implementación y
reversión independiente de un solo aporte.

## v1.2.17 - 2026-08-06

### Fundamentos de diseño compartido inyectados por políticas

- Avanzó el pin de plataforma inmutable a `v0.30.0`
(`499e6c1994d79be6049ef204fefd728f22b8093e`) y adoptó Design Core `0.2.0`.
- Se eliminaron la forma local, el diseño y los parciales de mezcla de The Pool. The Pool ahora inyecta su
Medianil centrado basado en relleno más espaciado entre títulos de marca, identidad de animación,
escala de tipo móvil y ancho de línea antes de importar neutral compartido Sass.
- Salida generada caracterizada antes y después de la migración: `main.css`
permaneció `d3568877d0f31903ccf02a7b37c82220115146609141457a5ae84969c123ea95`
y `admin.css` permaneció
`a398fef8d7d257092f1685dab132e9d98a87bbadba347a90a62fd5c081445e84`
byte por byte.
- Se agregaron regresiones de políticas de pin y tiempo de compilación. La extracción no agrega ningún navegador.
solicitud o código de tiempo de ejecución; The Pool conserva tokens, orden de importación, plantillas,
contenido, presupuestos de CSS, implementación y reversión independiente.

## v1.2.16 - 2026-08-06

### Primitivas del navegador Shell del sitio compartido

- Avanzó el pin de plataforma inmutable a `v0.29.0`
(`7ed3d9b0220b88126235a3b7edfd507f8846f56d`) y adoptó Site Shell `0.2.0`.
- Se eliminó el icono de carrito duplicado, la hoja de estilo diferida y la identidad de control de formulario de The Pool.
e implementaciones de navegadores con opciones de envío. La política Thin Liquid incluye mantener
Clave de caché de The Pool, nombres de proveedores y eventos, etiquetas accesibles, ID de control
Prefijo y prioridad del conjunto de datos local.
- Se conserva la carga diferida del carrito y las URL compartidas versionadas, por lo que la extracción agrega
no hay solicitudes ansiosas de tiempo de ejecución del carrito y mantiene la reversión independiente del submódulo.
- Se agregó caracterización del consumidor para opciones de envío, totales de carrito y etiquetas.
controles insertados dinámicamente, aplazamiento de hojas de estilo, carga en tiempo de ejecución, exactitud
Versiones de paquetes, cada ruta de origen compartida consumida y presupuestos de tamaño explícitos.
para cada primitiva del navegador Site Shell implementada.
- Estabilizó el presupuesto de preparación administrativa en torno a DOM y la preparación de aplicaciones para que
La latencia de medios o fuentes de terceros post-DOM no relacionadas no pueden enmascarar regresiones
en la ruta de inicialización del propio panel de The Pool.

## v1.2.15 - 2026-08-06

### Tiempo de ejecución compartido de evidencia de lanzamiento

- Avanzó el pin de plataforma inmutable a `v0.28.0`
(`5836ced5129ce3eddb09a035601de23ec58a5737`) y adoptó Release Core `0.2.0`.
- Se reemplazó la auditoría de política de caché duplicada de The Pool, la regla de respuesta del administrador de Cloudflare
cliente y la implementación de evidencia de lector de pantalla asistida con tecnología delgada y
Adaptadores de políticas seguros para la importación.
- Release Core ahora limita orígenes, rutas, metadatos de reglas, entradas de comandos y
resultados de diagnóstico; rechaza redirecciones; evita la interpolación de comandos de shell;
y excluye de la evidencia las credenciales, los datos de los clientes y los organismos de respuesta.
The Pool mantiene sus objetivos de producción, política de rutas, frases esperadas,
credenciales del proveedor, decisiones de lanzamiento, implementación e independencia
reversión de una sola confirmación.
- Se agregaron regresiones de adaptadores de consumidor para orígenes y políticas propiedad de The Pool más el
Cloudflare, caché, rendimiento, pin y cobertura de versión de lanzamiento existentes.

## v1.2.14 - 2026-08-06

### Componentes de diseño compartidos en tiempo de compilación

- Avanzó el pin de plataforma inmutable a `v0.27.0`
(`06a9453ed2f310f5acca1a1f864fdce4a45d5f56`) y adoptó Design Core `0.1.0`.
- Se eliminaron cinco parciales Sass locales de bytes idénticos y se resolvió su base.
componentes de botones, bloques de contenido, modales y de utilidad de la plataforma anclada
cargar la ruta con CSS generado equivalente a bytes.
- El paquete no agrega JavaScript al navegador ni costo de tiempo de solicitud. The Pool conserva
tokens, mixins, orden de importación, plantillas, política de enfoque y respuesta,
contenido, presupuestos de CSS, integración, implementación y reversión de Jekyll. Liquid
Los complementos include y Ruby permanecen locales por decisión explícita de arquitectura.

## v1.2.13 - 2026-08-06

### Configuración de prueba compartida y ayudante de ventana gráfica móvil

- Avanzó el pin de plataforma inmutable a `v0.26.0`
(`3063aae3cb1cf80e2f8bc5f9b1e40c814dff47b2`) y adoptó Test Core `0.1.0`.
- Se reemplazó la configuración de almacenamiento duplicada exacta del navegador y el desbordamiento horizontal.
ayudante con pequeños adaptadores Vitest y Playwright; La plataforma no gana corredor o
dependencia de la automatización del navegador.
- The Pool conserva accesorios, URL, ventanas gráficas, expectativas de respuesta/producto, CI,
implementación y reversión. El contrato independiente de accesibilidad y medios
las pruebas siguen siendo locales y el descubrimiento de pruebas Playwright cubre 113 casos.

## v1.2.12 - 2026-08-06

### Mecánica compartida de caja de salida duradera

- Avanzó el pin de plataforma inmutable a `v0.25.0`
(`4f1c7c042456da1a86116c24c7d346dfaddb21b4`) y Worker Núcleo `0.12.0`.
- Se reemplazaron ID de trabajos canónicos duplicados, creación de registros/colas limitadas,
clasificación de vencimiento/arrendamiento/vencimiento, retraso de reintento, evidencia de error redactada,
normalización de correo electrónico/etiquetas y mecánica de eventos Resend con primitivas compartidas.
- The Pool conserva las operaciones de KV, representación de plantillas, supresión global/de campaña,
envíos y programación del proveedor, efectos de aporte, credenciales, implementación y
reversión independiente. Pasan las pruebas de idempotencia y carga útil congelada existentes.

## v1.2.11 - 2026-08-06

### Transporte compartido de servicios fiscales delimitados

- Avanzó el pin de plataforma inmutable a `v0.24.0`
(`16ccc75209f1b07044299a60c0ff26520fe70607`) y Núcleo Fiscal `0.3.0`.
- Se reemplazó la búsqueda duplicada de Zip-Tax y GRT de Nuevo México, creación de direcciones,
street-parse y código de normalización fuente con transporte delimitado compartido.
- Las URL de los proveedores requieren HTTPS, las redirecciones se rechazan, los tiempos de espera se cancelan y
Los datos de solicitud/respuesta están limitados sin devolver credenciales ni datos sin procesar.
errores de red. The Pool conserva la selección de proveedor/alternativa y la campaña
tributación, cálculo de cotizaciones, efectos de pago, implementación y reversión.

## v1.2.10 - 2026-08-06

### Transporte compartido delimitado GitHub

- Avanzó el pin de plataforma inmutable a `v0.23.0`
(`a0006c3e0c3f8ab814387491753989956adbbe94`) y Worker Núcleo `0.11.0`.
- Se reemplazó el envío de flujo de trabajo duplicado de The Pool y el cliente API de contenido con un
adaptador delgado manteniendo la reconstrucción, optimización de medios, archivo de campaña,
publicación de archivos, lista de directorios y comportamiento de eliminación idempotente.
- Las solicitudes ahora rechazan redirecciones, tiempos de espera, rutas vinculadas, referencias, entradas de flujo de trabajo,
contenido y respuestas del proveedor, y devolver errores normalizados sin formato
excepciones de red o credenciales. The Pool conserva los valores predeterminados del repositorio,
política de contenido y flujo de trabajo, registro, autorización, efectos, implementación,
y retroceso independiente.

## v1.2.9 - 2026-08-06

### Transporte compartido y registro de país USPS

- Avanzó el pin de plataforma inmutable a `v0.22.0`
(`514c00932d5fb2fa05ee6f7cebb7ea44d9426d78`) y Núcleo de envío `0.2.0`.
- Se reemplazó el duplicado USPS OAuth, búsqueda de tasas, tiempo de espera, caché de token/cotización de The Pool,
e implementación de enfriamiento del proveedor con un adaptador de configuración delgada.
- Hizo del YAML de 95 países de Platform la fuente canónica y agregó explícito
verificar/escribir comandos de sincronización más una regresión de pin de igualdad de bytes para The Pool
Instantánea Jekyll.
- Las credenciales del proveedor siguen siendo solo para solicitud; el estado de clase de correo/token/caché es
acotado; tiempo de espera, actualización 401, tiempo de reutilización 429/5xx, respaldo y envío completo
el comportamiento permanece cubierto. The Pool conserva la elegibilidad de direcciones, tarifas de campaña,
efectos de pago/cumplimiento, almacenamiento, rutas, implementación y reversión.

## v1.2.8 - 2026-08-06

### Mecánica de estado de inventario compartido

- Avanzó el pin de plataforma inmutable a `v0.21.0`
(`98533957456eed4bb2eae6f474b9072a419b64bc`), adoptado
`@dustwave/inventory-core` `0.1.0` y Worker Núcleo `0.10.0`.
- Se reemplazó el mapa de recuento duplicado, la clonación de instantáneas, la caducidad de la reserva de The Pool,
y ayudantes de conteo reservado con mecánicas puras compartidas mientras se preserva el
La instantánea de la campaña almacenada tiene autoridad sobre la entrada de arranque posterior.
- Se agregó una regresión independiente previa al movimiento para la política de arranque de The Pool. el
el contrato de coordinador completo continúa cubriendo los cambios de selección atómica,
reclamos en competencia, confirmación/liberación de reserva, limpieza de vencimiento y
Migración de inventario heredado.
- The Pool conserva todas las transacciones de Durable Object, escribe KV, campaña/nivel
etiquetas, transiciones de pago y aporte, selección de TTL, rutas, implementación,
y retroceso independiente.

## v1.2.7 - 2026-08-06

### Mecánica de registro compartido y catálogo de medios

- Avanzó el pin de plataforma inmutable a `v0.19.0`
(`1bfbdd403fc9efafb8d261dd846cedb9d52ed444`), Worker Núcleo `0.9.0` y
Núcleo multimedia `0.4.0`.
- Se reemplazó la implementación duplicada de la consola de alcance y los medios del sitio de The Pool.
Mecánica de catálogo con finos adaptadores de políticas de campaña, preservando al mismo tiempo la
prefijos de producto/tiempo de ejecución existentes, política de gravedad, forma de manifiesto,
presupuestos de colocación, rutas de derivación y comportamiento de los medios públicos.
- Se agregó caracterización de medios independientes antes de la migración y cierre de fallas.
cobertura transversal. Etiquetas compartidas, ámbitos, campos de error, rutas de medios y
los conjuntos de rutas conocidas ahora están acotados.
- The Pool conserva el análisis del entorno/configuración, la política de registro y los destinos,
campaña/alcance predeterminado y política de slug, contenido, acceso al sistema de archivos,
transformaciones, rutas de administración, almacenamiento, implementación y reversión.

## v1.2.6 - 2026-08-06

### Mecánica de envío determinista compartida

- Avanzó el pin de plataforma inmutable a `v0.18.0`
(`3b8bdacc224bda625103718ba0fa8489517ff993`) y adoptado
`@dustwave/shipping-core` `0.1.0`.
- Se reemplazaron 542 líneas de perfil de artículo duplicado, agregación de envío mixto,
metadatos faltantes, cotización alternativa/gratuita/manual y mecánica de opciones de envío
con delgados adaptadores de políticas de campaña.
- Se agregó un contrato de consumidor independiente previo a la mudanza para nivel mixto,
envíos de artículos de soporte y complementos, además de comportamiento de respaldo de opciones.
- Selección limitada, catálogo, clase de correo y matrices de opciones antes de compartirse
bucles preservando la mesa plana actual USPS de primera clase y la normal
resultados de cotización.
- The Pool conserva el destino y la política de opción alternativa/gratuita/configurada de la campaña.
validación, credenciales y transporte USPS, OAuth/caché/retroceso/reintento,
pago, cumplimiento, almacenamiento, implementación y reversión.

## v1.2.5 - 2026-08-06

### Mecánica de seguridad de sesión compartida

- Avanzó el pin de plataforma inmutable a `v0.17.0`
(`3a526defd21d692292c73652966a044167f881d7`) y Worker Núcleo `0.8.0`.
- Se reemplazó la codificación/verificación del token de inicio de sesión caracterizado de The Pool,
serialización/borrado de cookies de sesión y verificaciones de solicitudes del mismo origen con
primitivas compartidas limitadas a través de adaptadores de políticas delgados The Pool.
- Se conservó la cookie de administración segura exacta, el encabezado de origen faltante actual y
comportamiento de origen local no configurado, TTL de inicio de sesión de 15 minutos, sesión de ocho horas
TTL, consumo nonce único, vencimiento de sesión fijo e independiente
revertir.
- Se agregó cobertura de rechazo para segmentos de token adicionales y se mantuvo la existente.
repetición, vencimiento, CSRF, origen cruzado, rol/alcance y falla de escritura no duradera
contratos.
- The Pool continúa siendo propietario de selección secreta, registros de inicio de sesión/sesión y campaña.
autorización, tokens CSRF y nombres de encabezados, rutas, almacenamiento, correo electrónico,
credenciales, implementación y reversión.

## v1.2.4 - 2026-08-06

### Mecánica de reintento y seguridad Resend compartida

- Avanzó el pin de plataforma inmutable a `v0.16.0`
(`d075c3e1a29134d3ba6e4631b76dc63212347d14`) y Worker Núcleo `0.7.0`.
- Se reemplazó la copia de verificación caracterizada Resend/Svix HMAC de The Pool con la
verificador de cuerpo sin formato compartido limitado, que conserva el adaptador de respuesta existente de The Pool
y todos los efectos de análisis, diario, entrega y supresión de eventos localmente.
- Se reemplazó la clase de error duplicada Resend y el estado reintentable/ambiguo de The Pool.
reglas con mecánicas puras compartidas. The Pool todavía decide intentar presupuestos,
ventanas de idempotencia, programación de retrasos, evidencia terminal y si alguna
se produce un reintento.
- Se agregó cobertura previa a la migración para candidatos con múltiples firmas, eventos obsoletos,
secretos mal formados, discrepancias corporales, tiempo de reintento 429 y rebote permanente
supresión. Los ID de eventos de gran tamaño y las marcas de tiempo fraccionarias ahora no se cierran.

## v1.2.3 - 2026-08-06

### Primitivas criptográficas compartidas

- Se reemplazó el token de alta entropía caracterizado SHA-256, HMAC-SHA-256 de The Pool,
análisis de cookies, normalización de correo electrónico y comparación de cadenas de trabajo constante
copias con la implementación inmutable `@dustwave/worker-core` `0.6.0`
ya fijado por The Pool a través de la plataforma `v0.15.0`.
- Se mantuvo la política de autenticación, la forma del token de inicio de sesión, la sesión y los registros CSRF.
permisos, rutas, almacenamiento KV, credenciales, liberación y reversión en The Pool;
el adaptador HMAC local conserva el orden de argumentos existente de The Pool.
- Se elevó el obsoleto respaldo del historial de inicio de sesión no-`randomUUID` de 8 a 16.
bytes aleatorios para que satisfaga el contrato de entropía de token de la plataforma sin
cambiando la ruta de tiempo de ejecución normal de Workers.
- Se agregó cobertura de contrato del consumidor para el resumen exacto y firma segura para URL
y formas de tokens, cookies codificadas, correo electrónico normalizado, igualdad en el trabajo constante,
y rechazo de tokens de tamaño insuficiente, junto con la repetición de inicio de sesión existente,
sesiones, CSRF y suites de historial redactado.

## v1.2.2 - 2026-08-06

### Consolidación de plataforma compartida

- Avanzó el gitlink `dust-wave-platform` exacto a `v0.15.0` inmutable
(`2e79a8d70cb6d30805ea141e53d32f9387441756`), incluyendo
`@dustwave/worker-core` `0.6.0` y `@dustwave/release-core` `0.1.0`.
- Se reemplazó la respuesta de seguridad/Cors Worker caracterizada de The Pool, zona horaria/fecha,
y Stripe transportan copias con adaptadores de políticas delgados The Pool. The Pool mantiene su
origen privado, alias de campaña, versión de API Stripe e identidad del proveedor,
reglas de pago, persistencia y autoridad de implementación.
- Se reemplazó el inventario Wrangler exacto, la transformación de respaldo KV, la suma de verificación,
copias de resultado de comando y evidencia de proveedor con primitivas de plataforma fijadas;
The Pool sigue siendo propietario de cada comando, credencial, llamada de proveedor y entorno.
ID, puerta de liberación, despliegue y reversión.
- Pruebas de consumo ampliadas para respaldo de origen privado y seguridad JSON completa
encabezados, límites de horario de verano, identidad del proveedor Stripe, faltantes
credenciales/ID de objeto y el paquete de plataforma/pin de origen exacto.
- Se evitó la construcción de un cliente Stripe durante la conciliación cuando el indexado
El lote de aporte no contiene objetos de proveedor, preservando el valor local que falta.
Ruta de evidencia de PaymentIntent y eliminación de configuraciones innecesarias de proveedores.

## v1.2.1 - 2026-08-06

Preparación de lanzamiento:

- Se migró el encabezado de navegación de bytes idénticos, anuncios en vivo, Worker
primitivas de zona horaria, instantánea de inicio de GRT de Nuevo México, actualizador y generado
minificador de activos a paquetes inmutables `dust-wave-platform` `v0.12.0`.
- Se eliminaron las copias fuente duplicadas de The Pool conservando sus plantillas.
localización, programación, política del proveedor de impuestos, datos de campaña/aporte, creación
orquestación, credenciales y autoridad de implementación independiente.
- Preservó las suites de caracterización de consumidores existentes y agregó las nuevas.
rutas compartidas y versiones exactas del paquete a la puerta pin de la plataforma ejecutable.

- Avanzó el gitlink `dust-wave-platform` exacto a través del espacio de trabajo `0.12.0`,
incluyendo `@dustwave/admin-shell` `0.10.2`, `@dustwave/build-core` `0.1.0`,
`@dustwave/site-shell` `0.1.0`, `@dustwave/tax-core` `0.2.0` y
`@dustwave/worker-core` `0.4.0`, manteniendo campaña, prenda, pago,
autoridad de almacenamiento e implementación dentro de The Pool.
- Se agregó un contrato de consumidor ejecutable para el gitlink inmutable, canónico.
submódulo remoto, versiones de paquetes y cada módulo compartido sin formato The Pool sirve
o importaciones.
- Habilitó la minificación segura de identificadores locales en JavaScript generado mientras
Preservar los valores globales del navegador y los presupuestos de activos de producción existentes.
- Hizo que el proceso de pago y limpieza de los envoltorios de lanzamiento Podman fuera seguro en macOS mediante el uso de un
Búsqueda de imágenes Playwright portátil y una configuración de prueba local efímera Jekyll.
- Se reemplazaron las decisiones de Lighthouse de muestra única con la mediana de tres ejecuciones,
evitar que una muestra ruidosa falle falsamente o apruebe una versión.
- Se promovió la verificación del inventario de accesorios de aporte mutable de una advertencia a una dura.
puerta de lanzamiento, alineó su elemento de campaña de unidad con la campaña construida, y
Normalizó ambas formas de respuesta de los puntos finales del inventario antes de afirmar los recuentos.
- Se hicieron simulacros de configuración de implementación no interactivos en torno a la planificación secreta, por lo que
Los valores del proveedor no se solicitan ni se pasan a una CLI durante el ensayo.
- Versiones transitivas `undici` y `ip-address` parcheadas fijadas para prueba local
y herramientas de implementación, superando auditorías de producción y de npm completas.
- Se fortaleció la comparación de secretos de administración heredados con el trabajo limitado fijo y se reemplazó un
verificación de tiempo de una sola solicitud con muestras medianas alternas en IP aisladas.
- Se preservó el puente de beneficios de Podcast deshabilitado de forma predeterminada y The Pool.
identidad de liberación reversible independientemente.

## v1.2.0 - 2026-08-05

Preparación de lanzamiento:

- Se agregó el submódulo `aindaco1/dust-wave-platform` anclado como límite versionado para las primitivas compartidas con Store, Dust Wave y Podcast.
- Se movió la implementación de Turnstile de bytes idénticos a `@dustwave/worker-core` manteniendo la unión de importación local de The Pool y agregando una prueba de contrato con el consumidor.
- Avanzó el límite compartido a `@dustwave/worker-core` 0.2.0, que agrega
criptografía neutral al producto mecanografiada y mecánica Stripe para Podcast sin moverse
Reglas comerciales de The Pool o cambiar el adaptador Turnstile existente de The Pool.
- Se mantuvo independiente la campaña, el aporte, la configuración, la sesión, el almacenamiento y la autoridad de implementación de The Pool; el submódulo no contiene datos ni secretos The Pool y se puede revertir mediante un puntero.
- Avanzó `@dustwave/worker-core` a 0.3.0 y agregó un sistema inerte cerrado ante fallas.
Cliente de concesión/revocación de The Pool a Podcast con un código único compartido de alta entropía
contrato. Mapeo de productos/niveles, entrega duradera y emisión de soporte
permanecerán deshabilitados hasta su configuración explícita y puerta de preparación.
- Avanzó el espacio de trabajo compartido a 0.6.0 y
`@dustwave/admin-shell` 0.2.0, moviendo QR de bytes idénticos a The Pool y Store
generador en el límite compartido fijado. The Pool todavía carga lo mismo
implementación caracterizada a través de su shell de administración estática; solo el
La autoridad de origen y la ruta generada cambiaron.
- Avanzó el espacio de trabajo compartido anclado a 0.8.1 y
`@dustwave/admin-shell` 0.7.1. Las rutas API `setHtml` del editor enriquecido aditivo
HTML restaurado a través del desinfectante de lista permitida existente; El comportamiento de The Pool es
sin cambios hasta que un formulario lo acepte, y la reversión sigue siendo una confirmación única
cambio de puntero de submódulo.
- Avanzó `@dustwave/admin-shell` a 0.8.0 y reemplazó el navegador en línea de The Pool
Salga del oyente con la protección compartida del ciclo de vida de cambios no guardados, cerrados ante fallas.
The Pool conserva su contenido caracterizado, configuración y administrador sucios
líneas de base; Store permanece sin cambios hasta que sus líneas base de editor separadas tengan un
Adaptador agregado seguro.
- `@dustwave/admin-shell` avanzado a 0.8.1 y The Pool enrutados caracterizados
clase de acción sucia, atributo de estado, etiqueta localizada y estado limpio
deshabilitar a través de la primitiva compartida. The Pool conserva todas las líneas base del editor,
regla de deshabilitación forzada y estilo de anillo de enfoque.
- Centralizó la identidad del proveedor Worker y agregó una prueba de contrato de liberación.
que mantiene los paquetes y bloqueos raíz/Worker, la configuración canónica, la etiqueta de lanzamiento,
Stripe y Resend alineados con v1.2.0.

## v1.1.2 - 2026-07-14

Alcance de la versión:

- Se corrigió la actualización engañosa del mapa del sitio al emitir `lastmod` solo desde fechas reales de página/campaña, y se amplió la auditoría generada para rechazar XML con formato incorrecto, duplicados, marcas de tiempo no válidas/futuras, URL privadas y deriva de datos estructurados.
- Se agregó una auditoría de rastreo posterior a la implementación sin dependencias que compara las respuestas de los mapas de sitio ordinarios y de inspección de Google, valida el estado de los mapas de sitio/robots y los tipos MIME, y recupera cada URL pública enviada con reintentos de propagación limitados.
- Se agregaron páginas de productos de Shopping localizadas y cerradas por fallas que reutilizan el nivel físico destacado de una campaña, el comportamiento del carrito existente, la identidad configurada del autor/empresa y los datos de políticas. La publicación del producto requiere un interruptor de habilitación explícito además de datos completos sobre la recompensa física y una fecha exacta de disponibilidad esperada.
- Mantuvo desactivado el candidato a cartel destacado de Their Love; confirmar su fecha exacta de disponibilidad y completar la verificación de Merchant Center más la configuración de feed/destino siguen siendo características futuras explícitas antes de que se espere la colocación de la pestaña Compras.
- Se agregaron datos de contacto/política de devolución del comerciante de la organización, metadatos enfocados en productos/ofertas y enlaces directos a anclajes estables de la política de envío y devoluciones junto a la marca de pie de página de DUST WAVE en la computadora de escritorio/tableta y debajo de los Términos en el menú móvil; Los controles automatizados garantizan que una política de no devoluciones nunca publique una ventana de devolución ficticia.
- Reescribió las páginas públicas Acerca de y Términos en inglés y español neutral de EE. UU. y Latinoamérica, utilizando valores de identidad/contacto `_config.yml` y documentando cargos de todo o nada, envío, valores predeterminados de venta final, manejo de errores de cumplimiento, verificación de informes de siete días, privacidad y reglas de envío de creatividades.
- Transferencia revisada de Store v1.0.8: The Pool ya contenía el precio, los medios, Stripe, la conciliación y el trabajo de correo electrónico duradero relevantes; adoptó la solución de recuperación de AWS CLI alojada en GitHub; expuso las API de revisión/revocación y búsqueda de auditoría/CSV de sesión existentes a través de secciones de configuración localizadas; hizo que sus guías de botones de información compartidos, filtros, tablas, controles de revocación, acciones en lenguaje sencillo, objetivos normalizados (incluidos los slugs de prueba locales generados) y explicaciones de estado/cambio fueran responsivos y comprensibles desde el escritorio hasta el dispositivo móvil, conservando al mismo tiempo identificadores canónicos para filtrado, diagnóstico y exportación; secciones de configuración compartidas alineadas según el orden de Store manteniendo las costuras específicas de The Pool; Brand & SEO adaptados a la política de compras sin devoluciones; y se excluyen las superficies de preparación, caché, catálogo, pedido, cupón, ticket, descarga, R2 y multiprocesador específicas de Store.
- Se igualó la capacidad de inicio de sesión de administrador local de Store al representar la URL de inicio de sesión devuelta solo para desarrollo como un enlace **Abrir administrador** localizado y al mismo tiempo mantener los enlaces de inicio de sesión implementados solo para correo electrónico.
- Se reforzaron los ayudantes previos a la fusión de Jekyll para que un host fallido o una compilación de Podman no puedan pasar a la minificación y validar la salida obsoleta de `_site`; la puerta de liberación ahora demuestra una compilación recién generada antes de las comprobaciones de artefactos.

Limpieza posterior al lanzamiento:

- Se eliminó el resto implícito de la fecha de recopilación Jekyll del mapa del sitio, el artículo de Open Graph, JSON-LD y se generaron metadatos de productos de compras para que las implementaciones no puedan suplantar las fechas de publicación o modificación del contenido. El mapa del sitio `lastmod` ahora requiere un `last_modified_at` creado; Las fechas de los artículos de la campaña utilizan `published_at` explícito cuando se proporcionan y, en caso contrario, la fecha de inicio de la campaña.
- Se agregó `/sitemap.txt` como un mapa del sitio de diagnóstico generado utilizando exactamente el mismo selector de elementos públicos compartido que `/sitemap.xml`, sin anunciar un segundo mapa del sitio canónico en `robots.txt`. Las auditorías generadas y posteriores a la implementación requieren que su lista de URL coincida exactamente con el mapa del sitio XML y compare las respuestas de inspección ordinarias con las de Google para ambos formatos.
- Evidencia registrada posterior a la implementación de que la herramienta de inspección oficial de Search Console llegó al mapa del sitio de producción desde direcciones propiedad de Google sin mitigación Cloudflare mientras recibía una respuesta HTTP 200 XML válida, aislando el error genérico restante de la prueba en vivo del firewall del sitio y el comportamiento de origen.

## v1.1.1 - 2026-07-12

Alcance de la versión:

- Se agregó un manifiesto de medios de repositorio determinista y reconstruible que cubre campañas/imágenes compartidas, videos y audio; Los hash de origen, las dimensiones, la duración, el tamaño del archivo, los derivados WebP/WebM responsivos, las ubicaciones de referencia, el estado de optimización y los derivados más grandes omitidos intencionalmente siguen siendo revisables en Git.
- Se amplió el selector de medios del panel existente con búsqueda, pestañas de tipos accesibles, clasificación reciente/por nombre, metadatos enriquecidos, advertencias de optimización y presupuesto de ubicación, visibilidad de referencias, informes de referencias rotas, selección de video/póster/audio local y acciones de reparación con alcance de función a través del flujo de trabajo del optimizador existente.
- Se agregó un reemplazo seguro de la fuente de la misma campaña con protección contra conflictos SHA GitHub, se mantuvieron los derivados generados fuera de los resultados del selector independiente y se mantuvo el repositorio como la única autoridad de medios; no se introdujo ninguna base de datos de medios KV ni backend de almacenamiento alternativo.
- Se agregó creación explícita de imágenes decorativas y se requiere texto alternativo para imágenes significativas; El contenido alternativo vacío heredado sigue siendo compatible con una advertencia de migración.
- Integración reforzada de Stripe con una versión API explícita, errores/observabilidad redactados normalizados, idempotencia determinista en escrituras seguras para reintentos, metadatos de tiempo/USD explícitos, marcadores de webhook de 35 días con concesiones de procesamiento y un diario mínimo de eventos de procesador de 400 días.
- Se hizo que la liquidación fuera segura contra fallas y reanudaciones con un estado de grupo de precarga duradero, reutilización segura dentro de la ventana de idempotencia de Stripe, puntos de control de trabajos obsoletos, recuperación exitosa de PaymentIntent y paradas de atención de necesidades en lugar de recargas ciegas después de resultados ambiguos.
- Se agregó conciliación programada y activada por superadministrador de la verdad de aportes indexadas, Stripe PaymentIntents y trabajos de liquidación, registrando evidencia `reconciliation-break:v1:*` abierta/resuelta sin escaneos de espacio de nombres KV.
- Transacciones de producción enrutadas, informes, actualizaciones de campaña, Blast, recordatorio de lanzamiento y correo electrónico de pago abandonado a través de una bandeja de salida KV compartida con cargas útiles congeladas, idempotencia determinista Resend, reintentos limitados, arrendamientos fallidos, webhooks de entrega de proveedores y evidencia de entrega a largo plazo con privacidad minimizada; El inicio de sesión de administrador y los envíos de prueba siguen siendo inmediatos.
- Se agregó la cancelación de la suscripción con un solo clic en el ámbito de la campaña para el diario, los hitos y el correo electrónico de anuncios, además de la supresión local permanente de rebotes/quejas compatible con las API de webhook y correo electrónico de Resend.
- Se agregaron medios enfocados, cliente Stripe, bandeja de salida, firma de webhook, reintento, supresión y cobertura de regresión Worker existente; configuración actualizada, configuración de Worker, pago/correo electrónico/seguridad/flujo de trabajo/panel/documentación de prueba y estado de la hoja de ruta para la versión completa.

## v1.1.0 - 2026-07-12

Alcance de la versión:

- Se agregaron precios opcionales específicos de variantes a los complementos de plataforma y campaña. Los precios en blanco heredan el precio base del producto, las anulaciones explícitas de cero dólares siguen siendo válidas y las tarjetas de carrito/Administrar aporte actualizan el precio mostrado cuando cambia la variante seleccionada.
- Autoridad monetaria mantenida en Worker: a las variantes complementarias nuevas o modificadas se les cambia el precio del catálogo actual, se ignoran los precios enviados por el navegador y un producto/variante sin cambios en un aporte existente conserva su `unitPrice` histórico válido a través de ediciones de solo cantidad.
- Se amplió el modelo de complemento compartido, las alternativas del navegador heredado, el editor de productos de administración, la validación y la serialización YAML sin introducir un segundo catálogo ni migrar productos existentes. Los precios de productos, variantes, catálogos e históricos no pueden eludir el límite de cantidad canónico `$1,000,000`.
- Se reemplazaron los ansiosos fondos de tarjetas de campaña de tamaño completo con fuentes WebP receptivas y decodificación diferida, lo que redujo la transferencia limitada medida de la página de inicio de aproximadamente 4,0 MB a 1,5 MB y el LCP de aproximadamente 20,3 segundos a 5,4 a 6,6 segundos.
- Se agregó Lighthouse centralizado y específico de ruta y evidencia de liberación de política de caché ampliada junto con los presupuestos de activos generados existentes. Se cubren once objetivos públicos/privados implementados y la caché Workers permanece deshabilitada hasta que la evidencia representativa demuestre el beneficio de p95 configurado.
- Se hicieron ejecutables los límites de tiempo del panel y Worker: las pruebas del navegador consumen presupuestos de preparación, cambio de pestañas y procesamiento de tablas; se lee el resumen/configuración del panel de muestras Worker; y una auditoría autenticada redactada evalúa los techos p95 configurados sin recopilar solicitudes ni cargas útiles del cliente.
- Se reforzaron las fallas de administración para que las respuestas no autorizadas sean privadas y no se puedan almacenar en caché, y se fijó la versión limpia y compatible de Lighthouse para que tanto las auditorías de producción como las de dependencia completa pasen sin vulnerabilidades conocidas.
- Se movió y actualizó `AGENTS.md` en la raíz del repositorio para que los contribuyentes y los agentes de codificación descubran automáticamente las invariantes de pago, seguridad, rendimiento, recuperación y versión actuales.

## v1.0.9 - 2026-07-12

Alcance de la versión:

- Modelo de respaldo y recuperación ante desastres adaptado a los límites de Git, `PLEDGES`, `VOTES`, `RATELIMIT`, Stripe y Durable Object de The Pool, con un RPO/RTO aprobado de cuatro horas y una política de retención de instantáneas de lanzamiento de 7 días/5 semanas/12 meses más.
- Se agregaron metadatos cubiertos por suma de verificación e instantáneas cifradas con valor KV, verificaciones de límites de repositorio, verificación de encriptación de antigüedad/GPG, recibos de liberación, poda de retención segura, copias fuera del dispositivo solo para agregar y evidencia de preparación sin exportación de valor secreto.
- Se agregaron planes de restauración basados en clasificación para local, vista previa y producción; validación de la familia autoritaria; reconstrucciones de estados derivados; exclusiones de cuarentena; limpieza de vista previa exacta; verificación de relectura; y puertas de mantenimiento de producción explícito, Stripe, resolución, conflicto, instantánea previa a la restauración y reconocimiento.
- Se agregaron ensayos de restauración semanales sintéticos y simulacros de vista previa protegidos de bajo tráfico trimestrales con datos de producción capturados deshabilitados hasta que se configuren las credenciales protegidas y la aprobación del operador. Los simulacros protegidos se cargan en un almacenamiento fuera de cuenta compatible con S3 y verifican una descarga de bytes idénticos antes de la restauración.
- Se agregó conciliación Stripe de solo lectura para los totales de aportes instantáneas y el estado de PaymentIntent, además de evidencia de verificación previa del tráfico Cloudflare de solo agregación.
- Dividió las actualizaciones de páginas de rutina desde Worker revisado manualmente/implementación de producción completa, fijó todas las acciones GitHub en confirmaciones inmutables, agregó cobertura mensual de Dependabot para acciones y ambos proyectos npm, e hizo que las sondas CLI Stripe no fueran interactivas.
- Se agregó un modelo de lectura de aporte The Pool compartido con marcas de agua deterministas seguras para la privacidad, respuestas sin cambios y lecturas masivas de producción KV en lotes de 100 en análisis, patrocinadores, informes, reparación de índices, liquidaciones y reposiciones financieras.
- Se agregó un historial de inicio de sesión de administrador con privacidad minimizada, revisión de sesiones activas/recientes, revocación explícita de sesiones, metadatos de auditoría con capacidad de búsqueda, exportaciones de CSV de auditoría seguras para fórmulas y carga diferida de Turnstile hasta que se conozca el estado no autenticado.
- Se agregó un conciliador de reglas de respuesta de administrador Cloudflare administrado y verificación pública para `private, no-store, no-transform, max-age=0, must-revalidate` en rutas de administración en inglés y español.
- Dividió el CSS exclusivo para administradores de la hoja de estilo pública, pospuso el CSS de fuente de visualización de Adobe, estableció presupuestos medidos para los activos generados y mantuvo la caché Workers desactivada hasta que la evidencia representativa muestre al menos un beneficio de p95 del 40 %.
- Se agregaron verificaciones semanales de deriva de la postura de producción, paquetes mensuales de revisión en español con hash de fuente sin reclamar revisión profesional, un flujo de trabajo E2E Podman programado y una puerta de recursos de suite de lanzamiento Podman de 6 GiB.
- Se agregaron artefactos de evidencia de proveedor JSON desinfectados para flujos de trabajo de recuperación/postura posteriores, con recuentos de fallas/advertencias/saltos y exclusiones explícitas de credenciales/datos de clientes.

## v1.0.8 - 2026-07-01

Alcance de la versión:

- Se adaptó el hardening de Cloudflare Rocket Loader derivado de Store al hacer que los layouts/includes propios de Pool emitan scripts con `data-cfasync="false"`, cubriendo campañas públicas, carritos, vista previa, administración, comunidad, resultados de aporte y superficies de administración.
- Carga de datos de marketing de administrador reforzada, por lo que los códigos de referencia guardados y el estado del proceso de pago abandonado se cargan lentamente solo cuando un administrador autenticado abre Marketing, con guardias de estado de carga y en vuelo con alcance de campaña.
- Se recordó la última pestaña del panel de administración más la sección Configuración, la campaña seleccionada de Campañas y la subpestaña Campañas en el estado local del navegador para que las recargas devuelvan a los administradores al mismo contexto de trabajo sin escrituras de Worker o KV.
- Se agregó una corrección global de navegador de proveedor de QR explícita para que el creador de QR de marketing de administrador no dependa de globales de script clásico sensibles al optimizador.
- Se agregó una auditoría de integridad local y cobertura de unidades para mantener los catálogos i18n compatibles alineados con el inglés.
- Se agregó cobertura de regresión de plantilla que escanea diseños/incluye scripts locales propios que no tienen la opción de exclusión de Rocket Loader.
- Se movieron los archivos de configuración de Vitest a los módulos ESM `.mts` y se actualizaron los scripts/exclusiones de Jekyll para evitar la ruta obsoleta de la API del nodo CJS de Vite.
- Se agregó una auditoría de SEO del sitio generado (`npm run test:seo`) adaptada de Store, se conectó a la puerta de combinación y se movió la representación de la URL del mapa del sitio a una inclusión compartida que emite alternativas de hreflang localizadas.
- Herramientas de evidencia de lanzamiento adaptadas para Pool con `release:smoke`, accesibilidad enfocada, i18n/SEO renderizado, evidencia de aporte/informe, preparación del proveedor, humo de pago y comandos de transcripción de lector de pantalla opcionales.
- Se agregó un flujo de trabajo de acciones de GitHub de evidencia del proveedor de lanzamiento para evidencia estricta de DNS de Cloudflare a través de un token de lectura de DNS dedicado.
- Se agregó soporte de ejecución en seco de correo electrónico sin envío de Pool a través de `POOL_EMAIL_DRY_RUN` / `RESEND_EMAIL_DRY_RUN` para que los humos de liberación puedan generar cargas útiles de correo electrónico de soporte/informe/administrador sin llamar a Resend.
- Se agregó evidencia de accesibilidad de lanzamiento específica de Pool para el orden de enfoque del aporte de campaña, actualizaciones de estado en vivo de recordatorio de lanzamiento y superficies de carrito de campaña de movimiento reducido.
- Se integró la cordura del comando de evidencia de liberación en la puerta de fusión y se habilitó el modo de ejecución en seco del correo electrónico de Pool para ejecuciones de humo de fusión local/CI.
- Se agregó pulido de metadatos móviles/CSS desde Store para que los encabezados de documentos públicos, administrativos, de administración, de comunidad, incrustados, de vista previa y de resultados de aporte opten por no participar en la detección automática de teléfono/fecha/dirección/correo electrónico, mientras que los controles compartidos heredan el tema actual de manera consistente.
- Se actualizó la solicitud de configuración del administrador para enviar el idioma preferido actual, manteniendo la normalización de filas i18n del lado del cliente existente de Pool lista para la localización del esquema del lado del trabajador.

## v1.0.7 - 2026-06-19

Alcance de la versión:

- Se agregó el estado del recordatorio de pago abandonado en el ámbito de la campaña en Marketing con recuentos agregados de colas/resultados, resultados recientes, controles de supresión/borrado del alcance, identificadores de correo electrónico con hash, eventos de auditoría, enlaces de reanudación de pago firmado y sin acciones de carrito abandonado específicas de reintento.
- `npm run setup:deploy` reforzado con reutilización del espacio de nombres Cloudflare KV, reutilización/creación de resultados de ejecución en seco más clara, comprobaciones de preparación del proveedor de solo lectura en vivo, `--skip-readiness` para ejecuciones en seco limitadas y cobertura de unidades basadas en subprocesos para rutas de ejecución en seco, secreto local, KV de producción, preparación y secreto generado.
- Se agregaron borradores compartidos explícitos de Marketing y Blast con un registro KV con alcance de campaña por superficie, vencimiento de 7 días, protección contra conflictos de revisión y sin escrituras en segundo plano.
- Se agregaron informes de rendimiento UTM/referencia de Analytics para enlaces de campaña guardados y no guardados, incluidos agregados de fuente/medio/campaña/contenido UTM de índices de aporte de campaña existentes sin escaneos de espacios de nombres KV.
- Se agregó un selector de medios de imágenes WYSIWYG compartido para los bloques de imágenes de contenido de campaña, diario y Blast. Los usuarios de la campaña ven medios relacionados con la campaña; Los superadministradores también pueden seleccionar imágenes compartidas/predeterminadas. El selector es de solo lectura y no agrega ningún estado KV nuevo.

## v1.0.6 - 2026-06-18

Alcance de la versión:

- **Campañas -> Marketing** ampliadas a un espacio de trabajo de promoción de campañas más completo sin agregar otra vista de panel de nivel superior. Los administradores de campañas pueden crear URL rastreadas, guardar códigos de referencia, obtener una vista previa/descargar códigos QR de campaña como PNG/SVG y utilizar el creador de inserciones de campañas existente desde la misma pestaña.
- Se agregaron **Campañas -> Explosión** para envíos masivos de correo electrónico a los patrocinadores. Los usuarios de campaña asignados y los superadministradores pueden redactar con el editor de contenido WYSIWYG compartido, cargar imágenes alojadas en la campaña a través del canal de medios existente, vincular videos de YouTube/Vimeo de forma segura por correo electrónico, enviarse pruebas a sí mismos, enviar explosiones en vivo a los patrocinadores de la campaña indexadas y revisar el historial de envíos de solo lectura.
- Se agregó validación automática de ejecución en seco de Blast antes de los envíos de prueba o en vivo. Los ensayos validan el contenido y la audiencia del índice de aportes de campaña sin enviar correos electrónicos, escribir registros de auditoría ni enumerar espacios de nombres KV; Los envíos en vivo requieren el hash de prueba coincidente y escriben el evento de auditoría después del envío.
- Se agregó generación de QR local en el navegador adaptada del enfoque `1612elphi/delphitools` con licencia del MIT, lo que mantiene las vistas previas y descargas de QR libres de lecturas/escrituras de Worker.
- Se agregaron recordatorios de pago abandonado basados ​​en el consentimiento para la ruta de pago propia. Los patrocinadores deben optar explícitamente por participar, los recordatorios se ponen en cola solo después de que la creación de la sesión de Stripe sea exitosa, los aportes completados eliminan los recordatorios en cola, las audiencias enviadas/suprimidas se deduplican y los enlaces para cancelar la suscripción se firman.
- Se mantuvo la programación de pago abandonado en el nivel gratuito con `abandoned-cart-queue:v1`, lotes limitados, límites de retención, marcadores de envío/supresión y ticks cron inactivos que omiten los escaneos de la lista de espacios de nombres KV.
- Se agregó el asistente multiplataforma `npm run setup:deploy` para configuración local y de producción. La CLI de Nodo libre de dependencia admite ejecuciones en seco, generación de secretos locales, sincronización de configuración, creación/actualización de Cloudflare KV, escrituras de secretos de trabajadores, escrituras de secretos de repositorio de GitHub, `gh`/`wrangler`/verificaciones de autenticación de CLI de Stripe opcionales y `wrangler deploy` opcional.

## v1.0.5 - 2026-06-14

Alcance de la versión:

- Se agregaron vistas previas de campañas protegidas para superadministradores, usuarios de campañas asignados y correos electrónicos de revisores invitados explícitamente. Los enlaces de vista previa están firmados, tienen alcance de campaña, son visibles en el panel para el administrador de publicación y caducan después de 24 horas.
- Se agregó la creación de campañas de superadministrador para campañas de solo vista previa. Los usuarios de la campaña son opcionales en el momento de la creación; Los superadministradores pueden asignar varios usuarios existentes o crear varios usuarios nuevos, y los usuarios asignados reciben el enlace del panel de administración por correo electrónico cuando se configura la entrega.
- Se agregó el archivo de campañas de superadministrador para campañas no activas. El desarrollo local archiva a través del asistente de repositorio montado, mientras que la producción envía el flujo de trabajo validado de GitHub Actions `archive-campaign`.
- Visibilidad pública preservada y límites de SEO: las campañas de solo vista previa permanecen ocultas de las rutas de campaña públicas, índices de inicio/comunidad/complementos, `/api/campaigns.json`, incrustaciones, metadatos de tarjetas compartidas, salida de mapas del sitio, intención de robots y captación previa pública hasta su lanzamiento.
- Se conserva la disciplina presupuestaria de KV: las lecturas del panel, la representación preliminar, la exploración de campos, los borradores locales, los informes, los soportes y los análisis siguen siendo de solo lectura; Las acciones explícitas de creación, vista previa de publicación, guardado de usuario, auditoría de archivo y correo electrónico realizan escrituras limitadas.
- Se agregaron salvaguardias livianas de edición multiusuario con verificaciones de revisión base de GitHub para contenido de campaña y publicaciones de vista previa, conflictos de publicación obsoleta, preservación de borradores locales y eventos de auditoría para acciones de creación, publicación de vista previa, archivo y publicación de contenido.
- Mantuvo la nueva interfaz de usuario del panel accesible, localizada, con capacidad de respuesta móvil y SECO al reutilizar etiquetas de administración compartidas/ayuda/botón de información, lista de correo electrónico, patrones modales, de enfoque y de estado.
- Se mejoró la resiliencia del desarrollo local de Podman con reinicios de servicios supervisados, intentos de recuperación de Podman obsoletos, soporte de ayuda de repositorio local para pruebas de creación/archivo y documentación actualizada de Podman.
- Se agregó una publicación de vista previa protegida respaldada por GitHub en `/admin/campaign-preview/publish`, lecturas de carga útil de vista previa no-store en `/admin/campaign-preview/:slug`, shells de vista previa genéricos sin índice en `/campaigns/:slug/preview/` para cada slug de campaña para que los enlaces enviados por correo electrónico no dependan de una reconstrucción posterior a la publicación y listas permitidas de acceso a vista previa de KV de 24 horas en `campaign-preview-reviewers:<slug>`.
- Se agregaron enlaces firmados de vista previa del panel de 24 horas para el administrador de publicación, correos electrónicos de vista previa firmados opcionales del revisor y correos electrónicos de asignaciones de campaña a través del tema de correo electrónico compartido Resend y el catálogo i18n.
- Se renderizaron cargas útiles de vista previa protegidas como vistas previas completas de páginas de campaña de solo lectura con CSS/fuentes de campaña cargados, incrustaciones de medios habilitadas y controles de aporte deshabilitados.
- Representación del diario de vista previa protegida coincidente con las pestañas del diario de campaña público, paneles de fase y tarjetas de entrada con guiones.
- Se agregaron controles del panel de superadministrador para la creación de nuevas campañas solo de vista previa y la publicación de vista previa protegida.
- Se agregó archivado de campañas solo para superadministradores para campañas no activas desde Campañas -> Configuración, respaldado localmente por escrituras de repositorio solo para desarrolladores y en producción por un flujo de trabajo manual de GitHub Actions que mueve `_campaigns/<slug>.md` y los medios propiedad de la campaña a `archive/campaigns/<slug>/` sin eliminar los datos archivados.
- Se agregó filtrado público/de solo vista previa en JSON de campaña, índices de página de inicio/comunidad/complementos, páginas localizadas, mapa del sitio, intención de robots y elegibilidad de captación previa.
- Se agregaron verificaciones de conflictos de revisión base para contenido de campaña y publicaciones de vista previa.
- Mantuve los correos electrónicos de vista previa fuera de la campaña Markdown respaldada por GitHub y de los artefactos generados públicamente; La fuente de la campaña ahora solo incluye el indicador de vista previa y `preview_reviewer_emails: []` vacío de compatibilidad.

## v1.0.4 - 2026-06-11

- Se agregó Configuración de superadministrador -> Seguimiento del uso del plan para cuotas de trabajadores de Cloudflare/KV y Resend, con carga automática, nombres de planes detectados por el proveedor cuando estén disponibles, barras de progreso, umbrales de advertencia y enlaces de planes de proveedor mientras se mantienen los tokens de proveedor en el lado del servidor.
- Se agregó un panel de análisis de ingresos netos de campaña/plataforma después de asignar las tarifas reales o estimadas del procesador de Stripe, al tiempo que se conservan los ingresos brutos de la campaña y las tarjetas de ingresos de la plataforma para la conciliación.
- Se agregó la asignación de tarifas de procesador a nivel de componente entre los ingresos de la campaña, los ingresos de la plataforma, los impuestos y el envío para que las exportaciones de tablas/CSV se concilien con las transacciones de saldo almacenadas de Stripe o las estimaciones de tarifas existentes.
- Variables de entorno de seguimiento de uso documentadas y límite de token de lectura de facturación y análisis GraphQL de Cloudflare de solo lectura para el uso y la detección del plan de trabajadores.
- Se reorganizó el andamiaje local del trabajador `.dev.vars` y la salida `npm run secrets:dev` en grupos basados en propósitos, incluidas las configuraciones y anulaciones del proveedor de uso del plan.

## v1.0.3 - 2026-06-01

- Se agregó manejo de zona horaria de plataforma configurable en todo el estado de la campaña de Jekyll, cuentas regresivas del navegador, automatización del ciclo de vida de los trabajadores, informes de los ejecutores de campañas, configuración del panel y duplicación de la configuración de los trabajadores. El valor predeterminado sigue siendo `America/Denver` por motivos de compatibilidad y los superadministradores pueden elegir entre las zonas horarias admitidas por la IANA.
- Se agregaron recordatorios del próximo lanzamiento de campaña con un formulario de registro público delgado, verificación de Cloudflare Turnstile, deduplicación de campaña/correo electrónico, enlaces de cancelación de suscripción firmados, trabajos de envío de KV limitados y entrega de Resend a través del módulo de correo electrónico compartido existente.
- Se agregó serialización de liquidación de campañas respaldada por Durable Object, claves de idempotencia deterministas Stripe y rechazo de lotes de campañas mixtas para que la liquidación programada/manual no pueda superponerse a los cargos de la misma campaña mientras los carros de campañas múltiples permanecen dentro del alcance de la campaña.
- Se agregaron secretos de automatización de administración con alcance para rutas de liquidación y transmisión. Cuando se configuran, `ADMIN_SETTLEMENT_SECRET` y `ADMIN_BROADCAST_SECRET` rechazan el uso alternativo del `ADMIN_SECRET` más amplio.
- Credenciales de implementación de producción reforzadas al requerir autenticación Cloudflare basada en token, documentar la forma del token API de usuario Cloudflare requerida para implementaciones Wrangler, dividir la purga de caché en `CLOUDFLARE_CACHE_PURGE_TOKEN` y eliminar secretos de repositorio heredados o no utilizados.
- Se fortaleció el flujo de trabajo de implementación para que la optimización de medios del panel abra una solicitud de extracción en lugar de enviar los cambios de medios generados directamente a `main`.
- Valores predeterminados de CORS privados ajustados, redacción de errores Stripe, pruebas de autenticación de pago/liquidación y generación de secretos locales para secretos de administración con alcance.
- Contenido público reforzado y límites de inserción: la desinfección de enlaces de Markdown de campaña ahora maneja esquemas inseguros anidados/codificados, las incrustaciones alojadas utilizan orígenes de destino específicos de postMessage y las páginas de administración tokenizadas optan por un comportamiento sin referencia.
- Se redujo el uso de escritura de KV de los trabajadores de referencia al cambiar el latido del programador a nivel de minutos para que persista cada hora en lugar de cada minuto, preservando la visibilidad del estado del cron y manteniendo el presupuesto de escritura de nivel gratuito disponible para mutaciones reales.
- Se redujo el uso de la lista de referencia Workers KV al agregar marcadores de estado de cola para el envío de recordatorios de lanzamiento y los reintentos de correo electrónico de confirmación del colaborador, de modo que los ticks programados inactivos omitan los escaneos de espacios de nombres y los reintentos esperen hasta que venza el siguiente intento en cola.
- Se agregó una proyección duradera del recuento de ventas del inventario adicional mantenida por las rutas de creación, modificación y cancelación del aporte, evitando escaneos repetidos del espacio de nombres del aporte para lecturas normales del inventario adicional después del primer arranque de proyección.
- Se actualizó el desarrollo local para que `_config.local.yml` pueda ocultar los widgets Turnstile de recordatorio de lanzamiento de la misma manera que el inicio de sesión del administrador local puede ocultar su widget Turnstile.
- Se amplió la imagen y los envoltorios del optimizador de medios de Podman con `optipng` y `gifsicle` para que la compresión de origen PNG/GIF local utilice el mismo flujo de trabajo de medios del repositorio que la generación responsiva de derivados de imágenes y videos.
- Se agregó un pase de rendimiento de PageSpeed móvil para las páginas de la campaña: los videos principales de YouTube ahora se muestran como carteles locales/fachadas de reproducción y cargan el iframe remoto solo después de la intención de reproducción, evitando el costo inicial de JavaScript/CSS de YouTube.
- Se agregaron precargas de imágenes de héroe responsivas y un escalón derivado WebP `640w` para que las páginas de campañas móviles puedan elegir activos de navegador más pequeños entre las variantes `480w` y `960w` existentes.
- Se actualizó el optimizador de medios para omitir los derivados WebP receptivos generados durante la optimización de la fuente, manteniendo actualizados los recursos del navegador generados sin volver a codificarlos de forma recursiva.
- Se corrigió el texto enriquecido del diario creado en el tablero para que los marcadores en negrita/cursiva/subrayado en línea normalicen los espacios de límites iniciales y finales en lugar de mostrar delimitadores de Markdown perdidos en las páginas de campañas públicas.
- Se corrigieron los enlaces hash del diario público, incluidos enlaces a pestañas del diario no predeterminadas, como `#diary-production`, para que la pestaña correspondiente se abra antes de que la página se desplace hasta el ancla.
- Se actualizaron las cargas de imágenes y videos del panel para enviar el flujo de trabajo **Optimizar medios del panel** con `scope=changed` después de que la confirmación de GitHub que preserva el origen sea exitosa; Las cargas de audio permanecen conservadas en origen.
- Se agregó una limpieza en el momento de la publicación para el contenido de la campaña propiedad del panel y los medios del diario que se eliminan del contenido publicado y ya no se hace referencia a ellos en ninguna otra parte de la misma campaña.

## v1.0.2 - 2026-06-01

- Se agregaron correcciones de rendimiento de páginas públicas de la revisión de PageSpeed: las páginas de campañas de video remoto ya no precargan imágenes destacadas ocultas, las imágenes de nivel optan por la decodificación diferida/asíncrona, los logotipos de marca predeterminados reservan sus dimensiones intrínsecas y las páginas públicas evitan las ansiosas preconexiones de Stripe antes de la intención del carrito.
- Se amplió el proceso de optimización de medios del panel para generar variantes de imágenes WebP responsivas para imágenes de origen PNG, JPEG y GIF, de modo que las plantillas de campañas públicas puedan servir activos de navegador más pequeños y al mismo tiempo mantener las cargas originales como fuentes de respaldo de la verdad.
- Se agregó una opción manual `scope=all` al flujo de trabajo **Optimizar medios del panel** para que las campañas existentes se puedan reprocesar a través del mismo canal de medios utilizado para las cargas de nuevos paneles.
- Se actualizaron las plantillas de campaña, nivel, tarjeta, galería y contenido-imagen para usar variantes responsivas generadas cuando existan sin cambiar la estructura de la página visible o las referencias de Markdown de la campaña.

## v1.0.1 - 2026-05-29

- Se agregó la tarifa de transacción de saldo real de Stripe/captura neta para aportes cobradas recientemente y una ruta de reposición de superadministrador para registros de aportes cobradas más antiguas.
- Panel de análisis actualizado para preferir las tarifas reales almacenadas de Stripe cuando estén disponibles, mantener las tarifas estimadas solo cuando sea necesario y etiquetar claramente los valores mixtos/estimados.
- Se agregaron cargas de medios del editor de contenido administrativo para bloques de contenido de campaña y diario, con vistas previas locales inmediatas y carga en el momento de la publicación en los directorios correctos de activos de la campaña.
- Se agregó el canal de optimización de medios del panel: `npm run media:optimize`, `npm run media:optimize:check` y un flujo de trabajo de GitHub Actions que comprime sin pérdidas las imágenes cargadas, genera derivados de video WebM de alta calidad y reescribe referencias literales de video de configuración/campaña después de que existan los derivados.
- Se mantuvieron las cargas del panel para preservar la fuente en el Worker mientras se documentaba el paso de optimización externa para operadores y bifurcaciones.
- Made Supporters y Analytics devuelven vistas vacías de solo lectura para campañas sin índices de aporte en lugar de bloquear paneles de campaña nuevos o vacíos.

## v1.0.0 - 2026-05-26

- Se agregó el panel de administración privado como superficie de operaciones y edición del navegador compatible en `/admin/` y `/es/admin/`.
- Se agregó autenticación de administrador de enlace mágico con alcance de rol para superadministradores y usuarios de campañas, con sesiones respaldadas por cookies, comprobaciones de origen/CSRF y API de administración seguras para el navegador que no exponen `ADMIN_SECRET`.
- Se agregó soporte de protección de desafío de inicio de sesión de administrador para implementaciones compatibles con Cloudflare Turnstile mientras se mantienen explícitas las omisiones locales/de prueba.
- Se agregaron pestañas del panel para Configuración, Complementos, Campañas, Análisis, Informes, Patrocinadores, Marketing, Usuarios, Secretos y credenciales, y Diagnóstico en tiempo de ejecución.
- Se reemplazó el modelo de edición de Pages CMS con el flujo de trabajo basado en el panel, manteniendo `_config.yml` y la campaña Markdown como la fuente de verdad revisable frente a la bifurcación.
- Se agregó edición de bloques WYSIWYG para contenido de campaña y entradas de diario, incluida configuración de medios, edición de enlaces, formato en línea estilo Markdown, vistas previas móviles, borradores locales y seguimiento del estado de publicación.
- Se agregó edición del panel para configuraciones de campaña, niveles, elementos de soporte, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario, decisiones, complementos de plataforma y configuraciones de plataforma.
- Se agregó manejo de carga en el panel para medios de campaña, activos de marca, imágenes complementarias y videos destacados utilizando directorios de activos basados en convenciones y nombres de archivos estilo slug.
- Se agregó un panel de administración de usuarios respaldado por Worker KV en `admin-users:v1`, separado de los flujos de publicación respaldados por GitHub.
- Se agregaron correos electrónicos de notificación para los usuarios del panel recién creados cuando se configura Resend; las ediciones del usuario no reenvían invitaciones.
- Se agregaron herramientas de marketing en el panel para la creación de URL de referencia/UTM, códigos de referencia guardados, interfaz de usuario de creación de inserción reutilizable y fragmentos de lanzamiento copiables.
- Se corrigieron las vistas previas de inserción de marketing para campañas con medios destacados de YouTube o Vimeo para que las barras de progreso, los hitos y las etiquetas de objetivos ampliados permanezcan contenidos.
- Se agregaron vistas de análisis, informes y patrocinadores del panel de control con alcance de rol con tablas ordenables/filtrables, visualización del centavo exacto de dólar y descargas CSV; Las vistas previas/descargas de informes no envían correos electrónicos ni escriben marcadores de envío.
- Se preservó el objetivo de nivel gratuito KV de Cloudflare Workers manteniendo las lecturas normales del panel, las vistas previas, los filtros, los análisis y los borradores locales en cero escrituras KV.
- Configuración del remitente de correo electrónico de aporte alineada con el dominio del remitente autorizado Resend y configuración del dominio del remitente documentada para bifurcaciones.
- Se hicieron explícitos los permisos de implementación de GitHub Pages para el flujo de trabajo de implementación de producción.

## v0.9.5 - 2026-05-03

- Se alineó el desarrollo de Worker local con GitHub Actions moviendo la imagen de Podman Worker al Nodo 24.
- Se actualizó el Worker `compatibility_date` a `2026-05-03` para que Wrangler 4/Miniflare comience limpiamente en el Nodo 24.
- Se actualizaron los contenedores de pruebas de host y Podman para preferir el Nodo 24, con el Nodo 22 como el respaldo mínimo de Wrangler 4.
- Se cambió el arranque de dependencia de Podman Worker a `npm ci` para que los inicios del contenedor local no reescriban `worker/package-lock.json`.
- Documentación de lanzamiento para creadores ampliada con complementos, inserciones alojadas, expectativas de respaldo de impuestos/envío, decisiones de envío gratuito, destinatarios de informes y transferencia de cumplimiento.
- Se agregó una ruta de lista de verificación de creadores en español para la incorporación de creadores y bifurcaciones.

## v0.9.4 - 2026-05-02

- Hito anterior para los informes de los ejecutores de campaña, el refuerzo de la implementación, el trabajo de la lista de verificación de los creadores y las actualizaciones de compatibilidad de la implementación de los trabajadores.
