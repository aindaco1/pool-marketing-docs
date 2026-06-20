---
title: Panel de administración
parent: Operaciones
nav_order: 1
render_with_liquid: false
lang: es
---

# Panel de administración

## Última actualización

20 de junio de 2026

Este documento es la referencia del operador para el panel de administración privado de The Pool y debe ser tratado como la fuente de verdad para la edición de campañas, informes, análisis, enlaces de marketing, complementos y administración de usuarios basados ​​en el panel.

## Audiencia

Utilice esta guía si es:

- un superadministrador que gestiona la configuración de la plataforma, los usuarios administradores, los complementos de la plataforma, los informes, los análisis o todas las campañas
- un administrador de campaña que gestiona la configuración asignada de la campaña, el contenido de la campaña, las recompensas, las entradas del diario, las decisiones y los informes específicos de la campaña.
- un mantenedor de bifurcación que decide qué configuraciones pertenecen a `_config.yml`, secretos de trabajo, KV o campaña Markdown

## Acceso

El panel está disponible en:

- `/admin/`
- `/es/admin/`

Los administradores inician sesión con un enlace mágico de correo electrónico. Los trabajadores implementados envían el enlace por correo electrónico a través de Resend y no lo devuelven en la respuesta del navegador. El desarrollo local puede exponer el enlace solo cuando el sitio/base de trabajadores es localhost o cuando `ADMIN_EXPOSE_LOGIN_LINK=true` está configurado explícitamente. El desarrollo local otorga acceso de superadministrador de arranque a través de `ADMIN_BOOTSTRAP_EMAILS` en `worker/.dev.vars` ignorado; Los usuarios de semilla/recuperación de producción provienen de `_config.yml` `admin.users` o `ADMIN_USERS_JSON` implementados.

El inicio de sesión de administrador puede requerir Cloudflare Turnstile. Configure la clave del widget público en `_config.yml` como `admin.turnstile_site_key` y almacene el `TURNSTILE_SECRET_KEY` coincidente como un secreto de trabajador. Cuando se configura el secreto, `POST /admin/auth/start` verifica el token de desafío antes de las escrituras con límite de velocidad, las escrituras sin inicio de sesión o la entrega de correo electrónico con enlace mágico. `ADMIN_TURNSTILE_BYPASS=true` está disponible solo para automatización local/de prueba y no debe habilitarse en trabajadores implementados.

Los usuarios administradores tienen dos roles:

- **Superadministrador**: puede administrar la configuración de la plataforma, los complementos de la plataforma, todas las campañas, análisis, informes, seguidores, herramientas de marketing y usuarios administradores.
- **Usuario de campaña**: puede gestionar únicamente las campañas asignadas a ese usuario. Los usuarios de la campaña no ven las pestañas Configuración o Complementos de nivel superior.

Las ediciones del usuario administrador realizadas en **Configuración -> Usuarios** se guardan directamente en Worker KV en `admin-users:v1`. No publican en GitHub y no activan la implementación de un sitio. `_config.yml` y `ADMIN_USERS_JSON` siguen siendo fuentes de semilla/recuperación.

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
|Resumen del panel, análisis, informes, seguidores, filtrado de tablas y vista previa del contenido|Sólo lectura; debería agregar cero escrituras KV|
|Editor de contenido **Guardar borrador**|Solo borrador local del navegador|
|Publicación del contenido/configuración de la campaña|El trabajador valida la entrada, escribe en archivos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y registra un evento de auditoría.|
|Publicación de vista previa protegida|El trabajador valida el alcance de la campaña y la revisión base, escribe solo indicadores de vista previa en Markdown de la campaña respaldada por GitHub, almacena el administrador de publicación más los correos electrónicos del revisor opcional en `PLEDGES` KV en `campaign-preview-reviewers:<slug>` con un TTL de 24 horas, devuelve un enlace firmado visible en el panel para el editor, envía enlaces firmados a revisores opcionales y registra un evento de auditoría|
|Creación de campaña de superadministrador|El trabajador crea un archivo `_campaigns/<slug>.md` de solo vista previa localmente en desarrollo o a través de GitHub en producción, opcionalmente guarda usuarios de campaña asignados/nuevos en `admin-users:v1`, envía correos electrónicos a los usuarios de campaña asignados cuando están presentes, activa la reconstrucción cuando está respaldado por GitHub y registra un evento de auditoría.|
|Archivado de campaña por superadministrador|El Worker valida el rol de superadministrador, CSRF, la existencia de la campaña y el estado no activo, luego archiva localmente en desarrollo o despacha `.github/workflows/archive-campaign.yml` en producción; el movimiento de archivado mantiene el código fuente de la campaña y los medios propiedad de la campaña bajo `archive/campaigns/<slug>/`|
|Publicación de configuración de plataforma y complementos de plataforma|El trabajador valida la entrada, escribe en la configuración/activos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y muestra el resultado como un mensaje de la plataforma del panel|
|Cargas de imágenes/vídeo/audio|El trabajador valida los medios, confirma la ruta del activo a través de GitHub y actualiza el campo relevante localmente hasta su publicación.|
|Guardar/editar/eliminar referencias de marketing|Mutación KV en el ámbito de la campaña para códigos de referencia guardados|
|Configuración -> Guardar usuarios|Escritura de KV único a `admin-users:v1`|
|Configuración -> Uso del plan|Llamadas API de proveedor Cloudflare/Resend de solo lectura; escrituras de cero KV u operaciones de lista|
|Secretos y credenciales|Estado de solo lectura solamente; Los valores secretos nunca se muestran, editan, serializan ni publican.|

