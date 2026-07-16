---
title: Sistema de correo electrónico
parent: Operaciones
nav_order: 4
render_with_liquid: false
lang: es
---

# Sistema de correo electrónico

## Última actualización

16 de julio de 2026

The Pool envía correo electrónico transaccional y de soporte de campaña a través de Resend desde Cloudflare Worker. Las plantillas se encuentran en `worker/src/email.js`, la copia localizada compartida se encuentra en `_data/i18n/*.yml` y la programación/selección de audiencia se encuentra principalmente en `worker/src/index.js`.

El sistema de correo electrónico es propiedad de Worker, por lo que el estado del aporte, la localización, la marca, los enlaces mágicos, el alcance de la campaña y el comportamiento de reenvío/reintento permanecen en una sola ruta.

## Archivos fuente

- `worker/src/email.js` crea y envía cargas útiles de correo electrónico.
- `worker/src/email-outbox.js` posee puesta en cola duradera, renderizado congelado, reintentos, verificación de eventos Resend y supresión.
- `worker/src/index.js` llama a los asistentes de correo electrónico desde las rutas de pago, gestión de aportes, programador, administrador, informe y Blast.
- `_data/i18n/en.yml` y `_data/i18n/es.yml` mantienen UI/tiempo de ejecución/copia de correo electrónico compartidos.
- `assets/i18n.json` es el catálogo generado que Worker puede recuperar para una copia de correo electrónico localizada.
- `_config.yml` contiene entradas no secretas de identidad del remitente y marca de correo electrónico.
- `worker/wrangler.toml` recibe vars de correo electrónico no secretos reflejados.

## Remitentes

Roles de remitente actuales:

- `PLEDGES_EMAIL_FROM` envía un correo electrónico sobre el ciclo de vida del aporte: confirmación, modificación, cancelación, error en el pago y éxito del cobro.
- `UPDATES_EMAIL_FROM` envía actualizaciones y correo electrónico operativo: recordatorios de lanzamiento, recordatorios de pago abandonado, actualizaciones del diario, hitos, Blast, acceso de administrador, asignación de campaña, vistas previas protegidas e informes.
- `SUPPORT_EMAIL` se convierte en la dirección de respuesta predeterminada cuando se configura.

Estos valores provienen de `_config.yml`:

```yml
platform:
  support_email: support@example.com
  pledges_email_from: "The Pool <pledges@pool.example.com>"
  updates_email_from: "The Pool <updates@pool.example.com>"
```

Los dominios del remitente deben estar autorizados en Resend. Para la implementación en vivo de Dust Wave, el dominio del remitente es `site.example.com`, por lo que `pledges@site.example.com` y `updates@site.example.com` requieren que se verifique el dominio Resend.

## Configuración

### 1. Configurar la identidad del remitente

Configure los campos del remitente en `_config.yml`, luego sincronice el espejo Worker:

```bash
npm run sync:worker-config
```

Los scripts principales de desarrollo/prueba/implementación ejecutan esta sincronización automáticamente, pero ejecutarla directamente es útil después de realizar ediciones manuales de configuración.

### 2. Verifique el dominio Resend

En Resend:

1. Agregue el dominio de envío exacto utilizado por `PLEDGES_EMAIL_FROM` y `UPDATES_EMAIL_FROM`.
2. Agregue los registros DNS que proporciona Resend.
3. Espere la verificación.
4. Confirme que la clave API pueda enviarse desde ese dominio.

Autorizar `example.com` no autoriza automáticamente a `pool.example.com` y autorizar a `pool.example.com` no autoriza automáticamente a `example.com`.

### 3. Store La clave API

Desarrollo local:

```bash
npm run secrets:dev
```

Producción:

```bash
wrangler secret put RESEND_API_KEY
```

No almacene `RESEND_API_KEY` en `_config.yml`, portadas de campaña, borradores de paneles ni documentos comprometidos.

### 4. Configurar la marca

La marca de correo electrónico utiliza una réplica seleccionada de `platform.*` y `design.*`:

- `EMAIL_LOGO_PATH`
- `EMAIL_FONT_FAMILY`
- `EMAIL_HEADING_FONT_FAMILY`
- `EMAIL_COLOR_TEXT`
- `EMAIL_COLOR_MUTED`
- `EMAIL_COLOR_SURFACE`
- `EMAIL_COLOR_BORDER`
- `EMAIL_COLOR_PRIMARY`
- `EMAIL_BUTTON_RADIUS`

