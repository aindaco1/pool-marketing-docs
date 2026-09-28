---
title: Panel de administración
parent: Operaciones
nav_order: 1
render_with_liquid: false
lang: es
---

# Panel de administración

## Última actualización

27 de septiembre de 2026

Este documento es la referencia del operador y la fuente de verdad para la edición, informes, análisis, enlaces de marketing, complementos y administración de usuarios de campañas basadas en paneles privados de The Pool.

## Audiencia

Utilice esta guía si es:

- un superadministrador que gestiona la configuración de la plataforma, los usuarios administradores, los complementos de la plataforma, los informes, los análisis o todas las campañas
- un administrador de campaña que gestiona la configuración asignada de la campaña, el contenido de la campaña, las recompensas, las entradas del diario, las decisiones y los informes específicos de la campaña.
- un mantenedor de bifurcación que decide qué configuraciones pertenecen a `_config.yml`, secretos de trabajo, KV o campaña Markdown

## Acceso

El panel está disponible en:

- `/admin/`
- `/es/admin/`

Los administradores inician sesión con un enlace mágico de correo electrónico. Workers implementado envía por correo electrónico el enlace a través de Resend y no lo devuelve en la respuesta del navegador. El desarrollo local puede exponer el enlace solo cuando el sitio/base Worker es localhost o cuando `ADMIN_EXPOSE_LOGIN_LINK=true` está configurado explícitamente; cuando se expone, el estado de inicio de sesión presenta un enlace **Abrir administrador** localizado en lugar de imprimir la URL tokenizada como texto. El desarrollo local otorga acceso de superadministrador de arranque a través de `ADMIN_BOOTSTRAP_EMAILS` en `worker/.dev.vars` ignorado; Los usuarios de semilla/recuperación de producción provienen de `_config.yml` `admin.users` o `ADMIN_USERS_JSON` implementados.

El inicio de sesión de administrador puede requerir Cloudflare Turnstile. Configure la clave del widget público en `_config.yml` como `admin.turnstile_site_key` y almacene el `TURNSTILE_SECRET_KEY` coincidente como un secreto Worker. Cuando se configura el secreto, `POST /admin/auth/start` verifica el token de desafío antes de las escrituras con límite de velocidad, las escrituras sin inicio de sesión o la entrega de correo electrónico con enlace mágico. `ADMIN_TURNSTILE_BYPASS=true` está disponible solo para automatización local/de prueba y no debe habilitarse en Workers implementado.

Los usuarios administradores tienen dos roles:

- **Superadministrador**: puede administrar la configuración de la plataforma, los complementos de la plataforma, todas las campañas, análisis, informes, patrocinadores, herramientas de marketing y usuarios administradores.
- **Usuario de campaña**: puede gestionar únicamente las campañas asignadas a ese usuario. Los usuarios de la campaña no ven las pestañas Configuración o Complementos de nivel superior.

Las ediciones del usuario administrador realizadas en **Configuración -> Usuarios** se guardan directamente en Worker KV en `admin-users:v1`. No publican en GitHub y no activan la implementación de un sitio. `_config.yml` y `ADMIN_USERS_JSON` siguen siendo fuentes de semilla/recuperación.

Las API del operador superadministrador también proporcionan revisión de sesión y auditoría:

- `GET /admin/sessions` enumera las sesiones activas y recientes con clases de navegador/SO/dispositivo y una huella digital de red con clave; nunca almacena una dirección IP completa, un agente de usuario completo o una ubicación precisa.
- `POST /admin/sessions/revoke` requiere protección CSRF del mismo origen y revoca una ID de sesión exacta mientras registra un evento de auditoría.
- `GET /admin/audit` busca por acción, correo electrónico de administrador exacto, campaña, fecha o consulta de texto libre delimitada.
- `GET /admin/audit.csv` exporta el mismo conjunto de eventos filtrados y antepone los valores iniciales de las fórmulas de la hoja de cálculo.

Turnstile JavaScript se aplaza hasta que la solicitud inicial `/admin/session` demuestre que se necesita el panel de inicio de sesión. Las visitas al panel autenticadas existentes no pagan por el tiempo de ejecución del desafío.

## Desarrollo Local

Utilice la pila Podman para que el sitio estático y el trabajador se ejecuten juntos:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Luego abre:

```text
http://127.0.0.1:4000/admin/
```

La pila de desarrollo deriva `CORS_ALLOWED_ORIGIN` del origen del sitio local y utiliza los valores predeterminados de campaña/administrador de prueba documentados en `README.md` y `worker/README.md`.

## Escribir modelo

El panel separa intencionalmente la navegación de solo lectura, los borradores locales, las escrituras KV y la publicación respaldada por GitHub.

|acción|Almacenamiento/efecto secundario|
|--------|------------------------|
|Resumen del panel, análisis, informes, patrocinadores, filtrado de tablas y vista previa del contenido|Sólo lectura; agrega cero escrituras KV|
|Restauración de pestaña/subpestaña del panel|Solo estado de la interfaz de usuario local del navegador; recuerda la última pestaña de nivel superior permitida, la sección Configuración, la campaña Campañas seleccionada y la subpestaña Campañas sin escrituras de Worker, KV o GitHub|
|Editor de contenido **Guardar borrador**|Solo borrador local del navegador|
|Campaña **Guardar**|Worker valida el proyecto completo seleccionado y escribe `_campaign_drafts/<slug>.md`; Los datos de la campaña pública permanecen sin cambios.|
|Campaña **Publicar**|Guarda las ediciones actuales, luego promociona los campos de creación guardados a `_campaigns/<slug>.md`, hace pública la campaña y activa la ruta normal de reconstrucción/implementación.|
|Publicación de vista previa protegida|El trabajador valida el alcance de la campaña y la revisión base, escribe solo indicadores de vista previa en Markdown de la campaña respaldada por GitHub, almacena el administrador de publicación más los correos electrónicos del revisor opcional en `PLEDGES` KV en `campaign-preview-reviewers:<slug>` con un TTL de 24 horas, devuelve un enlace firmado visible en el panel para el editor, envía enlaces firmados a revisores opcionales y registra un evento de auditoría|
|Creación de campaña de superadministrador|El trabajador crea un archivo `_campaigns/<slug>.md` de solo vista previa localmente en desarrollo o a través de GitHub en producción, opcionalmente guarda usuarios de campaña asignados/nuevos en `admin-users:v1`, envía correos electrónicos a los usuarios de campaña asignados cuando están presentes, activa la reconstrucción cuando está respaldado por GitHub y registra un evento de auditoría.|
|Archivo de campaña de superadministrador|El trabajador valida la función de superadministrador, CSRF, la existencia de la campaña y el estado no activo, luego archiva localmente en desarrollo o envía `.github/workflows/archive-campaign.yml` en producción; la medida de archivo mantiene la fuente de la campaña y los medios propiedad de la campaña bajo `archive/campaigns/<slug>/`|
|Publicación de configuración de plataforma y complementos de plataforma|El trabajador valida la entrada, escribe en la configuración/activos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y muestra el resultado como un mensaje de la plataforma del panel|
|Cargas de imágenes/vídeo/audio|Worker valida los medios, confirma la ruta del activo a través de GitHub y actualiza el campo relevante localmente hasta que se guarde el proyecto o se publique en la plataforma.|
|Guardar/editar/eliminar referencias de marketing|Mutación KV en el ámbito de la campaña para códigos de referencia guardados|
|Configuración -> Guardar usuarios|Escritura de KV único a `admin-users:v1`|
|Configuración -> Uso del plan|Llamadas API de proveedor Cloudflare/Resend de solo lectura; escrituras de cero KV u operaciones de lista|
|Configuración -> Temporización de diagnóstico en tiempo de ejecución|Resúmenes de observabilidad acotados de solo lectura; cero nuevos almacenes de telemetría y ninguna carga útil de solicitud/cliente|
|Configuración -> Sesiones de administrador|Revisión de sesión activa/reciente de solo lectura; la revocación elimina una sesión exacta y registra un evento de auditoría limitado|
|Configuración -> Registro de auditoría|Búsqueda KV filtrada de solo lectura; La exportación CSV utiliza los mismos filtros y permanece privada/sin almacenamiento|
|Secretos y credenciales|Estado de solo lectura solamente; Los valores secretos nunca se muestran, editan, serializan ni publican.|

Las lecturas normales del tablero deben permanecer dentro del presupuesto de escritura KV descrito en `worker/README.md` y cubierto por pruebas.

Las acciones de publicación respaldadas por GitHub requieren que el Worker implementado tenga configurados `GITHUB_TOKEN` más las variables de metadatos del repositorio. La carga, el guardado, la vista previa protegida y la publicación de campañas requieren la misma configuración de GitHub en producción; la pila de desarrollo local utiliza su asistente de repositorio configurado. Las copias de seguridad del navegador no dependen de GitHub. Guardar se desactiva cuando el editor coincide con la copia de trabajo guardada; La publicación permanece habilitada mientras el proyecto tenga cambios no publicados o nunca haya sido publicado.

## Pestañas de nivel superior

El orden del panel de nivel superior es:

