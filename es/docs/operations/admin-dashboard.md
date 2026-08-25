---
title: Panel de administración
parent: Operaciones
nav_order: 1
render_with_liquid: false
lang: es
---

# Panel de administración

## Última actualización

25 de agosto de 2026

Este documento es la referencia del operador y la fuente de verdad para The Pool.
edición de campañas, informes, análisis y marketing privados basados en paneles de control
enlaces, complementos y gestión de usuarios.

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
|Publicación del contenido/configuración de la campaña|El trabajador valida la entrada, escribe en archivos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y registra un evento de auditoría.|
|Publicación de vista previa protegida|El trabajador valida el alcance de la campaña y la revisión base, escribe solo indicadores de vista previa en Markdown de la campaña respaldada por GitHub, almacena el administrador de publicación más los correos electrónicos del revisor opcional en `PLEDGES` KV en `campaign-preview-reviewers:<slug>` con un TTL de 24 horas, devuelve un enlace firmado visible en el panel para el editor, envía enlaces firmados a revisores opcionales y registra un evento de auditoría|
|Creación de campaña de superadministrador|El trabajador crea un archivo `_campaigns/<slug>.md` de solo vista previa localmente en desarrollo o a través de GitHub en producción, opcionalmente guarda usuarios de campaña asignados/nuevos en `admin-users:v1`, envía correos electrónicos a los usuarios de campaña asignados cuando están presentes, activa la reconstrucción cuando está respaldado por GitHub y registra un evento de auditoría.|
|Archivo de campaña de superadministrador|El trabajador valida la función de superadministrador, CSRF, la existencia de la campaña y el estado no activo, luego archiva localmente en desarrollo o envía `.github/workflows/archive-campaign.yml` en producción; la medida de archivo mantiene la fuente de la campaña y los medios propiedad de la campaña bajo `archive/campaigns/<slug>/`|
|Publicación de configuración de plataforma y complementos de plataforma|El trabajador valida la entrada, escribe en la configuración/activos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y muestra el resultado como un mensaje de la plataforma del panel|
|Cargas de imágenes/vídeo/audio|El trabajador valida los medios, confirma la ruta del activo a través de GitHub y actualiza el campo relevante localmente hasta su publicación.|
|Guardar/editar/eliminar referencias de marketing|Mutación KV en el ámbito de la campaña para códigos de referencia guardados|
|Configuración -> Guardar usuarios|Escritura de KV único a `admin-users:v1`|
|Configuración -> Uso del plan|Llamadas API de proveedor Cloudflare/Resend de solo lectura; escrituras de cero KV u operaciones de lista|
|Configuración -> Temporización de diagnóstico en tiempo de ejecución|Resúmenes de observabilidad acotados de solo lectura; cero nuevos almacenes de telemetría y ninguna carga útil de solicitud/cliente|
|Configuración -> Sesiones de administrador|Revisión de sesión activa/reciente de solo lectura; la revocación elimina una sesión exacta y registra un evento de auditoría limitado|
|Configuración -> Registro de auditoría|Búsqueda KV filtrada de solo lectura; La exportación CSV utiliza los mismos filtros y permanece privada/sin almacenamiento|
|Secretos y credenciales|Estado de solo lectura solamente; Los valores secretos nunca se muestran, editan, serializan ni publican.|

Las lecturas normales del tablero deben permanecer dentro del presupuesto de escritura KV descrito en `worker/README.md` y cubierto por pruebas.

Las acciones de publicación respaldadas por GitHub requieren que el Worker implementado tenga `GITHUB_TOKEN` más las variables de metadatos del repositorio configurados. Sin ese token, el panel aún puede explorar, redactar, obtener una vista previa, administrar usuarios en tiempo de ejecución y guardar códigos de referencia, pero las acciones de publicación fallarán con un mensaje de configuración GitHub. Las acciones de publicación exitosas dejan el botón Publicar desactivado nuevamente una vez que el estado del servidor guardado coincide con el estado del formulario local.

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

