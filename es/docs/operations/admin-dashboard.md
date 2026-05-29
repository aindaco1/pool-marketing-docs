---
title: Panel de administración
parent: Operaciones
nav_order: 1
render_with_liquid: false
lang: es
---

# Panel de administración

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
|Publicación de configuración de plataforma y complementos de plataforma|El trabajador valida la entrada, escribe en la configuración/activos respaldados por GitHub, activa la ruta normal de reconstrucción/implementación y muestra el resultado como un mensaje de la plataforma del panel|
|Cargas de imágenes/vídeo/audio|El trabajador valida los medios, confirma la ruta del activo a través de GitHub y actualiza el campo relevante localmente hasta su publicación.|
|Guardar/editar/eliminar referencias de marketing|Mutación KV en el ámbito de la campaña para códigos de referencia guardados|
|Configuración -> Guardar usuarios|Escritura de KV único a `admin-users:v1`|
|Secretos y credenciales|Estado de solo lectura solamente; Los valores secretos nunca se muestran, editan, serializan ni publican.|

Las lecturas normales del tablero deben permanecer dentro del presupuesto de escritura KV descrito en `worker/README.md` y cubierto por pruebas.

Las acciones de publicación respaldadas por GitHub requieren que el trabajador implementado tenga configurado `GITHUB_TOKEN` más las variables de metadatos del repositorio. Sin ese token, el panel aún puede explorar, redactar, obtener una vista previa, administrar usuarios en tiempo de ejecución y guardar códigos de referencia, pero las acciones de publicación fallarán con un mensaje de configuración de GitHub. Las acciones de publicación exitosas deberían dejar el botón Publicar desactivado nuevamente una vez que el estado del servidor guardado coincida con el estado del formulario local.

## Pestañas de nivel superior

El orden del panel de nivel superior es:

1. **Configuración**: configuración de plataforma, marca/SEO, precios, impuestos, envío, informes de ejecución, diseño, usuarios, rendimiento, depuración, estado de credenciales y diagnóstico de tiempo de ejecución.
2. **Complementos**: disponibilidad de complementos de la plataforma y detalles del producto, visibles solo para superadministradores.
3. **Campañas**: configuración de campaña con alcance de función, contenido de la página, recompensas, complementos de campaña, objetivos ambiciosos, elementos en curso, entradas del diario y decisiones.
4. **Análisis**: análisis de cartera y campañas derivadas de promesas.
5. **Informes**: vista previa/descarga CSV para informes de compromiso y cumplimiento.
6. **Colaboradores**: navegación, filtrado, clasificación y exportación CSV de los colaboradores según el rol.
7. **Marketing**: creador de URL de referencia, códigos de referencia guardados, fragmentos de lanzamiento y controles del generador de inserción.

## Ajustes

Las configuraciones están agrupadas en una barra lateral izquierda. Los superadministradores pueden editar secciones de configuración publicables y guardar la administración de usuarios solo en tiempo de ejecución por separado.

### Plataforma

Los campos de identidad de la plataforma incluyen título del sitio, nombre de la plataforma, empresa, autor, nombre del creador predeterminado, correo electrónico de soporte, descripción del sitio, nombres de los remitentes del correo electrónico y modo de aplicación.

Los campos de remitente de compromiso y actualización deben utilizar dominios autorizados para la clave API de reenvío configurada. Para esta implementación, las confirmaciones de compromiso utilizan `The Pool <pledges@site.example.com>` para que el dominio del remitente coincida con el dominio de reenvío autorizado `site.example.com`.

### Marca y SEO

Los campos de marca y búsqueda incluyen logotipo, logotipo de pie de página, favicon, imagen social predeterminada, identificador X, texto alternativo de imagen social predeterminada, enlaces iguales y si el centro de la comunidad pública es indexable.

Utilice una URL igual por línea. Utilice URL de perfil público canónico, por ejemplo:

```text
https://www.instagram.com/example
https://www.imdb.com/name/nm0000000/
```

### URL canónicas

Los campos de URL canónicos controlan el sitio de producción y los orígenes de los trabajadores utilizados en los enlaces generados, los metadatos, la configuración del tiempo de ejecución del administrador y las expectativas de CORS de los trabajadores.

La pila local puede anular `SITE_BASE` y `WORKER_BASE` de `_config.local.yml`, pero `scripts/sync-worker-config.rb` mantiene `CANONICAL_SITE_BASE` y `CANONICAL_WORKER_BASE` fijados a los valores de producción de `_config.yml`. Eso permite que el panel local muestre los objetivos de publicación de producción sin interrumpir las solicitudes de localhost.

### Verificar

El proceso de pago expone la clave publicable de Stripe utilizada por la interfaz de usuario de pago del navegador. Esto no es un secreto, pero debe coincidir con el modo Stripe actual. Las claves secretas y los secretos de firma de webhooks permanecen en secretos de trabajador o en archivos env locales ignorados.

### Precios, impuestos y envío

Los precios cubren los valores de propinas de plataforma no secretas y tarifas fijas predeterminadas. Las secciones de impuestos y envío eligen proveedores y configuraciones de tiempo de ejecución no secretas. Los campos específicos del proveedor son condicionales; por ejemplo, los campos ZIP.TAX deben aparecer solo cuando se selecciona ZIP.TAX, y los campos USPS deben aparecer solo cuando USPS está habilitado.