1. **Configuración**: configuración de plataforma, marca/SEO, pago, precios, impuestos, envío, informes de ejecución, diseño, usuarios, sesiones de administración, historial de auditoría, uso del plan, rendimiento, depuración, estado de credenciales y diagnóstico de tiempo de ejecución.
2. **Complementos**: disponibilidad de complementos de la plataforma y detalles del producto, visibles solo para superadministradores.
3. **Campañas**: configuración de campaña basada en roles, contenido de la página, recompensas, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario, decisiones y envíos masivos de correos electrónicos a los patrocinadores.
4. **Análisis**: análisis de cartera y campañas derivadas de aportes.
5. **Informes**: vista previa/descarga CSV para informes de aporte y cumplimiento.
6. **Colaboradores**: navegación, filtrado, clasificación y exportación CSV de los colaboradores según el rol.
7. **Marketing**: creador de URL de referencia, códigos de referencia guardados, códigos QR de campaña descargables y controles del creador de incrustaciones.

Al recargar, el panel restaura la última pestaña de nivel superior permitida desde el estado local del navegador. También restaura la última sección de la barra lateral de Configuración y la última campaña/subpestaña Campañas seleccionada cuando esas superficies todavía están disponibles para el administrador que ha iniciado sesión. Las comprobaciones de roles aún ganan: los usuarios de la campaña nunca regresan a las pestañas Configuración o Complementos exclusivas para superadministradores, y las campañas o subpestañas faltantes recurren a la primera opción disponible.

## Ajustes

Las configuraciones están agrupadas en una barra lateral izquierda. Los superadministradores pueden editar secciones de configuración publicables y guardar la administración de usuarios solo en tiempo de ejecución por separado.

La barra lateral utiliza el orden compartido entre proyectos donde los productos se superponen. The Pool integra los campos separados de **URL canónicas** en **Plataforma** y utiliza **Informes de ejecución de campaña** en la costura de marketing global. El esquema Worker mantiene **Complementos de plataforma** en la línea de preparación, mientras que el navegador lo dirige a la pestaña **Complementos** de nivel superior de The Pool en lugar de duplicarlo en la barra lateral de Configuración. La automatización del navegador cubre el orden visible y la prueba del contrato de configuración cubre el orden completo de Worker:

1. Plataforma
2. Marca y SEO
3. Verificar
4. Precios
5. Impuesto
6. Envíos
7. Informes del corredor de campaña
8. Diseño
9. Usuarios
10. Sesiones de administración
11. Registro de auditoría
12. Uso del plan
13. Rendimiento avanzado
14. Depurar
15. Secretos y credenciales
16. Diagnóstico en tiempo de ejecución

### Plataforma

Los campos de identidad de la plataforma incluyen título del sitio, nombre de la plataforma, empresa, autor, nombre del creador predeterminado, correo electrónico de soporte, descripción del sitio, URL canónicas del sitio/trabajador, nombres de los remitentes de correo electrónico, modo de aplicación y zona horaria predeterminada de la plataforma. Los campos de URL canónicos se encuentran debajo de Descripción del sitio en la sección Plataforma, uno por columna en ventanas gráficas amplias.

Los campos de remitente de aporte y actualización deben utilizar dominios autorizados para la clave API Resend configurada. Para esta implementación, las confirmaciones de aporte utilizan `The Pool <pledges@site.example.com>` para que el dominio del remitente coincida con el dominio autorizado `site.example.com` Resend. Consulte [EMAIL.md](/es/docs/operations/email-system/) para conocer la configuración completa del remitente y la entrega.

El campo de zona horaria predeterminado es un menú de selección respaldado por valores de zona horaria admitidos por IANA. Controla los límites de inicio/fecha límite de la campaña, las cuentas regresivas, los informes programados de los ejecutores de la campaña, la automatización del ciclo de vida y las comprobaciones de liquidación. El valor predeterminado sigue siendo `America/Denver` hasta que un superadministrador lo cambia.

### Marca y SEO

Los campos de marca y búsqueda incluyen logotipo, logotipo de pie de página, favicon, imagen social predeterminada, identificador X, texto alternativo de imagen social predeterminada, enlaces iguales, país de política de devolución del comerciante y si el centro de la comunidad pública es indexable.

The Pool publica una política de no devoluciones tanto en los Términos públicos como en los datos estructurados de Shopping. El país se puede editar desde Brand & SEO y sigue siendo canónico en `_config.yml`; el tipo de póliza es de solo lectura como **Devoluciones no permitidas**. No exponga un control de política de devolución finito o ilimitado hasta que los términos públicos, los campos JSON-LD, la validación y las operaciones de cumplimiento admitan ese modelo en conjunto.

Utilice una URL igual por línea. Utilice URL de perfil público canónico, por ejemplo:

```text
https://www.instagram.com/example
https://www.imdb.com/name/nm0000000/
```

El panel envía el idioma preferido actual al cargar la configuración. La normalización de filas del lado del navegador posee la mayor parte de la localización de etiquetas de administración de The Pool, mientras que la solicitud mantiene el esquema de configuración de Worker compatible con las etiquetas de campo y el texto de opción localizados en el servidor.

La pila local puede anular `SITE_BASE` y `WORKER_BASE` de `_config.local.yml`, pero `scripts/sync-worker-config.rb` mantiene `CANONICAL_SITE_BASE` y `CANONICAL_WORKER_BASE` fijados a los valores de producción de `_config.yml`. Eso permite que el panel local muestre los objetivos de publicación de producción sin interrumpir las solicitudes de localhost.

### Verificar

El proceso de pago expone la clave publicable Stripe utilizada por la interfaz de usuario de pago del navegador. Esto no es un secreto, pero debe coincidir con el modo Stripe actual. Las claves secretas y los secretos de firma de webhooks permanecen en secretos Worker o en archivos env locales ignorados. Consulte [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/) para conocer las operaciones de configuración y liquidación de Stripe.

### Precios, impuestos y envío

Los precios cubren los valores de propinas de plataforma no secretas y tarifas fijas predeterminadas. Las secciones de impuestos y envío eligen proveedores y configuraciones de tiempo de ejecución no secretas. Los campos específicos del proveedor son condicionales; por ejemplo, los campos ZIP.TAX aparecen solo cuando se selecciona ZIP.TAX y los campos USPS aparecen solo cuando USPS está habilitado.

No almacene claves API ni secretos de proveedores en Configuración. Utilice secretos de trabajador o `.dev.vars` local ignorado.

### Informes para responsables de campaña

La configuración del informe del ejecutor de campaña controla el sistema de informes programados: estado habilitado, hora de envío de la zona horaria de la plataforma, prefijo del asunto, alternancia de informes de aporte/cumplimiento, inclusión de resumen y comportamiento de archivos adjuntos CSV. Los superadministradores configuran la zona horaria predeterminada de la plataforma en la sección Configuración de la plataforma.

La pestaña Informes sigue siendo la interfaz de usuario preferida del navegador para generar y descargar archivos CSV bajo demanda.

### Rendimiento avanzado

La configuración de rendimiento avanzada expone los controles públicos seguros de captación previa de intenciones:

- habilitar o deshabilitar la captura previa de documentos públicos
- ajuste el retardo de desplazamiento/enfoque antes de que comience la captación previa
- limitar el número de documentos precargados por vista de página

Los valores predeterminados son intencionalmente conservadores y se aplican solo a enlaces de documentos públicos del mismo origen. El tiempo de ejecución excluye los enlaces de administración, pago, gestión de aporte, comunidad de patrocinadores, tokenizados, externos y de consultas confidenciales. La publicación de estas configuraciones actualiza `_config.yml`, refleja las variables de trabajo `INTENT_PREFETCH_*` y requiere la reconstrucción estática normal antes de que las páginas públicas usen los nuevos valores.

### Diagnóstico en tiempo de ejecución

El diagnóstico en tiempo de ejecución muestra los orígenes efectivos del sitio/Worker y el límite CORS. También carga una tabla de siete días de solo lectura de las operaciones Worker muestreadas más lentas, incluidas p50, p95, p99 limitadas, duración máxima, fecha y recuento de muestras. Al actualizar la tabla se reutilizan los resúmenes de observabilidad del rendimiento existentes y no se recopilan cuerpos de solicitud, datos de clientes ni un segundo conjunto de registros de telemetría.

### Uso del plan

El uso del plan es una sección de solo lectura exclusiva para superadministradores para conocer los límites operativos del proveedor. Se carga automáticamente cuando se abre **Configuración -> Uso del plan** y se actualiza solo cuando el administrador recarga la página.

El trabajador llama a Cloudflare y Resend con credenciales del lado del servidor y devuelve nombres de planes, números de uso, límites, gravedad y enlaces de proveedores desinfectados. Los tokens del proveedor nunca llegan al navegador y el punto final no escribe KV ni enumera los espacios de nombres de KV.

El uso de Cloudflare utiliza `CLOUDFLARE_USAGE_API_TOKEN` o `CLOUDFLARE_ANALYTICS_API_TOKEN` más `CLOUDFLARE_ACCOUNT_ID`. Agregue lectura de facturación al token de uso para habilitar la detección automática del plan Workers; de lo contrario, establezca `PLAN_USAGE_CLOUDFLARE_PLAN`. El uso de Resend utiliza `RESEND_API_KEY`; Existen anulaciones de límites/plan opcionales porque las sondas Resend seguras pueden exponer encabezados de límite de velocidad sin encabezados de uso enviado mensualmente.

### Sesiones de administración