La barra lateral utiliza el orden compartido entre proyectos donde los productos se superponen.
The Pool pliega los campos separados **URL canónicas** en **Plataforma** y utiliza
**Informes del corredor de campaña** en la costura de marketing global. El esquema Worker
mantiene **Complementos de plataforma** en el punto de preparación, mientras que el navegador los dirige a
La pestaña **Complementos** de nivel superior de The Pool en lugar de duplicarla en Configuración
barra lateral. La automatización del navegador cubre el orden visible y el contrato de configuración.
La prueba cubre el pedido Worker completo:

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

### Informes del corredor de campaña

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

**Exportar filtrado CSV** reutiliza los filtros activos y la ruta de descarga privada/sin tienda autenticada. Los filtros se redistribuyen dentro de su tarjeta de configuración y las filas de auditoría se convierten en tarjetas de registro etiquetadas en pantallas estrechas en lugar de ampliar la página. Las celdas CSV que comienzan como fórmulas de hoja de cálculo tienen formato de escape. Trate las exportaciones como registros operativos privados: pueden contener detalles de auditoría adicionales almacenados y no deben adjuntarse a cuestiones públicas ni revelar evidencia sin revisión.

### Diseño

La configuración de diseño expone variables seleccionadas del tema, como la fuente del cuerpo, la fuente del encabezado, los colores del texto, los colores de superficie/borde/primarios y el radio del botón.

Los campos de fuentes deben hacer referencia a fuentes ya cargadas por el CSS del sitio. El panel no importa fuentes remotas arbitrarias.

### Usuarios

Los superadministradores pueden crear, editar y eliminar usuarios del panel.

Normas:

- No puede eliminar su propia cuenta de superadministrador.
- No puede degradar su propia cuenta de superadministrador.
- Puede degradar o eliminar a otros superadministradores.
- Los usuarios de la campaña deben tener al menos una campaña asignada.
- Los cambios del usuario se guardan en KV inmediatamente a través del botón Guardar usuarios; no utilizan el botón de publicación de Configuración.
- Los usuarios recién creados reciben instrucciones de inicio de sesión por correo electrónico cuando se configura Resend. Las ediciones a usuarios existentes no reenvían el correo electrónico.

### Secretos y credenciales

Esta sección informa el estado configurado/faltante para las credenciales de tiempo de ejecución únicamente. No debe mostrar ni editar valores secretos.

## Límite del panel de control entre proyectos

El panel Store es una fuente de patrones operativos reutilizables, no un segundo
modelo de producto. El mapeo The Pool actual es:

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

Al reutilizar otro patrón de administración de Dust Wave, use la autenticación, solicitud y autenticación existentes de The Pool.
ayudantes de estado, tabla, localización, configuración y prueba; no introducir
Almacenamiento con nombre Store o fuentes de verdad exclusivas del navegador.

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

Los superadministradores pueden crear una campaña sin usuarios de campaña asignados, seleccionar varios usuarios de campaña existentes, elegir **Crear nuevo usuario de campaña** y agregar uno o más usuarios de campaña nuevos con los nombres y correos electrónicos requeridos en el mismo cuadro de diálogo. Los nuevos usuarios se guardan en `admin-users:v1`; Los usuarios de campaña asignados reciben un correo electrónico con tecnología Resend con el enlace del panel de administración cuando se configura la entrega de correo electrónico.

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

Vista previa de páginas en vivo en `/campaigns/:slug/preview/` y equivalentes localizados. Se generan shells estáticos genéricos para cada slug de campaña, de modo que los enlaces de vista previa enviados por correo electrónico se puedan abrir inmediatamente; el shell no incluye el título de la campaña ni el borrador del contenido. Obtiene una vista previa completa de la página de la campaña de solo lectura a través del Worker con la sesión de administrador actual o un token de revisor válido, carga la hoja de estilo de la campaña y el kit de fuentes, permite incrustaciones de reproductores multimedia aprobados y deshabilita los controles de aporte. El shell de vista previa estática es `noindex,nofollow,noarchive`, no utiliza metadatos sociales, elimina el token de vista previa de la barra de direcciones después de la carga y permanece fuera de la salida del mapa del sitio público y de la elegibilidad de captación previa pública.

### Configuración de campaña