Las lecturas normales del tablero deben permanecer dentro del presupuesto de escritura KV descrito en `worker/README.md` y cubierto por pruebas.

Las acciones de publicación respaldadas por GitHub requieren que el trabajador implementado tenga configurado `GITHUB_TOKEN` más las variables de metadatos del repositorio. Sin ese token, el panel aún puede explorar, redactar, obtener una vista previa, administrar usuarios en tiempo de ejecución y guardar códigos de referencia, pero las acciones de publicación fallarán con un mensaje de configuración de GitHub. Las acciones de publicación exitosas deberían dejar el botón Publicar desactivado nuevamente una vez que el estado del servidor guardado coincida con el estado del formulario local.

## Pestañas de nivel superior

El orden del panel de nivel superior es:

1. **Configuración**: configuración de plataforma, marca/SEO, precios, impuestos, envío, informes de ejecución, diseño, usuarios, rendimiento, uso del plan, depuración, estado de credenciales y diagnóstico de tiempo de ejecución.
2. **Complementos**: disponibilidad de complementos de la plataforma y detalles del producto, visibles solo para superadministradores.
3. **Campañas**: configuración de campaña con alcance de función, contenido de la página, recompensas, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario, decisiones y blasts de correo para seguidores.
4. **Análisis**: análisis de cartera y campañas derivadas de promesas.
5. **Informes**: vista previa/descarga CSV para informes de compromiso y cumplimiento.
6. **Colaboradores**: navegación, filtrado, clasificación y exportación CSV de los colaboradores según el rol.
7. **Marketing**: creador de URL de referencia, códigos de referencia guardados, códigos QR de campaña descargables y controles del generador de inserción.

## Ajustes

Las configuraciones están agrupadas en una barra lateral izquierda. Los superadministradores pueden editar secciones de configuración publicables y guardar la administración de usuarios solo en tiempo de ejecución por separado.

### Plataforma

Los campos de identidad de la plataforma incluyen título del sitio, nombre de la plataforma, empresa, autor, nombre del creador predeterminado, correo electrónico de soporte, descripción del sitio, URL canónicas del sitio/trabajador, nombres de los remitentes de correo electrónico, modo de aplicación y zona horaria predeterminada de la plataforma. Los campos de URL canónicos se encuentran debajo de Descripción del sitio en la sección Plataforma, uno por columna en ventanas gráficas amplias.

Los campos de remitente de compromiso y actualización deben utilizar dominios autorizados para la clave API de reenvío configurada. Para esta implementación, las confirmaciones de compromiso utilizan `The Pool <pledges@site.example.com>` para que el dominio del remitente coincida con el dominio de reenvío autorizado `site.example.com`.

El campo de zona horaria predeterminado es un menú de selección respaldado por valores de zona horaria admitidos por IANA. Controla los límites de inicio/fecha límite de la campaña, las cuentas regresivas, los informes programados de los ejecutores de la campaña, la automatización del ciclo de vida y las comprobaciones de liquidación. El valor predeterminado sigue siendo `America/Denver` hasta que un superadministrador lo cambia.

### Marca y SEO

