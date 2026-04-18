---
title: Guía de pruebas
parent: Operaciones
nav_order: 3
render_with_liquid: false
lang: es
---

# Guía de pruebas

Esta guía cubre los conjuntos de pruebas automatizadas, la infraestructura de pruebas local y las rutas de verificación manual.

## Referencia rápida

```bash
npm run test:unit          # Unit tests (Vitest) — ~700ms
npm run test:unit:watch    # Watch mode
npm run test:unit:coverage # With coverage report
npm run test:secrets       # Secret exposure audit for local env files
npm run test:premerge      # Merge-readiness checks for changed Worker logic
npm run test:e2e           # E2E tests (Playwright) — fully automated browser coverage
npm run test:e2e:headless  # CI mode
npm run test:e2e:headless:podman  # Automated browser suite with Playwright in Podman
npm run test:e2e:parity    # First-party critical-path browser flows
npm run podman:doctor      # Cross-platform Podman readiness check
npm run test:security      # Security pen tests (Worker must be running)
npm run test:security:podman  # Security pen tests with a one-shot Podman-backed stack
npm run test:security:staging  # Security tests against a staging worker, if you maintain one
./scripts/test-checkout.sh --podman  # Manual checkout helper against the Podman stack
./scripts/test-e2e.sh --podman       # Automated browser helper against the Podman stack
npm run test:usps          # Live USPS credential + quote sanity check
npm test                   # Run all tests
```

`./scripts/test-e2e.sh --podman` es ahora la ruta del navegador totalmente automatizada. Utilice `./scripts/test-checkout.sh --podman` cuando desee específicamente realizar el pago manualmente en un navegador real.

Para la sección del navegador centrada en la accesibilidad, utilice:

```bash
./scripts/podman-playwright-run.sh npx playwright test \
  tests/e2e/accessibility-public-pages.spec.ts \
  tests/e2e/manage-flows.spec.ts \
  tests/e2e/community-flows.spec.ts \
  tests/e2e/public-page-controls.spec.ts \
  tests/e2e/campaign-checkout.spec.ts \
  --project=chromium \
  --grep "Public Page Accessibility|keyboard-only|Community Flows|Public Page Keyboard Controls"
```

---

## Pruebas unitarias (Vitest)

Pruebas rápidas y aisladas para funciones JS en `tests/unit/`.

### Cobertura

|Módulo|Funciones probadas|
|--------|-----------------|
|`live-stats.js`|`formatMoney`, `updateProgressBar`, `updateMarkerState`, `checkTierUnlocks`, `checkLateSupport`, `updateSupportItems`, `updateTierInventory`|
|`platform-tip`|Desinfección de propinas, derivación del porcentaje de propinas, cálculo del monto de la propina|
|`pledge-management`|Cumplimiento de plazos según el horario de verano (MST/MDT a través de Intl), cancelación/modificación/validación del método de pago, transiciones de estado de compromiso, independencia de múltiples campañas, envío en registros de compromiso, forma de respuesta de API|
|`settlement`|Agregación de cargos (incluidas tarifas de envío), éxito o fracaso del pago, flujo de reintento, modo de prueba, casos extremos, liquidación por lotes, índice de compromiso de campaña, envío de liquidación, envío en liquidación, latido cron|
|`email-broadcasts`|Extracción de extractos del diario (con truncamiento de puntos suspensivos), ayudas de seguimiento del diario/hitos, lógica de verificación de hitos, limitación de velocidad|
|`email-tip`|Desgloses de correos electrónicos de soporte conscientes de las sugerencias en correos electrónicos de confirmación/modificados/cancelados/fallidos/cargados|
|`votes`|Almacenamiento/descopia de votos basado en correo electrónico, recuperación del estado de los votos, resultados de campaña, agregación de resultados|

### Correr

```bash
npm run test:unit          # Run once
npm run test:unit:watch    # Watch mode for development
npm run test:unit:coverage # Generate coverage report
```

---

## Runbook de regresión previo a la fusión

Úselo antes de fusionar ramas que toquen el pago, la lógica empresarial del trabajador, el cumplimiento o los flujos de transmisión.

### Puerta automatizada

```bash
npm run test:premerge
```

Esto se ejecuta:

- `npm run test:secrets` para verificar que los archivos env locales permanezcan ignorados y sus valores secretos no aparezcan en los archivos rastreados o en el historial de git
- `node --check` para los puntos de entrada de los trabajadores modificados
- Suites de regresión enfocadas:
  - `tests/unit/worker-business-logic.test.ts`
  - `tests/unit/worker-ops-integrity.test.ts`
  - `tests/unit/stats-pagination.test.ts`