La configuración de la campaña incluye identidad, fechas, monto objetivo, estado cargado/de solo lectura, correos electrónicos de informes del corredor, anulaciones de envío, medios destacados, imagen del creador, fondos y otros temas de la campaña.

Slug y URL son campos derivados de sólo lectura. Se conservan las babosas de campaña existentes. Para nuevas campañas creadas con repositorios, mantenga la URL del slug segura y estable porque el pago, los informes, los enlaces mágicos y los registros de aporte dependen de ello.

Los superadministradores ven **Archivar campaña** en la parte inferior de la subpestaña Configuración después de **Fondo de campaña** y **Fondo de progreso** cuando la campaña no está activa actualmente. Los usuarios de la campaña nunca ven este control y las campañas activas lo ocultan por completo. Al archivar se solicita confirmación y luego se saca la campaña de la fuente activa sin eliminar datos. En el desarrollo local, `ADMIN_LOCAL_REPO_WRITES_ENABLED=true` enruta al trabajador a través de un asistente de repositorio local protegido por token que mueve los archivos de repositorio montados. En producción, el trabajador inicia el repositorio **Campaña de archivo** Acción de GitHub. Ambas rutas mueven `_campaigns/<slug>.md`, los archivos de imagen/video/audio propiedad de la campaña y los medios complementarios de la campaña a los que se hace referencia a `archive/campaigns/<slug>/`, escriben un `archive-manifest.json` y dejan los medios todavía referenciados por otras campañas activas en su lugar y enumerados en el manifiesto.

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

Los niveles definen los niveles de recompensa de aporte. Se conservan los ID de nivel existentes; Los nuevos ID se derivan del nombre y se muestran como de solo lectura.

Los niveles físicos pueden utilizar un ajuste preestablecido de envío o metadatos de paquete explícitos. Los niveles digitales ocultan los campos de envío. El límite de cantidad controla la disponibilidad total; Apilable controla si un patrocinador puede reclamar más de una unidad.

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

Las decisiones definen las indicaciones de voto/encuesta de los patrocinadores. `vote` significa que el resultado está destinado a decidir un resultado; `poll` significa que el resultado son comentarios de los patrocinadores. Ambos usan la misma opción y cuentan el flujo actual.

El estado es de solo lectura y se deriva de la fecha límite. La elegibilidad se limita a los patrocinadores de la campaña o a los patrocinadores de la campaña cobrados.

## Informes

Los informes pueden obtener una vista previa y descargar exportaciones CSV estándar para las campañas a las que puede acceder el administrador que ha iniciado sesión.

Tipos de informes admitidos:

- informe de aporte
- informe de cumplimiento

La interfaz de usuario del informe del navegador está orientada a la descarga. No necesita controles manuales de envío de correo electrónico ni de marcación como enviado.

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

El editor de contenido de la campaña, los editores de contenido de entrada del diario y los bloques de imágenes Blast presentan primero los medios seleccionados en el navegador. El bloque muestra la imagen, el vídeo o la selección de audio seleccionados inmediatamente, pero el archivo no se carga hasta que el usuario publica el contenido o envía/prueba un Blast. Durante la publicación o el envío Blast, el panel carga medios preparados en el directorio de activos de la campaña, reemplaza la vista previa temporal del navegador con la ruta final `/assets/...` y luego confirma el YAML de la campaña o crea la carga útil de correo electrónico Blast.

Los bloques Contenido de campaña, Diario y Blast pueden elegir imágenes existentes, videos/pósteres locales y audio desde el cuadro de diálogo de la biblioteca multimedia con alcance. Búsqueda, pestañas de imagen/vídeo/audio, clasificación reciente/nombre, miniaturas, dimensiones/duración/tamaño de archivo, campaña/alcance compartido, ubicaciones de referencia, estado de optimización, advertencias de ubicación y referencias rotas provienen del manifiesto de medios reconstruible registrado. Los derivados responsivos generados se describen en su tarjeta de origen en lugar de aparecer como opciones independientes. La URL de origen permanece disponible solo para reparación o edición avanzada de rutas, y el selector no agrega ningún estado de medios KV.