Las sesiones de administrador son una superficie de revisión exclusiva para superadministradores. Se carga cuando se abre **Configuración -> Sesiones de administrador** y muestra las sesiones activas más un historial de inicio de sesión minimizado de 30 días. Las etiquetas de cliente contienen únicamente clases analizadas de navegador, sistema operativo y dispositivo; Las identificaciones de red son huellas digitales codificadas. No se almacenan las direcciones IP completas, las cadenas de agente de usuario completas ni la ubicación precisa.

La sesión actual está etiquetada y no se puede revocar desde su propia fila. Cada dos sesiones activas tienen un control **Revocar**. La revocación requiere confirmación y el token CSRF del mismo origen existente, invalida solo ese ID de sesión, actualiza la lista y escribe un evento de auditoría. En pantallas estrechas, las sesiones activas y los inicios de sesión recientes se convierten en tarjetas de registro etiquetadas para que el cliente, el tiempo, el estado y la acción sigan siendo legibles sin necesidad de desplazarse horizontalmente por la página.

### Registro de auditoría

El registro de auditoría es un historial operativo exclusivo para superadministradores. Se carga cuando se abre **Configuración -> Registro de auditoría** y admite filtros de fecha, acción, correo electrónico exacto del administrador, campaña y texto delimitado. La guía de fecha, acción, correo electrónico, campaña, búsqueda y estado/cambio utiliza la información sobre herramientas localizada compartida del botón de información del panel; Los filtros de acción y campaña utilizan opciones legibles al enviar sus identificadores internos canónicos. Las filas del navegador exponen solo la proyección de auditoría minimizada: hora, acción, administrador, campaña/pedido/producto/fuente objetivo, estado y nombres de campos modificados. Los identificadores de acciones internas conocidas se presentan como descripciones localizadas en lenguaje sencillo; Los identificadores desconocidos reciben un respaldo legible y sin puntuación. Los objetivos también resuelven títulos de campaña y describen pedidos, productos, superficies de plataforma u fuentes de eventos conservando el valor interno en el título de diagnóstico de la celda. Los slugs de campaña `local-no-user-<timestamp>` generados se muestran como **Campaña de prueba local (no asignada)** en lugar de exponer su marca de tiempo de implementación. Los identificadores sin procesar siguen siendo autorizados para el filtrado y la exportación CSV.

**Estado/cambios** explica el resultado que reportó un evento y nombra los campos que cambió. No es necesario que los eventos informen ninguno de los valores, por lo que **Sin detalles adicionales** es un resultado válido en lugar de un error de carga. El resultado interno `empty` del adaptador de resumen Film Stripe se muestra como **No hay datos de resumen coincidentes**: la lectura se completó, pero ninguna de sus referencias asignadas de Film Stripe tenía métricas de resumen The Pool coincidentes.

**Exportar filtrado CSV** reutiliza los filtros activos y la ruta de descarga privada/no-store autenticada. Los filtros se redistribuyen dentro de su tarjeta de configuración y las filas de auditoría se convierten en tarjetas de registro etiquetadas en pantallas estrechas en lugar de ampliar la página. Las celdas CSV que comienzan como fórmulas de hoja de cálculo tienen formato de escape. Trate las exportaciones como registros operativos privados: pueden contener detalles de auditoría adicionales almacenados y no deben adjuntarse a cuestiones públicas ni revelar evidencia sin revisión.

### Diseño

La configuración de diseño expone variables seleccionadas del tema, como la fuente del cuerpo, la fuente del encabezado, los colores del texto, los colores de superficie/borde/primarios y el radio del botón.

Los campos de fuentes deben hacer referencia a fuentes ya cargadas por el CSS del sitio. El panel no importa fuentes remotas arbitrarias.

### Usuarios

Los superadministradores pueden crear, editar y eliminar usuarios del panel.

Normas:

- No puede eliminar su propia cuenta de superadministrador.
- No puede degradar su propia cuenta de superadministrador.
- Puede degradar o eliminar a otros superadministradores.
- Los nuevos usuarios de campañas deben tener al menos una campaña asignada. Un usuario de campaña no asignado existente puede permanecer sin asignar mientras se editan otros usuarios; esa cuenta no tiene acceso a la campaña hasta que se agregue una tarea. Para borrar una asignación existente aún es necesario eliminar la cuenta o seleccionar otra campaña.
- Las tareas aceptan campañas de repositorio no publicadas que se muestran en el panel, incluidos los proyectos recién creados. No es necesario que una campaña sea pública antes de poder agregar colaboradores.
- Los cambios del usuario se guardan en KV inmediatamente a través del botón Guardar usuarios; no utilizan el botón de publicación de Configuración.
- Los usuarios recién creados reciben instrucciones de inicio de sesión por correo electrónico cuando se configura Resend. Las ediciones a usuarios existentes no reenvían el correo electrónico.

### Secretos y credenciales

Esta sección informa el estado configurado/faltante para las credenciales de tiempo de ejecución únicamente. No debe mostrar ni editar valores secretos.

### Anulaciones de diagnósticos en tiempo de ejecución

Estas variables Worker complementan el espejo de configuración canónico; no crean un segundo catálogo de configuración editable:

|variable|Propósito|
| --- | --- |
|`ADMIN_LOCAL_REPO_SERVICE`|URL auxiliar del repositorio exclusivo para desarrolladores; `env.dev` utiliza `http://127.0.0.1:8799`. El Worker por sí solo no puede escribir archivos host.|
|`ADMIN_TURNSTILE_REQUIRED`|Error cerrado cuando se espera la configuración del administrador Turnstile.|
|`CLOUDFLARE_WORKER_SCRIPT_NAME`|Filtrar el uso de Cloudflare por script Worker; omitir para uso en toda la cuenta.|
|`PLAN_USAGE_CLOUDFLARE_PLAN`, `PLAN_USAGE_RESEND_PLAN`|Mostrar planes alternativos cuando la detección de proveedores no esté disponible.|
|`CLOUDFLARE_*_DAILY_LIMIT`, `CLOUDFLARE_*_MONTHLY_LIMIT`|Mostrar anulaciones de cuota para las métricas Workers/KV cuando los datos del proveedor omiten límites, como `CLOUDFLARE_WORKERS_REQUESTS_MONTHLY_LIMIT`.|
|`RESEND_EMAILS_MONTHLY_LIMIT`, `RESEND_EMAILS_DAILY_LIMIT`|Resend muestra anulaciones de cuotas.|
|`PLAN_USAGE_WARNING_PERCENT`, `PLAN_USAGE_CRITICAL_PERCENT`|Umbrales de advertencia de progreso de uso.|

Estas anulaciones de visualización no cambian las cuotas de los proveedores. Mantenga las credenciales en secretos Worker; [Security](/es/docs/operations/security/) es propietario de sus ámbitos.

## Límite del panel de control entre proyectos

El panel Store es una fuente de patrones operativos reutilizables, no un segundo modelo de producto. El mapeo The Pool actual es:

|Superficie Store|Decisión The Pool|
| --- | --- |
|Sesiones de administración|Transferido al exponer las API de revisión/revocación de privacidad minimizada existentes de The Pool en Configuración|
|Registro de auditoría y filtrado CSV|Se transfiere al exponer las API de auditoría con capacidad de búsqueda existentes de The Pool, con un filtro de campaña y campos de destino específicos de The Pool.|
|Orden de la sección de configuración|Las secciones de la barra lateral compartidas utilizan el orden entre proyectos; Los informes del ejecutor The Pool ocupan la costura de marketing, mientras que el esquema de complementos de la plataforma de costura de preparación se dirige a la pestaña Complementos de nivel superior de The Pool.|
|Controles de la política de devolución del comerciante|Adaptado a la política actual de no devoluciones de The Pool: país editable más tipo de póliza de solo lectura; Los campos de retorno finito no admitidos permanecen ausentes.|
|URL canónicas|Ya presente en Configuración -> Plataforma; ninguna sección duplicada|
|Uso del plan, secretos, diagnósticos en tiempo de ejecución, configuración de rendimiento, usuarios|Ya presente en The Pool y retenido|
|preparación Store|No copiado tal como está: la instantánea del producto, las descargas, los cupones, los boletos, el R2 y los cheques de pedidos no se asignan a las campañas; The Pool utiliza secretos y credenciales, uso del plan, diagnósticos en tiempo de ejecución, comprobaciones de postura de producción y evidencia de liberación de humo.|
|Workers Controles de caché|No copiado: los cachés de pedidos/catálogos autenticados de Store son específicos del dominio; The Pool mantiene sus propias estadísticas en vivo/TTL de inventario y postura de caché basada en evidencia|
|Valores predeterminados de marketing globales de Store|No copiado: The Pool ya tiene enlaces de marketing relacionados con la campaña, borradores compartidos, referencias, códigos QR, incrustaciones y controles de recordatorio.|
|Productos, cupones, descargas, boletos, pedidos y UI de conciliación|No copiado: los equivalentes admitidos de The Pool son campañas, complementos, patrocinadores, informes, liquidación y conciliación de aportes.|

Al reutilizar otro patrón de administración de Dust Wave, utilice los ayudantes de autenticación, solicitud, estado, tabla, localización, configuración y prueba existentes de The Pool; no introduzca almacenamiento con nombre Store ni fuentes de información fiables exclusivas del navegador.

