---
title: Desarrollo local con Podman
parent: Operaciones
nav_order: 5
render_with_liquid: false
lang: es
---

# Desarrollo local con Podman

## Última actualización

16 de julio de 2026

Este repositorio ahora incluye una ruta de desarrollo local sin raíz respaldada por Podman para los dos servicios que generalmente crean la mayor rotación de configuración de host:

- sitio jekyll
- Servidor de desarrollo local Cloudflare Worker

El objetivo es facilitar el arranque local para las bifurcaciones y al mismo tiempo preservar la seguridad y los límites similares a los de producción.

## Alcance actual

Incluido hoy:

- Contenedores Podman desarraigados para Jekyll y el Trabajador
- los mismos puertos locales que el flujo de host:
  - `http://127.0.0.1:4000`
  - `http://127.0.0.1:8787`
- fuente de repositorio montada en enlace para una iteración rápida sin reconstrucción de imágenes en cambios de código normales
- El estado local de Wrangler persistió en el árbol de trabajo del repositorio.
- Imagen de desarrollo del trabajador basada en el Nodo 24, que coincide con el tiempo de ejecución de implementación de GitHub Actions
- Uso local de `worker/.dev.vars`, incluida la generación automática de `CHECKOUT_INTENT_SECRET`.
- Valores predeterminados del panel de administración local, incluido el correo electrónico de administrador de arranque de `worker/.dev.vars` y el cableado de origen CORS para `http://127.0.0.1:4000`
- Reenvío opcional de CLI de Stripe del host al trabajador local
- Descubrimiento automático de Stripe CLI desde rutas de instalación comunes de macOS/Homebrew
- Ejecución automatizada de Playwright sin cabeza en un contenedor Podman dedicado
- Scripts de ayuda para informes locales, de pago, E2E, de trabajador, de aporte mutable y compatibles con Podman
- soporte de respaldo previo a la fusión para la compilación de Jekyll y las fases de humo/navegador locales en máquinas sin un host funcional Bundler/cadena de herramientas Jekyll

Aún no incluido:

- un paso del navegador de pago manual en contenedores
- verdadera validación de host para Linux y Windows en este hilo de repositorio

Eso es intencional. La primera parte está destinada a mejorar la incorporación y la paridad local sin correr el riesgo de regresiones en las aplicaciones.

## Por qué existe este camino

El modo Podman está diseñado en torno a tres prioridades:

1. Seguridad
- solo contenedores desarraigados
- sin contenedores privilegiados
- Los secretos permanecen en archivos env locales, no integrados en imágenes.

2. paridad
- Los mismos puertos que el flujo de host actual.
- mismo modelo de estado de trabajador local a través de `wrangler dev`
- misma superposición de configuración local de Jekyll a través de `_config.yml,_config.local.yml`
- Mismo modelo de configuración estructurado, con `_config.local.yml` mantenido intencionalmente delgado para anulaciones locales de la máquina.

3. Horquillabilidad
- no se requiere host Ruby para el inicio de la aplicación happy-path
- no se requiere host Wrangler para el inicio de la aplicación happy-path
- la fuente está montada en enlace, por lo que los cambios normales de código no requieren reconstrucciones de imágenes

## Requisitos previos

