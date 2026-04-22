---
title: Calculadora de impuestos
parent: Operaciones
nav_order: 8
render_with_liquid: false
lang: es
---

# Calculadora de impuestos

Este documento cubre el modelo actual de cálculo de impuestos en The Pool, incluyendo selección de proveedor, configuración para forks, comportamiento del navegador, endpoints del Worker y las verificaciones que conviene correr antes de publicar cambios relacionados con impuestos.

La versión corta: los impuestos ahora son una responsabilidad de primera clase del Worker, no solo una tasa fija configurada en todas partes. Una implementación puede seguir usando una tasa plana, pero también puede cambiar a cálculo por proveedor o por reglas locales sin duplicar la matemática del checkout.

## Qué controla esta capa

La capa de impuestos existe para mantener una sola respuesta consistente entre:

- vistas previas del carrito
- UI de checkout personalizada
- canonicalización final del checkout
- recálculo en Manage Pledge
- totales guardados del pledge
- emails para supporters
- reportes y exportaciones

En el modelo actual, el Worker sigue siendo la fuente de verdad. El navegador puede pedir vistas previas, pero los totales finales persistidos siguen saliendo del cálculo del Worker.

## Modos de proveedor actuales

The Pool soporta hoy cuatro modos de proveedor de impuestos:

| Proveedor | Qué hace | Cuándo conviene |
|----------|----------|-----------------|
| `flat` | Usa la tasa heredada `pricing.sales_tax_rate` | implementaciones simples que quieren una sola tasa configurada |
| `offline_rules` | Usa reglas vendorizadas de VAT/GST y fallback a nivel estatal | forks que quieren lógica por ubicación sin depender de una API local para cada cotización |
| `nm_grt` | Parte del dataset vendorizado de Nuevo México y puede afinar con la API EDAC GRT | implementaciones centradas en Nuevo México que necesitan más precisión local |
| `zip_tax` | Usa ZIP.TAX para búsquedas jurisdiccionales en EE. UU. y cae en `offline_rules` fuera de US/CA | implementaciones enfocadas en EE. UU. que quieren precisión local apoyada en proveedor |

## Superficie de configuración

La configuración de impuestos para forks vive en la [`Guía de personalización`](/es/docs/development/customization-guide/) bajo `tax`.

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

La base de compatibilidad sigue existiendo:

- `pricing.sales_tax_rate` todavía se usa con `flat`
- `SALES_TAX_RATE` todavía se refleja al Worker para ese modo heredado

## Espejo del Worker y secretos

La configuración no secreta de impuestos se refleja desde el sitio al entorno del Worker:

- `TAX_PROVIDER`
- `TAX_ORIGIN_COUNTRY`
- `TAX_USE_REGIONAL_ORIGIN`
- `NM_GRT_API_BASE`
- `ZIP_TAX_API_BASE`
- `SALES_TAX_RATE` para `flat`

Si habilitas `zip_tax`, también debes definir:

- `ZIP_TAX_API_KEY`

Mantén esa clave fuera de `_config.yml`. Debe ir como secreto del Worker o en `worker/.dev.vars` para trabajo local.

Si usas la ruta del dataset inicial de Nuevo México, actualiza el archivo vendorizado con:

```bash
node ./scripts/update-nm-grt-starter.mjs
```

## Comportamiento del navegador y del checkout

El navegador puede mostrar intencionalmente un estado provisional mientras todavía no tenga suficiente detalle de destino.

Comportamiento actual:

- carrito y checkout pueden mostrar el impuesto como `--`
- el navegador puede pedir una vista previa con `POST /tax/quote`
- la canonicalización final sigue ocurriendo en `POST /checkout-intent/start`
- si el proveedor configurado necesita más detalle de ubicación, el Worker puede devolver un resultado provisional en lugar de adivinar
- la ruta `nm_grt` es la más precisa incorporada hoy y normalmente necesita una dirección completa a nivel de calle, no solo ZIP/estado

