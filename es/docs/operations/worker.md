---
title: Worker de promesas
parent: Operaciones
nav_order: 2
render_with_liquid: false
lang: es
---

# The Pool Aporte Worker

## Última actualización

6 de septiembre de 2026

Worker posee pago canónico, integración de Stripe, persistencia de aportes, acceso de patrocinadores con alcance de pedidos, entrega de correo electrónico, datos en vivo, administración y liquidación de campañas programadas.

## Desarrollo

Ejecute la pila local completa desde la raíz del repositorio:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Para una sesión de host exclusiva para Worker, ejecútela desde este directorio:

```bash
npm ci
npm run dev
```

Los scripts npm Worker sincronizan primero el espejo de configuración. La configuración canónica se encuentra en la raíz `_config.yml`; Las diferencias locales viven en `_config.local.yml`. Las credenciales locales y el acceso de arranque utilizan `.dev.vars` ignorados en este directorio. Siga a [Contributing](/es/docs/development/contributing/) y [Podman](/es/docs/operations/podman-local-dev/) para conocer la configuración y los requisitos de tiempo de ejecución admitidos.

## Propiedad y referencia

El Worker consume paquetes de plataforma inmutables para mecánicas compartidas. The Pool conserva todas las rutas, esquemas de solicitud, modelos de campaña/aporte, políticas de almacenamiento, credenciales, efectos secundarios del proveedor, implementación y decisiones de reversión. La plantilla Jekyll es una herramienta de actualización de origen y no la importa este Worker.

- [Arquitectura](/es/docs/development/architecture/): propiedad, persistencia, acceso de patrocinadores y programación.
- [Worker API](/es/docs/reference/worker-api/): contratos de punto final y ejemplos de solicitud/respuesta.
- [Personalización](/es/docs/development/customization-guide/): configuración y espejos del sitio a Worker.
- [Procesador de pagos](/es/docs/operations/payment-processor/): pago, webhooks, liquidación y conciliación.
- [Email](/es/docs/operations/email-system/): configuración del remitente, bandeja de salida, recordatorios y supresión.
- [Tax](/es/docs/operations/tax-calculator/) y [Shipping](/es/docs/operations/shipping/): configuración específica del proveedor y comportamiento de cotización.
- [Dashboard](/es/docs/operations/admin-dashboard/): acceso de administrador, edición, informes, diagnósticos y anulaciones de tiempo de ejecución.
- [Seguridad](/es/docs/operations/security/), [Riesgo ético](/es/docs/development/ethical-risk-review/) y [Copia de seguridad y restauración](/es/docs/operations/backup-restore/): límites de confianza y recuperación.
- [Testing](/es/docs/operations/testing/): controles enfocados, accesorios y la puerta completa.

## Despliegue

Utilice el flujo de trabajo **Implementar producción** enviado manualmente para un sitio coordinado y un lanzamiento de Worker. La rutina impulsa a `main` a actualizar las páginas mediante **Actualizar páginas de producción** y no implementa Worker. [Deployment](/es/docs/operations/deployment/) posee credenciales, pasos de lanzamiento y verificaciones diarias posteriores a la implementación. El respaldo manual exclusivo de Worker, ejecutado desde este directorio, es `npm run deploy`.