Cuando `SITE_BASE` es localhost, las imágenes de correo electrónico incrustadas vuelven a la base de activos del sitio público para que los clientes de la bandeja de entrada no reciban URL de imágenes de localhost rotas.

### 5. Configurar webhooks de entrega

La entrega de producción no requiere Contactos o Transmisiones Resend. The Pool sigue siendo la fuente veraz de audiencia y consentimiento y envía una solicitud `/emails` por destinatario.

Cree un punto final de webhook Resend para:

```text
https://worker.example.com/webhooks/resend
```

Suscríbase a eventos de correo electrónico entregados, rebotados, reclamados, fallidos y suprimidos, luego almacene el secreto de firma de Svix devuelto como `RESEND_WEBHOOK_SECRET`. Worker verifica el cuerpo sin formato, `svix-id`, la marca de tiempo y la firma antes de actualizar el estado de entrega. El seguimiento de aperturas/clics no se utiliza para pagos ni para conocer la audiencia.

## Tipos de correo electrónico

### Enlace mágico de administrador

Se envía cuando un administrador solicita iniciar sesión desde `/admin/` o `/es/admin/`.

- Utiliza un nonce de inicio de sesión de corta duración.
- Puede requerir Cloudflare Turnstile antes de enviar el correo electrónico.
- El desarrollo local puede exponer la URL de inicio de sesión en el navegador solo para rutas de prueba/localhost.
- Los valores del remitente están normalizados para evitar la inyección del encabezado del correo electrónico.

### Usuario administrador creado

Se envía cuando un superadministrador crea un usuario del panel y la entrega de notificaciones está habilitada para esa acción.

- Explica qué acceso se agregó.
- Dirige al usuario a la página de inicio de sesión del panel.
- No incluye contraseña.
- Utiliza Resend solo cuando `RESEND_API_KEY` está configurado.

### Asignación de campaña

Se envía cuando se asignan usuarios de campaña durante la creación de una nueva campaña o flujos de administración relacionados.

- Identifica el acceso a la campaña.
- Apunta al panel de administración.
- Utiliza la ruta de correo electrónico de administrador compartida.

### Vista previa de campaña protegida

Se envía cuando un usuario autorizado del panel invita a revisores a una vista previa de la campaña protegida.

- Los enlaces de revisor están firmados y caducan después de 24 horas.
- Las direcciones de correo electrónico de acceso previo se encuentran solo en listas permitidas de corta duración Worker KV.
- Los correos electrónicos de la vista previa no están comprometidos con el Markdown de la campaña, el JSON público, la salida del mapa del sitio ni los metadatos generados.

### Confirmación de aporte

Se envía después de que se confirma una sesión de pago en modo de configuración Stripe y Worker persiste en el aporte.

Incluye:

- título de la campaña y elementos de aporte
- subtotal, propina, impuestos, envío y total cuando corresponda
- Administrar enlace mágico de aporte
- Enlace de la comunidad de patrocinadores cuando la campaña tiene decisiones.
- copia localizada basada en `preferredLang` almacenado

Para el pago de varias campañas en paquete, Worker mantiene los aportes relacionadas con la campaña y envía correos electrónicos de apoyo específicos de la campaña.

### Aporte modificado

Enviado cuando un patrocinador cambia un aporte activo.

Incluye:

- contexto de aporte anterior y nuevo
- deltas con precisión de centavos
- elementos actualizados
- Enlace Administrar aporte

Los cambios estructurales al mismo precio, como los intercambios de variantes complementarias, aún cuentan como cambios reales y pueden enviar un correo electrónico de actualización.

### Aporte cancelado

Se envía después de que se cancele un aporte activo antes de la fecha límite.

Incluye:

- confirmación de que la tarjeta guardada no fue cargada
- desglose final del aporte
- enlace de la campaña para volver a comprometerse si la campaña permanece activa

La cancelación también elimina al colaborador de futuras audiencias de actualización de campaña cuando no queda ningún aporte activo para ese correo electrónico/campaña.

### Pago fallido

Se envía cuando falla una liquidación PaymentIntent fuera de sesión.

Incluye:

- monto adeudado
- Detalles de la campaña y el aporte.
- Actualizar el llamado a la acción de la tarjeta a través de Manage Pledge

Las actualizaciones de los métodos de pago siguen estando disponibles después de la fecha límite de la campaña para que los patrocinadores puedan recuperar las tarjetas fallidas.

### Carga exitosa

Se envía cuando la liquidación cobra exitosamente una prenda.

Incluye:

- importe final cobrado
- desglose de campaña/nivel
- impuestos, envío y propina cuando corresponda

### Actualización del diario

Se envía cuando se difunden nuevas entradas del diario de campaña.

- Utiliza un extracto de texto sin formato generado a partir del contenido del diario.
- Enlaces al diario de campaña.
- Realiza un seguimiento de las entradas enviadas en KV para que la misma entrada del diario no se transmita repetidamente.
- La actualización de los metadatos del diario existente no debería enviar un nuevo correo electrónico cuando el ID de entrada sea estable.

### Hito

Se envía cuando un aporte impulsa una campaña a superar los umbrales de hitos configurados.

- Activado por la persistencia del aporte.
- Utiliza la ruta compartida Resend.
- Mantiene un texto de hitos breve y centrado en la campaña.

### Blast / Anuncio

Enviado desde Campañas -> Blast o el punto final de anuncios heredado.

Comportamiento actual:

- Los usuarios de campañas solo pueden enviar campañas asignadas.
- Los superadministradores pueden enviar mensajes para cualquier campaña.
- Los simulacros validan el tema, el contenido, la CTA y la audiencia indexada antes del envío.
- Los envíos de prueba van únicamente al administrador que ha iniciado sesión.
- Los envíos en vivo requieren un hash de ejecución en seco coincidente.
- Los envíos en vivo escriben un evento de auditoría administrativa después del envío.
- El historial de envío lee registros de auditoría recientes.

El contenido Blast admite bloques WYSIWYG seguros para correo electrónico:

- encabezados
- texto
- citas
- listas
- enlaces
- imágenes alojadas en la campaña de `/assets/images/...`
- imágenes de campaña existentes seleccionadas del selector de medios
- Enlaces de YouTube/Vimeo representados como enlaces/botones seguros para correo electrónico

Los enlaces activos de imágenes remotas arbitrarias, los iframes y los reproductores de vídeo integrados se omiten en las cargas útiles de correo electrónico.

### Recordatorio de lanzamiento

Se envía una vez cuando se activa una próxima campaña, solo a las personas que se registraron explícitamente.

Comportamiento actual:

- Los formularios de registro públicos pueden usar Cloudflare Turnstile.
- Los registros se deduplican mediante hash de campaña/correo electrónico.
- Los marcadores de supresión se comprueban antes del envío.
- Los marcadores de envío evitan la entrega duplicada.
- Los enlaces para cancelar la suscripción están firmados y tienen alcance de campaña.
- La cola de envío utiliza un marcador de estado de cola para que los cronómetros inactivos omitan los análisis del espacio de nombres.

### Recordatorio de pago abandonado

Se envía solo cuando el colaborador opta explícitamente por un recordatorio de pago.

Comportamiento actual:

- Worker pone en cola el recordatorio solo después de que Stripe crea exitosamente una sesión de pago.
- La persistencia exitosa del aporte elimina el recordatorio pendiente de ese pedido.
- Antes de enviar, Worker verifica los índices de aportes de campaña para evitar enviar correos electrónicos a los patrocinadores que completaron otro pedido.
- Los enlaces de recordatorio utilizan tokens de reanudación y cancelación de suscripción firmados.
- Los enlaces de reanudación restauran una instantánea de compra/carro desinfectada e inician una nueva sesión Stripe.
- La instantánea nunca almacena secretos Stripe en la URL.

Se prefiere `ABANDONED_CART_TOKEN_SECRET` para firmar recordatorios y recurre a `MAGIC_LINK_SECRET` cuando se omite.

### Informes del corredor de campaña

Enviado según el cronograma configurado para la campaña `runner_report_emails`.

Tipos de informes:

- Libro de aporte de campaña diario durante campañas en vivo.
- exportación única después del cumplimiento de la fecha límite

Comportamiento actual:

- El tiempo utiliza `platform.timezone`.
- Los archivos adjuntos CSV son opcionales según la configuración.
- Los destinatarios de la campaña reciben filas completadas por la campaña.
- `platform.support_email` puede recibir filas separadas de cumplimiento de plataforma cuando los complementos de plataforma necesitan cumplimiento.
- Las vistas previas/descargas de los informes del panel son de solo lectura y no envían correos electrónicos ni escriben marcadores de envío.

## Entrega y reintento

Los envíos de producción utilizan registros `email-outbox:v1:*`. La persistencia ocurre antes del efecto secundario Resend y el programador de minutos drena lotes limitados. Cada trabajo:

- tiene un ID de trabajo determinista The Pool y Resend `Idempotency-Key`
- se procesa una vez, congela la carga útil exacta del proveedor y registra un hash de contenido
- utiliza un contrato de arrendamiento de procesamiento para que el trabajo interrumpido pueda reanudarse
- respeta `Retry-After`, respuestas de cuota y retraso exponencial acotado
- rechaza el reintento ciego después de que una respuesta ambigua sobreviva la ventana de idempotencia de 24 horas de Resend
- caduca los datos de carga útil transitoria después de 30 días y conserva solo evidencia mínima `email-delivery:v1:*` durante 400 días

`sendPreparedResendEmail` es el asistente del proveedor central. Él:

- publicaciones en `https://api.resend.com/emails`
- utiliza `Authorization: Bearer ${RESEND_API_KEY}`
- incluye HTML y cuerpos de texto sin formato
- aplica la respuesta cuando `SUPPORT_EMAIL` está configurado
- resume los errores del proveedor Resend
- devuelve reintento normalizado, ambigüedad, estado y tipo de error del proveedor en respuestas que no son correctas

La cola `supporter-email-retry:*` anterior sigue siendo legible durante la migración, pero los reintentos ahora entregan la entrega final a la bandeja de salida compartida. Los enlaces mágicos de inicio de sesión del administrador y los envíos de prueba explícitos siguen siendo inmediatos porque retrasarlos haría que la interacción fuera inutilizable.

El correo de diario, hito y anuncios en vivo incluye una URL `List-Unsubscribe` firmada con alcance de campaña y un encabezado RFC 8058 `List-Unsubscribe-Post`. GET muestra una confirmación humana; POST devuelve un éxito en blanco y escribe una supresión de campaña con hash indefinida. Las preferencias de marketing de campaña no suprimen el correo transaccional de aporte/pago.

Los rebotes permanentes, las quejas y las supresiones de proveedores crean un marcador `email-suppression:v1:*` local con hash. La bandeja de salida comprueba la supresión global y de campaña inmediatamente antes de la entrega del proveedor.

## Consentimiento y confianza

Los cambios de correo electrónico deben seguir la [revisión de riesgos éticos](/es/docs/development/ethical-risk-review/) cuando agregan nuevas audiencias, activadores, recordatorios, informes o superficies de marketing.

Normas:

- Envíe comunicaciones a sus patrocinadores únicamente a partir de un aporte explícito, un registro explícito, un alcance de campaña autorizado por el administrador o una necesidad operativa documentada.
- Mantenga los recordatorios de lanzamiento y los recordatorios de pagos abandonados habilitados, acotados, deduplicados y suprimibles.
- Ejecute pruebas de prueba o sin envío antes de nuevas rutas de envío masivo.
- No utilice la urgencia, la escasez o la personalización de manera que tergiverse el estado de la campaña, el inventario, los plazos, los impuestos, el envío, las tarifas o los totales de los aportes.
- Mantenga comprensibles los cuerpos de texto sin formato, los enlaces localizados, la identidad del remitente y el comportamiento de soporte/respuesta sin necesidad de que el destinatario inspeccione HTML.
- Trate los correos electrónicos Blast, diario, hitos, vista previa y asignaciones como superficies sensibles a la confianza; revise quién los recibe, qué datos revelan y cómo se puede contener un envío erróneo.

## Copia y localización

El texto dirigido a personas debe ser breve, directo y localizable.

Normas:

- Coloque una copia de correo electrónico compartida en `_data/i18n/en.yml` y `_data/i18n/es.yml`.
- Deje que `worker/src/email.js` mantenga cadenas en inglés de respaldo para las claves faltantes.
- Preserve `preferredLang` de los flujos de pago/registro cuando esté disponible.
- Utilice enlaces localizados `/manage/` y `/community/:slug/` cuando exista la ruta local.
- Evite agregar textos extensos escritos por la campaña al YAML de traducción; El contenido de la campaña pertenece a los archivos de la campaña.

## Seguridad del contenido

El contenido del correo electrónico tiene restricciones más estrictas que el contenido de la página de la campaña:

- Elimina los caracteres de control de los valores de encabezado configurables.
- Escape del texto de campaña/controlado por el usuario antes de representar HTML.
- Genere texto sin formato a partir de HTML para los clientes que lo necesiten.
- Utilice únicamente imágenes alojadas en el sitio en los correos electrónicos Blast.
- Convierta contenido de YouTube y Vimeo en enlaces/botones, no incrustados.
- Evite los archivos adjuntos SVG y los patrones de archivos adjuntos de contenido activo.
- Mantenga los enlaces tokenizados con alcance, firmada y duración limitada siempre que sea posible.

## Pruebas

Cobertura de unidad enfocada:

```bash
npm run test:unit -- \
  tests/unit/email-tip.test.ts \
  tests/unit/email-security.test.ts \
  tests/unit/email-broadcasts.test.ts \
  tests/unit/email-outbox.test.ts \
  tests/unit/worker-ops-integrity.test.ts
```

Comprobaciones más amplias útiles:

```bash
npm run test:unit
npm run test:i18n
npm run test:secrets
npm run release:payment-smoke -- --no-dev-vars
```

Para obtener evidencia de publicación que debería generar cargas útiles de correo electrónico sin llamar a Resend, configure `POOL_EMAIL_DRY_RUN=true` o `RESEND_EMAIL_DRY_RUN=true`. La ruta de envío compartida devuelve una identificación de prueba y omite la solicitud del proveedor, lo que permite que las comprobaciones de aporte, informe, recordatorio de lanzamiento, pago abandonado y Blast adyacentes a Blast demuestren la construcción de la carga útil sin enviar correo.

Humo manual:

1. Inicie la pila Podman con `./scripts/dev.sh --podman`.
2. Complete una compra de prueba.
3. Confirmar la persistencia del aporte y el comportamiento de confirmación de los patrocinadores.
4. Activar una modificación y cancelación de aporte en una campaña de prueba local.
5. Campañas de prueba -> Blast ejecución en seco y envío de prueba desde el panel.
6. Obtenga una vista previa/descargue informes y confirme que no se envían correos electrónicos mediante las descargas del panel.
7. Revise los errores del panel Resend si falla la entrega.

## Solución de problemas

Si el correo electrónico no se envía:

- Confirme que `RESEND_API_KEY` esté configurado en el tiempo de ejecución de Worker.
- Confirme que el dominio del remitente coincida con `PLEDGES_EMAIL_FROM` / `UPDATES_EMAIL_FROM`.
- Verifique el estado de verificación del dominio Resend.
- Consulte los registros Worker para ver el error resumido del proveedor.
- Confirmar que el desarrollo local no se basa únicamente en un secreto de producción.
- Ejecute `npm run test:secrets` antes de realizar cambios secretos locales.

Si las imágenes están rotas en el correo electrónico recibido:

- Confirme que la ruta de la imagen esté alojada en el sitio en `/assets/images/...`.
- Confirme que el sitio público implementado pueda servir a esa ruta.
- Evite las URL exclusivas de localhost en las cargas útiles de correo electrónico.

Si falta una copia localizada:

- Ejecute `npm run test:i18n`.
- Verifique `_data/i18n/{lang}.yml` para ver la clave que falta.
- Confirme que Worker pueda recuperar `SITE_BASE/assets/i18n.json` o que tenga `I18N_CATALOG_JSON` en las pruebas.

## Documentos relacionados

- [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/)
- [FLUJOS DE TRABAJO.md](/es/docs/development/workflows/)
- [PERSONALIZACIÓN.md](/es/docs/development/customization-guide/)
- [PANEL.md](/es/docs/operations/admin-dashboard/)
- [SEGURIDAD.md](/es/docs/operations/security/)
- [PRUEBA.md](/es/docs/operations/testing/)
- [trabajador/README.md](/es/docs/operations/worker/)