- Regresiones del filtro de seguridad de contenido en `tests/unit/content-safety-filter.test.ts`, incluidos esquemas de enlaces Markdown inseguros y validación estricta de URL incrustadas estructuradas
- Cobertura de auditoría de contenido de campaña en `tests/unit/campaign-content-security.test.ts`, incluido el subconjunto HTML en línea permitido y el rechazo de etiquetas sin procesar no permitidas.
- Cobertura de serialización de inventario de niveles de objetos duraderos en `tests/unit/tier-inventory-do.test.ts`
- Guiones de humo locales contra la campaña mutable de solo prueba:
  - `scripts/test-worker.sh` para verificaciones de contrato de sitio/trabajador y verificación de `/checkout-intent/start` con formato incorrecto
  - `scripts/smoke-pledge-management.sh` para una cobertura de modificación/cancelación exitosa en la campaña mutable solo local, utilizando las respuestas de reconstrucción del administrador más verificaciones de deriva de proyección de solo lectura como fuente autorizada de estadísticas/inventario durante el humo.
- Suite de unidad completa a través de `npm run test:unit`
- Paquete de seguridad a través de `npm run test:security` contra un trabajador local iniciado automáticamente
- Suite de seguridad respaldada por Podman a través de `npm run test:security:podman` cuando desea que el sitio/pila de trabajo se inicie y se ejerza en la misma invocación.
- Dramaturgo sin cabeza E2E vía `npm run test:e2e:headless`

El script previo a la fusión ahora inicia automáticamente Jekyll con `_config.yml,_config.local.yml` cuando es necesario, de modo que la campaña `smoke-editable` solo local esté disponible durante la activación de la fusión y el arnés Playwright use la misma configuración combinada localmente.
Esa puerta ahora intenta primero la ruta del host Bundler/Jekyll, incluido un intento único de `bundle install` cuando Bundler está presente pero faltan gemas. Mantiene el humo del trabajador del host más ligero, pero ejecuta el humo de compromiso mutable a través de la pila respaldada por Podman para que la ruta de modificación/cancelación con estado utilice un estado de servicio local aislado incluso cuando la ruta de compilación del host tiene éxito. Si la ruta Ruby del host aún no puede compilarse limpiamente, recurre a una compilación Jekyll respaldada por Podman más los asistentes de navegador/humo compatibles con Podman restantes en lugar de fallar solo en la configuración del host.
Para ejecuciones de navegadores sin cabeza, Playwright ahora construye un `_site` estático y sirve esa salida con un servidor HTTP liviano en lugar de usar `jekyll serve`, lo que mantiene las comprobaciones automatizadas del navegador más cercanas al diseño real de los activos publicados.

Esta rama ahora tiene como valor predeterminado la ruta de tiempo de ejecución/carro propio tanto en `_config.yml` como en `_config.local.yml`, y la ruta del navegador ya no admite el antiguo tiempo de ejecución del carro alojado.

El reciente refuerzo de seguridad que ahora cubre la puerta incluye:

- comportamiento de cierre fallido de `GET /pledge` cuando existe un token de enlace mágico pero la fila de compromiso no
- Neutralización del esquema de enlaces de Markdown en contenido de formato largo
- Validación de origen exacto para incrustaciones estructuradas (`spotify`, `youtube`, `vimeo`)
- reservas serializadas de inventario de nivel limitado al inicio del pago y confirmación en el momento de persistencia exitosa

Los valores predeterminados del trabajador local en [worker/wrangler.toml](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml) ahora coinciden con la configuración propia. `./scripts/dev.sh --podman` ahora genera automáticamente un `CHECKOUT_INTENT_SECRET` local en `worker/.dev.vars` si falta, por lo que los nuevos inicios de pago local no fallan al cerrarse en un secreto de desarrollo no inicializado.

Para trabajo local, prefiera `./scripts/dev.sh --podman`. Inicia a Jekyll y al Trabajador en contenedores Podman desarraigados, preservando al mismo tiempo los mismos puertos y el estado local de Wrangler.