- [Podman](https://podman.io/docs/installation)
- opcional: [Stripe CLI](https://stripe.com/docs/stripe-cli) si desea reenvío de webhook local

## Matriz de soporte

|SO anfitrión|modelo podman|Estado actual|
|---------|--------------|----------------|
|macos|`podman machine` máquina virtual|Validado por host en esta rama. Prefiera `libkrun` si `applehv` es inestable.|
|linux|Podman nativo desarraigado|Compatible con la lógica del iniciador y el flujo de autoverificación, pero no validado por el host en este hilo.|
|ventanas|`podman machine` máquina virtual|Compatible con la lógica del iniciador y el flujo de autoverificación cuando se ejecuta desde un shell compatible con bash, pero no validado por el host en este hilo.|

En macOS y Windows, `./scripts/dev.sh --podman` inicializará/iniciará el `podman machine` predeterminado cuando sea necesario. En Linux, el iniciador omite la administración de la máquina y se comunica directamente con el motor Podman local sin raíz.

Si Podman en macOS aparece en el backend `applehv` anterior y el inicio de la máquina es inestable, prefiera `libkrun` en `~/.config/containers/containers.conf`:

```toml
[machine]
provider = "libkrun"
```

## Iniciar desarrollo local

Consulte al médico primero si desea una verificación rápida de preparación:

```bash
npm run podman:doctor
npm run podman:self-check
```

En macOS y Windows, el desarrollo normal advierte cuando la máquina Podman tiene menos de 6144 MiB. Las fases `npm run test:premerge` y `npm run release:smoke -- --podman-e2e` requeridas imponen ese mínimo en poco tiempo. Cambie el tamaño de una máquina parada con `podman machine set --memory 6144`, reiníciela y vuelva a ejecutar el doctor. El flujo de trabajo semanal/manual `.github/workflows/podman-e2e.yml` ejercita por separado la ruta Podman de Linux sin raíz sin implementar nada.

`npm run podman:self-check` es el pase de confianza automatizado más potente en esta rama. Ejecuta al médico, inicia la pila respaldada por Podman, ejecuta el humo del trabajador y ejecuta la suite automatizada Playwright en un contenedor.

Más concretamente, la autocomprobación cubre:

- `npm run podman:doctor`
- `./scripts/dev.sh --podman`
- `./scripts/test-worker.sh --podman`
- `npm run test:e2e:headless:podman`

La puerta de fusión más amplia también ejecuta `./scripts/smoke-pledge-management.sh --podman`, por lo que la ruta de modificación/cancelación mutable aún obtiene una cobertura de estado aislada incluso cuando las fases de compilación del host se realizan correctamente.

Ese humo de aporte mutable ahora también sigue siendo compatible con configuraciones impositivas impulsadas por el proveedor, como `tax.provider: nm_grt`: la ruta del accesorio de prueba del trabajador genera una dirección de facturación para que `/test/setup` pueda crear un aporte real consciente de los impuestos en lugar de asumir un impuesto fijo.

Desde la raíz del repositorio:

```bash
./scripts/dev.sh --podman
```

Eso será:

- asegúrese de que Podman esté disponible y desarraigado
- cree las imágenes de desarrollo de Jekyll y Worker si es necesario
- crear un pod Podman con los puertos locales estándar
- montar el repositorio en ambos contenedores
- generar automáticamente secretos `worker/.dev.vars` si es necesario
- reinicie el sitio o los contenedores de trabajo automáticamente si alguno de los procesos de desarrollo sale
- Opcionalmente, inicie el reenvío de webhooks de Stripe desde el host.

Después del arranque, el panel de administración local está disponible en:

```text
http://127.0.0.1:4000/admin/
```

El trabajador local ofrece API de panel en `http://127.0.0.1:8787`, con `CORS_ALLOWED_ORIGIN` derivado para el sitio local. El panel puede ejercitar las campañas de prueba locales inicializadas y el KV local. La gestión de usuarios del panel guarda la escritura en KV local (`admin-users:v1`) en lugar de comprometerse con GitHub. La configuración de Dev Worker también establece `ADMIN_LOCAL_REPO_WRITES_ENABLED=true` e inicia un asistente de repositorio local protegido por token en la dirección de bucle invertido del contenedor de Worker, por lo que **Crear nueva campaña** y **Archivar campaña** pueden escribir/mover archivos en el repositorio montado en lugar de depender del envío del flujo de trabajo de GitHub mientras se realizan pruebas localmente.

Foreground `./scripts/dev.sh --podman` también supervisa el módulo de desarrollo. Si Jekyll o Wrangler salen, el iniciador imprime registros recientes, reinicia el contenedor detenido y recrea el pod si un reinicio directo no es suficiente. Se vuelve a intentar la recreación del pod porque Podman ocasionalmente puede devolver errores de inicio parcial como `starting some containers: internal libpod error`; entre intentos, el iniciador elimina contenedores/pods de desarrollo parciales por nombre y etiqueta de pila de desarrollo, verifica que los artefactos antiguos hayan desaparecido, espera a que se libere el puerto de Podman, actualiza la conexión de Podman y reinicia la máquina Podman en macOS/Windows si la limpieza por sí sola no borra el estado obsoleto. El iniciador también inicia el pod vacío antes de agregar el sitio y los contenedores de trabajo, lo que evita una ruta de Podman inestable donde un pod creado puede dejar `pool-dev-site` creado y `pool-dev-worker` perdido. Las comprobaciones de preparación de Jekyll esperan la página `/admin/` real en lugar de cualquier respuesta HTTP, por lo que un oyente obsoleto o un sitio aún en construcción no cuentan como listos. Ajuste el intervalo de verificación con `PODMAN_SUPERVISE_INTERVAL`, la cola del registro de reinicio con `PODMAN_SUPERVISE_LOG_LINES`, los reintentos de inicio con `PODMAN_STACK_START_ATTEMPTS`, el retraso de reintento con `PODMAN_STACK_RETRY_DELAY`, el tiempo de espera de preparación del sitio con `PODMAN_SITE_READY_TIMEOUT` y el tiempo de espera de preparación del trabajador con `PODMAN_WORKER_READY_TIMEOUT`. Los flujos auxiliares separados aún reciben la política de reinicio `unless-stopped` de Podman en el sitio y en los contenedores de trabajadores.

## Reconstruir imágenes

Los cambios de código normales no necesitan una reconstrucción de la imagen porque el repositorio está montado en enlace.

Reconstruir cuando cambies:

- `Containerfile.dev`
- `worker/Containerfile.dev`
- requisitos del paquete del sistema
- Requisitos del optimizador de medios como `optipng`, `gifsicle`, `libjpeg-turbo-progs`, `webp` o `ffmpeg`.
- supuestos de arranque de dependencia
- Supuestos de tiempo de ejecución de Nodo/Wrangler como el trabajador `compatibility_date`

Usar:

```bash
PODMAN_REBUILD=1 ./scripts/dev.sh --podman
```

La imagen del sitio también admite los contenedores de optimización de medios locales:

```bash
npm run media:optimize:podman
npm run media:optimize:check:podman
```

Utilice `PODMAN_REBUILD=1 npm run media:optimize:podman` después de los cambios de paquete para que el contenedor del optimizador tenga las herramientas nativas PNG/GIF/JPEG/WebP/video actuales.

## Pruebas del navegador

Los scripts de ayuda del navegador ahora pueden iniciarse en la pila respaldada por Podman:

```bash
./scripts/test-checkout.sh --podman
./scripts/test-e2e.sh --podman
./scripts/test-worker.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/pledge-report.sh --podman --local
./scripts/fulfillment-report.sh --podman --local
npm run test:security:podman
npm run test:e2e:headless:podman
npm run release:smoke -- --evidence-file /tmp/pool-release-smoke.md
```

Las exportaciones de informes de producción remota también pueden ejecutarse a través del contenedor de trabajadores. Cree un token API de usuario de Cloudflare con acceso **Cuenta/Almacenamiento KV de trabajadores/Lectura** a la cuenta propietaria del espacio de nombres KV `PLEDGES`, luego guárdelo con la identificación de la cuenta en un archivo env local ignorado, como `worker/.dev.vars`:

```bash
CLOUDFLARE_API_TOKEN=your-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

Ejecutar:

```bash
./scripts/pledge-report.sh --podman --env production --remote > ~/Desktop/pool-pledge-report.csv
./scripts/fulfillment-report.sh --podman --env production --remote > ~/Desktop/pool-fulfillment-report.csv
```

Los contenedores de informes cargan la autenticación de Cloudflare desde `.env`, `.env.local`, `.env.cloudflare` y `worker/.dev.vars`, la pasan a `podman exec` e imprimen el progreso en stderr para que los archivos CSV redirigidos permanezcan limpios.

`./scripts/test-e2e.sh --podman` ahora es una cobertura de navegador totalmente automatizada. El asistente dedicado `./scripts/test-checkout.sh --podman` sigue siendo la ruta interactiva manual cuando específicamente desea realizar un pago real en su propio navegador. El conjunto de navegador automatizado sin cabeza se ejecuta en su propio contenedor Playwright y reutiliza el sitio/trabajador que ya se está ejecutando en lugar de intentar iniciar Jekyll dentro del contenedor de prueba.

El contenedor de humo de liberación utiliza la misma ruta E2E respaldada por Podman cuando Podman está disponible. Pase `--podman-e2e` para requerir esa fase para la evidencia de publicación, o `--skip-podman-e2e` solo cuando otra ejecución registrada ya cubra la misma superficie del navegador.

La evidencia de Lighthouse de ruta central también utiliza la pila Podman:

```bash
npm run test:performance:lighthouse
```

Esta es una prueba de divulgación, no un requisito de todas las relaciones públicas. Utilice la variante de host solo cuando ya esté instalado un Chromium local compatible.

Para una cobertura del navegador de panel enfocada en la pila respaldada por Podman, use:

```bash
npm run test:e2e:headless:podman -- tests/e2e/admin-dashboard.spec.ts --project=chromium
```

Esa suite enfocada es la verificación del navegador local preferida para cambios en la interfaz de usuario del administrador, como Crear nueva campaña, publicación de vista previa protegida, botón de información compartido/comportamiento de ayuda y diseño de barra lateral de Campañas responsiva.

Para comandos del lado del host que necesitan un sitio/trabajador respaldado por Podman sin asumir persistencia de pila separada, use [`scripts/podman-stack-run.sh`](https://github.com/your-org/your-project/blob/main/scripts/podman-stack-run.sh). `npm run test:security:podman` usa ese contenedor para iniciar la pila, ejecutar el paquete de seguridad y derribar la pila en una sola invocación.

El contenedor de trabajadores tiene por defecto `node:24-bookworm-slim`. Si la extracción de una imagen de Podman local se detiene pero la imagen de Playwright ya está almacenada en caché, el iniciador puede reutilizar `mcr.microsoft.com/playwright:v1.57.0-noble` como base del Nodo 24 para que el desarrollo aún coincida con el tiempo de ejecución del Nodo 24 de GitHub Actions.

Para la ruta del navegador sin cabeza del lado del host, Playwright ahora crea un `_site` estático limpio y lo sirve con un servidor HTTP liviano en lugar de depender de `jekyll serve`. Esto mantiene las regresiones del navegador más cercanas a la forma real de los activos publicados y evita cierta inestabilidad de WEBrick durante las ejecuciones paralelas.

## Primera ejecución multiplataforma

Si está configurando una bifurcación nueva, esta es la secuencia recomendada más corta:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
npm run test:e2e:headless:podman
```

Si el médico aprueba y la suite Podman sin cabeza está en verde, estás en un buen lugar para el trabajo local normal.

Tenga en cuenta que el sitio estático generado ahora excluye carpetas internas del repositorio como `worker/`, `scripts/` y `tests/`, por lo que la verificación estática local se acerca más a lo que realmente publicaría una bifurcación.

Nivel de confianza actual:

- macOS: trabajo validado por host en esta rama
- Linux: preparado y autocomprobable, pero no validado por el host aquí
- Windows: preparado y autocomprobable desde un shell compatible con bash, pero no validado por el host aquí

Las pruebas unitarias de filtro de seguridad de contenido también saben cómo recurrir a Podman cuando las gemas del host Bundler/Jekyll no están disponibles, por lo que una configuración de Ruby del host faltante ya no daña esa parte de la suite en una máquina donde Podman está en buen estado.

## Registros

Si el pod ya se está ejecutando, inspeccione los registros con:

```bash
podman logs -f pool-dev-site
podman logs -f pool-dev-worker
```

Cuando la supervisión en primer plano reinicia un servicio detenido, imprime las últimas líneas `PODMAN_SUPERVISE_LOG_LINES` para ese contenedor antes de reiniciarlo. Para mirar continuamente, mantenga abierta una terminal `podman logs -f` separada.

Si la puerta de fusión más amplia falla específicamente en `7b. Podman mutable-pledge smoke`, primero confirme que la pila esté en buen estado con:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
./scripts/smoke-pledge-management.sh --podman
```

Esa secuencia ahora ejerce la misma ruta de dispositivo de prueba con reconocimiento de ubicación en la que se basa la puerta de fusión.

Si `./scripts/dev.sh --podman` nunca supera el inicio de Podman, primero verifique la máquina:

```bash
podman machine inspect
podman machine stop
podman machine start
```

Si la máquina arrancó en modo de emergencia o se bloqueó durante el primer arranque, la recuperación más rápida es:

```bash
podman machine rm -f podman-machine-default
podman machine init --now
```

En macOS, el iniciador utiliza el socket API Unix reenviado de la máquina directamente una vez que la VM está activa. Esto evita una clase de problemas de conexión predeterminados que vimos con la CLI empaquetada.

El doctor y el iniciador ahora también realizan una breve verificación de estabilidad después del inicio para que no parpadeen en verde en una máquina que inmediatamente vuelve a caer en un estado de conexión obsoleta.

En Linux, si `podman info` falla, arregle primero la sesión local de Podman sin raíz y luego vuelva a ejecutar el doctor:

```bash
podman info
npm run podman:doctor
```

En Windows, si `podman machine` existe pero la VM está detenida, use:

```bash
podman machine start podman-machine-default
npm run podman:doctor
```

## Notas de seguridad

- El modo Podman no tiene raíces por diseño.
- El Trabajador todavía lee secretos de `worker/.dev.vars`; No se copia nada secreto en una imagen.
- El reenvío de Stripe sigue siendo un proceso del lado del host, por lo que el flujo de autenticación del navegador sigue siendo familiar y explícito.

## Notas de paridad de producción

El modo Podman no pretende clonar perfectamente la producción de Cloudflare, pero preserva las suposiciones locales más importantes:

- procesos separados del sitio y del trabajador
- Simulación local de Wrangler para KV / Objetos duraderos
- Nodo 24 en el contenedor de trabajadores, que coincide con las acciones de GitHub
- la misma fecha de compatibilidad de trabajadores utilizada en la implementación
- la misma configuración de entorno/desarrollo del trabajador utilizada por el flujo de host
- el mismo carrito propio y ruta de pago
- la misma ruta del navegador de compilación estática utilizada por el arnés sin cabeza del host

## Próximos pasos probables

Las mejoras de seguimiento más seguras son:

- Cobertura del navegador en contenedores/manual más allá de la suite automatizada sin cabeza.
- Envoltorios compatibles con Podman para cualquier script auxiliar local restante que los equipos quieran mantener dentro del mismo modelo de iniciador.
- especificación de pod declarativa opcional para equipos que prefieren un manifiesto de entorno local registrado