## Complementos de plataforma

La pestaña Complementos administra productos para toda la plataforma que se pueden adjuntar a los aportes independientemente de los ingresos de la campaña.

Cada producto admite:

- nombre e ID derivado de solo lectura
- descripción
- subir imagen
- precio
- categoría física/digital
- preestablecido de envío
- peso/dimensiones manuales cuando un producto físico no tiene ajuste de envío preestablecido
- inventario
- URL de origen
- nombre de opción variante
- variantes con etiqueta, ID de solo lectura derivada, anulación de precio opcional e inventario

Los complementos digitales ocultan los campos de envío. Los complementos físicos pueden utilizar dimensiones de paquete preestablecidas o explícitas.

Si deja un precio variante en blanco, se hereda el precio base del producto. La publicación escribe una variante `price` solo para una anulación no negativa válida; Los ID de productos/variantes existentes y las variantes sin anulaciones permanecen sin cambios.

## Campañas

El campo **Estado** de solo lectura muestra el estado efectivo del ciclo de vida a partir de las fechas de la campaña en la zona horaria de la plataforma, incluidas las transiciones automáticas de lanzamiento y fecha límite. No muestra un valor `state` obsoleto guardado en el frente de la campaña.

Las campañas se muestran en una barra lateral izquierda. Los superadministradores ven todas las campañas. Los usuarios de campañas solo ven las campañas asignadas.

Para los superadministradores, la primera fila de la barra lateral de Campañas es un botón `+` con solo íconos para **Crear nueva campaña**. Las campañas existentes aparecen debajo de esa fila. Los usuarios de la campaña no ven el botón crear.

Cada campaña tiene estas subpestañas:

1. **Configuración**
2. **Contenido**
3. **Niveles**
4. **Artículos de soporte**
5. **Complementos**
6. **Metas ambiciosas**
7. **Artículos en curso**
8. **Entradas del diario**
9. **Decisiones**

### Crear nueva campaña

Crear nueva campaña es solo para superadministradores. Crea una campaña de solo vista previa que permanece invisible para `/campaigns/:slug/` público, rutas de campaña localizadas, índices de página de inicio/comunidad/complementos, `/api/campaigns.json`, tarjetas compartidas, resultados de mapas del sitio, intención de rastreo de robots, incrustaciones y elegibilidad de captación previa pública hasta que se lanza la campaña.

El título de la campaña es obligatorio. La asignación de usuarios de campaña es opcional.

Los superadministradores pueden crear una campaña sin usuarios de campaña asignados, seleccionar varios usuarios de campaña existentes, elegir **Crear nuevo usuario de campaña** y agregar uno o más usuarios de campaña nuevos con los nombres y correos electrónicos requeridos en el mismo cuadro de diálogo. Los nuevos usuarios se guardan en `admin-users:v1`; Los usuarios de campaña asignados reciben un correo electrónico con tecnología Resend con el enlace del panel de administración cuando se configura la entrega de correo electrónico.

La creación agrega la nueva campaña a las asignaciones existentes de los usuarios seleccionados y conserva a otros usuarios. Un usuario existente no seleccionado y sin campañas no bloquea la creación ni las ediciones no relacionadas en **Configuración -> Usuarios**. Esta excepción se deriva de la membresía almacenada, nunca de una lista de permitidos proporcionada por el cliente.

El trabajador deriva el slug del título, escribe `_campaigns/<slug>.md` a través de la ruta de publicación existente de GitHub, establece valores predeterminados de solo vista previa/ocultos para el público, activa la reconstrucción normal y registra un evento de auditoría. El flujo no requiere fechas de lanzamiento, monto objetivo, recompensas, imágenes ni contenido de la página.

### Guardar y publicar

Los botones **Guardar**, **Vista previa** y **Publicar** se aplican a la campaña seleccionada en las nueve subpestañas de creación. **Guardar borrador** sigue siendo la copia de seguridad local del navegador del editor de contenido. Guardar localmente no borra el botón Guardar principal.

Save escribe una copia de trabajo respaldada por Git para proyectos no publicados y ya públicos. Carga contenido preparado y medios del diario antes de confirmar la configuración/contenido combinado de la campaña. Los activos cargados utilizan nuevas rutas; Guardar nunca cambia las páginas en vivo, los precios, el pago o los medios en vivo existentes. Los guardados fallidos conservan los cambios del editor. Los archivos borrador se excluyen de la salida de Jekyll y se incluyen en las copias de seguridad del repositorio; su repositorio y acceso a los activos sigue el modelo de fuente/medios existente.

Publicar primero guarda las ediciones actuales y luego promociona la copia guardada utilizando el permiso de editor de campaña existente. La publicación requiere un título, fechas ordenadas válidas y un objetivo positivo. Limpia las banderas ocultas; la recaudación de fondos todavía sigue las fechas. Los conflictos de fuente pública detienen la publicación y preservan la copia de trabajo. Las campañas existentes utilizan su copia publicada hasta el primer guardado; no es necesaria una migración masiva.

### Vista previa protegida

La vista previa guarda las ediciones actuales antes de abrir el cuadro de diálogo para compartir y vuelve a verificar la revisión guardada antes de compartir. Los enlaces de revisor existentes muestran los últimos guardados exitosos hasta que caduquen. Guardar no envía invitaciones, no cambia la lista de permitidos de revisores y no extiende la caducidad del enlace. La reapertura de la Vista previa conserva los enlaces activos existentes; las invitaciones opcionales siguen siendo explícitas. Los superadministradores y los usuarios de campañas asignados pueden publicar una vista previa protegida de las campañas que pueden editar.

Vista previa de publicación:

- valida el alcance de la campaña actual y el token CSRF
- rechaza revisiones de base obsoletas cuando el Markdown de la campaña cambió desde que se cargó el editor
- escribe solo el estado de vista previa en Markdown de la campaña respaldada por GitHub; los correos electrónicos de la vista previa no están confirmados
- almacena el administrador de publicación más la lista de permitidos de revisor opcional en `PLEDGES` KV en `campaign-preview-reviewers:<slug>` con un TTL de 24 horas
- devuelve un enlace de vista previa firmado para el administrador de publicación para que el panel pueda mantenerlo visible después de que se cierre el modal
- Los correos electrónicos invitaban explícitamente a revisores adicionales. Enlaces de vista previa firmados que caducan en 24 horas, y ese vencimiento se indica en la copia del correo electrónico.
- registra un evento de auditoría administrativa

Vista previa de páginas en vivo en `/campaigns/:slug/preview/` y equivalentes localizados. Se generan shells estáticos genéricos para cada slug de campaña, incluidas las fuentes marcadas como `published: false` que Jekyll excluye de su colección de campañas públicas. Una campaña recién creada necesita que se creen sus páginas iniciales para finalizar; La vista previa posterior publica la reutilización de ese shell sin esperar otra compilación. El shell no incluye el título de la campaña ni el borrador del contenido. El Worker protegido lee la copia de trabajo guardada cuando está presente; de ​​lo contrario, la campaña canónica. Obtiene una vista previa completa de la página de la campaña de solo lectura a través de Worker con la sesión de administrador actual o un token de revisor válido, carga la hoja de estilo de la campaña y el kit de fuentes, permite incrustaciones de reproductores multimedia aprobadas y deshabilita los controles de aporte. El shell de vista previa estática es `noindex,nofollow,noarchive`, no utiliza metadatos sociales, elimina el token de vista previa de la barra de direcciones después de la carga y permanece fuera de la salida del mapa del sitio público y de la elegibilidad de captación previa pública.

### Configuración de campaña

La configuración de la campaña incluye identidad, fechas, monto objetivo, estado cargado/de solo lectura, correos electrónicos de informes del corredor, anulaciones de envío, medios destacados, imagen del creador, fondos y otros temas de la campaña.

