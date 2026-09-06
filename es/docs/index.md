---
title: Preguntas frecuentes
nav_order: 1
description: Preguntas frecuentes y ruta de lectura recomendada para The Pool.
lang: es
---

# Preguntas frecuentes

## Última actualización

6 de septiembre de 2026

Esta página es la **forma más rápida de orientarse** antes de sumergirse en los documentos completos.

## Preguntas comunes

### ¿Qué es The Pool?

The Pool es una **plataforma de financiación colectiva de todo o nada** para películas, medios y otros proyectos impulsados ​​por artistas. Está diseñado para que los patrocinadores lo sientan *ligero* y, al mismo tiempo, brinda a los mantenedores una infraestructura real para aportes, cumplimiento y actualizaciones continuas.

Para ver el marco público completo, lea [Acerca de The Pool](/es/docs/overview/about-the-pool/).

### ¿Cómo funciona el aporte de todo o nada?

Los patrocinadores hacen aportes durante un período de campaña, pero las tarjetas **solo se cargan si la campaña alcanza su objetivo**. Si no se cumple el objetivo, la campaña se cierra sin recaudar fondos.

Esa explicación para los patrocinadores se encuentra en [Acerca de The Pool](/es/docs/overview/about-the-pool/), y los detalles de implementación se encuentran en [Arquitectura](/es/docs/development/architecture/).

### ¿Los patrocinadores necesitan una cuenta?

No. The Pool es intencionalmente **cuenta ligera**. Los patrocinadores gestionan los aportes a través de enlaces mágicos seguros de correo electrónico en lugar de nombres de usuario y contraseñas.

Si desea la versión técnica de ese flujo, comience con [Architecture](/es/docs/development/architecture/) y luego [Worker API](/es/docs/reference/worker-api/).

### ¿Cómo funcionan los enlaces mágicos?

Después de crear un aporte, el trabajador envía al colaborador un **enlace de token con alcance** que le permite ver, modificar o cancelar ese aporte sin un sistema de cuenta tradicional. El navegador nunca se convierte en la fuente de verdad del estado de aporte.

Lea [Acerca de The Pool](/es/docs/overview/about-the-pool/) para obtener una explicación en lenguaje sencillo y [Arquitectura](/es/docs/development/architecture/) más [Guía de seguridad](/es/docs/operations/security/) para ver el modelo de ingeniería.

### ¿Para quién es The Pool?

Está diseñado para creadores que desean **apoyo directo a la campaña** sin convertir la experiencia en una plataforma comercial convencional con muchas cuentas. También está diseñado para que las bifurcaciones puedan adaptar el sistema a otros proyectos de crowdfunding de marca.

El contexto público está en [Acerca de The Pool](/es/docs/overview/about-the-pool/) y la superficie de personalización orientada hacia la horquilla está en [Guía de personalización](/es/docs/development/customization-guide/).

### ¿Cómo se construye?

The Pool combina [Jekyll](https://jekyllrb.com/), [Cloudflare Workers](https://workers.cloudflare.com/), [Stripe](https://stripe.com/), [Podman](https://podman.io/) y [GitHub Pages](https://pages.github.com/) en una pila que sigue siendo **relativamente simple de razonar** y al mismo tiempo admite flujos de aportes reales.

Comience con [Acerca de The Pool](/es/docs/overview/about-the-pool/) y [Arquitectura](/es/docs/development/architecture/) para el mapa del sistema.

### ¿Es de código abierto?

Sí. El grupo es de **código abierto** y está documentado para contribuyentes, mantenedores y bifurcaciones.

## Ruta de lectura recomendada

1. [Acerca de The Pool](/es/docs/overview/about-the-pool/) para conocer el alcance del producto, el modelo de patrocinadores, la pila y la forma de implementación.
2. [Arquitectura](/es/docs/development/architecture/) para el mapa del sistema y los límites de la arquitectura.
3. [Worker API](/es/docs/reference/worker-api/) para contratos de terminales y ejemplos de solicitud/respuesta.
4. [Procesador de pagos](/es/docs/operations/payment-processor/) para pago canónico, webhooks Stripe, liquidación y conciliación.
5. [Deployment](/es/docs/operations/deployment/) para la configuración, las credenciales y el flujo de trabajo de lanzamiento del sitio/Worker.
6. [Panel de administración](/es/docs/operations/admin-dashboard/) cuando edita campañas, configuraciones, complementos, informes, análisis, enlaces de marketing, medios o usuarios.
7. [Guía de pruebas](/es/docs/operations/testing/) antes de enviar cualquier cambio de comportamiento.

## Explorar por sección

Comience con la sección que coincida con el tipo de trabajo que está realizando:

- [Descripción general](/es/docs/overview/) para contexto público, marco de plataforma y páginas de políticas.
- [Desarrollo](/es/docs/development/) para la configuración, arquitectura, personalización, incrustaciones, localización, revisión ética y trabajo de extensión de los contribuyentes.
- [Operaciones](/es/docs/operations/) para Worker y configuración de pagos, correo electrónico, copia de seguridad/recuperación, entornos locales, envío, seguridad, accesibilidad, SEO y preparación para fusión.
- [Referencia](/es/docs/reference/) para notas de la versión, trabajos potenciales, plantillas de procesos compartidos y el mapa fuente de The Pool a marketing.