[`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml) ahora es una capa de solo anulación, no una segunda configuración base. Cuando cambie o agregue configuraciones de orientación hacia la fork, prefiera [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) a menos que el valor realmente difiera solo en su máquina local.

Los scripts de ayuda del navegador admiten el mismo modo:

```bash
./scripts/test-checkout.sh --podman
./scripts/test-e2e.sh --podman
./scripts/test-worker.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/pledge-report.sh --podman --local
./scripts/fulfillment-report.sh --podman --local
```

Esos ayudantes todavía ejecutan Playwright y shell smoke logic en el host por ahora, pero primero inician el sitio y el Worker a través de la pila local compartida respaldada por Podman. Los scripts de informes ahora también se pueden ejecutar directamente a través del contenedor de trabajadores. Esto mantiene las pruebas y exportaciones locales más cerca de los límites del servicio similar a la producción sin forzar la configuración del host Ruby o Wrangler.

Para los comandos del lado del host que necesitan la pila respaldada por Podman pero que no deben depender de la persistencia de la pila separada en shells separados, use [`scripts/podman-stack-run.sh`](https://github.com/your-org/your-project/blob/main/scripts/podman-stack-run.sh). `npm run test:security:podman` usa ese contenedor.

Para una ruta de navegador mayoritariamente independiente del host, `npm run test:e2e:headless:podman` ahora ejecuta la suite Playwright automatizada dentro de un contenedor Podman dedicado en la misma red de pod local que el sitio y el Worker.

La cobertura reciente del navegador también incluye aserciones de ventanas gráficas móviles dedicadas para:

- páginas de campaña y controles públicos secundarios
- Cajones de carrito/caja en tamaños de teléfono pequeños
- Administre la accesibilidad de la tarjeta de promesa y actualización en ventanas gráficas móviles cortas
- controles sin desbordamiento horizontal en las principales vías públicas y de gestión de promesas

La cobertura reciente de páginas públicas ahora también protege el Chrome de campaña más localizado, que incluye:

- Estados de carga/reproducción de vídeo heroico
- copia teaser de la comunidad de seguidores
- etiquetas de pestañas del diario y estados vacíos
- etiquetas de la fase de producción y copia de CTA
- etiquetas de accesibilidad de la galería

El conjunto de filtros de seguridad de contenido en `tests/unit/content-safety-filter.test.ts` también recurre a Podman cuando las gemas del host Bundler/Jekyll no están disponibles. En macOS, puede iniciar la máquina Podman como parte de ese respaldo.

El alcance actual de Podman es intencionalmente limitado:

- incluido: Jekyll, Worker, `worker/.dev.vars` local, estado de Wrangler local, reenvío CLI de Stripe de host opcional, `test-checkout.sh`, `test-e2e.sh`, `test-worker.sh`, `smoke-pledge-management.sh`, `pledge-report.sh` y `fulfillment-report.sh` compatibles con Podman
- También se incluye: Playwright sin cabeza en contenedores para el conjunto de navegadores automatizados.
- aún no incluido: un paso del navegador de pago manual interactivo en contenedores

Utilice [docs/PODMAN.md](/es/docs/operations/podman-local-dev/) para conocer la configuración exacta y las limitaciones actuales.

Si cambia `pricing.sales_tax_rate` o `pricing.flat_shipping_rate` en la configuración de Jekyll, el repositorio ahora sincroniza automáticamente los valores de Worker reflejados en [worker/wrangler.toml](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml) a través de las rutas principales de desarrollo/prueba. Reinicie `./scripts/dev.sh --podman` antes de probar las matemáticas de pago para que ambos servicios recojan los nuevos valores.

Si ajusta el comportamiento de lectura del plan gratuito, manténgalos sincronizados también:

- `cache.live_stats_ttl_seconds`
- `cache.live_inventory_ttl_seconds`

Después de cambiar el TTL de la caché localmente, reinicie `./scripts/dev.sh --podman` y vuelva a ejecutar:

```bash
npx vitest run tests/unit/live-stats.test.ts tests/unit/manage-page.test.ts tests/unit/config-boot.test.ts
```

Esas suites protegen la ruta de lectura combinada `/live/:slug`, el comportamiento de la caché del navegador y el cableado de arranque de configuración del que dependen las forks.

En GitHub, la misma puerta se ejecuta automáticamente en el flujo de trabajo `Merge Smoke` para solicitudes de extracción dirigidas a `main`.

La puerta de fusión ahora escribe un archivo de registro por fase e imprime un resumen final de PASA/FALLA con las rutas de registro. Si falla una fase tardía respaldada por Podman, comience con el directorio de registro impreso al final de la ejecución en lugar de desplazarse por toda la transcripción.

### Auditoría secreta

Ejecute esto antes de presionar cuando los secretos locales hayan cambiado, o deje que `npm run test:premerge` lo ejecute automáticamente:

```bash
npm run test:secrets
```

La auditoría comprueba:

- `worker/.dev.vars` permanece ignorado y sin seguimiento
- Los valores secretos no permitidos de los archivos env locales no aparecen en los archivos de repositorio con o sin seguimiento.
- esos valores no aparecen en el historial de git

CI permanece seguro cuando `worker/.dev.vars` no existe; en ese caso, la auditoría aún verifica las reglas de ignorar y omite el escaneo de valores locales.

### Comparación de sucursales principales

Ejecute la misma puerta automatizada en `main` en un árbol de trabajo limpio para que la línea base y la rama del parche sean directamente comparables. Si `main` es anterior a `test:premerge`, ejecute manualmente allí los comandos de sintaxis, unidad, seguridad y E2E equivalentes.

```bash
git worktree add ../pool-main-check main
ln -s "$(pwd)/node_modules" ../pool-main-check/node_modules
cd ../pool-main-check
npm run test:premerge
```

Si crea el árbol de trabajo temporal, elimínelo después de la comparación:

```bash
cd -
git worktree remove ../pool-main-check
```

### Lista de verificación manual de humo

Ejecútelos contra la preparación antes de fusionarlos cuando exista un entorno de preparación. Si no existe un entorno de prueba para The Pool, ejecute la misma lista de verificación localmente con `./scripts/dev.sh --podman` y registre esa excepción en las notas de la versión/PR.

1. Inicie un nuevo pago en una campaña de prueba en vivo y confirme que `/checkout-intent/start` devuelve un arranque de sesión personalizado en modo personalizado o una URL alojada en modo alternativo alojado.
2. Complete una promesa y verifique que el webhook almacene la promesa, la actualización de estadísticas y la ruta del correo electrónico de confirmación se mantenga en buen estado.
3. Modifique una promesa con cambios de nivel/soporte/cantidad personalizada y verifique los totales, el historial y la actualización del inventario correctamente.
4. Cancele una promesa no cargada y verifique que las estadísticas y el inventario se publiquen correctamente.
5. Realice ensayos de liquidación y ejecución real de las promesas iniciales, confirmando que las campañas solo marcan el acuerdo cuando nada necesita atención.
6. Active transmisiones de diarios, anuncios e hitos en una campaña lo suficientemente grande como para cruzar los límites de paginación.

Para cambios en la lógica empresarial de pago o de trabajador, aún se requiere un pase de humo antes de fusionar:

- Prefiere la puesta en escena cuando esté disponible.
- Si no existe ninguna preparación, utilice la ruta local más segura:
  - `./scripts/dev.sh --podman`
  - `./scripts/smoke-pledge-management.sh`
  - la lista de verificación del operador en [docs/MERGE_SMOKE_CHECKLIST.md](/es/docs/operations/merge-smoke-checklist/)
  - una nota de relaciones públicas que indique explícitamente que no existe un entorno de prueba

Para obtener una versión lista para el operador con comandos exactos y resultados esperados, use [docs/MERGE_SMOKE_CHECKLIST.md](/es/docs/operations/merge-smoke-checklist/).

Para un ensayo local de gestión de promesas, prefiera la campaña `smoke-editable`. Es solo local a través de `test_only: true`, permanece activo mucho más allá de la ventana de humo normal y le brinda a `/test/setup` un objetivo estable para la cobertura de modificación/cancelación.

Puedes ejercitar ese camino de principio a fin con:

```bash
./scripts/smoke-pledge-management.sh
```

Cuando `ADMIN_SECRET` está disponible, esa ruta de humo ahora también verifica que la campaña permanezca limpia en la proyección después de la configuración, modificación y cancelación llamando al punto final de solo lectura `POST /stats/:slug/check` entre fases de mutación.

Para la verificación CSV local con respecto a su estado de trabajador local real, utilice:

```bash
./scripts/pledge-report.sh --local
./scripts/fulfillment-report.sh --local
```

Utilice `pledge-report.sh` cuando desee el libro mayor completo, incluidas las deltas de modificación/cancelación y las anotaciones de cambio de propinas. Utilice `fulfillment-report.sh` cuando desee fusionar el estado actual de un patrocinador dentro de una campaña.

Si la vista de cumplimiento fusionada y el sitio público alguna vez no están de acuerdo para una campaña, trátelo primero como un problema probable de estadísticas obsoletas/proyección de inventario, no como un error de notificación de forma predeterminada. Las estadísticas de administración y los puntos finales de recálculo de inventario ahora reparan índices `campaign-pledges:{slug}` obsoletos mientras reconstruyen el estado de proyección de la campaña.

Antes de reparar una proyección, ahora puede comprobar explícitamente la desviación:

```bash
./scripts/check-projections.sh                 # Check all campaigns
./scripts/check-projections.sh hand-relations  # Check one campaign
./scripts/check-projections.sh --podman        # Reuse/start the Podman dev stack first
```

Ese script llama a los puntos finales de verificación de deriva del administrador de solo lectura y sale de un valor distinto de cero cuando las proyecciones almacenadas `campaign-pledges:{slug}`, `stats:{slug}` o `tier-inventory:{slug}` ya no coinciden con la verdad del compromiso activo.

### Cambios de comportamiento intencionales

Al revisar los resultados, no los marque como regresiones:

- Los enlaces mágicos ahora tienen un alcance de pedido en lugar de un alcance de correo electrónico.
- `/checkout-intent/start` ahora reserva un inventario limitado y escaso antes de la confirmación del pago, y la persistencia exitosa confirma esa reserva.
- El `GET /checkout` heredado está deshabilitado intencionalmente.

### Agregar pruebas

Cree archivos en `tests/unit/` con la extensión `.test.ts`:

```typescript
import { describe, it, expect } from 'vitest';

describe('myFunction', () => {
  it('does something', () => {
    expect(myFunction()).toBe(expected);
  });
});
```

---

## Pruebas E2E (Dramaturgo)

Pruebas basadas en navegador para flujos de usuarios completos en `tests/e2e/`.

### Cobertura

**Estructura de la página de campaña:**
- Elementos de página requeridos (héroe, barra lateral, barra de progreso)
- Atributos de datos de la barra de progreso para live-stats.js
- Marcadores de hitos (1/3, 2/3, meta)
- Marcadores de meta estirados

**Tarjetas de nivel:**
- Atributos y ganchos de artículos de carrito propios
- Visualización de inventario para niveles limitados
- Estado de bloqueo de nivel cerrado e insignia de desbloqueo
- Estados deshabilitados en campañas no activas

**Productos físicos y envío:**
- Campo personalizado `_category` (físico/digital) en botones de nivel
- Los niveles físicos activan el estado de expectativa de envío propio antes de la recolección de Stripe
- Las campañas solo digitales no tienen niveles de categorías físicas

**Artículos de soporte:**
- Estructura (cantidad, progreso, entrada, botón)
- Entrada → sincronización de precios del carrito propio
- Atributos de datos de soporte tardío

**Cantidad personalizada:**
- Atributos de estructura y datos
- Entrada → sincronización de precios del carrito propio
- Atributos de soporte tardío

**Tarjetas de página de inicio y campaña:**
- Visualización de tarjetas y elementos requeridos.
- Enlaces de campaña válidos
- Atributos del botón de nivel destacado

**Integración en tiempo de ejecución del carrito:**
- Arranque en tiempo de ejecución y raíz de carrito neutral
- POOL_CONFIG para live-stats.js
- Funciones globales (refreshLiveStats, getTierInventory)

**Flujo del carrito:**
- Navegación y añadir al carrito
- Estado del carrito a través de PoolCartProvider
- Autocompletar de facturación/estado de pago controlado por el proveedor
- El control deslizante de propinas actualiza los totales del carrito inmediatamente
- Las campañas de un solo nivel reemplazan el nivel anterior inmediatamente cuando se selecciona un nuevo nivel.
- La vista previa del pago propio publica cargas útiles canónicas en `/checkout-intent/start`
- Las páginas de resultados canceladas o exitosas de origen restauran o hidratan el estado del compromiso guardado

**Administrar flujo:**
- Carga de promesas respaldadas por tokens en `/manage/`
- Inicio de actualización del método de pago para promesas activas y `payment_failed`
- Cancelar publicaciones de confirmación en `/pledge/cancel`
- Modificar publicaciones de confirmación a `/pledge/modify`

**Accesibilidad:**
- Saltar enlace
- Hito de contenido principal
- Etiquetas de botones accesibles
- Etiquetas de entrada de formulario

**Temporizadores de cuenta regresiva:**
- Valores pre-renderizados (sin flash "00 00 00 00")
- El temporizador se actualiza cada segundo.

**Estados de la campaña:**
- Niveles habilitados para campañas en vivo
- Próximos niveles de campaña inhabilitados
- Indicadores estatales en progreso meta

**Aspectos destacados de la cobertura de pago:**
- Flujo completo del compromiso: tiempo de ejecución del carrito → revisión del compromiso → paso de pago de Stripe en el sitio → página de éxito
- Verifique que la vista previa del resumen del pedido de pago aparezca inmediatamente y se resuelva en totales que tengan en cuenta las propinas
- Cobertura de prueba de integración de API de trabajador para estadísticas en vivo y arranque de pago

### Correr

```bash
npm run test:e2e           # Full suite (auto-starts Jekyll)
npm run test:e2e:quick     # Headed mode (requires running server)
npm run test:e2e:headless  # CI mode (headless)
npm run test:e2e:parity    # Critical cart/manage browser regressions
npm run test:e2e:ui        # Interactive UI mode
```

### Agregar pruebas

Cree archivos en `tests/e2e/` con la extensión `.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test('user can do something', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('.element')).toBeVisible();
});
```

---

## Pruebas de seguridad (Vitest)

Pruebas de penetración para la API Worker. Ubicado en `tests/security/`.

### Cobertura

|categoría|Pruebas|
|----------|-------|
|Omisión de autenticación|Omisión de token de desarrollo, validación de token, caducidad, manipulación|
|Seguridad del webhook|Verificación de firma de franja, manejo de eventos duplicados, inyección de dirección de envío, manejo de webhooks heredados eliminados|
|Autorización|Puntos finales de administración, acceso entre usuarios, protecciones de puntos finales de prueba|
|Validación de entrada|XSS, inyección, desbordamiento, entrada con formato incorrecto, hasAbuso de bandera física, manipulación de tarifas de envío, niveles adicionales/inyección de artículos de soporte|
|Limitación de tasa|Solicitudes de ráfaga, resistencia DoS|

### Correr

```bash
# Start local Worker first
cd worker && wrangler dev

