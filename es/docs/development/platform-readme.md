---
title: README de la plataforma
parent: Desarrollo
nav_order: 11
render_with_liquid: false
lang: es
---

# The Pool

## Última actualización

6 de septiembre de 2026

**Base de plataforma de crowdfunding de código abierto**

La versión actual es **v1.2.20**. Los cambios posteriores a esa etiqueta se registran en **Inédito** en el [Changelog](/es/docs/reference/changelog/); El trabajo prospectivo pertenece al [Roadmap](/es/docs/reference/roadmap/).

The Pool combina un sitio estático Jekyll, un carrito de navegador propio y un Cloudflare Worker para un crowdfunding creativo de todo o nada. Los patrocinadores guardan una tarjeta mediante un paso de pago Stripe en el sitio. Las campañas financiadas cobran después de su fecha límite; Las campañas fallidas no cobran. Un pago puede incluir varias campañas, cada una de las cuales persiste y se liquida como un aporte de campaña independiente.

## Características

- Aportes sin cuentas y enlaces mágicos con alcance de pedido para administrar, cancelar o actualizar una tarjeta.
- Precios, impuestos, envío, propinas de plataforma opcional e inventario de recompensas limitadas verificados por Worker.
- Niveles físicos y digitales, complementos de campaña y plataforma, precios de variantes e informes de cumplimiento.
- Cronogramas de campaña, objetivos ambiciosos, diarios de producción y decisiones exclusivas de los patrocinadores.
- Un panel privado con alcance de roles para campañas, configuraciones, productos, informes, patrocinadores, análisis, marketing y usuarios.
- Páginas públicas localizadas en inglés y español, flujos de patrocinadores, controles del panel y correos electrónicos.
- Recordatorios de lanzamiento y pago basados en el consentimiento, actualizaciones de campañas y entrega duradera de correo electrónico a través de Resend.
- Inserciones de campaña, tarjetas para compartir en redes sociales, optimización de medios que preservan la fuente y marca configurable.
- Liquidación por lotes, conciliación de pagos, herramientas de copia de seguridad/recuperación cifradas y comprobaciones de liberación ejecutables.

## Arquitectura

|capa|Responsabilidad|
| --- | --- |
|Jekyll / GitHub Pages|Páginas públicas estáticas, rutas localizadas, contenido de campaña y recursos del navegador|
|Cloudflare Worker|Pago canónico, persistencia de aportes, estadísticas en vivo, administración, correo electrónico y liquidación programada|
|Stripe|Campos de pago seguros, métodos de pago guardados y cargos fuera de sesión|
|Git/YAML/rebaja|Configuración de plataforma, campañas y fuente de medios revisables|

Los gitlinks grabados fijan revisiones inmutables de la plataforma Dust Wave y de la plantilla Jekyll. The Pool conserva los modelos de sus productos, rutas, almacenamiento, contenido, localización, credenciales, política de proveedor, implementación y reversión. Consulte [Arquitectura](/es/docs/development/architecture/) para obtener detalles sobre la propiedad y el ciclo de vida.

## Inicio rápido

Ejecute desde la raíz del repositorio con la versión de Node.js en [.nvmrc](https://github.com/aindaco1/pool/blob/main/.nvmrc) y Podman:

```bash
git submodule update --init --recursive
npm run setup:deploy -- --mode=local
npm run podman:doctor
./scripts/dev.sh --podman
```

El sitio se ejecuta en `http://127.0.0.1:4000`; el Worker se ejecuta en `http://127.0.0.1:8787`. [Configuración de Podman](/es/docs/operations/podman-local-dev/) cubre requisitos previos, soporte de plataforma, contenedores y solución de problemas. [Contributing](/es/docs/development/contributing/) cubre la instalación de dependencias, el respaldo del host, los patrones de desarrollo y el flujo de trabajo de contribución.

La configuración de bifurcación canónica se encuentra en [_config.yml](https://github.com/aindaco1/pool/blob/main/_config.yml). [_config.local.yml](https://github.com/aindaco1/pool/blob/main/_config.local.yml) contiene anulaciones locales de la máquina; Las credenciales Worker pertenecen a `worker/.dev.vars` ignoradas localmente y a los secretos Cloudflare Worker cuando se implementan. Siga [Customization](/es/docs/development/customization-guide/) y los runbooks del proveedor vinculados allí.

## Verificación e implementación

Utilice el control relevante más limitado durante el desarrollo. La puerta completa previa a la fusión es:

```bash
npm run test:premerge
```

[Testing](/es/docs/operations/testing/) cubre suites y verificación local; [Fusionar Smoke](/es/docs/operations/merge-smoke-checklist/) posee la aprobación del operador.

Al enviar los cambios revisados ​​a `main` se actualiza GitHub Pages. Las versiones de Worker utilizan el flujo de trabajo **Implementar producción** distribuido manualmente, que implementa ambos servicios de la revisión seleccionada. Siga [Deployment](/es/docs/operations/deployment/) para conocer la configuración, las credenciales, los pasos de lanzamiento y las comprobaciones posteriores a la implementación.

## Documentación

Comience con el [índice de documentación](/es/docs/development/), organizado por tarea y audiencia. Los creadores que estén preparando un lanzamiento pueden utilizar la [Lista de verificación para creadores de campañas](https://github.com/aindaco1/pool/blob/main/creator-campaign-checklist.md), también disponible [en español](https://github.com/aindaco1/pool/blob/main/es/creator-campaign-checklist.md).

La guía de cambios para todo el repositorio se encuentra en [AGENTS.md](/es/docs/development/agents-operator-guide/). El proyecto utiliza la [licencia MIT](https://github.com/aindaco1/pool/blob/main/LICENSE).
