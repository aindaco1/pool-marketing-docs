---
title: Flujo de trabajo de video de producto
parent: Desarrollo
nav_order: 9
render_with_liquid: false
lang: es
---

# Flujo de trabajo de video de producto

## Última actualización

25 de agosto de 2026

The Pool tiene un canal de recorrido de producto repetible y solo local construido en el paquete `@dustwave/product-video-core` anclado. Captura la interfaz pública real y genera videos transparentes adecuados para un héroe de un sitio de marketing sin ingresar detalles de pago o dependiendo del estado en vivo de Stripe o Worker.

El flujo predeterminado realiza esta secuencia:

1. abra la página de inicio renderizada localmente
2. abrir la campaña de prueba `smoke-editable`
3. agregar su nivel estándar
4. agregue su complemento de cartel de campaña
5. avanzar a la vista previa de pago

## Límite de propiedad

La plataforma posee la mecánica neutral del marco:

- validación de flujo declarativo acotado
- escenario Playwright transparente y cursor sintético
- rutas de salida generadas protegidas
- construcción de argumentos FFmpeg sin shell y verificación de plano alfa decodificada
- Evidencia de salida de ProRes, VP9 WebM alfa y HEVC alfa

The Pool posee:

- Inicio de vista previa de Jekyll y `_config.test.yml`
- el dispositivo y los selectores `smoke-editable`
- `assets/capture-presentation.css`
- sincronización del flujo y opciones editoriales
- nombres de salida y la copia opcional del repositorio de marketing
- revisión, publicación y reversión de videos generados

La hoja de estilo de captura se inyecta únicamente en el marco local Playwright. Se emite como un recurso estático para que el CSP de página estricto pueda cargarlo, pero no está vinculado desde las plantillas de producción y no agrega ninguna solicitud de producción.

## Comandos

Capture una secuencia de fotogramas rápida sin ejecutar FFmpeg:

```bash
npm run video:demo:capture
```

Renderice el conjunto de salida predeterminado completo:

```bash
npm run video:demo:render
```

Ejecute la captura breve de la interfaz de usuario real utilizada para verificar el dispositivo y los selectores:

```bash
npm run test:product-video
```

Utilice una vista previa ya en ejecución o seleccione formatos portátiles:

```bash
./scripts/render-product-demo.sh \
  --base-url http://127.0.0.1:4010 \
  --format prores \
  --format webm
```

Para copiar los resultados del navegador en un repositorio de marketing desprotegido existente:

```bash
POOL_MARKETING_REPO=/path/to/pool-marketing-docs npm run video:demo:render
```

El destino ya debe ser un pago de Git. El comando crea solo su directorio `assets/videos` y copia:

- `product-demo.webm` a `hero-demo.webm`
- `product-demo.mp4` a `hero-demo.mp4`

## Comportamiento de pago limpio

Cuando la vista previa predeterminada de `http://127.0.0.1:4010` no está disponible, el contenedor The Pool crea un sitio generado único usando:

```text
_config.yml,_config.test.yml
```

Esa configuración de prueba rastreada expone `smoke-editable` sin depender de la configuración local de la máquina ignorada. Un origen personalizado no disponible falla explícitamente en lugar de provocar que el contenedor vincule un host o puerto arbitrario.

## Contrato de salida

Cada ejecución recibe un directorio calificado por proceso único:

```text
tmp/product-video/<timestamp>-<pid>/
```

Contiene el sitio generado cuando The Pool inicia la vista previa, la secuencia de fotogramas PNG, los manifiestos de captura y renderizado y, a menos que se haya seleccionado `--capture-only`, los siguientes resultados:

- `output/product-demo-master.mov` — Maestro alfa ProRes 4444
- `output/product-demo.webm` — VP9 alfa para Chromium y Firefox
- `output/product-demo.mp4` — HEVC alfa para plataformas Safari y Apple

Los directorios de ejecución existentes nunca se sobrescriben ni se eliminan de forma recursiva. Todo el árbol `tmp/` permanece ignorado. Jekyll también excluye ese árbol, y la puerta de artefactos previa a la fusión falla si aparece una ruta `_site/tmp` generada, lo que impide que los artefactos de captura local ingresen a una implementación de Pages.

## Requisitos del anfitrión

- Nodo y `@playwright/test` anclado al repositorio
- Ruby/Bundler y las dependencias Jekyll registradas cuando The Pool debe iniciar una vista previa
- Python 3 para el servidor estático loopback
- FFmpeg y FFprobe para renderizado
- una compilación de Apple FFmpeg que expone `hevc_videotoolbox` para la salida alfa HEVC

En hosts sin VideoToolbox, seleccione solo ProRes y WebM. El comando de solo captura no necesita FFmpeg ni FFprobe.

## Barandillas de seguridad y rendimiento

- Capture los valores predeterminados en bucle invertido. La plataforma requiere una marca explícita para orígenes remotos; The Pool no habilita esa bandera.
- La navegación de flujo tiene el mismo origen y el lenguaje de flujo no tiene ninguna acción JavaScript arbitraria.
- Los directorios de marco y renderizado deben permanecer debajo de `tmp/product-video`.
- La salida existente falla al cerrarse, por lo que una ruta mal escrita no puede desencadenar una eliminación recursiva.
- Los comandos del codificador utilizan matrices de argumentos sin shell.
- La captura registra la velocidad de cuadros efectiva y falla por debajo del piso configurado en lugar de producir silenciosamente un renderizado acelerado.
- No se comprometen datos del cliente, pago en vivo, credencial, video generado o destino de marketing.

## Actualizando el flujo

La política de consumo de duración de la producción vive en `video/product-demo.smoke-editable.json`. Mantenga alineado el contrato corto en `tests/fixtures/product-video.smoke.json` al cambiar de selector. Las pruebas de pago de campañas existentes cubren los mismos controles de nivel, carrito, complemento y vista previa de pago; `tests/unit/product-video-workflow.test.ts` además bloquea el límite de la plataforma y la postura de producción de solo captura.
