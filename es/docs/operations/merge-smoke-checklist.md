---
title: Checklist de smoke tests antes del merge
parent: Operaciones
nav_order: 4
render_with_liquid: false
lang: es
---

# Checklist de smoke tests antes del merge

Utilice esta lista de verificación antes de fusionar sucursales que cambien el pago, la persistencia del webhook, la gestión de promesas, el inventario, la liquidación o las transmisiones de seguidores.

Esta versión está optimizada para el comportamiento actual de la lógica empresarial de pago y del trabajador en `main`.

## Alcance de esta rama

Estos comportamientos cambiaron intencionalmente y **no** deben tratarse como regresiones durante las pruebas de humo:

- Los enlaces mágicos tienen un alcance de orden en lugar de un alcance de correo electrónico.
- `/checkout-intent/start` ahora reserva un inventario limitado y escaso antes de la confirmación del pago, y la persistencia exitosa confirma esa reserva.
- El `GET /checkout` heredado está deshabilitado.
- La liquidación solo marca una campaña completamente liquidada cuando no se omitió ninguna promesa activa.

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

Para verificaciones de gestión de promesas solo locales, utilice la campaña `smoke-editable`. Se define como `test_only: true`, por lo que aparece en el desarrollo local cuando `_config.local.yml` habilita `show_test_campaigns`, mientras permanece excluido de la página de inicio de producción y de producción `/api/campaigns.json`.

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
3. Una segunda bandeja de entrada de correo electrónico para seguidores para comprobaciones de inventario y compromisos múltiples.
4. Promesas inicializadas para pruebas de liquidación:
   - un compromiso activo con un cliente/método de pago válido de Stripe
   - Un compromiso activo falta intencionalmente `stripeCustomerId`
5. Una campaña con suficientes seguidores para cruzar los límites de paginación, si está disponible.

## Regla de pasa/falla

Trate cualquiera de estos como bloqueadores de fusión:

- el pago se realiza correctamente pero persiste la forma de compromiso incorrecta
- modificar/cancelar rupturas de compromisos totales, estadísticas o inventario de niveles
- un único enlace mágico aún puede enumerar o modificar otro orden
- El acuerdo marca una campaña completa mientras que las promesas activas aún necesitan atención.
- hito, diario o anuncio envía seguidores perdidos o duplicados inesperadamente

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

1. Complete una prueba de pago real para una sola promesa.
2. Verifique que la página se cargue correctamente.
3. Verifique que el compromiso exista en los datos respaldados por el trabajador y que el colaborador pueda abrir el enlace de administración desde el correo electrónico.
4. Resultado esperado:
   - webhook persiste el compromiso una vez
   - el nivel almacenado/complemento/cantidad personalizada coincide con la sesión de pago real
   - El punto final de estadísticas refleja el nuevo subtotal.

Comprobaciones útiles:

```bash
curl -s "$STAGING_WORKER_URL/stats/<campaign-slug>" | jq
curl -s "$STAGING_WORKER_URL/inventory/<campaign-slug>" | jq
```

### 3. Alcance del enlace mágico

1. Cree o identifique dos compromisos para el mismo correo electrónico de apoyo.
2. Abra el enlace de administración del primer correo electrónico de compromiso.
3. Intente ver o actuar sobre el segundo compromiso de esa misma sesión/enlace.
4. Resultado esperado:
   - el enlace sólo puede gestionar su propio pedido
   - otras promesas en el mismo correo electrónico no se enumeran ni se pueden modificar a través de ese token

### 4. Modificar el flujo

1. Modificar una prenda no cargada:
   - cambiar el nivel base si está permitido
   - ajustar la cantidad si está permitido
   - agregar o eliminar elementos de soporte
   - agregar o eliminar soporte personalizado
2. Verifique los totales actualizados en la interfaz de usuario de administración y en los datos almacenados.
3. Resultado esperado:
   - El subtotal, los impuestos, la propina y el importe final se actualizan de forma coherente.
   - El historial de compromisos registra la modificación.
   - Las estadísticas y el inventario reflejan el nuevo estado del compromiso.

### 5. Cancelar flujo

1. Cancelar una promesa no cargada a través de su propio enlace de gestión.
2. Vuelva a verificar las estadísticas y el inventario.
3. Resultado esperado:
   - compromiso pasa al estado cancelado
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
2. Verifique que la respuesta muestre los seguidores y los registros omitidos con precisión.
3. Resultado esperado:
   - los compromisos activos a los que les faltan datos de clientes de Stripe aparecen como omitidos o que necesitan atención
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
   - las campañas con promesas activas omitidas **no** obtienen un marcador final `campaign-charged`
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
   - Todos los compromisos calificados en la paginación KV están actualizados.
   - La repetición de la liquidación después del reabastecimiento reduce o borra los registros de clientes omitidos.

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ADMIN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$STAGING_WORKER_URL/admin/backfill-customers/<campaign-slug>" | jq
```

### 11. Comprobaciones de difusión y paginación

Ejecútelos en una campaña con suficientes seguidores para probar la paginación, si es posible.

1. Anuncio de simulacro.
2. Verificación del diario o transmisión del diario.
3. Verificación de hitos o transmisión de hitos.
4. Resultado esperado:
   - El recuento de destinatarios incluye el conjunto completo de seguidores.
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
- Backfill: pass
- Broadcast pagination/milestones: pass

Notes:
- <any intentional behavior observed>
- <any non-blocking staging caveats>
- <note that no staging environment exists, if applicable>
```
