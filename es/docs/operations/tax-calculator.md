---
title: Calculadora de impuestos
parent: Operaciones
nav_order: 12
render_with_liquid: false
lang: es
---

# Calculadora de impuestos

## Última actualización

25 de agosto de 2026

Este documento cubre el modelo actual de cálculo de impuestos de The Pool, incluido
selección de proveedor, configuración orientada a la bifurcación, comportamiento del navegador, Worker
puntos finales y los controles que los operadores deben realizar antes del envío relacionados con impuestos.
cambios.

Los impuestos son una preocupación de primera clase Worker en lugar de una tasa fija configurada
en todas partes. Una implementación puede permanecer con una tarifa fija o cambiar a una respaldada por el proveedor
o cálculos de ubicación proporcionados sin bifurcar las matemáticas de pago
el navegador, Worker, gestión de aportes, correos electrónicos e informes.

## Qué controla esta capa

La capa impositiva mantiene una respuesta consistente en:

- vistas previas del carrito
- UI de checkout personalizada
- canonicalización final del checkout
- recálculo en Manage Pledge
- totales guardados del pledge
- correos electrónicos de patrocinadores
- reportes y exportaciones

El Worker sigue siendo la fuente de la verdad. El navegador puede solicitar vistas previas, pero
los totales persistentes provienen del cálculo del lado Worker.

## Modos de proveedor actuales

Los modos de proveedor de cara al operador admitidos son:

|Proveedor|Qué hace|Cuándo conviene|
| --- | --- | --- |
|`flat`|Utiliza el `pricing.sales_tax_rate` configurado|Implementaciones simples que requieren una tarifa configurada|
|`offline_rules`|Usa reglas vendorizadas de VAT/GST y fallback a nivel estatal|Bifurcaciones que desean un comportamiento consciente de la ubicación sin una solicitud de jurisdicción local en vivo para cada cotización|
|`nm_grt`|Utiliza el conjunto de datos inicial de Nuevo México suministrado y puede refinar direcciones completas de Nuevo México con la API EDAC GRT|implementaciones centradas en Nuevo México que necesitan más precisión local|
|`zip_tax`|Utiliza ZIP.TAX para búsquedas de jurisdicciones de EE. UU. y Canadá y recurre a `offline_rules` para otros países.|Implementaciones que desean precisión fiscal local respaldada por el proveedor|

Worker todavía acepta el valor del proveedor heredado `external` como alias para
`zip_tax`, pero las nuevas configuraciones y ediciones del panel deben usar `zip_tax`.

## Superficie de configuración

La configuración de impuestos orientada a la bifurcación se encuentra en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) y se describe
en [PERSONALIZACIÓN.md](/es/docs/development/customization-guide/).

Claves actuales:

- `tax.provider`
- `tax.origin_country`
- `tax.use_regional_origin`
- `tax.nm_grt_api_base`
- `tax.zip_tax_api_base`

Ejemplo:

```yml
tax:
  provider: nm_grt
  origin_country: US
  use_regional_origin: false
  nm_grt_api_base: https://grt.edacnm.org
  zip_tax_api_base: https://api.zip-tax.com
```

La línea base de compatibilidad sigue estando disponible:

- `pricing.sales_tax_rate` es utilizado por `flat`
- `SALES_TAX_RATE` refleja esa tarifa configurada en Worker

## Espejo del Worker y secretos

La configuración de impuestos no secreta se refleja desde la configuración del sitio en Worker
ambiente:

- `TAX_PROVIDER`
- `TAX_ORIGIN_COUNTRY`
- `TAX_USE_REGIONAL_ORIGIN`
- `NM_GRT_API_BASE`
- `ZIP_TAX_API_BASE`
- `SALES_TAX_RATE` para `flat`

Si habilita `zip_tax`, configure también `ZIP_TAX_API_KEY`. Mantenga esa llave fuera de
`_config.yml`; configúrelo como un secreto Worker o en `worker/.dev.vars` ignorado para
trabajo local.

Actualice el conjunto de datos de inicio de Nuevo México suministrado con:

```bash
node ./scripts/update-nm-grt-starter.mjs
```

## Comportamiento del navegador y del checkout

El navegador puede mostrar un estado provisional antes de tener suficiente destino.
detalle.

Comportamiento actual:

- carrito y checkout pueden mostrar el impuesto como `--`
- el navegador solicita una vista previa a través de `POST /tax/quote`
- el pago canónico se realiza a través de `POST /checkout-intent/start`
- un proveedor con reconocimiento de ubicación puede requerir detalles de facturación o destino de envío
antes de devolver una cotización
- `nm_grt` prueba la API EDAC solo cuando una dirección de Nuevo México incluye una
calle analizable más ciudad y código postal; de lo contrario usa el motor de arranque
conjunto de datos o respaldo plano configurado

Por lo tanto, una vista previa de impuestos puede quedar incompleta al principio del proceso de pago y resolución.
una vez que los detalles de facturación o envío estén presentes.

## Endpoints principales

### `POST /tax/quote`

Este punto final devuelve una vista previa de impuestos calculada por Worker para el carrito propio.
y la interfaz de usuario de pago.

Sirve para:

- visualización provisional en carrito
- resúmenes del checkout personalizado
- recálculo después de cambios de destino

Reglas operativas:

- la solicitud debe provenir del origen del sitio confiable
- La ruta tiene tarifa limitada y tamaño corporal limitado.
- la respuesta es privada y no almacenable en caché
- la ruta es para vistas previas de la interfaz de usuario propias, no para uso público de terceros
- faltando el detalle de destino requerido devuelve un error en lugar de un supuesto
resultado de impuestos con reconocimiento de ubicación

### `POST /checkout-intent/start`

Este es el bootstrap de pago autorizado. Él:

- canonicaliza el carrito
- valida campaña e inventario
- calcula los totales finales de pago
- persiste la instantánea de pago firmada utilizada por Stripe y Worker

Si el impuesto del navegador parece incorrecto, determine si el problema afecta únicamente
Estado de vista previa de `/tax/quote` o también el resultado canónico de `/checkout-intent/start`.

## Desarrollo Local

Para trabajos locales normales:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Comportamiento importante:

- reinicie la pila local después de cambiar `_config.yml` para que el espejo Worker sea
refrescado
- La cobertura de humo de aporte variable admite configuraciones impulsadas por el proveedor, como
`tax.provider: nm_grt`
- un dispositivo sin suficientes detalles de facturación o envío puede producir un resultado esperado
Estado provisional en lugar de un error del producto.

Consulte [PODMAN.md](/es/docs/operations/podman-local-dev/), [TESTING.md](/es/docs/operations/testing/) y el
[Worker README](/es/docs/operations/worker/) para el tiempo de ejecución circundante.

## Verificación

Cuando la configuración de impuestos, el código de proveedor, el manejo del destino de pago o los precios
cambios en la pantalla, verifique:

- la vista previa del carrito se actualiza cuando cambia el destino
- el comportamiento provisional `--` aparece solo cuando corresponde
- `POST /tax/quote` devuelve la forma esperada para el proveedor configurado
- `POST /checkout-intent/start` devuelve totales finales que coinciden con las reglas de implementación
- Manage Pledge mantiene el subtotal, los impuestos, el envío, la propina y el total coherentes
- los totales de aportes almacenados, los correos electrónicos y los informes utilizan la misma respuesta de impuestos
- La copia localizada del asistente fiscal sigue siendo correcta.
- Pases `npx vitest run tests/unit/tax.test.ts`
- Se superan las pruebas del carrito afectado, de la gestión del aporte, de la lógica empresarial Worker y del panel de control.

## Solución de problemas

### El impuesto siempre se ve plano

Controlar:

- `tax.provider` en `_config.yml`
- valores Worker reflejados en `worker/wrangler.toml`
- si reiniciaste la pila local después de cambiar la configuración

### El impuesto se queda en `--`

Controlar:

- si el proveedor necesita más detalles sobre el destino
- si el navegador envía los campos de facturación o envío que utiliza el proveedor
- si el problema afecta solo a la vista previa o también al pago canónico

### ZIP.TAX no está disponible

Controlar:

- `tax.provider: zip_tax`
- `tax.zip_tax_api_base`
- `ZIP_TAX_API_KEY`

### Los resultados de Nuevo México son demasiado amplios

Controlar:

- si el destino incluye una calle, ciudad y código postal analizables
- si hace falta refrescar el dataset inicial
- si `nm_grt` es el proveedor adecuado para la implementación

## Documentación relacionada

- [PERSONALIZACIÓN.md](/es/docs/development/customization-guide/)
- [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/)
- [PRUEBA.md](/es/docs/operations/testing/)
- [PODMAN.md](/es/docs/operations/podman-local-dev/)
- [PROJECT_OVERVIEW.md](/es/docs/development/project-overview/)
- [trabajador/README.md](/es/docs/operations/worker/)