Los campos de marca y búsqueda incluyen logotipo, logotipo de pie de página, favicon, imagen social predeterminada, identificador X, texto alternativo de imagen social predeterminada, enlaces iguales y si el centro de la comunidad pública es indexable.

Utilice una URL igual por línea. Utilice URL de perfil público canónico, por ejemplo:

```text
https://www.instagram.com/example
https://www.imdb.com/name/nm0000000/
```

La pila local puede anular `SITE_BASE` y `WORKER_BASE` de `_config.local.yml`, pero `scripts/sync-worker-config.rb` mantiene `CANONICAL_SITE_BASE` y `CANONICAL_WORKER_BASE` fijados a los valores de producción de `_config.yml`. Eso permite que el panel local muestre los objetivos de publicación de producción sin interrumpir las solicitudes de localhost.

### Verificar

El proceso de pago expone la clave publicable de Stripe utilizada por la interfaz de usuario de pago del navegador. Esto no es un secreto, pero debe coincidir con el modo Stripe actual. Las claves secretas y los secretos de firma de webhooks permanecen en secretos de trabajador o en archivos env locales ignorados.

### Precios, impuestos y envío

Los precios cubren los valores de propinas de plataforma no secretas y tarifas fijas predeterminadas. Las secciones de impuestos y envío eligen proveedores y configuraciones de tiempo de ejecución no secretas. Los campos específicos del proveedor son condicionales; por ejemplo, los campos ZIP.TAX deben aparecer solo cuando se selecciona ZIP.TAX, y los campos USPS deben aparecer solo cuando USPS está habilitado.

No almacene claves API ni secretos de proveedores en Configuración. Utilice secretos de trabajador o `.dev.vars` local ignorado.

### Informes del corredor de campaña

La configuración del informe del ejecutor de campaña controla el sistema de informes programados: estado habilitado, hora de envío de la zona horaria de la plataforma, prefijo del asunto, alternancia de informes de compromiso/cumplimiento, inclusión de resumen y comportamiento de archivos adjuntos CSV. Los superadministradores configuran la zona horaria predeterminada de la plataforma en la sección Configuración de la plataforma.

La pestaña Informes sigue siendo la interfaz de usuario preferida del navegador para generar y descargar archivos CSV bajo demanda.

### Rendimiento avanzado

La configuración de rendimiento avanzada expone los controles públicos seguros de captación previa de intenciones:

- habilitar o deshabilitar la captura previa de documentos públicos
- ajuste el retardo de desplazamiento/enfoque antes de que comience la captación previa
- limitar el número de documentos precargados por vista de página

Los valores predeterminados son intencionalmente conservadores y se aplican solo a enlaces de documentos públicos del mismo origen. El tiempo de ejecución excluye los enlaces de administración, pago, gestión de compromiso, comunidad de seguidores, tokenizados, externos y de consultas confidenciales. La publicación de estas configuraciones actualiza `_config.yml`, refleja las variables de trabajo `INTENT_PREFETCH_*` y requiere la reconstrucción estática normal antes de que las páginas públicas usen los nuevos valores.

### Uso del plan

El uso del plan es una sección de solo lectura exclusiva para superadministradores para conocer los límites operativos del proveedor. Se carga automáticamente cuando se abre **Configuración -> Uso del plan** y se actualiza solo cuando el administrador recarga la página.

El trabajador llama a Cloudflare y Resend con credenciales del lado del servidor y devuelve nombres de planes, números de uso, límites, gravedad y enlaces de proveedores desinfectados. Los tokens del proveedor nunca llegan al navegador y el punto final no escribe KV ni enumera los espacios de nombres de KV.

El uso de Cloudflare utiliza `CLOUDFLARE_USAGE_API_TOKEN` o `CLOUDFLARE_ANALYTICS_API_TOKEN` más `CLOUDFLARE_ACCOUNT_ID`. Agregue lectura de facturación al token de uso si la detección automática del plan de trabajadores debería funcionar; de lo contrario, establezca `PLAN_USAGE_CLOUDFLARE_PLAN`. El uso de reenvío utiliza `RESEND_API_KEY`; Existen anulaciones de planes/límites opcionales porque las sondas de reenvío seguras pueden exponer encabezados de límite de velocidad sin encabezados de uso de envío mensual.

### Diseño

La configuración de diseño expone variables seleccionadas del tema, como la fuente del cuerpo, la fuente del título, los colores del texto, los colores de superficie/borde/primarios y el radio del botón.

