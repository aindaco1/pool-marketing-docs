---
title: Checklist de smoke tests antes del merge
parent: Operaciones
nav_order: 7
render_with_liquid: false
lang: es
---

# Checklist de smoke tests antes del merge

## Última actualización

25 de agosto de 2026

Utilice esta lista de verificación antes de fusionar sucursales que cambien el pago, la persistencia del webhook, la gestión de aportes, el inventario, la liquidación o las transmisiones de patrocinadores.

## Ambiente

Configúrelos para el shell del operador antes de comenzar:

```bash
export STAGING_SITE_URL="https://pool-staging.example.com"
export STAGING_WORKER_URL="https://pledge-staging.example.com"
export ADMIN_SECRET="..."
```

Si el sitio de prueba y el trabajador comparten el mismo patrón de dominio en su configuración, use las URL de prueba reales en lugar de los marcadores de posición anteriores.

Si no existe un entorno de prueba, apunte estas variables al desarrollo local:

```bash
export STAGING_SITE_URL="http://127.0.0.1:4000"
export STAGING_WORKER_URL="http://127.0.0.1:8787"
export ADMIN_SECRET="..."
```

En ese caso, ejecute `./scripts/dev.sh --podman` primero y registre en la aprobación que la combinación se basó en la puerta automatizada más la cobertura de humo local porque no existe un entorno de preparación.

## Ensayo local

Antes de un pase de puesta en escena, o en lugar de uno cuando no existe ninguna puesta en escena, puedes ensayar la mayor parte del flujo localmente con:

```bash
./scripts/dev.sh --podman
```

Ese guión comienza:

- Jekyll en `http://127.0.0.1:4000`
- el Trabajador en `http://127.0.0.1:8787`
- Reenvío del webhook CLI de Stripe al trabajador local

Utilice el ensayo local para comprobar la integridad del proceso de pago, la entrega de webhooks, la gestión del comportamiento de los enlaces y los puntos finales de administración antes de ejecutar el mismo flujo en la puesta en escena.

Para sucursales con muchos paneles, abra el panel local en `http://127.0.0.1:4000/admin/`. La pila de desarrollo genera los valores predeterminados del administrador de arranque documentados en `README.md` y `worker/README.md`; Los cambios de gestión de usuarios realizados en el panel se guardan en el KV del trabajador local y se restablecen con el estado del KV local.

Para cambios en la interfaz de usuario del panel de administración, cambie entre pestañas de nivel superior, seleccione una sección de Configuración no predeterminada, seleccione una campaña de Campañas y una subpestaña de Campañas no predeterminada, vuelva a cargar la página y confirme que se restablezca el mismo espacio de trabajo permitido. Luego inicie sesión como usuario de campaña o simule un usuario y confirme que las pestañas exclusivas de superadministrador no se restauren.

Para verificaciones de gestión de aportes solo locales, utilice la campaña `smoke-editable`. Se define como `test_only: true`, por lo que aparece en el desarrollo local cuando `_config.local.yml` habilita `show_test_campaigns`, mientras permanece excluido de la página de inicio de producción y de producción `/api/campaigns.json`.

Antes de probar las superficies de implementación, ejecute el asistente de configuración en modo de prueba y confirme que planifica los cambios de Cloudflare/GitHub sin modificar nada:

```bash
npm run setup:deploy -- --mode=production --dry-run --skip-auth --skip-secrets
```

Utilice `--skip-readiness` para un ensayo limitado solo local o deje la preparación habilitada cuando desee que el asistente realice comprobaciones de solo lectura GitHub, Wrangler, Stripe, Resend, USPS y ZIP.TAX con cualquier credencial de proveedor disponible. El conjunto de unidades también incluye cobertura de CLI falsa para el asistente de configuración, por lo que las pruebas de puerta de fusión detectan regresiones en la planificación de prueba, el comportamiento de reutilización/creación de KV, la generación de secretos locales y las escrituras secretas de Worker generadas antes del humo en vivo.

