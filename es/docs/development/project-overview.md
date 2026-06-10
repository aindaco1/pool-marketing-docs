---
title: Resumen del proyecto
parent: Desarrollo
nav_order: 2
render_with_liquid: false
lang: es
---

# Descripción general del proyecto

**Objetivo:**
Habilite el crowdfunding creativo con una verdadera lógica de *todo o nada* utilizando alojamiento estático.
Los creadores definen campañas en Markdown; los patrocinadores se comprometen a través del carrito propio de The Pool y un paso de pago en el modo de configuración de Stripe en el sitio; Las tarjetas se cargan automáticamente sólo si la campaña está financiada. Opcionalmente, los patrocinadores pueden agregar una propina de plataforma del 0% al 15% (5% predeterminado) que se incluye en el cargo final pero se excluye del progreso de la campaña.

## Última actualización

10 de junio de 2026

**Marca:**
- Nombre de la plataforma: **The Pool**
- Nombre de la empresa: configúrelo según el nombre de su organización o estudio.
- Tema predeterminado: el estilo editorial más tranquilo de Dust Wave
- Personalización de la bifurcación: `_config.yml` ahora impulsa una superficie de token/marca seleccionada que llega a páginas públicas, elementos de Stripe en el sitio y correos electrónicos de seguidores.

---

## Resumen del sistema

|capa|Plataforma|Rol|
|-------|-----------|------|
|**Frontal**|Páginas de GitHub (Jekyll + Sass + tiempo de ejecución del carrito)|Páginas de campaña, carrito, UX|
|**Pagos**|Stripe (Sesiones de pago en modo configuración + cargos fuera de sesión)|Campos de pago seguros, métodos de pago guardados y luego tarjetas de cargo|
|**API/pegamento**|Trabajador de Cloudflare (`worker.example.com`)|Maneja el arranque de pago, webhooks, totales con reconocimiento de propinas, recuperación y datos de informes.|
|**IU de administrador**|Panel privado (`/admin/`, `/es/admin/`)|Configuraciones, campañas, complementos, análisis, informes, seguidores, herramientas de marketing y usuarios basados en roles|
|**Automatización**|Programador de trabajadores + Acción de GitHub|Auto-liquidación (por lotes) + transiciones de estado|
|**Almacenamiento**|Rebaja / YAML|Definiciones y estado de la campaña|
|**Estilo**|Sass + vars de tema generados|Sistema de diseño compartido para páginas públicas, pago, gestión de promesas y superficies de pago/correo electrónico de marca.|

Todo el código está versionado y auditable. La edición de la campaña ahora fluye a través del panel de administración privado o ediciones directas del repositorio, y los cambios publicables aún se confirman en el repositorio a través de la ruta de GitHub controlada por el trabajador.
Las cargas de medios del panel conservan el origen en el límite del trabajador: las cargas de imágenes/videos solicitan el flujo de trabajo de optimización del repositorio después de la confirmación, y las publicaciones de contenido/diario eliminan los medios propiedad del panel de la misma campaña a los que ya no se hace referencia.

## Planificar notas de eficiencia para bifurcaciones

La arquitectura actual está optimizada deliberadamente para que las implementaciones de Cloudflare gasten su presupuesto en mutaciones de promesas en lugar de navegación informal:

- Las páginas de campaña y la página de administración prefieren una lectura combinada de `/live/:slug` en lugar de estadísticas y solicitudes de inventario separadas.
- el navegador almacena en caché las estadísticas en vivo y el inventario en `localStorage` para los TTL configurados, y las pestañas ocultas dejan de actualizarse hasta que vuelven a ser visibles.
- Los informes del panel, los partidarios, los análisis, los asistentes de liquidación, las búsquedas de audiencia de transmisión de administradores y las estadísticas/conciliación de inventario prefieren el índice `campaign-pledges:{slug}` y evitan costosas exploraciones de espacios de nombres en rutas de lectura normales.
- Las cargas/vistas previas de contenido del panel, vistas previas/descargas de informes, filtros de soporte, vistas de análisis y listas de referencias de marketing están diseñadas para agregar cero escrituras de KV.
- Las rutas de escritura de nivel limitado ahora solicitan al coordinador de cada campaña la disponibilidad según la reserva, mientras que el inventario público permanece en KV como proyección.
- El inventario de complementos de la plataforma utiliza una proyección de recuento de ventas después del arranque en lugar de reconstruirse a partir de escaneos del espacio de nombres de compromiso en lecturas normales.
- iniciar el envío de recordatorios y la confirmación del partidario reintentar el sondeo utiliza marcadores de estado de cola, por lo que los ticks programados inactivos omiten los escaneos de la lista KV y recurren a las verificaciones de compatibilidad cada hora
- La limitación de velocidad aún falla al cerrarse, pero las solicitudes bloqueadas repetidas dentro de la misma ventana ya no reescriben el mismo contador KV en cada visita.