Los campos de fuentes deben hacer referencia a fuentes ya cargadas por el CSS del sitio. El panel no importa fuentes remotas arbitrarias.

### Usuarios

Los superadministradores pueden crear, editar y eliminar usuarios del panel.

Normas:

- No puede eliminar su propia cuenta de superadministrador.
- No puede degradar su propia cuenta de superadministrador.
- Puede degradar o eliminar a otros superadministradores.
- Los usuarios de la campaña deben tener al menos una campaña asignada.
- Los cambios del usuario se guardan en KV inmediatamente a través del botón Guardar usuarios; no utilizan el botón de publicación de Configuración.
- Los usuarios recién creados reciben instrucciones de inicio de sesión por correo electrónico cuando se configura Reenviar. Las ediciones a usuarios existentes no reenvían el correo electrónico.

### Secretos y credenciales

Esta sección informa el estado configurado/faltante para las credenciales de tiempo de ejecución únicamente. No debe mostrar ni editar valores secretos.

## Complementos de plataforma

La pestaña Complementos administra productos para toda la plataforma que se pueden adjuntar a las promesas independientemente de los ingresos de la campaña.

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
- variantes con etiqueta, ID de solo lectura derivada e inventario

Los complementos digitales ocultan los campos de envío. Los complementos físicos pueden utilizar dimensiones de paquete preestablecidas o explícitas.

## Campañas

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

Campos obligatorios:

- título de la campaña
- uno o más usuarios de la campaña

Los superadministradores pueden crear una campaña sin usuarios de campaña asignados, seleccionar varios usuarios de campaña existentes, elegir **Crear nuevo usuario de campaña** y agregar uno o más usuarios de campaña nuevos con los nombres y correos electrónicos requeridos en el mismo cuadro de diálogo. Los nuevos usuarios se guardan en `admin-users:v1`; Los usuarios de campaña asignados reciben un correo electrónico con reenvío con el enlace del panel de administración cuando se configura la entrega de correo electrónico.

El trabajador deriva el slug del título, escribe `_campaigns/<slug>.md` a través de la ruta de publicación existente de GitHub, establece valores predeterminados de solo vista previa/ocultos para el público, activa la reconstrucción normal y registra un evento de auditoría. El flujo no requiere fechas de lanzamiento, monto objetivo, recompensas, imágenes ni contenido de la página.

### Vista previa protegida

El botón **Vista previa** aparece junto a **Publicar** para el contenido de la campaña. Los superadministradores y los usuarios de campañas asignados pueden publicar una vista previa protegida de las campañas que pueden editar.

Vista previa de publicación:

- valida el alcance de la campaña actual y el token CSRF
- rechaza revisiones de base obsoletas cuando el Markdown de la campaña cambió desde que se cargó el editor
- escribe solo el estado de vista previa en Markdown de la campaña respaldada por GitHub; los correos electrónicos de la vista previa no están confirmados
- almacena el administrador de publicación más la lista de permitidos de revisor opcional en `PLEDGES` KV en `campaign-preview-reviewers:<slug>` con un TTL de 24 horas
- devuelve un enlace de vista previa firmado para el administrador de publicación para que el panel pueda mantenerlo visible después de que se cierre el modal
- Los correos electrónicos invitaban explícitamente a revisores adicionales. Enlaces de vista previa firmados que caducan en 24 horas, y ese vencimiento se indica en la copia del correo electrónico.
- registra un evento de auditoría administrativa

Vista previa de páginas en vivo en `/campaigns/:slug/preview/` y equivalentes localizados. Se generan shells estáticos genéricos para cada slug de campaña, de modo que los enlaces de vista previa enviados por correo electrónico se puedan abrir inmediatamente; el shell no incluye el título de la campaña ni el borrador del contenido. Obtiene una vista previa completa de la página de la campaña de solo lectura a través del Worker con la sesión de administrador actual o un token de revisor válido, carga la hoja de estilo de la campaña y el kit de fuentes, permite incrustaciones de reproductores multimedia aprobados y deshabilita los controles de compromiso. El shell de vista previa estática es `noindex,nofollow,noarchive`, no utiliza metadatos sociales, elimina el token de vista previa de la barra de direcciones después de la carga y permanece fuera de la salida del mapa del sitio público y de la elegibilidad de captación previa pública.