Para la aprobación de la versión, capture el resultado del paquete de evidencia combinado:

```bash
npm run release:smoke -- --evidence-file /tmp/pool-release-smoke.md
```

Utilice reposiciones enfocadas como `npm run release:a11y-evidence`, `npm run release:i18n-seo-evidence`, `npm run release:pledge-evidence`, `npm run release:providers -- --no-dev-vars` y `npm run release:payment-smoke -- --no-dev-vars` cuando una nota de la versión necesite evidencia más limitada.

Para una versión con calidad de producción, capture también el recurso generado, el Lighthouse específico de la ruta, el caché implementado y las puertas de tiempo autenticadas Worker:

```bash
npm run test:performance:budgets
npm run test:performance:lighthouse
npm run test:cache-policy
npm run test:performance:runtime -- --input=/path/to/redacted-performance-observability.json
npm audit --omit=dev --audit-level=moderate
npm audit --audit-level=moderate
```

Configuración local recomendada para modificar/cancelar humo:

```bash
curl -s -X POST http://127.0.0.1:8787/test/setup \
  -H "Content-Type: application/json" \
  -d '{"email":"smoke-local@example.com","campaignSlug":"smoke-editable"}' | jq
```

O ejecute la verificación de mutación/cancelación local de extremo a extremo directamente:

```bash
./scripts/smoke-pledge-management.sh
```

## Configuración de datos de prueba

Preparar o identificar:

1. Una campaña de puesta en escena en vivo con:
   - al menos un nivel estándar
   - un nivel limitado
   - un nivel controlado por umbral si está disponible
   - al menos un elemento de soporte si está disponible
2. Una bandeja de entrada de correo electrónico de apoyo en la que puede recibir correo.
3. Una segunda bandeja de entrada de correo electrónico para patrocinadores para comprobaciones de inventario y aportes múltiples.
4. Aportes inicializadas para pruebas de liquidación:
   - un aporte activo con un cliente/método de pago válido de Stripe
   - Un aporte activo falta intencionalmente `stripeCustomerId`
5. Una campaña con suficientes patrocinadores para cruzar los límites de paginación, si está disponible.

## Regla de pasa/falla

Trate cualquiera de estos como bloqueadores de fusión:

- el pago se realiza correctamente pero persiste la forma de aporte incorrecta
- modificar/cancelar rupturas de aportes totales, estadísticas o inventario de niveles
- un único enlace mágico aún puede enumerar o modificar otro orden
- El acuerdo marca una campaña completa mientras que los aportes activos aún necesitan atención.
- hito, diario o anuncio envía patrocinadores perdidos o duplicados inesperadamente
- falla un Lighthouse específico de ruta, un activo generado, un caché implementado, una interacción con el panel de control o un presupuesto autenticado de Worker p95
- un hallazgo de auditoría de dependencia de producción permanece, o un hallazgo exclusivo de desarrollo carece de una resolución o justificación explícita
- un cambio de dinero, datos, mensajería, administración, automatización, uso compartido público o indexación omite la [revisión de riesgo ético](/es/docs/development/ethical-risk-review/) requerida

## Lista de verificación

### 1. Inicio del pago

1. Abra una página de campaña de preparación en vivo.
2. Agregue un nivel normal y proceda al pago.
3. Confirme que el navegador llegue exitosamente al paso de pago de Stripe en el sitio o a la ruta alternativa alojada si ese modo está habilitado intencionalmente.
4. Resultado esperado:
   - no hay errores de consola en la página de la campaña
   - el resumen de pago coincide con el nivel seleccionado, los artículos de soporte, el monto personalizado y la propina
   - Si el nivel seleccionado es escaso y está a punto de agotarse, el inicio del proceso de pago puede retenerlo inmediatamente.

### 2. Finalización del pago

