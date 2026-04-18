---
title: Desarrollo local con Podman
parent: Operaciones
nav_order: 2
render_with_liquid: false
lang: es
---

# Desarrollo local con Podman

Este repositorio ahora incluye una ruta de desarrollo local sin raíz respaldada por Podman para los dos servicios que generalmente crean la mayor rotación de configuración de host:

- sitio jekyll
- Servidor de desarrollo local Cloudflare Worker

El objetivo es facilitar el arranque local para las forks y al mismo tiempo preservar la seguridad y los límites similares a los de producción.

## Alcance actual

Incluido hoy:

- Contenedores Podman desarraigados para Jekyll y el Trabajador
- los mismos puertos locales que el flujo de host:
  - `http://127.0.0.1:4000`
  - `http://127.0.0.1:8787`
- fuente de repositorio montada en enlace para una iteración rápida sin reconstrucción de imágenes en cambios de código normales
- El estado local de Wrangler persistió en el árbol de trabajo del repositorio.
- Uso local de `worker/.dev.vars`, incluida la generación automática de `CHECKOUT_INTENT_SECRET`.
- Reenvío opcional de CLI de Stripe del host al trabajador local
- Descubrimiento automático de Stripe CLI desde rutas de instalación comunes de macOS/Homebrew
- Ejecución automatizada de Playwright sin cabeza en un contenedor Podman dedicado
- Scripts de ayuda para informes locales, de pago, E2E, de trabajador, de promesa mutable y compatibles con Podman
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

`npm run podman:self-check` es el pase de confianza automatizado más potente en esta rama. Ejecuta al médico, inicia la pila respaldada por Podman, ejecuta el humo del trabajador y ejecuta la suite automatizada Playwright en un contenedor.

Más concretamente, la autocomprobación cubre:

- `npm run podman:doctor`
- `./scripts/dev.sh --podman`
- `./scripts/test-worker.sh --podman`
- `npm run test:e2e:headless:podman`

La puerta de fusión más amplia también ejecuta `./scripts/smoke-pledge-management.sh --podman`, por lo que la ruta de modificación/cancelación mutable aún obtiene una cobertura de estado aislada incluso cuando las fases de compilación del host se realizan correctamente.

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
- Opcionalmente, inicie el reenvío de webhooks de Stripe desde el host.

## Reconstruir imágenes

Los cambios de código normales no necesitan una reconstrucción de la imagen porque el repositorio está montado en enlace.

Reconstruir cuando cambies:

- `Containerfile.dev`
- `worker/Containerfile.dev`
- requisitos del paquete del sistema
- supuestos de arranque de dependencia

Usar:

```bash
PODMAN_REBUILD=1 ./scripts/dev.sh --podman
```

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
```

`./scripts/test-e2e.sh --podman` ahora es una cobertura de navegador totalmente automatizada. El asistente dedicado `./scripts/test-checkout.sh --podman` sigue siendo la ruta interactiva manual cuando específicamente desea realizar un pago real en su propio navegador. El conjunto de navegador automatizado sin cabeza se ejecuta en su propio contenedor Playwright y reutiliza el sitio/trabajador que ya se está ejecutando en lugar de intentar iniciar Jekyll dentro del contenedor de prueba.

Para comandos del lado del host que necesitan un sitio/trabajador respaldado por Podman sin asumir persistencia de pila separada, use [`scripts/podman-stack-run.sh`](https://github.com/your-org/your-project/blob/main/scripts/podman-stack-run.sh). `npm run test:security:podman` usa ese contenedor para iniciar la pila, ejecutar el paquete de seguridad y derribar la pila en una sola invocación.

Para la ruta del navegador sin cabeza del lado del host, Playwright ahora crea un `_site` estático limpio y lo sirve con un servidor HTTP liviano en lugar de depender de `jekyll serve`. Esto mantiene las regresiones del navegador más cercanas a la forma real de los activos publicados y evita cierta inestabilidad de WEBrick durante las ejecuciones paralelas.

## Primera ejecución multiplataforma

Si está configurando una fork nueva, esta es la secuencia recomendada más corta:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
npm run test:e2e:headless:podman
```

Si el médico aprueba y la suite Podman sin cabeza está en verde, estás en un buen lugar para el trabajo local normal.

Tenga en cuenta que el sitio estático generado ahora excluye carpetas internas del repositorio como `worker/`, `scripts/` y `tests/`, por lo que la verificación estática local se acerca más a lo que realmente publicaría una fork.

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
- El reenvío de franjas sigue siendo un proceso del lado del host, por lo que el flujo de autenticación del navegador sigue siendo familiar y explícito.

## Notas de paridad de producción

El modo Podman no pretende clonar perfectamente la producción de Cloudflare, pero preserva las suposiciones locales más importantes:

- procesos separados del sitio y del trabajador
- Simulación local de Wrangler para KV / Objetos duraderos
- la misma configuración de entorno/desarrollo del trabajador utilizada por el flujo de host
- el mismo carrito propio y ruta de pago
- la misma ruta del navegador de compilación estática utilizada por el arnés sin cabeza del host

## Próximos pasos probables

Las mejoras de seguimiento más seguras son:

- Cobertura del navegador en contenedores/manual más allá de la suite automatizada sin cabeza.
- Envoltorios compatibles con Podman para cualquier script auxiliar local restante que los equipos quieran mantener dentro del mismo modelo de iniciador.
- especificación de pod declarativa opcional para equipos que prefieren un manifiesto de entorno local registrado