Por eso una vista previa de impuestos puede verse incompleta al inicio del checkout y aun así resolverse correctamente cuando ya existen datos de facturación o envío.

## Endpoints principales

### `POST /tax/quote`

Este endpoint devuelve una vista previa de impuestos calculada por el Worker para la UI propia de carrito y checkout.

Sirve para:

- visualización provisional en carrito
- resúmenes del checkout personalizado
- actualización del impuesto cuando cambia el destino

Notas operativas:

- está protegido por mismo origen
- tiene rate limiting
- está pensado para vistas previas de UI propia, no para consumo público de terceros
- puede devolver un resultado provisional o sin impuesto cuando faltan datos de destino necesarios

### `POST /checkout-intent/start`

Este sigue siendo el punto de verdad del checkout.

Es el endpoint que:

- canonicaliza el carrito
- valida campaña e inventario
- calcula los totales finales del checkout
- persiste el snapshot firmado en el que luego se apoyan Stripe y el Worker

Si el comportamiento del impuesto se ve mal en el navegador, conviene confirmar primero si el problema existe solo en la vista previa o también en la respuesta canónica de `checkout-intent/start`.

## Notas para desarrollo local

Para trabajo diario, conviene usar la ruta con Podman:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Comportamiento local importante hoy:

- cambiar la config de impuestos en `_config.yml` no alcanza por sí solo; hay que reiniciar la pila local para actualizar el espejo del Worker
- la ruta de smoke para pledges mutables ya es compatible con configuraciones de impuestos por proveedor como `tax.provider: nm_grt`
- si un fixture local no incluye suficiente información de facturación o envío, un resultado provisional puede ser esperado y no necesariamente un bug

Consulta también [`Podman Local Dev`](/es/docs/operations/podman-local-dev/), [`Guía de pruebas`](/es/docs/operations/testing/) y [`Pledge Worker`](/es/docs/operations/worker/) para el contexto operativo.

## Qué verificar antes de publicar

Si cambias configuración de impuestos, código de proveedor, manejo de destino en checkout o presentación de precios, conviene verificar todo esto:

- la vista previa del carrito se actualiza cuando cambia el destino
- el comportamiento provisional `--` aparece solo cuando corresponde
- `POST /tax/quote` devuelve la forma de respuesta esperada para el proveedor configurado
- `POST /checkout-intent/start` devuelve totales finales coherentes con las reglas de la implementación
- el recálculo en Manage Pledge mantiene alineados subtotal, impuesto, envío, propina y total
- los totales guardados, los emails y los reportes siguen usando la misma respuesta de impuestos
- el copy localizado relacionado con impuestos sigue leyéndose bien si el cambio tocó la UI del checkout

## Solución de problemas

### El impuesto siempre se ve plano

Revisa:

- `tax.provider` en `_config.yml`
- las variables reflejadas del Worker en `worker/wrangler.toml`
- si reiniciaste la pila local después de cambiar la configuración

### El impuesto se queda en `--`

Revisa:

- si el proveedor elegido necesita más detalle de destino
- si el navegador está enviando los campos de facturación o envío que ese proveedor realmente usa
- si el problema aparece solo en modo vista previa o también en `checkout-intent/start`

### La ruta de ZIP.TAX no funciona

Revisa:

- `tax.provider: zip_tax`
- `tax.zip_tax_api_base`
- `ZIP_TAX_API_KEY`

### Los resultados de Nuevo México son demasiado generales

Revisa:

- si solo se está enviando ZIP/estado en vez de una dirección completa
- si hace falta refrescar el dataset inicial
- si ese fork debería quedarse en `nm_grt` o usar otro modo de proveedor

## Documentos relacionados

- [`Pledge Worker`](/es/docs/operations/worker/)
- [`Guía de pruebas`](/es/docs/operations/testing/)
- [`Podman Local Dev`](/es/docs/operations/podman-local-dev/)
- [`Guía de personalización`](/es/docs/development/customization-guide/)
- [`Descripción general del proyecto`](/es/docs/development/project-overview/)