1. Complete una prueba de pago real para una sola aporte.
2. Verifique que la página se cargue correctamente.
3. Verifique que el aporte exista en los datos respaldados por el trabajador y que el colaborador pueda abrir el enlace de administración desde el correo electrónico.
4. Resultado esperado:
   - webhook persiste el aporte una vez
   - el nivel almacenado/complemento/cantidad personalizada coincide con la sesión de pago real
   - El punto final de estadísticas refleja el nuevo subtotal.

Comprobaciones útiles:

```bash
curl -s "$STAGING_WORKER_URL/stats/<campaign-slug>" | jq
curl -s "$STAGING_WORKER_URL/inventory/<campaign-slug>" | jq
```

### 3. Alcance del enlace mágico

1. Cree o identifique dos aportes para el mismo correo electrónico de apoyo.
2. Abra el enlace de administración del primer correo electrónico de aporte.
3. Intente ver o actuar sobre el segundo aporte de esa misma sesión/enlace.
4. Resultado esperado:
   - el enlace sólo puede gestionar su propio pedido
   - otros aportes en el mismo correo electrónico no se enumeran ni se pueden modificar a través de ese token

### 4. Modificar el flujo

1. Modificar una prenda no cargada:
   - cambiar el nivel base si está permitido
   - ajustar la cantidad si está permitido
   - agregar o eliminar elementos de soporte
   - agregar o eliminar soporte personalizado
2. Verifique los totales actualizados en la interfaz de usuario de administración y en los datos almacenados.
3. Resultado esperado:
   - El subtotal, los impuestos, la propina y el importe final se actualizan de forma coherente.
   - El historial de aportes registra la modificación.
   - Las estadísticas y el inventario reflejan el nuevo estado del aporte.

### 5. Cancelar flujo

1. Cancelar un aporte no cargada a través de su propio enlace de gestión.
2. Vuelva a verificar las estadísticas y el inventario.
3. Resultado esperado:
   - aporte pasa al estado cancelado
   - el subtotal se elimina de las estadísticas de la campaña
   - Se libera inventario limitado.

### 6. Comportamiento de inventario limitado

1. Inicie el pago para un nivel limitado pero **no** complete el pago.
2. Desde un segundo navegador/perfil, comience a pagar para el mismo nivel limitado de la última unidad.
3. Resultado esperado:
   - el segundo pago está bloqueado o agotado mientras la primera reserva aún está activa
   - El inventario público sigue siendo la proyección de los reclamos comprometidos, por lo que el comportamiento de agotamiento de cara al usuario puede llevar brevemente el recuento de reclamos públicos.
   - La persistencia exitosa del webhook confirma la reserva retenida en lugar de volver a reclamarla contra una fuente de verdad separada.

### 7. Comportamiento de nivel controlado por umbral

1. Intente comprar un nivel con límite de umbral antes de alcanzarlo.
2. Si es posible, repita después de sembrar suficiente soporte para cruzar el umbral.
3. Resultado esperado:
   - antes del umbral: la selección es rechazada/deshabilitada
   - después del umbral: la selección tiene éxito normalmente

### 8. Ensayo de liquidación

1. Realice un ensayo de liquidación para una campaña de prueba financiada.
2. Verifique que la respuesta muestre los patrocinadores y los registros omitidos con precisión.
3. Resultado esperado:
   - los aportes activos a los que les faltan datos de clientes de Stripe aparecen como omitidos o que necesitan atención
   - no se crea ningún marcador de finalización mediante el ensayo

Ejemplo:

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"dryRun":true}' \
  "$STAGING_WORKER_URL/admin/settle/<campaign-slug>" | jq
```

### 9. Ejecución en vivo de liquidación

1. Ejecute una liquidación en vivo a partir de datos de preparación inicial o una campaña de prueba dedicada.
2. Inspeccionar el estado de respuesta y seguimiento.
3. Resultado esperado:
   - las campañas con aportes activos omitidas **no** obtienen un marcador final `campaign-charged`
   - Las campañas sin trabajos pendientes se marcan como resueltas.
   - Los cargos exitosos envían los correos electrónicos posteriores al cargo esperados.

Punto final preferido para campañas más grandes:

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  "$STAGING_WORKER_URL/admin/settle-dispatch/<campaign-slug>" | jq
```

