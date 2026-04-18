---
title: Guía de seguridad
parent: Operaciones
nav_order: 5
render_with_liquid: false
lang: es
---

# Guía de seguridad

Este documento cubre la arquitectura de seguridad, los riesgos conocidos, las medidas de refuerzo aplicadas, las compensaciones aceptadas y los procedimientos de prueba de penetración para la plataforma de financiación colectiva The Pool.

## Arquitectura de seguridad

### Mecanismos de autenticación

|Mecanismo|Puntos finales|Descripción|
|-----------|-----------|-------------|
|**Fichas de enlace mágico**|`/pledge*`, `/pledges`, `/votes`|Tokens firmados HMAC-SHA256 con vencimiento de 90 días|
|**Firma de webhook de rayas**|`/webhooks/stripe`|Verificación HMAC-SHA256 según las especificaciones de Stripe|
|**Secreto de administrador**|`/admin/*`|Encabezado `Authorization: Bearer <secret>` o `x-admin-key`|
|**Protección del modo de prueba**|`/test/*`|`APP_MODE === 'test'` verificación del entorno|

### Almacenamiento de datos (Cloudflare KV)

|Patrón clave|Espacio de nombres|Datos|Sensibilidad|
|-------------|-----------|------|-------------|
|`pledge:{orderId}`|PROMESAS|Correo electrónico, monto, ID de Stripe, estado|**Alta** - PII + datos de pago|
|`email:{email}`|PROMESAS|Matriz de ID de pedido|**Medio**: vincula el correo electrónico a las promesas|
|`stats:{slug}`|PROMESAS|Totales agregados|**Bajo** - público|
|`tier-inventory:{slug}`|PROMESAS|Recuentos de reclamos de nivel|**Bajo** - público|
|`stripe-event:{id}`|PROMESAS|bandera "procesada"|**Bajo** - idempotencia|
|`campaign-pledges:{slug}`|PROMESAS|Matriz de ID de pedido por campaña|**Bajo** - índice|
|`campaign-charged:{slug}`|PROMESAS|Marca de tiempo de finalización de la liquidación|**Bajo** - bandera|
|`settlement-job:{slug}`|PROMESAS|Progreso del lote de liquidación|**Bajo** - efímero|
|`pending-extras:{orderId}`|PROMESAS|Artículo de soporte temporal/extras de pago de cantidad personalizada|**Bajo** - efímero|
|`pending-tiers:{orderId}`|PROMESAS|Metadatos de nivel de desbordamiento temporal durante el pago|**Bajo** - efímero|
|`cron:lastRun`|PROMESAS|Marca de tiempo de la última ejecución cron|**Bajo** - seguimiento|
|`vote:{slug}:{decision}:{email}`|VOTOS|elección de voto|**Medio** - vincula a un partidario para que vote|
|`results:{slug}:{decision}`|VOTOS|recuentos de votos|**Bajo** - semipúblico|
|`rl:{endpoint}:{ip}`|LÍMITE DE TARIFAS|Recuento de solicitudes + tiempo de reinicio|**Bajo** - efímero|

La reserva escasa de nivel limitado y la verdad del recuento comprometido ya no se almacenan en KV. Ese estado sensible a la raza ahora reside en el coordinador de Objetos Durables por campaña, mientras que KV mantiene solo la proyección pública `tier-inventory:{slug}`.

---

## Descripción general del refuerzo de seguridad

La postura de seguridad actual está diseñada en torno a algunos principios básicos:

- mantener los precios, el estado de la promesa y el servidor de liquidación canónicos
- alcance el acceso de los seguidores lo más estrictamente posible
- falla cerrada cuando faltan secretos o comprobaciones del entorno
- mantenga el almacenamiento del navegador y las respuestas almacenables en caché con baja sensibilidad de forma predeterminada
- validar el contenido creado y solicitar cargas útiles antes de que alcancen una lógica sensible
- Preservar la visibilidad operativa a través de pruebas de seguridad repetibles y manejo de secretos explícitos.

### Control de acceso y control ambiental

- Los enlaces mágicos están dirigidos a rutas de campaña y compromisos específicos en lugar de cuentas de usuario amplias.
- Las rutas `/test/*` están cerradas en modo de prueba y no deben ser accesibles en implementaciones normales.
- Las rutas de administración requieren un secreto explícito y están diseñadas para fallar cuando no se configuran correctamente.
- La votación de los seguidores está vinculada a la identidad de correo electrónico del seguidor asociada con el compromiso autorizado, lo que evita una simple amplificación del voto de múltiples compromisos.