# In another terminal:
npm run test:security                # Against localhost:8787

# Against staging, if you maintain one:
npm run test:security:staging

# Against production (read-only tests):
WORKER_URL=https://worker.example.com PROD_MODE=true npm run test:security
```

### Requisitos previos

- Trabajador que se ejecuta localmente (`wrangler dev`) o URL de preparación/producción accesible
- Para una cobertura de prueba completa, establezca las variables de entorno:
  - `WORKER_URL`: URL base (predeterminada: `http://localhost:8787`)
  - `PROD_MODE`: omitir pruebas destructivas (predeterminado: `false`)
  - `ADMIN_SECRET`: para pruebas de autenticación de administrador
  - `TEST_TOKEN` — Token de enlace mágico válido

Consulte [tests/security/README.md](/es/docs/operations/security-test-suite/) para obtener más detalles.

---

## Requisitos previos de las pruebas manuales

- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) (`npm install -g wrangler`)
- [Stripe CLI](https://stripe.com/docs/stripe-cli) para pruebas de webhook
- Cuenta Stripe (modo de prueba)
- Reenviar cuenta (nivel gratuito: 3000 correos electrónicos/mes)

---

## 1. Configuración del trabajador de Cloudflare

### Crear espacios de nombres KV

```bash
wrangler login
wrangler kv:namespace create "VOTES"
wrangler kv:namespace create "VOTES" --preview
wrangler kv:namespace create "PLEDGES"
wrangler kv:namespace create "PLEDGES" --preview
```

### Establecer secretos

```bash
cd worker
openssl rand -base64 32

wrangler secret put STRIPE_SECRET_KEY
wrangler secret put MAGIC_LINK_SECRET
wrangler secret put CHECKOUT_INTENT_SECRET
wrangler secret put RESEND_API_KEY
wrangler secret put ADMIN_SECRET
```

### Ejecutar trabajador localmente

Privilegiado:

```bash
./scripts/dev.sh --podman
```

Respaldo manual:

```bash
cd worker
npx wrangler dev --env dev --port 8787
```

## 2. Reenviar configuración

### Crear cuenta y clave API

1. Regístrese en [resend.com](https://resend.com)
2. Vaya a **Claves API** → **Crear clave API**
3. Nombre: "Desarrollador de proyectos"
4. Permiso: "Enviando acceso"
5. Copie la clave (comienza con `re_`)

### Verificar dominio (para producción)

1. Vaya a **Dominios** → **Agregar dominio**
2. Agregue su dominio de envío verificado
3. Agregue los registros DNS que proporciona Reenviar
4. Esperar verificación

### Modo de prueba (no se necesita dominio)

Para realizar pruebas, puede enviar a su propio correo electrónico sin verificación de dominio:
- Reenviar permite enviar desde `onboarding@resend.dev` en modo de prueba
- O utilice su correo electrónico personal verificado

### Envío de correo electrónico de prueba

```bash
curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer re_YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "onboarding@resend.dev",
    "to": "your-email@example.com",
    "subject": "Test from your deployment",
    "html": "<p>Magic link test!</p>"
  }'
```

---

## 3. Configuración de franjas (modo de prueba)

### Obtener claves de prueba

1. Inicie sesión en [dashboard.stripe.com](https://dashboard.stripe.com)
2. Cambiar a **Modo de prueba** (arriba a la derecha)
3. Vaya a **Desarrolladores** → **Claves API**
4. Copiar **Clave secreta** (`sk_test_...`)

### Instalar CLI de banda

```bash
# macOS
brew install stripe/stripe-cli/stripe

# Login
stripe login
```

### Reenviar webhooks al trabajador local

Opción preferida para pruebas locales de un extremo a otro:

```bash
./scripts/dev.sh --podman
```

Esto inicia el reenvío Jekyll, the Worker, Stripe CLI y escribe el `STRIPE_WEBHOOK_SECRET` coincidente en `worker/.dev.vars`.
También borra los procesos obsoletos en los puertos `4000`, `8787` y `4040` para que la pila local coincida con el arnés de prueba/humo automatizado.

Respaldo manual:

```bash
# Forward Stripe webhooks to your local Worker
stripe listen --forward-to 127.0.0.1:8787/webhooks/stripe
# Note the webhook signing secret it outputs (whsec_...)
```

Agregue el secreto del webhook a su configuración de trabajador local:
```bash
printf '\nSTRIPE_WEBHOOK_SECRET=whsec_...\n' >> worker/.dev.vars
# Or edit worker/.dev.vars and replace the existing STRIPE_WEBHOOK_SECRET value
```

---

## 4. Prueba completa de un extremo a otro

### Iniciar todos los servicios

Privilegiado:

```bash
./scripts/dev.sh --podman
```

Respaldo manual:

Terminal 1 - Jekyll:
```bash
bundle exec jekyll serve --config _config.yml,_config.local.yml --port 4000
# Site at http://127.0.0.1:4000
```

Terminal 2 - Trabajador:
```bash
cd worker
npx wrangler dev --env dev --port 8787
# Worker at http://127.0.0.1:8787
```

Terminal 3 - CLI de banda:
```bash
stripe listen --forward-to 127.0.0.1:8787/webhooks/stripe
```

### Pruebe el flujo

1. **Añadir al carrito**: Ir a http://127.0.0.1:4000/campaigns/hand-relations/
   - Haga clic en "Prometer $5" en un nivel
   - El carrito se abre con el artículo.

2. **Pagar**: haga clic en "Continuar con el compromiso" en la revisión del carrito propio
   - Verifique que la reseña muestre el subtotal + propina + impuestos + envío inmediatamente
   - Utilice la tarjeta de prueba Stripe: `4242 4242 4242 4242`
   - Cualquier vencimiento futuro, cualquier CVC

3. **Configuración de Stripe**: el segundo sidecar de pago lo mantiene en el sitio y monta la interfaz de usuario de pago seguro de Stripe.
   - La tarjeta está guardada (no cargada)
   - El cliente espera la confirmación de persistencia del compromiso antes de considerar el flujo como exitoso.
   - Luego serás enviado a la página de éxito.

4. **Consultar correo electrónico**: Deberías recibir los correos electrónicos de los seguidores con enlaces mágicos.

5. **Pruebe el acceso a la comunidad**:
   - Haga clic en el enlace de la comunidad en el correo electrónico.
   - O utilice: http://127.0.0.1:4000/community/hand-relations/?dev=1

6. **Votación de prueba**:
   - Votar sobre una decisión
   - Actualizar página: tu voto debe persistir

### Tarjetas de prueba de rayas

|Número de tarjeta|Escenario|
|-------------|----------|
|`4242 4242 4242 4242`|Guardado/configuración exitosos|
|`4000 0000 0000 3220`|Se requiere 3D Secure|
|`4000 0000 0000 9995`|Rechazado (fondos insuficientes)|
|`4000 0000 0000 0002`|Rechazado (genérico)|

---

## 5. Prueba de componentes individuales

### Prueba de ficha de enlace mágico

```js
// In browser console on any page with the Worker running
const token = 'YOUR_TOKEN';
fetch(`http://localhost:8787/pledge?token=${token}`)
  .then(r => r.json())
  .then(console.log);
```

### API de votación de prueba

```bash
# Get vote status
curl "http://localhost:8787/votes?token=YOUR_TOKEN&decisions=poster,festival"

# Cast vote
curl -X POST http://localhost:8787/votes \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN","decisionId":"poster","option":"A"}'
```

### Pruebe KV localmente

```bash
# List keys
wrangler kv:key list --binding VOTES --preview

# Get a value
wrangler kv:key get "results:hand-relations:poster" --binding VOTES --preview
```

---

## 6. Solución de problemas

### El inicio del proceso de pago falla y se cierra
- Verifique que `CHECKOUT_INTENT_SECRET` exista en `worker/.dev.vars`
- Confirme que la carga útil del carrito utilice ID de artículo propios válidos, como `{campaignSlug}__{tierId}`.

### Webhook no recibido
- Verifique que Stripe CLI se esté ejecutando y reenviando
- Verificar registros de trabajadores: `wrangler tail`
- Verificar que el secreto del webhook esté configurado

### Correo electrónico no enviado
- Verifique Reenviar panel para ver si hay errores
- Verifique que la clave API sea correcta
- Verifique que la dirección "de" esté verificada o use `onboarding@resend.dev`

### La página de la comunidad muestra "Acceso denegado"
- Utilice `?dev=1` para pruebas locales sin trabajador
- Verificar clave de almacenamiento de sesión: `supporter_token_hand-relations`

### Los votos no persisten
- Verifique el enlace KV en wrangler.toml
- Utilice el espacio de nombres `--preview` para desarrolladores locales
- Verifique los registros de trabajadores en busca de errores

---

## 7. Mejoras para los trabajadores de pruebas

### Validación de campaña de prueba

1. **Construye Jekyll para generar campañas.json:**
   ```bash
   bundle exec jekyll build
   cat _site/api/campaigns.json  # Verify it exists
   ```

2. **Prueba de inicio de pago propio con formato incorrecto:**
   ```bash
   curl -X POST http://localhost:8787/checkout-intent/start \
     -H "Content-Type: application/json" \
     -d '{"campaignSlug":"hand-relations","items":[{"id":"bad-item","quantity":1}],"email":"test@example.com"}'
   ```
Esperado: Devuelve un error de validación de cierre fallido como `Invalid cart item id`

### Verificación de firma de Test Stripe Webhook

1. **Asegúrese de que Stripe CLI reenvíe webhooks:**
   ```bash
   ./scripts/dev.sh --podman
   # Or, manually: stripe listen --forward-to localhost:8787/webhooks/stripe
   ```

2. **Establecer el secreto del webhook:**
   ```bash
   # scripts/dev.sh --podman does this automatically for worker/.dev.vars
   # Manual setup only if you are not using the main Podman dev script
   ```

3. **Activar un webhook de prueba:**
   ```bash
   stripe trigger checkout.session.completed
   ```
Verifique los registros de trabajadores para ver el mensaje "Compromiso confirmado".

4. **Prueba de firma no válida (debe fallar):**
   ```bash
   curl -X POST http://localhost:8787/webhooks/stripe \
     -H "stripe-signature: invalid" \
     -d '{"type":"test"}'
   ```
Esperado: `{"error":"Invalid signature"}`

### Prueba de metadatos de compromiso almacenados

Después de completar un flujo de contribución:

1. **Consulte los datos de las promesas respaldadas por los trabajadores** a través de `/pledge?token=...`
2. **Verifique que los datos contengan:**
   - `stripeCustomerId`
   - `stripePaymentMethodId`
   - `pledgeStatus: "active"`
   - `charged: false`

### Puntos finales de gestión de promesas de prueba

1. **Obtenga detalles de la promesa (requiere un token válido):**
   ```bash
   # Use token from supporter email
   curl "http://localhost:8787/pledge?token=YOUR_TOKEN"
   ```
Esperado: devuelve detalles del pedido con indicadores `canModify`, `canCancel`.

2. **Cancelar compromiso:**
   ```bash
   curl -X POST http://localhost:8787/pledge/cancel \
     -H "Content-Type: application/json" \
     -d '{"token":"YOUR_TOKEN"}'
   ```
Esperado: `{"success":true,"message":"Pledge cancelled"}`

3. **Verificar cancelación:**
   - Consulte el compromiso ahora informa `pledgeStatus: "cancelled"`
   - Reintentar cancelar: debería obtener una respuesta de error limpia

### Método de pago de actualización de prueba

```bash
curl -X POST http://localhost:8787/pledge/payment-method/start \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN"}'
```
Esperado: devuelve un arranque de sesión personalizado para `Update Card` en el sitio o una URL alojada en modo alternativo.

### Pruebe el punto final de estadísticas en vivo

1. **Obtenga estadísticas en vivo para una campaña:**
   ```bash
   curl http://localhost:8787/stats/hand-relations
   ```
Esperado: Devuelve `{ pledgedAmount, pledgeCount, tierCounts, goalAmount, ... }`

2. **Verificar la actualización de las estadísticas después del compromiso:**
   - Haz una promesa de prueba
   - Llamar al punto final de estadísticas nuevamente
   - Confirmar que `pledgedAmount` aumentó

3. **Recalcular estadísticas (admin):**
   ```bash
   curl -X POST http://localhost:8787/stats/hand-relations/recalculate \
     -H "Authorization: Bearer YOUR_ADMIN_SECRET"
   ```

### Activador de reconstrucción de administrador de prueba

```bash
curl -X POST http://localhost:8787/admin/rebuild \
  -H "Authorization: Bearer YOUR_ADMIN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"reason":"test-rebuild"}'
```
Esperado: devuelve `{ success: true }` y activa el flujo de trabajo de GitHub.

---

## 8. Lista de verificación de producción

- [] Cambiar Stripe a claves en vivo
- [] Verifica tu dominio de envío en Reenviar
- [] Implementar trabajador: `wrangler deploy`
- [] Configurar el webhook de Stripe en el panel → `https://worker.example.com/webhooks/stripe`
- [ ] Pruebe con una contribución real de $1

## 9. Referencia de secretos

### Acciones de GitHub (Repositorio → Configuración → Secretos)
- `STRIPE_SECRET_KEY` — Secreto en vivo de Stripe (sk_...)
- `CHECKOUT_INTENT_SECRET`: secreto de HMAC para la firma de intención de pago
- Utiliza `GITHUB_TOKEN` proporcionado automáticamente para confirmaciones

### Trabajador de Cloudflare (wrangler o panel → Variables)
- `STRIPE_SECRET_KEY` - igual que arriba
- `SITE_BASE` — `https://site.example.com`
- `WORKER_BASE` — `https://worker.example.com`
- `APP_MODE` — `live` o `test`
- `CHECKOUT_INTENT_SECRET`: cadena aleatoria de más de 32 caracteres para firmar el pago
- `MAGIC_LINK_SECRET`: cadena aleatoria de más de 32 caracteres para la firma de tokens HMAC
- `RESEND_API_KEY` — Reenviar clave API para correos electrónicos de soporte (re_...)
- `ADMIN_SECRET`: cadena aleatoria para puntos finales de API de administración
- `GITHUB_TOKEN`: (opcional) PAT de GitHub con alcance `workflow` para activadores de reconstrucción

### Cloudflare KV
- **Espacio de nombres**: `PLEDGES`: almacena datos de promesas y estadísticas agregadas.
  - Claves: `pledge:{orderId}` → promesa JSON
  - Claves: `email:{email}` → conjunto de ID de pedido
  - Teclas: `stats:{campaignSlug}` → `{ pledgedAmount, pledgeCount, tierCounts }`
- **Espacio de nombres**: `VOTES` — Votos de la comunidad de tiendas
  - Claves: `vote:{campaignSlug}:{decisionId}:{orderId}` → cadena de opción
  - Claves: `results:{campaignSlug}:{decisionId}` → JSON `{optionA: count, ...}`

### Panel de control de rayas
- Punto final del webhook = `https://worker.example.com/webhooks/stripe`
  - Eventos: `checkout.session.completed`
- No se requiere catálogo de productos; los montos provienen de artículos del carrito propios canonizados por los trabajadores

### Reenviar panel
- **Dominio**: verifique su dominio de envío para el remitente transaccional configurado
- **Clave API**: Crear clave con permiso de "Acceso de envío"
- Se utiliza para: todos los correos electrónicos de compromiso dirigidos a los seguidores (confirmación, acceso a la comunidad/administración, actualizaciones del diario, anuncios, éxito de los cargos, errores de pago, cancelaciones)
- Nota del desarrollador local: incluso cuando `SITE_BASE` apunta a `127.0.0.1`, las imágenes de correo electrónico incrustadas aún usan la base de recursos pública `https://site.example.com`, por lo que las vistas previas de la bandeja de entrada no muestran URL de imágenes de host local rotas.