### 10. Reabastecimiento del cliente

1. Ejecute el reabastecimiento del cliente para una campaña con valores `stripeCustomerId` faltantes conocidos.
2. Resultado esperado:
   - Todos los aportes calificados en la paginación KV están actualizados.
   - La repetición de la liquidación después del reabastecimiento reduce o borra los registros de clientes omitidos.

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$STAGING_WORKER_URL/admin/backfill-customers/<campaign-slug>" | jq
```

### 11. Comprobaciones de difusión y paginación

Ejecútelos en una campaña con suficientes patrocinadores para probar la paginación, si es posible.

1. Anuncio de simulacro.
2. Verificación del diario o transmisión del diario.
3. Verificación de hitos o transmisión de hitos.
4. Resultado esperado:
   - El recuento de destinatarios incluye el conjunto completo de patrocinadores.
   - sin truncamiento obvio en la primera página de resultados
   - no hay envío de hitos duplicados desde una verificación repetida o superpuesta

Ejemplos:

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"campaignSlug":"<campaign-slug>","subject":"Smoke Test","body":"Dry run","dryRun":true}' \
  "$STAGING_WORKER_URL/admin/broadcast/announcement" | jq

curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  "$STAGING_WORKER_URL/admin/milestone-check/<campaign-slug>" | jq
```

### 12. Humo en el panel de administración

Ejecute esta sección cuando la sucursal cambie la interfaz de usuario del panel, las rutas de los trabajadores administrativos, la configuración de la campaña, los complementos, las cargas, los informes, los análisis, los patrocinadores, las herramientas de marketing o la gestión de usuarios.