**Informes de usuarios de campaña** enumera los usuarios de campaña asignados, seleccionados de forma predeterminada. Desmarque a alguien, luego Guardar y publicar para detener sus informes para esta campaña; revisarlos nuevamente reanuda la entrega. **Correos electrónicos de informes adicionales** conserva los destinatarios manuales. Las preferencias de informes no cambian el acceso al panel. Consulte [Email](/es/docs/operations/email-system/#informes-para-responsables-de-campaña) para conocer las reglas de programación y destinatarios.

Slug y URL son campos derivados de sólo lectura. Se conservan las babosas de campaña existentes. Para nuevas campañas creadas con repositorios, mantenga la URL del slug segura y estable porque el pago, los informes, los enlaces mágicos y los registros de aporte dependen de ello.

Los superadministradores ven **Archivar campaña** en la parte inferior de la subpestaña Configuración después de **Fondo de campaña** y **Fondo de progreso** cuando la campaña no está activa actualmente. Los usuarios de la campaña nunca ven este control y las campañas activas lo ocultan por completo. Al archivar se solicita confirmación y luego se saca la campaña de la fuente activa sin eliminar datos. En desarrollo local, `ADMIN_LOCAL_REPO_WRITES_ENABLED=true` enruta Worker a través de un asistente de repositorio local protegido por token que mueve archivos de repositorio montados. En producción, Worker inicia el repositorio **Campaña de archivo** Acción GitHub. Ambas rutas mueven `_campaigns/<slug>.md`, los archivos de imagen/video/audio propiedad de la campaña y los medios complementarios de la campaña a los que se hace referencia a `archive/campaigns/<slug>/`, conservan la copia de trabajo guardada en el archivo, escriben un `archive-manifest.json` y dejan los medios todavía referenciados por otras campañas activas en su lugar y enumerados en el manifiesto.

### Contenido

La pestaña Contenido edita el contenido de la página de formato largo de la campaña en un editor de bloques WYSIWYG.

Los tipos de bloques admitidos incluyen:

- texto
- citar
- imagen
- galería
- vídeo
- sonido
- incrustar
- divisor

El editor admite controles de inserción de bloques, deshacer con el teclado para cambios de bloques, formato en línea estilo Markdown, enlaces, listas desordenadas/ordenadas, controles de alineación, configuraciones de medios y vista previa móvil. Las ediciones de texto se almacenan automáticamente en el navegador actual. **Guardar borrador** confirma que el almacenamiento del navegador aceptó el contenido actual; no publica. **Publicar** permanece disponible para contenido no publicado y valida y escribe a través de Worker. La recarga restaura un borrador local sin reemplazarlo con contenido del servidor. Cargar contenido de campaña y mostrar la vista previa en línea del editor de contenido no escribe en el almacenamiento de borradores. La acción del encabezado **Vista previa** ejecuta primero Guardar el proyecto, como se describe en [Guardar y publicar](#guardar-y-publicar).

La advertencia de abandono de página del navegador permanece activa para las ediciones no guardadas en el proyecto, incluso después de **Guardar borrador**. Un guardado principal exitoso lo borra solo para las ediciones enviadas; La escritura más reciente permanece sin guardar. Las fallas de almacenamiento muestran un error y dejan el estado de guardado sucio. Un borrador modificado en otra pestaña o un borrador ilegible se deja intacto en lugar de sobrescribirse silenciosamente. Los archivos multimedia seleccionados permanecen en la memoria hasta que se cargan: Guardar borrador guarda solo texto. Mantenga la página abierta hasta que se complete el guardado principal. Otras configuraciones, niveles y formularios de diario de la campaña no se incluyen en el borrador del navegador del editor de contenido; el Guardar principal los conserva con el Contenido en la copia de trabajo guardada.

La clave y el formato del borrador del navegador existente siguen siendo compatibles. La carga nunca lo reescribe. Antes de que el nuevo editor sobrescriba por primera vez un borrador de contenido existente, almacena una copia de recuperación exacta en la clave original más `:recovery-v1`. Las copias de recuperación no se eliminan automáticamente. El almacenamiento ilegible y los cambios de otra pestaña evitan la sobrescritura.

Los borradores locales pertenecen al origen exacto del sitio, al perfil del navegador y al idioma del editor. No están sincronizados con otro navegador o dispositivo y no son copias de seguridad del servidor. Un borrador no publicado conserva su revisión base, por lo que los cambios en el servidor de otro autor no se pueden sobrescribir silenciosamente. Si solo cambiaron los indicadores de vista previa y el contenido del servidor aún coincide con la línea base original del borrador, se utiliza la revisión actual del servidor. Un conflicto que involucra contenido modificado requiere comparar el borrador conservado con la campaña actual antes de volver a aplicar las ediciones; Recargar repetidamente no descarta el borrador ni evita el conflicto.

Los bloques de vídeo subidos pueden incluir una imagen de póster explícita. Cuando no se establece ningún póster, el panel y la página de la campaña pública generan un póster en el navegador a partir del primer cuadro del video mientras mantienen el video reproducible cargado de forma diferida hasta que el usuario presiona reproducir.

Reglas de seguridad del contenido:

- Prefiera Markdown para el formato en línea.
- Los enlaces de Safe Markdown se conservan.
- Se rechazan los esquemas inseguros como `javascript:` y `data:`.
- La capa de normalización del trabajador rechaza los scripts sin formato, los atributos del controlador de eventos y el HTML no compatible.
- Las incorporaciones estructuradas deben utilizar proveedores aprobados y orígenes confiables exactos.

#### Recuperar un borrador perdido del navegador

Mantenga el perfil del navegador afectado y las pestañas del editor aún abiertas. No borre los datos del sitio, reinstale o reinicie el navegador ni reemplace el contenido que falta mientras investiga. Primero copie cualquier texto que aún esté visible en un editor. Con el panel anterior, cargar la campaña puede sobrescribir el borrador del navegador, así que evite actualizar ese editor nuevamente durante la recuperación.

1. Consulte el historial de Git tanto de `_campaign_drafts/<slug>.md` (guardado del proyecto) como de `_campaigns/<slug>.md` (contenido publicado). La Vista previa del encabezado actual guarda el proyecto primero; La creación de una campaña o el uso del flujo de enlace de vista previa anterior no guardaban el contenido exclusivo del navegador. Las solicitudes de vista previa de contenido en línea solo se validan/procesan. Los registros KV del revisor de vista previa contienen información de acceso, no texto borrador.
2. En el **perfil del navegador original**, inspeccione el Almacenamiento local para conocer el origen exacto del sitio utilizado para editar (normalmente `https://site.example.com`). Inspeccione tanto `pool-admin-content-draft:en:<slug>` como `pool-admin-content-draft:es:<slug>`, además de la copia `:recovery-v1` de cada clave. Exporte los valores primarios y de recuperación por separado; el asistente de exportación de consola revisado a continuación exporta claves principales y contenido visible del editor únicamente. Abrir una página pública en ese origen permite la inspección del almacenamiento sin ejecutar el editor de administración. Exporte el valor bruto antes de editarlo; no comparta toda la base de datos de almacenamiento, cookies, tokens de inicio de sesión ni borradores no relacionados.
3. Una matriz `longContent` no vacía puede contener texto recuperable, rutas de medios, títulos y formato. Una matriz vacía no establece que no se haya creado nada: la ruta de carga anterior podría haberla sobrescrito. Los borradores locales del navegador en otro origen/perfil/idioma deben verificarse por separado si se utilizó ese contexto.
4. Si ni el proyecto guardado ni las claves primarias/de recuperación contienen el contenido que falta, conserve una copia del perfil del navegador afectado antes de cualquier intento de recuperación forense. Una copia de seguridad del perfil del dispositivo/navegador anterior a la actualización puede conservarlo. Las copias de seguridad ordinarias de sitios/servidores no pueden recuperar texto que nunca se almacenó allí y no se garantiza la recuperación de archivos de bases de datos sobrescritos del navegador. Los archivos multimedia seleccionados deben recuperarse de los archivos originales del creador.

Para Chrome, el [script de exportación de consola ](https://github.com/aindaco1/pool/blob/main/scripts/export-campaign-browser-draft.js) revisado está preconfigurado para `deinonychus` en `https://site.example.com`. Ejecútelo en el perfil original, en la pestaña del editor existente sin recargar. Si esa pestaña está cerrada, abra la página de inicio pública del sitio en una nueva pestaña. Abra la consola de la página superior con **Cmd+Opción+J** en macOS o **Ctrl+Shift+J** en Windows/Linux, revise/pegue el script completo y presione Entrar. Descarga un archivo JSON con marca de tiempo que contiene los dos valores exactos del borrador sin procesar y cualquier texto del editor coincidente que aún esté presente. No cambia el almacenamiento, no publica, envía una solicitud, lee cookies ni exporta otras campañas. Los valores vacíos/mal formados se preservan honestamente; el script no puede deshacer un valor sobrescrito. Guarde el archivo descargado para revisarlo antes de intentar una restauración. Adapte el slug y el origen explícitos solo para otra investigación de campaña autorizada.

Vuelva a aplicar el contenido recuperado únicamente después de guardar una copia independiente y confirmar la campaña y la revisión actual del servidor. La recuperación no autoriza el lanzamiento de una campaña ni el envío de invitaciones de vista previa.

### Niveles

Los niveles definen los niveles de recompensa de aporte. Se conservan los ID de nivel existentes; Los nuevos ID se derivan del nombre y se muestran como de solo lectura.

Los niveles físicos pueden utilizar un ajuste preestablecido de envío o metadatos de paquete explícitos. Los niveles digitales ocultan los campos de envío. El límite de cantidad controla la disponibilidad total; Apilable controla si un patrocinador puede reclamar más de una unidad.

### Artículos de soporte

Los elementos de apoyo son necesidades de financiación de campaña independientes. Se conservan las identificaciones existentes; Los nuevos ID se derivan del nombre y se muestran como de solo lectura.

Los artículos de soporte digital ocultan los campos de envío. Los artículos de soporte físico pueden utilizar ajustes preestablecidos de envío y metadatos de paquetes.

### Complementos de campaña

Los complementos de campaña son productos opcionales adjuntos a una sola campaña. Siguen el mismo modelo de producto/variante que los complementos de la plataforma, pero contribuyen a la contabilidad de la campaña en lugar de a los ingresos de los complementos de la plataforma.

Las campañas publicadas siguen siendo editables. En **Campañas -> Complementos**, los usuarios de campaña asignados pueden cargar fotos de productos de campaña nuevos o existentes y luego guardar y publicar la revisión. Las cargas heredan el alcance de la campaña del editor; Los registros complementarios individuales no necesitan un slug de campaña. El editor de complementos de la plataforma de nivel superior y sus cargas permanecen restringidos a superadministradores.

### Metas extendidas

Los objetivos ampliados definen hitos de financiación con umbrales, títulos, descripciones y estado de visualización.

### Artículos en curso

Los elementos continuos definen las necesidades de soporte posteriores a la campaña o continuas que se muestran en la plantilla de campaña.

### Entradas del diario

Las entradas del diario son actualizaciones de la campaña ordenadas primero por las más recientes. Cada entrada incluye título, fecha/hora, fase y su propio editor de contenido WYSIWYG. El contenido del diario utiliza el mismo modelo de bloque de contenido que la pestaña Contenido de la campaña.

### Decisiones

Las decisiones definen las indicaciones de voto/encuesta de los patrocinadores. `vote` significa que el resultado está destinado a decidir un resultado; `poll` significa que el resultado son comentarios de los patrocinadores. Ambos usan la misma opción y cuentan el flujo actual.

El estado es de solo lectura y se deriva de la fecha límite. La elegibilidad se limita a los patrocinadores de la campaña o a los patrocinadores de la campaña cobrados.

## Informes

Los informes pueden obtener una vista previa y descargar exportaciones CSV estándar para las campañas a las que puede acceder el administrador que ha iniciado sesión.

Tipos de informes admitidos:

- informe de aporte
- informe de cumplimiento

La interfaz de usuario del informe del navegador está orientada a la descarga. No necesita controles manuales de envío de correo electrónico ni de marcación como enviado.

### Informes de aporte de CLI

Genere informes CSV de aportes de Cloudflare KV:

```bash
# Remote production/dev reports require Wrangler auth.
(cd worker && npx wrangler login)

# Or, for non-interactive shells and Podman-backed report runs:
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# All pledges, production KV
./scripts/pledge-report.sh

# Single campaign
./scripts/pledge-report.sh worst-movie-ever

# Dev/preview KV
./scripts/pledge-report.sh --env dev

# Save to file
./scripts/pledge-report.sh worst-movie-ever > pledges.csv
```

Para informes remotos respaldados por Podman, coloque `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` en el shell del host o en un archivo env local ignorado como `.env.local`, `.env.cloudflare` o `worker/.dev.vars`; los envoltorios de informes pasan los valores de autenticación de Cloudflare a `podman exec`.

Configuración de bifurcación para informes de producción:

1. En Cloudflare, vaya a **Mi perfil -> Tokens API -> Crear token**.
2. Cree un token de usuario con **Cuenta/Almacenamiento KV de trabajadores/Lectura** con alcance para la cuenta propietaria del espacio de nombres KV `PLEDGES` de esta bifurcación.
3. Guárdelo con la identificación de la cuenta en `worker/.dev.vars` u otro archivo env ignorado:

```bash
CLOUDFLARE_API_TOKEN=your-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

4. Ejecute exportaciones de producción a través del mismo entorno de trabajo de Podman utilizado por las pruebas locales:

```bash
./scripts/pledge-report.sh --podman --env production --remote > ~/Desktop/pool-pledge-report.csv
./scripts/fulfillment-report.sh --podman --env production --remote > ~/Desktop/pool-fulfillment-report.csv
```

El progreso se escribe en stderr, mientras que los datos CSV se escriben solo en stdout, por lo que las redirecciones de archivos se mantienen limpias.

**Formato de salida:** Una fila por entrada del historial (estilo libro mayor). Esto significa:
- Nuevas aportes: 1 fila (creada)
- aportes modificados: más de 2 filas (creadas + deltas de modificación)
- aportes cancelados: 2 filas (creadas + canceladas con montos negativos)

**Columnas de salida:** `email`, `campaign`, `items`, `add_on_items`, `campaign_subtotal`, `platform_add_on_subtotal`, `subtotal`, `tip_percent`, `tip`, `tax`, `shipping`, `total`, `status`, `charged`, `created_at`, `order_id`.

**Valores de estado:**
- `created`: creación de aporte inicial (los elementos muestran la lista de niveles completa)
- `modified`: cambio de nivel/cantidad de aporte (los elementos muestran diferencias: `+Added Tier`, `-Removed Tier`)
- `cancelled` — Aporte cancelado (muestra montos negativos)
- `active` — Aporte heredado sin historia
- `charged` — aporte cargado heredada sin historia
- `failed` — Aporte fallido heredado sin historia

**Formato de elementos de fila modificado:**
```
(modified) +Line of Dialogue; -Writer Credit x2; +Custom Support $5.00
```
- `+Tier` o `+Tier xN`: se agregó un nivel (o se aumentó la cantidad)
- `-Tier` o `-Tier xN`: se eliminó el nivel (o se redujo la cantidad)
- `+Custom Support $X` o `-Custom Support $X`: se agregó o eliminó soporte personalizado
- `; tip updated to N%`: la propina cambió durante la misma modificación, incluso si otros campos de contribución también cambiaron
- Los niveles sin cambios no aparecen en la diferencia

**Soporte personalizado en artículos:** Cuando un aporte incluye soporte personalizado, aparece como `Custom Support $X.XX` en la columna de artículos (por ejemplo, `Line of Dialogue; Custom Support $25.00`).

**Formato de fila cancelada:** Las filas canceladas muestran montos negativos (subtotal, propina, impuestos, envío, total), de modo que la suma de todas las filas da el total correcto de la campaña. Los elementos tienen el prefijo `-` para indicar su eliminación.

**Asignación de nombres de niveles:** El informe convierte los ID de niveles en nombres legibles por humanos (por ejemplo, `frame` → `One Frame`, `dialogue` → `Line of Dialogue`).

Utilice `campaign_subtotal` para la contabilidad del progreso de la campaña; `subtotal` también incluye complementos de plataforma. Las filas del historial codifican cambios y cancelaciones como deltas. `total` incluye propina, impuestos y envío; Las sumas del libro mayor describen los montos de los aportes registradas y no prueban el cobro exitoso del pago.

### Informes de cumplimiento de CLI

Genere informes agregados que muestren el **estado actual** del aporte de cada patrocinador (para fines de cumplimiento):

```bash
# All pledges, production KV
./scripts/fulfillment-report.sh

# Single campaign
./scripts/fulfillment-report.sh worst-movie-ever

# Dev/preview KV
./scripts/fulfillment-report.sh --env dev

# Save to file
./scripts/fulfillment-report.sh worst-movie-ever > fulfillment.csv
```

**Formato de salida:** El estado actual del aporte se agrega por patrocinador y campaña, luego se divide por campaña o plataforma cuando sea necesario. Por lo tanto, un patrocinador puede tener más de una fila de cumplimiento para una campaña.

**Columnas de salida:** `email`, `campaign`, `fulfiller`, `items`, `add_on_items`, `campaign_subtotal`, `platform_add_on_subtotal`, `subtotal`, `tip_percent`, `tip`, `tax`, `shipping`, `total`, `shipping_address`.

**Diferencias clave con aporte-report.sh:**
- Muestra **estado de nivel actual** (no el historial)
- **Agrega** múltiples aportes por patrocinador/campaña antes de dividirlos por cumplidores.
- **Excluye** aportes cancelados
- Enumera los elementos entregables; El soporte personalizado aún participa en los totales de dinero aplicables.
- **No** columnas de estado, creada_en o id_pedido
- Los artículos muestran las cantidades finales (por ejemplo, si el patrocinador se modifica desde el cuadro → diálogo, solo aparece el diálogo)
- Incluye `shipping_address` para el cumplimiento del nivel físico
- `total` es el monto del cargo final, incluida la propina opcional de The Pool.

**Casos de uso:**
- Hojas de cálculo de cumplimiento (qué recompensas entregar a cada patrocinador)
- El patrocinador cuenta por nivel
- Seguimiento de entregables

## Patrocinadores

La pestaña Patrocinadores muestra filas de patrocinadores con alcance de rol con filtrado en vivo, clasificación, alcance de campaña, montos en centavos de dólar exactos y exportación CSV para el conjunto de resultados actualmente visible. Los superadministradores pueden elegir **Todas** las campañas; Los usuarios de la campaña pueden elegir entre las campañas asignadas.

## Analítica

Los análisis se derivan de índices de aportes y resúmenes de campañas existentes. No crea escrituras KV específicas de análisis en la vista.

El panel muestra tarjetas para los totales de aportes, categorías de ingresos, ingresos netos después de las tarifas de procesador asignadas, impuestos, envío, tarifas de Stripe, estado del aporte, patrocinadores, aporte promedio, complementos de campaña, atribución de referencia, fuente/medio/campaña/contenido UTM, tipo de cumplimiento, idioma y otros desgloses derivados del aporte. Los valores monetarios muestran centavos exactos.

Si a una campaña le falta su proyección `campaign-pledges:<slug>`, Analytics permanece como de solo lectura, devuelve una fila de campaña puesta a cero y muestra un aviso de índice faltante sin bloqueo en lugar de enumerar la verdad del aporte o fallar en la pestaña Marketing.

Los ingresos brutos de la campaña y los ingresos de la plataforma permanecen visibles para la conciliación. Los ingresos netos de la campaña y los ingresos netos de la plataforma restan la parte asignada a cada categoría de las tarifas reales del procesador de Stripe cuando existen datos de transacciones de saldo almacenados. los aportes activos y las filas de aportes cargados más antiguas sin datos reales del saldo de Stripe continúan utilizando la estimación de planificación estándar. Los reabastecimientos exclusivos de superadministradores pueden recuperar de forma segura datos históricos de transacciones de saldo de Stripe sin escaneos de listas KV a través de `POST /admin/analytics/stripe-financials/backfill`.

## Marketing

La pestaña Marketing crea URL de campaña con parámetros de referencia y UTM, muestra los controles de vista previa/descarga de QR de la campaña junto a la salida de la URL, guarda códigos de referencia, expone la interfaz de usuario del generador de inserción de campaña, carga/guarda un borrador de campaña compartido y muestra el estado del recordatorio de pago abandonado para la campaña seleccionada. El rendimiento de referencias y UTM se encuentra en Analytics, por lo que los informes de rendimiento de la campaña permanecen en un solo lugar.

Tienda de códigos de referencia guardados:

- nombre de referencia
- código de referencia
- URL generada
- Metadatos de origen del código QR para la URL generada
- marca de tiempo de creación

El creador de URL se borra después de guardar y actualizar. Los guardados, ediciones y eliminaciones de referencias son mutaciones KV explícitas.

Los códigos QR se generan en el navegador a partir del resultado del generador de URL de la campaña actual o de una URL de referencia guardada, incluidos los parámetros UTM y de referencia. Las actualizaciones de vista previa del constructor actual sin llamadas de trabajador y las descargas PNG/SVG son descargas de archivos locales del navegador. Las acciones de vista previa y descarga de QR no leen ni escriben KV.

Los borradores de marketing compartido son explícitos: los usuarios hacen clic en **Cargar borrador compartido**, **Guardar borrador compartido** o **Borrar borrador compartido**. Un borrador es un registro KV con alcance de campaña con un TTL de 7 días y un token de revisión, por lo que los guardados obsoletos fallan y generan un conflicto en lugar de sobrescribir el trabajo de otro administrador. La carga es de sólo lectura; guardar o borrar es el único borrador que se escribe.

El panel de pago abandonado muestra el estado de los recordatorios de campaña de los contadores agregados de colas/resultados y resultados recientes sin listado de KV. Los resultados de la supresión creados por el administrador incluyen la dirección de correo electrónico suprimida para que los administradores puedan borrar esa supresión de la tabla de resultados recientes; Las mutaciones de supresión todavía ocurren solo con una acción explícita y no incluyen una acción de volver a intentar este carrito específico.

## Explosión

Campañas -> Blast envía mensajes masivos de correo electrónico a los patrocinadores para la campaña seleccionada sin agregar otra vista del panel de nivel superior. Los usuarios de campañas pueden enviar mensajes masivos para las campañas que se les hayan asignado, y los superadministradores pueden enviar mensajes masivos para cualquier campaña. Los borradores de Blast permanecen locales en el navegador a menos que un administrador use explícitamente los botones de borrador compartido; Los borradores Blast compartidos utilizan el mismo modelo KV de 7 días con alcance de campaña protegido contra revisiones que los borradores de Marketing. Blast reutiliza el editor de contenido WYSIWYG de la campaña para encabezados, textos, citas, listas, enlaces, imágenes cargadas alojadas en la campaña, imágenes de campaña existentes del selector de medios y enlaces de videos de YouTube/Vimeo listos para enviar por correo electrónico. El panel carga automáticamente imágenes Blast preparadas a través de la misma ruta de carga de medios de la campaña utilizada por los bloques de contenido y diario antes del ensayo, por lo que los archivos de imágenes se confirman en `assets/images/campaigns/<slug>/` y se ponen en cola para la optimización de medios del repositorio antes de que se cree la carga útil del correo electrónico. El tablero ejecuta automáticamente la validación de prueba antes de Enviar prueba o Enviar Blast; La carga fallida o las verificaciones de audiencia explican el motivo antes de intentar enviar cualquier correo electrónico.

Los ensayos validan el mensaje, calculan el recuento de audiencia indexada y devuelven un hash de ensayo sin escrituras con límite de velocidad, escrituras de auditoría, envíos de correo electrónico ni listas KV. Los envíos de prueba van únicamente al administrador que ha iniciado sesión. Los envíos en vivo requieren el hash de prueba correspondiente para el mensaje y la audiencia exactos, enviarse a través del remitente de actualizaciones compartido Resend y escribir un evento de auditoría después del envío. La pestaña Blast muestra el historial de envíos de solo lectura de registros de auditoría recientes, incluido el asunto, el contenido, la etiqueta del botón CTA y la URL del botón CTA.

La representación masiva de correo electrónico solo incluye imágenes del sitio alojado de `/assets/images/...`; Las URL de imágenes remotas arbitrarias se omiten en el lado del servidor. Los bloques de YouTube y Vimeo se muestran como enlaces/botones seguros para el correo electrónico en lugar de iframe o incrustaciones de vídeo porque la mayoría de los clientes de correo electrónico bloquean los reproductores integrados.

Si falta `campaign-pledges:<slug>`, los ensayos de Blast y los envíos fallan y se cierran con `campaign_index_required`; reconstruir el índice de la campaña antes de enviarla. Esto evita recurrir a escaneos de espacios de nombres en una ruta de operador que puede ejecutarse en producción.

## Medios de comunicación

La optimización de imágenes se publica automáticamente tras validar las imágenes y superar todas las comprobaciones de Merge Smoke. Las ramas temporales se eliminan después de cada ejecución, por lo que los administradores no necesitan mantener ramas ni pull requests de optimización. Los fallos dejan intacto el contenido fuente publicado; vuelva a ejecutar la optimización de archivos pendientes después de resolver el fallo. Consulte [Optimización de medios](/es/docs/operations/performance/#optimización-de-medios) para conocer la validación, la recuperación y la publicación.

Las imágenes y los videos cargados a través del panel se validan antes de la persistencia, se les cambia el nombre con nombres de archivo estilo slug en minúsculas y se asignan al directorio de activos que coincida con su uso:

- Imágenes de marca de plataforma: `assets/images/defaults/`
- Imágenes de productos complementarios de plataforma: `assets/images/add-ons/`
- Imágenes de productos complementarios de campaña: `assets/images/campaign-add-ons/`
- Imágenes de campaña, imágenes de bloques de contenido, imágenes de niveles, imágenes de diario e imágenes de opciones de decisión: `assets/images/campaigns/<campaign-slug>/`
- Vídeos de campaña: `assets/videos/campaigns/<campaign-slug>/`
- Audio de la campaña: `assets/audio/campaigns/<campaign-slug>/`
- Plataforma/vídeos predeterminados: `assets/videos/defaults/`

Medios de campaña recomendados:

- Imagen principal: cuadrada, alrededor de 1000x1000px
- Ancho de la imagen principal: 16:9, alrededor de 1600x900 px
- Imagen del creador: cuadrada, alrededor de 400x400px
- Imagen social predeterminada: imagen grande 16:9 o compatible con Open Graph
- Vídeo heroico: carga directa MP4/WebM/MOV de hasta 100 MB (100 000 000 bytes) o una URL de YouTube/Vimeo

El mismo límite de video se aplica a los reemplazos de contenido, diario y biblioteca multimedia. El panel envía archivos de vídeo como cuerpos de solicitud binarios; el Worker transmite su codificación GitHub sin mantener el archivo completo en la memoria. Los permisos de campaña, la preservación de la fuente, las rutas de nuevos activos y la optimización después de una confirmación exitosa se aplican a estas cargas. Una carga fallida no reemplaza la ruta del medio guardado. Vuelva a cargar las pestañas anteriores del panel antes de cargar videos grandes.

El editor de contenido de la campaña, los editores de contenido de entrada de diario y los bloques de imágenes Blast presentan primero los medios seleccionados en el navegador. El bloque muestra la imagen, el vídeo o la selección de audio seleccionados inmediatamente, pero el archivo no se carga hasta que el usuario guarda el proyecto o envía/prueba un Blast. La vista previa móvil también muestra miniaturas locales delimitadas de imágenes preparadas; La reproducción de vídeo/audio estará disponible después de guardar el proyecto. Los marcadores de posición de texto vacíos se omiten al guardar el contenido de la campaña o del diario. Durante el guardado del proyecto o el envío de Blast, el panel carga medios preparados en el directorio de activos de la campaña, reemplaza la vista previa temporal del navegador con la ruta final `/assets/...` y luego confirma el YAML de la campaña o crea la carga útil de correo electrónico Blast.

Los bloques Contenido de campaña, Diario y Blast pueden elegir imágenes existentes, videos/pósteres locales y audio desde el cuadro de diálogo de la biblioteca multimedia con alcance. Búsqueda, pestañas de imagen/vídeo/audio, clasificación reciente/nombre, miniaturas, dimensiones/duración/tamaño de archivo, campaña/alcance compartido, ubicaciones de referencia, estado de optimización, advertencias de ubicación y referencias rotas provienen del manifiesto de medios reconstruible registrado. Los derivados responsivos generados se describen en su tarjeta de origen en lugar de aparecer como opciones independientes. La URL de origen permanece disponible solo para reparación o edición avanzada de rutas, y el selector no agrega ningún estado de medios KV.

El texto alternativo es opcional y nunca bloquea Guardar o Publicar. Las descripciones que faltan generan consejos de accesibilidad; Las descripciones proporcionadas están normalizadas a texto sin formato de hasta 300 caracteres. Marque explícitamente una imagen puramente decorativa; una descripción omitida no cambia ese estado. Las ubicaciones comunes de héroe, galería, nivel, Blast y carteles muestran presupuestos de tamaño/dimensión de archivo de asesoramiento.

El reemplazo seguro se limita a la misma campaña, directorio de activos y tipo de medio, y requiere el SHA de contenido GitHub actual para que las ediciones obsoletas fallen en lugar de sobrescribir el trabajo más nuevo. El reemplazo de campaña crea una nueva URL de activo y muestra referencias conocidas antes de la mutación. Las referencias existentes conservan sus medios originales; Elija Usar medios y guarde el proyecto para adoptar el reemplazo. Los usuarios de la campaña pueden enviar optimización de archivos modificados; La optimización del repositorio completo sigue siendo solo para superadministradores.

Las cargas de medios relacionadas con la campaña requieren acceso a esa campaña. Los superadministradores pueden cargar cualquier medio de campaña y plataforma/medio predeterminado; Los administradores de campañas solo pueden cargar medios para las campañas que administran. Las cargas de complementos de plataforma y marcas de plataforma siguen siendo solo para superadministradores.

Cuando se elimina un bloque de medios de contenido publicado, o se elimina una entrada del diario con bloques de medios, el Trabajador compara los datos de la campaña anterior con el borrador normalizado que se está confirmando. Los archivos propiedad del panel que se encuentran en los mismos directorios de medios de la campaña se eliminan de GitHub cuando ya no se hace referencia a ellos en ningún otro lugar de esa campaña. Se conservan las URL externas, los recursos compartidos/predeterminados y los medios de campaña a los que todavía hace referencia otro bloque o campo.

El endpoint de carga del Worker conserva los archivos fuente. Valida el tipo, el tamaño, los permisos de campaña, el directorio y el nombre de archivo, pero no ejecuta optimizadores nativos ni FFmpeg. Tras confirmar en GitHub una carga de imagen o video, el Worker inicia **Optimize dashboard media** con `scope=changed`. El flujo publica automáticamente la compresión de imágenes sin pérdidas ya validada, las variantes adaptables más pequeñas y el manifiesto actualizado. Los videos originales siguen disponibles; la transcodificación es una operación local que requiere una revisión independiente.

Los movimientos de archivos de campaña se realizan en el lado del repositorio por el mismo motivo. En desarrollo local, el trabajador llama al asistente de repositorio local cuando `ADMIN_LOCAL_REPO_WRITES_ENABLED=true`; En producción, el panel envía el flujo de trabajo **Archivar campaña** después de la autorización del superadministrador, y el flujo de trabajo valida el slug antes de mover la fuente de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/`.

Vuelva a intentar el flujo de trabajo con `scope=changed` para procesar cargas pendientes o `scope=all` para reprocesar todas las imágenes de origen. El alcance modificado utiliza hashes de origen y tamaños faltantes en lugar de depender de la última confirmación. Ambos ámbitos preservan derivados omitidos intencionalmente que serían mayores que su fuente. `npm run media:manifest` reconstruye el índice sin procesar archivos binarios. Los comandos locales y el flujo de trabajo del vídeo revisado están documentados en [Performance](/es/docs/operations/performance/#optimización-de-medios).

Utilice texto alternativo significativo para imágenes que comuniquen contenido. Los fondos decorativos pueden utilizar texto alternativo vacío en las plantillas públicas.

## Barandillas de seguridad y accesibilidad

El panel sigue estas reglas del proyecto:

- Los controles del navegador son ayudas de usabilidad; La validación del trabajador es autorizada.
- Todas las mutaciones requieren una sesión de administrador válida y un encabezado CSRF.
- El alcance de las funciones y las campañas se aplica en el lado del servidor.
- Los secretos nunca se almacenan en `_config.yml`, campaña YAML, borradores de paneles, registros de usuarios de KV o confirmaciones de GitHub.
- Los correos electrónicos de acceso a vista previa se almacenan solo en listas permitidas de Worker KV de corta duración, no en Markdown de campaña, JSON público, salida de mapa del sitio ni metadatos de página generados.
- Los cambios que agregan mensajes masivos, distribución de marketing, análisis, cambios de roles, visibilidad pública o retención de nuevos datos requieren la [revisión de riesgos éticos](/es/docs/development/ethical-risk-review/).
- Utilice etiquetas de administración compartidas/componentes de ayuda para nuevos campos.
- El editor oculto Chrome no es accesible mediante el teclado.
- Las tablas ordenables exponen `aria-sort`.

Consulte `docs/SECURITY.md` y `docs/ACCESSIBILITY.md` para conocer los estándares detallados.

## Pruebas

Comprobaciones útiles y enfocadas:

```bash
node --check assets/js/admin-dashboard.js
npx vitest run tests/unit/admin-dashboard.test.ts
npm run test:e2e:headless:podman -- tests/e2e/admin-dashboard.spec.ts --project=chromium
```

Utilice la puerta más amplia antes de la fusión cuando los cambios en el panel afecten el comportamiento de los trabajadores, la representación pública o la configuración compartida:

```bash
./scripts/pre-merge-regression.sh
```

## Solución de problemas

### No se puede iniciar el inicio de sesión de administrador

Controlar:

- el trabajador esta corriendo
- `CORS_ALLOWED_ORIGIN` coincide con el origen del sitio
- el correo electrónico está presente en `_config.yml` `admin.users`, `ADMIN_USERS_JSON`, `ADMIN_BOOTSTRAP_EMAILS` o en la lista de usuarios respaldada por KV
- Los secretos locales existen en `worker/.dev.vars`.
- si Turnstile está habilitado, `_config.yml` tiene `admin.turnstile_site_key` y el trabajador tiene `TURNSTILE_SECRET_KEY`
- Si el recordatorio de inicio del torniquete está habilitado, `_config.yml` tiene `launch_reminders.turnstile_site_key` y el trabajador tiene `TURNSTILE_SECRET_KEY` o `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY`.
- si realiza la prueba localmente con Turnstile habilitado, use las claves de prueba de Cloudflare o configure `ADMIN_TURNSTILE_BYPASS=true` solo en un entorno de trabajo local/de prueba

### Los cambios no aparecen en el sitio público

Las acciones de publicación del panel se comprometen con GitHub e inician la ruta de implementación normal. Espere a que finalice la implementación y luego realice una actualización completa. Los borradores del navegador local no afectan el sitio público hasta que se publiquen.

### La configuración de los trabajadores parece obsoleta

Los puntos de entrada admitidos ejecutan `scripts/sync-worker-config.rb` automáticamente. Si editó `_config.yml` o `_config.local.yml` directamente y está verificando `worker/wrangler.toml` antes de reiniciar la pila, ejecute:

```bash
npm run sync:worker-config
```

### Una campaña muestra datos vacíos o faltantes

Consulte la portada de Markdown de la campaña y la respuesta de Configuración del trabajador. YAML no válido o formas de campo no compatibles pueden impedir que los campos se representen correctamente en el panel.

### Los informes, los patrocinadores o los análisis muestran mensajes de índice que faltan

Los puntos finales de lectura del panel se basan en índices `campaign-pledges:{slug}` e intencionalmente no recurren a costosos escaneos de espacios de nombres. Ejecute las herramientas de reparación/reconstrucción de proyección explícitamente cuando a una campaña antigua le falte su índice.


### Representación y comentarios del editor compartido

El panel y la vista previa de Worker utilizan el códec del editor de plataforma anclado para Markdown en línea, incluido el texto en cursiva anidado dentro del texto en negrita. The Pool conserva la representación del bloque de campaña y la validación de URL. El filtro público Ruby tiene una prueba de paridad para énfasis anidado. Los mixins de Shared Design Core brindan contención de control del editor, ajuste de nombres de archivos largos, apilamiento de panel abierto, espaciado y medios de vista previa receptivos.

Las cargas de imágenes mantienen una vista previa local de pestañas codificada por la ruta del repositorio devuelta. Las imágenes principales y los bloques del editor permanecen visibles antes de que el nuevo activo llegue al sitio público, incluso después de guardar el proyecto. Las vistas previas móviles en zona protegida reciben miniaturas de imágenes delimitadas. Las cargas útiles para guardar/publicar contienen únicamente rutas de repositorio canónicas; Las URL de objetos y las miniaturas de datos nunca se guardan como contenido de la campaña. Cerrar sesión borra estas vistas previas. Al recargar se pierde el caché local, por lo que los activos no publicados aún necesitan la implementación estática normal antes de que sus rutas públicas puedan cargarse en otra pestaña.

Las solicitudes fallidas utilizan los valores predeterminados de comentarios legibles en inglés/español de la plataforma, con los nombres de los campos de diario/campaña localizados de The Pool. Por ejemplo, `longContent[0].src` aparece como campo de origen en el bloque de contenido 1. Los motivos de validación conocidos generan un mensaje procesable; Los errores de proveedores desconocidos utilizan un respaldo de estado de solicitud localizado. Los diagnósticos originales permanecen en el `rawData` del error detectado para su depuración y no se muestran directamente. Los títulos escritos por el creador no están traducidos. La falta de texto alternativo sigue siendo un aviso de advertencia y no puede impedir Guardar o Publicar.