No almacene claves API ni secretos de proveedores en Configuración. Utilice secretos de trabajador o `.dev.vars` local ignorado.

### Informes del corredor de campaña

La configuración del informe del ejecutor de campaña controla el sistema de informes programados: estado habilitado, hora de envío de Mountain Time, prefijo de asunto, alternancia de informes de compromiso/cumplimiento, inclusión de resumen y comportamiento de archivos adjuntos CSV.

La pestaña Informes sigue siendo la interfaz de usuario preferida del navegador para generar y descargar archivos CSV bajo demanda.

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

### Configuración de campaña

La configuración de la campaña incluye identidad, fechas, monto objetivo, estado cargado/de solo lectura, correos electrónicos de informes del corredor, anulaciones de envío, medios destacados, imagen del creador, fondos y otros temas de la campaña.

Slug y URL son campos derivados de sólo lectura. Se conservan las babosas de campaña existentes. Para nuevas campañas creadas con repositorios, mantenga la URL del slug segura y estable porque el pago, los informes, los enlaces mágicos y los registros de compromiso dependen de ello.

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

El editor admite comandos de barra diagonal, deshacer con el teclado para cambios de bloques, formato en línea estilo Markdown, enlaces, listas desordenadas/ordenadas, controles de alineación, configuraciones de medios y vista previa móvil. **Guardar borrador** almacena un borrador local del navegador. **Publicar** valida y escribe a través del Trabajador.

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

El panel muestra tarjetas con los totales de promesas, categorías de ingresos, impuestos, envío, tarifas de Stripe, estado de la promesa, patrocinadores, promesa promedio, complementos de campaña, atribución de referencia, fuente UTM, tipo de cumplimiento, idioma y otros desgloses derivados de la promesa. Los valores monetarios muestran centavos exactos.

Las tarifas de Stripe utilizan la tarifa de transacción del saldo de Stripe/los valores netos reales almacenados para las promesas cobradas cuando estén disponibles. Las promesas activas y las filas de promesas cargadas más antiguas sin datos reales del saldo de Stripe continúan utilizando la estimación de planificación estándar. Los reabastecimientos exclusivos de superadministradores pueden recuperar de forma segura datos históricos de transacciones de saldo de Stripe sin escaneos de listas KV a través de `POST /admin/analytics/stripe-financials/backfill`.

## Marketing

La pestaña Marketing crea URL de campaña con parámetros UTM y de referencia, guarda códigos de referencia, genera fragmentos de lanzamiento y expone la interfaz de usuario del generador de inserción de campaña.

Tienda de códigos de referencia guardados:

- nombre de referencia
- código de referencia
- URL generada
- marca de tiempo de creación

El creador de URL se borra después de guardar y actualizar. Los guardados, ediciones y eliminaciones de referencias son mutaciones KV explícitas.

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

El editor de contenido de la campaña y los editores de contenido de entrada del diario colocan primero los medios seleccionados en el navegador. El bloque muestra la imagen, el vídeo o la selección de audio seleccionados inmediatamente, pero el archivo no se carga hasta que el usuario lo publica. Durante la publicación, el panel carga medios preparados en el directorio de activos de la campaña, reemplaza la vista previa temporal del navegador con la ruta final `/assets/...` y luego confirma el YAML de la campaña.

Las cargas de medios relacionadas con la campaña requieren acceso a esa campaña. Los superadministradores pueden cargar cualquier medio de campaña y plataforma/medio predeterminado; Los administradores de campañas solo pueden cargar medios para las campañas que administran. Las cargas de complementos de plataforma y marcas de plataforma siguen siendo solo para superadministradores.

El punto final de carga del trabajador preserva el origen. Valida el tipo, tamaño, alcance de la campaña, directorio y nombre de archivo, pero no ejecuta optimizadores de imágenes nativos ni FFmpeg. La compresión de imágenes sin pérdidas y la transcodificación de vídeo se ejecutan fuera del Worker a través del canal de medios del repositorio.

Utilice `npm run media:optimize` localmente o el flujo de trabajo **Optimizar medios del panel** de GitHub Actions después de que las cargas del panel lleguen al repositorio. Utilice `npm run media:optimize:check` cuando revise una rama con muchos medios y desee fallar en optimizaciones de imágenes pendientes o en derivados de video faltantes. La canalización optimiza las imágenes en su lugar cuando el resultado optimizado es más pequeño, genera derivados `.webm` de alta calidad junto a los archivos MP4/MOV cargados y reescribe referencias literales `_campaigns` / `_config.yml` del video fuente cargado al derivado WebM generado. Los videos originales permanecen en el repositorio para revertirlos y volver a codificarlos en el futuro.

Utilice texto alternativo significativo para imágenes que comuniquen contenido. Los fondos decorativos pueden utilizar texto alternativo vacío en las plantillas públicas.

## Barandillas de seguridad y accesibilidad

El panel sigue estas reglas del proyecto:

- Los controles del navegador son ayudas de usabilidad; La validación del trabajador es autorizada.
- Todas las mutaciones requieren una sesión de administrador válida y un encabezado CSRF.
- El alcance de las funciones y las campañas se aplica en el lado del servidor.
- Los secretos nunca se almacenan en `_config.yml`, campaña YAML, borradores de paneles, registros de usuarios de KV o confirmaciones de GitHub.
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