1. Inicie sesión en `/admin/` con un correo electrónico de administrador autorizado.
2. Verifique que las pestañas principales se representen sin desbordamiento horizontal en los anchos de escritorio, tableta y dispositivo móvil.
3. En **Configuración**, confirmar que las secciones publicables muestran un botón `Publish` deshabilitado hasta que se realice un cambio real. Confirme que **Usuarios**, **Uso del plan**, **Secretos y credenciales** y **Diagnóstico en tiempo de ejecución** no muestren una acción de publicación no utilizada.
4. En **Configuración -> Usuarios**, cree o edite un usuario de campaña, guarde y confirme que el cambio entre en vigor sin un flujo de publicación de GitHub.
5. En **Configuración -> Uso del plan**, verifique que el uso se cargue automáticamente, no hay ningún botón `Refresh usage`, los encabezados de Cloudflare/Resend tienen texto de ayuda legible y las tarjetas no se desbordan en el móvil.
6. En **Campañas**, cambie las subpestañas de la campaña y verifique que el contenido, los niveles, los complementos de la campaña, las entradas del diario y las decisiones se carguen solo para la campaña seleccionada.
7. Como superadministrador, verifique que la primera fila de la barra lateral de Campañas sea el botón `+`, cree una campaña de solo vista previa con varios usuarios de campaña nuevos o existentes y confirme que los usuarios asignados reciban el correo electrónico con el enlace del panel cuando se configure Resend.
8. En **Contenido**, verifique que **Publicar** y **Vista previa** aparezcan juntos. Publique una vista previa protegida, confirme que el panel muestra el enlace de vista previa del usuario actual, agregue correos electrónicos de revisor opcionales, confirme que la copia del correo electrónico dice que el enlace caduca en 24 horas y confirme que los correos electrónicos de vista previa no se escriben en Markdown de la campaña o en JSON público.
9. En **Contenido** y **Entradas del diario**, agregue/edite un bloque de contenido, verifique el comportamiento de vista previa WYSIWYG, abra el selector de medios del bloque de imágenes, confirme que los usuarios de la campaña solo vean los medios de la campaña y confirme que `Save Draft` solo se habilita cuando el borrador local difiere del valor guardado.
10. En **Complementos** y en la campaña **Complementos**, verifique que los productos físicos muestren campos preestablecidos de envío/paquete, que los productos digitales oculten los campos de envío, que los ID de producto/variante deriven de nombres/etiquetas para nuevas entradas, que los precios de variantes en blanco hereden el precio del producto, que se conserve el cero explícito, que los precios de variantes diferentes actualicen el subtotal mostrado y que los precios superiores a `$1,000,000` no superen la validación de vista previa.
11. En **Análisis**, **Informes** y **Colaboradores**, verifique que la vista predeterminada `All` solo muestre las campañas disponibles para el administrador actual, los montos de ingresos brutos y netos muestren los centavos exactos cuando corresponda, los desgloses de referencia/fuente UTM/medio/campaña/contenido se cargan desde aportes indexadas y la exportación CSV coincide con las filas visibles.
12. En **Marketing**, guarde/edite/elimine un código de referencia, verifique que el creador de URL se borre después de guardar/actualizar, confirme las actualizaciones de vista previa de QR de la URL de la campaña actual, descargue archivos QR PNG/SVG, use **Guardar borrador compartido** / **Cargar borrador compartido** / **Borrar borrador compartido**, confirme las cargas de estado de pago abandonado sin listado de KV, verifique que las filas de supresión creadas por el administrador muestren el correo electrónico suprimido con una acción Borrar y confirme que el creador de campañas integrado todavía funciona.
13. En el proceso de pago propio, confirme que la casilla de recordatorio de pago abandonado no esté marcada de forma predeterminada, utilice una copia de beneficios, persista después de ser marcada y que los enlaces de recordatorio firmados restablezcan el borrador del carrito/contacto abandonado antes de iniciar una nueva sesión de Stripe.
14. En **Campañas -> Blast**, redacta un correo electrónico masivo para tus patrocinadores con texto más una imagen alojada, una imagen existente seleccionada o un bloque de YouTube/Vimeo; use **Guardar borrador compartido** / **Cargar borrador compartido** / **Borrar borrador compartido**; Haga clic en **Enviar prueba** y verifique que el ensayo automático devuelva un recuento de audiencia/hash antes de que el correo electrónico de prueba llegue al administrador que inició sesión. Luego haga clic en **Enviar envío masivo**, confirme el envío en vivo y verifique el asunto, el contenido, la etiqueta del botón de CTA y la URL del botón de CTA debajo del editor. Utilice una campaña con un índice `campaign-pledges:<slug>` reconstruido; los índices faltantes no se cierran con `campaign_index_required` antes de enviar cualquier correo electrónico.
15. Para `/es/admin/`, verifique que las etiquetas de pestañas traducidas, Planificar etiquetas/enlaces de uso, Crear nueva campaña/Copia vista previa y que la navegación en tableta/móvil no se desborde.
16. En **Configuración -> Diagnóstico en tiempo de ejecución**, verifique que las filas `admin_dashboard_summary` y `admin_settings` de muestra aparezcan después del uso normal, contengan solo datos de tiempo agregados limitados y que el punto final permanezca privado/sin almacenamiento.

## Plantilla de aprobación

Registre el resultado del humo en el PR o en las notas de la versión:

```md
Smoke completed on <date> in <staging|local>.

- Checkout start/completion: pass
- Magic link scope: pass
- Modify/cancel: pass
- Limited inventory behavior: pass
- Threshold gating: pass
- Settlement dry/live: pass
- Ethical Risk review: pass / not applicable
- Backfill: pass
- Broadcast pagination/milestones: pass
- Admin dashboard smoke, if relevant: pass
- Performance budgets/Lighthouse/cache/runtime evidence: pass / omission documented
- Production and full dependency audit: pass
- Create new campaign/protected preview smoke, if relevant: pass

Notes:
- <any intentional behavior observed>
- <any non-blocking staging caveats>
- <note that no staging environment exists, if applicable>
```