### Configuración de campaña

La configuración de la campaña incluye identidad, fechas, monto objetivo, estado cargado/de solo lectura, correos electrónicos de informes del corredor, anulaciones de envío, medios destacados, imagen del creador, fondos y otros temas de la campaña.

Slug y URL son campos derivados de sólo lectura. Se conservan las babosas de campaña existentes. Para nuevas campañas creadas con repositorios, mantenga la URL del slug segura y estable porque el pago, los informes, los enlaces mágicos y los registros de compromiso dependen de ello.

Los superadministradores ven **Archivar campaña** en la parte inferior de la subpestaña Configuración después de **Fondo de campaña** y **Fondo de progreso** cuando la campaña no está activa actualmente. Los usuarios de la campaña nunca ven este control y las campañas activas lo ocultan por completo. Al archivar se solicita confirmación y luego se saca la campaña del código fuente activo sin eliminar datos. En el desarrollo local, `ADMIN_LOCAL_REPO_WRITES_ENABLED=true` enruta al Worker a través de un helper de repositorio local protegido por token que mueve los archivos del repositorio montado. En producción, el Worker inicia la GitHub Action del repositorio **Archivar campaña**. Ambas rutas mueven `_campaigns/<slug>.md`, los archivos de imagen/video/audio propiedad de la campaña y los medios de add-ons de campaña referenciados a `archive/campaigns/<slug>/`, escriben un `archive-manifest.json` y dejan en su lugar, y enumerados en el manifiesto, los medios todavía referenciados por otras campañas activas.

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

El editor admite controles de inserción de bloques, deshacer con el teclado para cambios de bloques, formato en línea estilo Markdown, enlaces, listas desordenadas/ordenadas, controles de alineación, configuraciones de medios y vista previa móvil. **Guardar borrador** almacena un borrador local del navegador. **Publicar** valida y escribe a través del Trabajador.

Los bloques de vídeo subidos pueden incluir una imagen de póster explícita. Cuando no se establece ningún póster, el panel y la página de la campaña pública generan un póster en el navegador a partir del primer cuadro del video mientras mantienen el video reproducible cargado de forma diferida hasta que el usuario presiona reproducir.

Reglas de seguridad del contenido:

- Prefiera Markdown para el formato en línea.
- Los enlaces de Safe Markdown se conservan.
- Se rechazan los esquemas inseguros como `javascript:` y `data:`.
- La capa de normalización del trabajador rechaza los scripts sin formato, los atributos del controlador de eventos y el HTML no compatible.
- Las incorporaciones estructuradas deben utilizar proveedores aprobados y orígenes confiables exactos.

### Niveles

Los niveles definen los niveles de recompensa de compromiso. Se conservan los ID de nivel existentes; Los nuevos ID se derivan del nombre y se muestran como de solo lectura.

Los niveles físicos pueden utilizar un ajuste preestablecido de envío o metadatos de paquete explícitos. Los niveles digitales ocultan los campos de envío. El límite de cantidad controla la disponibilidad total; Apilable controla si un partidario puede reclamar más de una unidad.

### Artículos de soporte

Los elementos de apoyo son necesidades de financiación de campaña independientes. Se conservan las identificaciones existentes; Los nuevos ID se derivan del nombre y se muestran como de solo lectura.

Los artículos de soporte digital ocultan los campos de envío. Los artículos de soporte físico pueden utilizar ajustes preestablecidos de envío y metadatos de paquetes.

### Complementos de campaña

Los complementos de campaña son productos opcionales adjuntos a una sola campaña. Siguen el mismo modelo de producto/variante que los complementos de la plataforma, pero contribuyen a la contabilidad de la campaña en lugar de a los ingresos de los complementos de la plataforma.

### Metas extendidas

Los objetivos ampliados definen hitos de financiación con umbrales, títulos, descripciones y estado de visualización.

### Artículos en curso

Los elementos continuos definen las necesidades de soporte posteriores a la campaña o continuas que se muestran en la plantilla de campaña.

### Entradas del diario

Las entradas del diario son actualizaciones de la campaña ordenadas primero por las más recientes. Cada entrada incluye título, fecha/hora, fase y su propio editor de contenido WYSIWYG. El contenido del diario utiliza el mismo modelo de bloque de contenido que la pestaña Contenido de la campaña.

### Decisiones