Los bloques de imágenes significativos requieren texto alternativo. Marque una imagen puramente decorativa explícitamente para conservar el texto alternativo vacío; No utilice el modo decorativo para evitar describir el contenido de la campaña. Las ubicaciones comunes de héroe, galería, nivel, Blast y carteles muestran presupuestos de tamaño/dimensión de archivo de asesoramiento.

El reemplazo seguro se limita a la misma campaña, directorio de activos y tipo de medio, y requiere el SHA de contenido GitHub actual para que las ediciones obsoletas fallen en lugar de sobrescribir el trabajo más nuevo. El reemplazo mantiene estable el camino y muestra referencias conocidas antes de la mutación. Los usuarios de la campaña pueden enviar optimización de archivos modificados; La optimización del repositorio completo sigue siendo solo para superadministradores.

Las cargas de medios relacionadas con la campaña requieren acceso a esa campaña. Los superadministradores pueden cargar cualquier medio de campaña y plataforma/medio predeterminado; Los administradores de campañas solo pueden cargar medios para las campañas que administran. Las cargas de complementos de plataforma y marcas de plataforma siguen siendo solo para superadministradores.

Cuando se elimina un bloque de medios de contenido publicado, o se elimina una entrada del diario con bloques de medios, el Trabajador compara los datos de la campaña anterior con el borrador normalizado que se está confirmando. Los archivos propiedad del panel que se encuentran en los mismos directorios de medios de la campaña se eliminan de GitHub cuando ya no se hace referencia a ellos en ningún otro lugar de esa campaña. Se conservan las URL externas, los recursos compartidos/predeterminados y los medios de campaña a los que todavía hace referencia otro bloque o campo.

El punto final de carga del trabajador preserva el origen. Valida el tipo, tamaño, alcance de la campaña, directorio y nombre de archivo, pero no ejecuta optimizadores de imágenes nativos ni FFmpeg. Para cargas de imágenes y videos, el trabajador envía el flujo de trabajo **Optimizar medios del panel** de acciones de GitHub con `scope=changed` después de que la confirmación de GitHub se realice correctamente. La compresión de imágenes sin pérdidas y la transcodificación de vídeo aún se ejecutan fuera del Worker a través del canal de medios del repositorio.

Los movimientos de archivos de campaña se realizan en el lado del repositorio por el mismo motivo. En desarrollo local, el trabajador llama al asistente de repositorio local cuando `ADMIN_LOCAL_REPO_WRITES_ENABLED=true`; En producción, el panel envía el flujo de trabajo **Archivar campaña** después de la autorización del superadministrador, y el flujo de trabajo valida el slug antes de mover la fuente de la campaña y los medios propiedad de la campaña a `archive/campaigns/<slug>/`.

Utilice `npm run media:optimize` localmente o envíe manualmente el flujo de trabajo cuando vuelva a intentar la optimización, revise los cambios de medios del repositorio o procese archivos fuera de la ruta de carga del panel. `npm run media:manifest` reconstruye sólo `_data/media-optimization-manifest.json`; nunca procesa binarios. Si la máquina host no tiene instalados los optimizadores nativos, use `npm run media:optimize:podman` para ejecutar el mismo script dentro de la imagen del sitio Podman con `optipng`, `gifsicle`, `libjpeg-turbo-progs`, `webp` y `ffmpeg`. Utilice `npm run media:optimize:check` o `npm run media:optimize:check:podman` cuando revise una rama con muchos medios y desee fallar en optimizaciones de imágenes pendientes, variantes WebP responsivas, derivados de video faltantes o un manifiesto obsoleto. La canalización optimiza las imágenes en su lugar cuando el resultado optimizado es más pequeño, genera variantes de imágenes `.webp` responsivas para plantillas públicas en `320w`, `480w`, `640w`, `960w` y `1600w`, genera derivados de `.webm` de alta calidad junto a los archivos MP4/MOV cargados y reescribe textos literales. `_campaigns` / `_config.yml` hace referencia desde el vídeo fuente subido al derivado WebM generado. Las imágenes y los vídeos originales permanecen en el repositorio para revertirlos y volver a codificarlos en el futuro. Utilice la opción manual `scope=all` del flujo de trabajo cuando los medios existentes implementados necesiten un reprocesamiento completo.

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