Eso significa que el límite real para la mayoría de las bifurcaciones suele ser **KV escribe a partir de una actividad de compromiso exitosa**, no el tráfico de lectura pública ni el sondeo de listas inactivas. `RATELIMIT` es ahora un requisito estricto para las implementaciones admitidas, pero eso por sí solo no hace que el plan gratuito no sea viable para la forma de financiación colectiva a pequeña escala prevista para el proyecto.

## Forma de desarrollo local

La ruta local de baja fricción recomendada ahora usa Podman:

- `./scripts/dev.sh --podman` arranca a Jekyll y al Trabajador en contenedores desarraigados
- `npm run podman:doctor` comprueba primero la preparación del host
- `./scripts/test-e2e.sh --podman` ahora ejecuta el paquete de navegador de forma totalmente automatizada

La ruta Ruby/Wrangler basada en host todavía existe, pero Podman es la forma más fácil de obtener un entorno local similar a la producción sin instalar manualmente todas las dependencias.

Para los trabajadores estándar/pagados desplegados, el repositorio ahora también declara `limits.cpu_ms = 100` en `worker/wrangler.toml` como un respaldo de denegación de billetera. Ese límite es intencionalmente conservador, pero solo se aplica en la red implementada de Cloudflare, no durante el desarrollo local.

### Escenarios aproximados de planificación

Estos escenarios son intencionalmente aproximados. Asumen los TTL predeterminados del navegador de 5 minutos, una lectura en vivo combinada en cargas de campaña en frío y los límites del plan gratuito publicados por Cloudflare a partir del 7 de abril de 2026.

|Escenario|Cómo se siente operativamente|Planificación para llevar|
|----------|----------------------------------|-------------------|
|Primer lanzamiento|Una o dos campañas activas, unos cuantos miles de visitas a la página de la campaña durante varios días y un puñado de promesas completadas por día.|Lo gratuito debería seguir siendo un punto de partida razonable.|
|Fuerte tracción en la primera semana|Varios miles de lecturas dinámicas de Worker por día y un par de docenas de mutaciones de promesas en campañas en vivo.|A menudo, todavía es viable de forma gratuita, pero aquí es donde el pago comienza a reducir la ansiedad operativa.|
|Plataforma comunitaria establecida|Mutaciones frecuentes de promesas todos los días en múltiples campañas activas, además de flujos de informes/reparaciones administrativas más regulares|El pago se convierte en la opción más cómoda a largo plazo; siga monitoreando los costos de las rutas de mutación y abuso.|

Para conocer los límites actuales de Cloudflare, consulte:

- [Precios para trabajadores](https://developers.cloudflare.com/workers/platform/pricing/)
- [Límites KV de los trabajadores](https://developers.cloudflare.com/kv/platform/limits/)

---

## Flujo de financiación

1. **El visitante se compromete** a través del carrito propio → El trabajador crea una sesión de pago de Stripe en modo de configuración y el segundo sidecar de pago existente monta la interfaz de usuario de pago segura de Stripe en el sitio. Un pago puede incluir artículos de varias campañas. El carrito y el proceso de pago muestran el subtotal, el envío, el impuesto sobre las ventas y la propina de plataforma opcional de un modelo de precios compartido.
2. **Stripe** guarda una tarjeta a través de ese paso de pago en el sitio y devuelve las identificaciones al Trabajador.
3. El trabajador almacena los datos de las promesas en **Cloudflare KV** (niveles, artículos de soporte, montos personalizados, dirección de envío, porcentaje/cantidad de propina, ID de Stripe), ampliando un pago combinado en una promesa con alcance de campaña por campaña. El cliente no considera el pago como exitoso hasta que se confirme la persistencia.
4. **El programador de trabajadores** ejecuta el trabajo del ciclo de vida diario después de la medianoche en la zona horaria de la plataforma configurada:
   - Registra un latido cada hora (`cron:lastRun` en KV) para monitorear sin convertir el programador de nivel de minutos en una rotación constante de escritura en KV.
   - Activa la reconstrucción del sitio cuando pasa `goal_deadline` (`live` → `post`).
   - Si se financia, envía la liquidación por lotes a través del autoencadenamiento `/admin/settle-dispatch`.
   - Cada lote (6 promesas) se ejecuta en una invocación de Trabajador separada para permanecer dentro de los límites de las subrequests.
   - Los cargos se agregan por correo electrónico dentro de cada campaña: un cargo por seguidor por campaña.
   - Actualiza el estado del compromiso a `charged` o `payment_failed` en KV.
   - Activa la reconstrucción de páginas de GitHub y la purga de caché de Cloudflare en transiciones de estado.
5. **Los informes y las exportaciones de cumplimiento** utilizan los mismos creadores de informes de campaña:
   - El panel de administración muestra una vista previa de los informes de compromiso y cumplimiento de las campañas a las que el administrador puede acceder y descarga el informe visible como CSV.
   - Las vistas previas/descargas de informes del panel no envían correos electrónicos ni escriben marcadores de envío.
   - La automatización de cumplimiento programada o basada en secuencias de comandos aún puede usar las rutas del informe de trabajo cuando esté configurada.

**Reglas de precios:**
- El progreso de la campaña utiliza únicamente el subtotal.
- Las propinas de la plataforma son opcionales, por defecto son del 5% y tienen un límite del 15%.
- El impuesto sobre las ventas utiliza la tasa impositiva de implementación configurada.
- El envío físico lo calcula el trabajador a partir de las reglas de envío de implementación/campaña, incluidas las cotizaciones en vivo de USPS cuando están habilitadas, además del comportamiento de envío gratuito o alternativo configurado.
- Los totales finales almacenados/cargados son `subtotal + shipping + tax + tip`.

**Notas de endurecimiento de caja:**
- Se entregan respuestas confidenciales de arranque/finalización de pago `private, no-store`.
- Los POST del navegador para el inicio/completación del pago y el inicio del método de pago se verifican en origen con `SITE_BASE`.
- El almacenamiento de larga duración del navegador mantiene la estructura del carrito y las entradas de precios; Los borradores de contacto/dirección permanecen dentro del ámbito de la sesión.
- Después de una persistencia exitosa, el cliente invalida inmediatamente las estadísticas/inventario en vivo almacenados en caché y deja un marcador de actualización de corta duración para que las páginas de campaña restauradas obtengan totales nuevos.

---

## Ciclo de vida de la campaña

|Estado|Significado|Experiencia de usuario visible|
|--------|----------|------------|
|`upcoming`|Programado/aún no disponible|Botones deshabilitados, mensaje "próximamente"|
|`live`|Aceptar promesas|Carrito activo, barra de progreso actualizándose|
|`post`|Terminado|Muestra resultados financiados o no financiados|
|`charged`|(bandera)|Verdadero después de una facturación exitosa|

---

## Metas extendidas

- Declarado directamente en el frontal de cada campaña.
- Marcado automáticamente *logrado* cuando `pledged_amount >= threshold`.
- Atributo opcional `requires_threshold` en niveles para revelar nuevos beneficios una vez desbloqueados.

---

## Mapa de código

```
.
├── _campaigns/           # Markdown campaign data
├── _layouts/             # Page templates (campaign, community, manage, etc.)
├── _includes/            # Reusable components
│   └── blocks/           # Content block renderers (text, image, video, gallery, etc.)
├── _plugins/             # Jekyll plugins (money filter)
├── assets/
│   ├── main.scss         # Sass entry point
│   ├── partials/         # 14 active modular Sass partials (tokens, primitives, page surfaces)
│   └── js/               # Cart, campaign, and runtime scripts
├── worker/               # Cloudflare Worker (worker.example.com)
│   └── src/              # Stripe setup, webhooks, email, votes, tokens, tip-aware totals
├── admin.md              # Private admin dashboard route
├── scripts/              # Automation & reporting scripts
├── tests/e2e/            # Playwright end-to-end tests
└── .github/workflows/    # Deploy action
```

---

## Lista de verificación de implementación

1. ✅ Dominio: `site.example.com` (CNAME para páginas de GitHub).
2. ✅ Tiempo de ejecución del carrito propio habilitado en la configuración del sitio y en la compilación local.
3. ✅ Cloudflare Worker implementado (`worker.example.com`) con secretos de firma de Stripe + Worker.
4. ✅ Webhook de banda configurado → Trabajador `/webhooks/stripe`.
5. ✅ Conjunto de secretos de repositorio: `STRIPE_SECRET_KEY`, `CHECKOUT_INTENT_SECRET` y secretos de administrador/correo electrónico.
6. ✅ Programador de trabajadores a nivel de minutos habilitado con puertas diarias de zona horaria de plataforma: verifique a través de `GET /admin/cron/status`.
7. ✅ Purga de caché de Cloudflare configurada (preferido: token de API/ID de cuenta; correo electrónico heredado/autenticación de clave aún funciona si se configura explícitamente).
8. ✅ La campaña de prueba se ejecuta de un extremo a otro en el modo de prueba de Stripe.
9. ✅ El contenido de formato largo desinfecta los esquemas de enlaces de Markdown y solo muestra incrustaciones estructuradas de orígenes exactos aprobados.
10. ✅ Las lecturas de enlaces mágicos de promesas faltantes fallan al cerrarse con `404`.
11. ✅ El panel de administración privado emite `noindex`, utiliza autenticación de enlace mágico y mantiene las mutaciones KV de usuario/referencia separadas de los flujos de publicación respaldados por GitHub.

---

## Filosofía

- **Estático primero:** GitHub Pages proporciona transparencia y control de versiones para cada estado de la campaña.
- **Backend mínimo:** Cloudflare Worker reemplaza un servidor de aplicaciones completo.
- **Automatización sobre operaciones:** GitHub Actions realiza todos los eventos basados en tiempo.
- **Transferencia abierta:** El estado de la campaña y la plataforma sigue siendo revisable como Markdown/YAML, incluso cuando las ediciones de rutina se realizan a través del panel.
- **Coherencia del diseño:** Utiliza el mismo lenguaje visual que Dust-wave-shop para lograr coherencia de marca.

## Aprendizajes críticos

1. **Los inclusiones de Jekyll requieren el prefijo `include.`**: al pasar parámetros a las inclusiones, acceda siempre a ellos con `{{ include.param }}`, no con `{{ param }}`.
2. **Cadenas YAML**: cadenas entre comillas con caracteres especiales (dos puntos, comillas) para evitar errores de análisis.
3. **División por cero**: siempre verifique los denominadores antes de dividir en las plantillas de Liquid.
4. **Compilación Sass**: Jekyll compila archivos `.scss` automáticamente cuando `sass:` está configurado en `_config.yml`.
5. **Prerenderizado de cuenta regresiva**: Calcule los valores iniciales en el momento de la compilación (Jekyll) o el tiempo de renderizado (JS) para evitar el flash "00 00 00 00".
6. **Flujo de datos de elementos de soporte**: Cart.js extrae elementos de soporte → El trabajador almacena en KV temporal → Webhook se fusiona en el compromiso final.
7. **Manejo de zona horaria compatible con el horario de verano**: toda la lógica de fecha límite (cuenta regresiva frontal, liquidación de trabajadores, transiciones de estado de campaña) utiliza `platform.timezone` / `PLATFORM_TIMEZONE` con `Intl.DateTimeFormat`; el valor predeterminado es `America/Denver`.
8. **La seguridad del contenido debe mantenerse en el momento del procesamiento**: las auditorías de creación ayudan, pero la protección real proviene de la desinfección del enlace Markdown en tiempo de ejecución y la validación de inserción del origen exacto.
9. **Los enlaces mágicos deben requerir filas de compromiso reales**: la validez del token por sí sola no es suficiente; Los registros de promesas faltantes no deberían cerrarse.
10. **Chrome localizado debe permanecer compartido**: los controles de la página de la campaña y la copia de estado que pertenecen a la plataforma, no al creador, deben fluir a través del catálogo de configuración regional compartido para que las plantillas públicas, la interfaz de usuario en tiempo de ejecución y los correos electrónicos de los seguidores no se separen.
11. **El trabajo de rendimiento debe permanecer estático primero**: prefiera la salida estable de Jekyll, la minificación de activos generados, la carga en tiempo de ejecución diferida y la captación previa conservadora solo pública antes de agregar complejidad al cliente.
12. **El trabajo del ciclo de vida de los medios debe permanecer respaldado por el repositorio**: las cargas del panel confirman primero los archivos fuente, la automatización del repositorio posee la optimización nativa de imágenes/videos y la limpieza en el momento de la publicación solo elimina los medios de la misma campaña que desaparecieron del contenido de autor y no se mencionan en ningún otro lugar.

---