Las decisiones definen las indicaciones de voto/encuesta de los seguidores. `vote` significa que el resultado está destinado a decidir un resultado; `poll` significa que el resultado son comentarios de los seguidores. Ambos usan la misma opción y cuentan el flujo actual.

El estado es de solo lectura y se deriva de la fecha límite. La elegibilidad se limita a los partidarios de la campaña o a los partidarios de la campaña cobrados.

## Informes

Los informes pueden obtener una vista previa y descargar exportaciones CSV estándar para las campañas a las que puede acceder el administrador que ha iniciado sesión.

Tipos de informes admitidos:

- informe de compromiso
- informe de cumplimiento

La interfaz de usuario del informe del navegador está orientada a la descarga. No necesita controles manuales de envío de correo electrónico ni de marcación como enviado.

## Partidarios

La pestaña Partidarios muestra filas de seguidores con alcance de rol con filtrado en vivo, clasificación, alcance de campaña, montos en centavos de dólar exactos y exportación CSV para el conjunto de resultados actualmente visible. Los superadministradores pueden elegir **Todas** las campañas; Los usuarios de la campaña pueden elegir entre las campañas asignadas.

## Analítica

Los análisis se derivan de índices de compromisos y resúmenes de campañas existentes. No debería crear escrituras KV específicas de análisis en la vista.

El panel muestra tarjetas con los totales de promesas, categorías de ingresos, ingresos netos después de las tarifas de procesador asignadas, impuestos, envío, tarifas de Stripe, estado de la promesa, patrocinadores, promesa promedio, complementos de campaña, atribución de referencia, UTM source/medium/campaign/content, tipo de cumplimiento, idioma y otros desgloses derivados de la promesa. Los valores monetarios muestran centavos exactos.

Si a una campaña le falta su proyección `campaign-pledges:<slug>`, Analytics permanece en modo de solo lectura, devuelve una fila de campaña en cero y muestra un aviso no bloqueante de índice faltante en lugar de listar la verdad de promesas o fallar la pestaña Marketing.

Los ingresos brutos de la campaña y los ingresos de la plataforma permanecen visibles para la conciliación. Los ingresos netos de la campaña y los ingresos netos de la plataforma restan la parte asignada a cada categoría de las tarifas reales del procesador de Stripe cuando existen datos de transacciones de saldo almacenados. Las promesas activas y las filas de promesas cargadas más antiguas sin datos reales del saldo de Stripe continúan utilizando la estimación de planificación estándar. Los reabastecimientos exclusivos de superadministradores pueden recuperar de forma segura datos históricos de transacciones de saldo de Stripe sin escaneos de listas KV a través de `POST /admin/analytics/stripe-financials/backfill`.

## Marketing

La pestaña Marketing crea URL de campaña con parámetros UTM y de referencia, muestra los controles de vista previa/descarga de QR junto a la salida de URL, guarda códigos de referencia, expone la interfaz de usuario del generador de inserción, carga/guarda un borrador compartido de campaña y muestra la salud de recordatorios de checkout abandonado para la campaña seleccionada. El rendimiento de referencias y UTM vive en Analytics para que los informes de campaña permanezcan en un solo lugar.

Tienda de códigos de referencia guardados:

- nombre de referencia
- código de referencia
- URL generada
- metadatos de fuente QR para la URL generada
- marca de tiempo de creación

El creador de URL se borra después de guardar y actualizar. Los guardados, ediciones y eliminaciones de referencias son mutaciones KV explícitas.

Los códigos QR se generan en el navegador a partir de la salida actual del creador de URL de campaña o de una URL de referencia guardada, incluidos parámetros de referencia y UTM. La vista previa actual del creador se actualiza sin llamadas al Worker, y las descargas PNG/SVG son descargas locales del navegador. Las acciones de vista previa y descarga de QR no leen ni escriben KV.

Los borradores compartidos de Marketing son explícitos: los usuarios hacen clic en **Cargar borrador compartido**, **Guardar borrador compartido** o **Borrar borrador compartido**. Un borrador es un registro KV con alcance de campaña, TTL de 7 días y token de revisión para que los guardados obsoletos fallen con conflicto en lugar de sobrescribir el trabajo de otro admin. Cargar es de solo lectura; guardar o borrar son las únicas escrituras de borrador.