### Protecciones de origen, administrador y webhook

- El manejo del webhook de Stripe se basa en la verificación de firmas y un secreto configurado explícito
- La comparación admin-secret es segura en lugar de utilizar una comparación directa ingenua
- Los flujos POST sensibles del navegador, como el arranque del proceso de pago, la finalización y las actualizaciones de los métodos de pago, se verifican en origen con la base del sitio configurado.
- Las superficies de devolución de llamada heredadas que ya no pertenecen al flujo de pago en vivo se eliminan intencionalmente en lugar de dejarlas inactivas.

### Endurecimiento del navegador y de la respuesta

- Las respuestas de finalización y arranque de pago específicas del pedido se entregan con `Cache-Control: private, no-store`
- La persistencia de larga duración del navegador se limita a la estructura del carrito y a las entradas de precios, mientras que los borradores de contactos y direcciones permanecen en el ámbito de la sesión.
- Los marcadores de recuperación de corta duración se utilizan para la continuidad del proceso de verificación en lugar de dejar el estado sensible en vuelo almacenado indefinidamente.
- Los encabezados de respuesta de seguridad reducen el rastreo de MIME, el riesgo de encuadre y la filtración innecesaria de referencias.

### Validación de entrada y contenido

- Las cargas útiles de inicio de pago validan identificadores de campaña, direcciones de correo electrónico, artículos del carrito y entradas de contribuciones antes de la reconstrucción canónica.
- Los puntos finales de votación validan los identificadores de decisiones y los valores de las opciones antes de que alcancen la lógica de cambio de estado.
- Las etiquetas creadas por el creador y el contenido enriquecido se escapan o se desinfectan de forma predeterminada, y solo se conserva un subconjunto HTML muy pequeño incluido en la lista de permitidos.
- las incrustaciones estructuradas se incluyen en la lista permitida para precisar los proveedores aprobados y las formas de URL en lugar de verificaciones amplias de subcadenas
- Los destinos de los enlaces de rebajas están restringidos a esquemas seguros y enlaces internos.

### Inventario e integridad de datos

- El escaso inventario de nivel limitado se coordina a través de un objeto duradero por campaña en lugar de confiar en el estado KV visible para el cliente para conocer la verdad sensible a la raza.
- El inventario público sigue siendo una proyección para lecturas eficientes, mientras que la reserva y el compromiso de verdad permanecen en el coordinador.
- La finalización del pago invalida las estadísticas y el inventario almacenados en caché, por lo que las páginas restauradas no siguen mostrando totales de compromiso previo obsoletos.
- la liquidación y los informes dependen de los registros de promesas propiedad del servidor en lugar de los totales enviados por el navegador

### Controles de abuso y salvaguardias operativas

- La limitación de tarifas está disponible para rutas costosas como pago, gestión de promesas, operaciones administrativas y webhooks.
- Las solicitudes bloqueadas están diseñadas para fallar en el cierre sin convertir el abuso en escrituras KV adicionales excesivas.
- Los conjuntos de pruebas de seguridad y auditoría secreta son parte de la ruta de verificación documentada.
- El modelo de seguridad supone que los operadores mantendrán los secretos de implementación rotados, con alcance y fuera del historial del repositorio.

## Límites aceptados

Algunas compensaciones siguen siendo intencionales en el modelo actual:

- Los enlaces mágicos son duraderos porque la gestión de promesas sin cuentas debe seguir siendo utilizable en todos los cronogramas de la campaña.
- Los tokens aún llegan a través de URL enviadas por correo electrónico, por lo que la plataforma se basa en un acceso con alcance, encabezados de respuesta y una persistencia limitada del navegador en lugar de un flujo completo de intercambio de tokens.

Si una implementación necesita una postura más estricta que la predeterminada, los siguientes pasos más probables serían una vida útil más corta de los tokens, flujos de reemisión de tokens más fáciles y un intercambio de tokens único que elimine los tokens sin procesar de las URL visibles después de su entrada.

---


## Lista de verificación de secretos

Antes de implementar en producción, verifique que estos secretos estén configurados:

|Secreto|Variable de entorno|Longitud mínima|
|--------|---------------------|------------|
|Clave API de banda|`STRIPE_SECRET_KEY_LIVE`|N/A|
|Secreto del webhook de rayas|`STRIPE_WEBHOOK_SECRET_LIVE`|32+ caracteres|
|Secreto de intención de pago|`CHECKOUT_INTENT_SECRET`|32+ caracteres|
|Secreto del enlace mágico|`MAGIC_LINK_SECRET`|32+ caracteres|
|Secreto de administrador|`ADMIN_SECRET`|32+ caracteres|
|Reenviar clave API|`RESEND_API_KEY`|N/A|

Generar secretos seguros:
```bash
openssl rand -base64 32
```

---

## Pruebas de penetración

Consulte [tests/security/README.md](/es/docs/operations/security-test-suite/) para conocer el conjunto de pruebas de penetración.

Ejecute pruebas de seguridad:
```bash
npm run test:secrets            # Audit local secret exposure in files + history
npm run test:security           # Against local Worker
npm run test:security:staging   # Against a staging worker, if you maintain one
```

`npm run test:premerge` ahora incluye la auditoría secreta automáticamente, por lo que la activación de combinación local verifica tanto el comportamiento de seguridad como la exposición accidental de credenciales.

Para ejecuciones locales, mantenga configurado `CHECKOUT_INTENT_SECRET` si desea que la suite de inicio de pago y pago del trabajador en vivo ejerza la ruta de firma propia real.

---

## Respuesta a incidentes

### Compromiso de token

Si un token de enlace mágico está comprometido:
1. El token está vinculado a un ID de pedido/correo electrónico/campaña específico.
2. Sólo puede acceder/modificar ese pedido autorizado.
3. Para invalidar: elimine el compromiso de KV (`GET /pledge` luego devolverá `404` para ese token)
4. Opcionalmente: regenerar MAGIC_LINK_SECRET (invalida TODOS los tokens)

### Compromiso secreto del administrador

1. Gire inmediatamente `ADMIN_SECRET` a través de `wrangler secret put`
2. Revisar los registros de auditoría para detectar acciones administrativas no autorizadas
3. Vuelva a verificar las estadísticas de la campaña y prometa la integridad de los datos.

### Compromiso secreto de Stripe Webhook

1. Gire el secreto del webhook en Stripe Dashboard → Webhooks
2. Actualizar `STRIPE_WEBHOOK_SECRET_*` en Worker
3. Verifique si hay promesas sospechosas creadas durante la ventana de exposición

### Webhook de Stripe perdido (Desarrollo)

Si el paso de pago en el sitio se completa pero el compromiso aún no aparece (común en desarrolladores locales cuando el reenvío del webhook se retrasa o no funciona):

1. Verifique la salida de Stripe CLI para conocer el estado de entrega del webhook
2. El cliente primero intentará `/checkout-intent/complete` automáticamente para la recuperación local, pero si el compromiso aún no aparece, use el punto final de recuperación del administrador para crearlo manualmente:
   ```bash
   curl -X POST http://localhost:8787/admin/recover-checkout \
     -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
     -H 'Content-Type: application/json' \
     -d '{"sessionId": "cs_test_..."}'
   ```
3. El punto final obtiene la sesión de pago de Stripe y crea el compromiso si no existe.

**Prevención:**
- Utilice `scripts/dev.sh` que ejecuta el trabajador con simulación KV local
- `scripts/dev.sh` inicia un único oyente Stripe, reenvía eventos a `127.0.0.1:8787/webhooks/stripe`, escribe el secreto `whsec_...` de ese mismo oyente en `worker/.dev.vars` y borra los procesos locales obsoletos en los puertos de desarrollo estándar antes del inicio.
- Si inicia Stripe manualmente, use la misma instancia de escucha para reenviar y para el secreto que copia en la configuración local.
- `./scripts/dev.sh --podman` es la forma más fácil de mantener el límite de producción del sitio local/trabajador sin depender de la configuración del host Ruby/Wrangler.
- Para realizar pruebas con datos inicializados, ejecute `./scripts/seed-all-campaigns.sh` después de iniciar el trabajador.

---

## Contactos de seguridad

- **Seguridad de Stripe:** [stripe.com/docs/security](https://stripe.com/docs/security)
- **Estado de Cloudflare:** [cloudflarestatus.com](https://www.cloudflarestatus.com)

---