El panel de checkout abandonado muestra salud de recordatorios con alcance de campaña desde contadores agregados de cola/resultados y resultados recientes sin listar KV. Los resultados de supresión creados por admins incluyen el correo suprimido para que los admins puedan borrar esa supresión desde la tabla de resultados recientes; las mutaciones de supresión siguen ocurriendo solo mediante acción explícita y no incluyen una acción de reintentar este carrito específico.

## Blast

Campaigns -> Blast envía correos a seguidores para la campaña seleccionada sin agregar otra vista de nivel superior del panel. Los usuarios de campaña pueden enviar blasts para campañas asignadas, y los superadministradores pueden enviar para cualquier campaña. Los borradores de Blast permanecen locales en el navegador salvo que un admin use explícitamente los botones de borrador compartido; los borradores compartidos de Blast usan el mismo modelo KV de 7 días, protegido por revisión y con alcance de campaña que los borradores de Marketing. Blast reutiliza el editor WYSIWYG de campaña para encabezados, texto, citas, listas, enlaces, imágenes de campaña alojadas subidas, imágenes de campaña existentes del selector de medios y enlaces de video YouTube/Vimeo listos para correo. El panel sube automáticamente las imágenes provisionales de Blast por la misma ruta de carga de medios de campaña que usan Content y diary antes de la prueba, de modo que los archivos quedan confirmados bajo `assets/images/campaigns/<slug>/` y en cola para optimización de medios del repositorio antes de construir la carga del correo. El panel ejecuta automáticamente la validación de prueba antes de Enviar prueba o Enviar blast; los fallos de carga o audiencia explican el motivo antes de intentar enviar correo.

Las pruebas validan el mensaje, calculan el conteo de audiencia indexada y devuelven un hash de prueba sin escrituras de rate limit, auditoría, envíos de correo ni listas KV. Los envíos de prueba van solo al admin con sesión iniciada. Los envíos reales requieren el hash de prueba correspondiente para el mensaje y la audiencia exactos, envían mediante el remitente compartido de actualizaciones de Resend y escriben un evento de auditoría después del despacho. La pestaña Blast muestra historial de envíos de solo lectura desde eventos recientes de auditoría, incluido asunto, contenido, CTA Button Label y CTA Button URL.

El renderizado de correo de Blast solo incluye imágenes alojadas del sitio desde `/assets/images/...`; las URL arbitrarias de imágenes remotas se omiten del lado del servidor. Los bloques de YouTube y Vimeo se renderizan como enlaces/botones seguros para correo en lugar de iframes o embeds de video, porque la mayoría de clientes de correo bloquean reproductores embebidos.

Si falta `campaign-pledges:<slug>`, las pruebas y envíos de Blast fallan cerrados con `campaign_index_required`; reconstruya el índice de campaña antes de enviar. Esto evita recurrir a escaneos de espacios de nombres de promesas en una ruta de operador que puede ejecutarse en producción.

## Medios de comunicación

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
- Vídeo heroico: carga directa MP4/WebM/MOV de hasta 100 MB, o una URL de YouTube/Vimeo

El editor de contenido de la campaña, los editores de contenido de entrada del diario y los bloques de imagen de Blast colocan primero los medios seleccionados en el navegador. El bloque muestra la imagen, el vídeo o la selección de audio seleccionados inmediatamente, pero el archivo no se carga hasta que el usuario publica contenido o envía/prueba un Blast. Durante la publicación o el envío de Blast, el panel carga medios preparados en el directorio de activos de la campaña, reemplaza la vista previa temporal del navegador con la ruta final `/assets/...` y luego confirma el YAML de la campaña o construye la carga del correo Blast.

Los bloques de imagen en Campaign Content, Diary y Blast también pueden elegir una imagen existente desde un diálogo de biblioteca de medios con alcance. El selector lista archivos de imagen existentes respaldados por GitHub bajo `assets/images/campaigns/<slug>/`; los superadministradores también pueden elegir archivos compartidos/predeterminados bajo `assets/images/defaults/`. El selector es de solo lectura, no agrega estado KV y establece directamente la ruta del bloque de imagen. El campo Source URL sigue disponible para reparación o edición avanzada de rutas.

Las cargas de medios relacionadas con la campaña requieren acceso a esa campaña. Los superadministradores pueden cargar cualquier medio de campaña y plataforma/medio predeterminado; Los administradores de campañas solo pueden cargar medios para las campañas que administran. Las cargas de complementos de plataforma y marcas de plataforma siguen siendo solo para superadministradores.

Cuando se elimina un bloque de medios de contenido publicado, o se elimina una entrada del diario con bloques de medios, el Trabajador compara los datos de la campaña anterior con el borrador normalizado que se está confirmando. Los archivos propiedad del panel que se encuentran en los mismos directorios de medios de la campaña se eliminan de GitHub cuando ya no se hace referencia a ellos en ningún otro lugar de esa campaña. Se conservan las URL externas, los recursos compartidos/predeterminados y los medios de campaña a los que todavía hace referencia otro bloque o campo.

El punto final de carga del trabajador preserva el origen. Valida el tipo, tamaño, alcance de la campaña, directorio y nombre de archivo, pero no ejecuta optimizadores de imágenes nativos ni FFmpeg. Para cargas de imágenes y videos, el trabajador envía el flujo de trabajo **Optimizar medios del panel** de acciones de GitHub con `scope=changed` después de que la confirmación de GitHub se realice correctamente. La compresión de imágenes sin pérdidas y la transcodificación de vídeo aún se ejecutan fuera del Worker a través del canal de medios del repositorio.

Los movimientos de archivado de campaña se realizan del lado del repositorio por el mismo motivo. En desarrollo local, el Worker llama al helper de repositorio local cuando `ADMIN_LOCAL_REPO_WRITES_ENABLED=true`; en producción, el panel despacha el flujo de trabajo **Archivar campaña** después de la autorización del superadministrador, y el flujo de trabajo valida el slug antes de mover el código fuente de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/`.

Utilice `npm run media:optimize` localmente o envíe manualmente el flujo de trabajo cuando vuelva a intentar la optimización, revise los cambios de medios del repositorio o procese archivos fuera de la ruta de carga del panel. Si la máquina host no tiene instalados los optimizadores nativos, use `npm run media:optimize:podman` para ejecutar el mismo script dentro de la imagen del sitio Podman con `optipng`, `gifsicle`, `libjpeg-turbo-progs`, `webp` y `ffmpeg`. Utilice `npm run media:optimize:check` o `npm run media:optimize:check:podman` cuando revise una rama con muchos medios y desee fallar en optimizaciones de imágenes pendientes, variantes WebP responsivas o derivados de video faltantes. La canalización optimiza las imágenes en su lugar cuando el resultado optimizado es más pequeño, genera variantes de imagen `.webp` responsivas para plantillas públicas en `320w`, `480w`, `640w`, `960w` y `1600w`, genera derivados de `.webm` de alta calidad junto a los archivos MP4/MOV cargados y reescribe `_campaigns` literal. / `_config.yml` hace referencia del vídeo fuente subido al derivado WebM generado. Las imágenes y los vídeos originales permanecen en el repositorio para revertirlos y volver a codificarlos en el futuro. Utilice la opción manual `scope=all` del flujo de trabajo cuando los medios existentes implementados necesiten un reprocesamiento completo.

Utilice texto alternativo significativo para imágenes que comuniquen contenido. Los fondos decorativos pueden utilizar texto alternativo vacío en las plantillas públicas.

## Barandillas de seguridad y accesibilidad

El panel sigue estas reglas del proyecto:

- Los controles del navegador son ayudas de usabilidad; La validación del trabajador es autorizada.
- Todas las mutaciones requieren una sesión de administrador válida y un encabezado CSRF.
- El alcance de las funciones y las campañas se aplica en el lado del servidor.
- Los secretos nunca se almacenan en `_config.yml`, campaña YAML, borradores de paneles, registros de usuarios de KV o confirmaciones de GitHub.
- Los correos electrónicos de acceso a vista previa se almacenan solo en listas permitidas de Worker KV de corta duración, no en Markdown de campaña, JSON público, salida de mapa del sitio ni metadatos de página generados.
- Se deben utilizar componentes de ayuda/etiqueta de administrador compartidos para los campos nuevos.
- El editor oculto Chrome no debería ser accesible mediante el teclado.
- Las tablas ordenables deben exponer `aria-sort`.

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

### Los informes, los partidarios o los análisis muestran mensajes de índice que faltan

Los puntos finales de lectura del panel se basan en índices `campaign-pledges:{slug}` e intencionalmente no recurren a costosos escaneos de espacios de nombres. Ejecute las herramientas de reparación/reconstrucción de proyección explícitamente cuando a una campaña antigua le falte su índice.

---
