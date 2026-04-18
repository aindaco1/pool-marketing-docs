---
title: Preguntas frecuentes
nav_order: 1
description: Preguntas frecuentes y ruta de lectura recomendada para The Pool.
lang: es
---

# Preguntas frecuentes

Esta página es la **forma más rápida de orientarse** antes de sumergirse en los documentos completos.

## Última actualización

17 de abril de 2026

## Preguntas comunes

### ¿Qué es The Pool?

The Pool es una **plataforma de financiación colectiva de todo o nada** para películas, medios y otros proyectos impulsados por artistas. Está diseñada para sentirse *liviana para les supporters* y, al mismo tiempo, brindar a quienes la mantienen una infraestructura real para pledges, cumplimiento y actualizaciones continuas.

Para ver el marco público completo, lea [Acerca de The Pool](/es/docs/overview/about-the-pool/).

### ¿Cómo funciona la promesa de todo o nada?

Les supporters hacen pledges durante una ventana de campaña, pero las tarjetas **solo se cargan si la campaña alcanza su objetivo**. Si no se cumple el objetivo, la campaña se cierra sin recaudar fondos.

Esa explicación para los seguidores se encuentra en [Acerca de The Pool](/es/docs/overview/about-the-pool/), y los detalles de implementación se encuentran en [Flujos de trabajo](/es/docs/development/workflows/).

### ¿Los seguidores necesitan una cuenta?

No. The Pool es intencionalmente **liviano en cuentas**. Les supporters gestionan sus pledges a través de magic links seguros por correo en lugar de nombres de usuario y contraseñas.

Si desea la versión técnica de ese flujo, vaya de [Descripción general del proyecto](/es/docs/development/project-overview/) a [Flujos de trabajo](/es/docs/development/workflows/) y luego a [Worker de promesas](/es/docs/operations/worker/).

### ¿Cómo funcionan los enlaces mágicos?

Después de crear un pledge, el Worker envía al supporter un **enlace con token acotado** que le permite ver, modificar o cancelar ese pledge sin un sistema de cuenta tradicional. El navegador nunca se convierte en la fuente de verdad del estado del pledge.

Lea [Acerca de The Pool](/es/docs/overview/about-the-pool/) para obtener una explicación en lenguaje sencillo y [Flujos de trabajo](/es/docs/development/workflows/) más [Guía de seguridad](/es/docs/operations/security/) para ver el modelo de ingeniería.

### ¿Para quién es The Pool?

Está diseñado para creadores que desean **soporte directo para sus campañas** sin convertir la experiencia en una plataforma comercial convencional cargada de cuentas. También está pensado para que los forks puedan adaptar el sistema a otros proyectos de crowdfunding con marca propia.

El contexto público está en [Acerca de The Pool](/es/docs/overview/about-the-pool/) y la superficie de personalización orientada hacia la fork está en [Guía de personalización](/es/docs/development/customization-guide/).

### ¿Cómo se construye?

The Pool combina [Jekyll](https://jekyllrb.com/), [Cloudflare Workers](https://workers.cloudflare.com/), [Stripe](https://stripe.com/), [Podman](https://podman.io/) y [GitHub Pages](https://pages.github.com/) en una stack que sigue siendo **relativamente sencilla de entender** y, al mismo tiempo, admite flujos reales de pledges.

Comience con [Descripción general de la plataforma](/es/docs/overview/platform/) y [Descripción general del proyecto](/es/docs/development/project-overview/) para el mapa del sistema.

### ¿Es de código abierto?

Sí. The Pool es **de código abierto** y está documentado para contribuyentes, mantenedores y forks.

## Ruta de lectura recomendada

1. [Descripción general de la plataforma](/es/docs/overview/platform/) para conocer el alcance del producto, la pila y la forma de implementación.
2. [Descripción general del proyecto](/es/docs/development/project-overview/) para el mapa del sistema y los límites de la arquitectura.
3. [Flujos de trabajo](/es/docs/development/workflows/) para el ciclo de vida del compromiso, el estado y las rutas de los trabajadores.
4. [Worker de promesas](/es/docs/operations/worker/) para secretos, configuración de KV y puntos finales de API.
5. [Guía de pruebas](/es/docs/operations/testing/) antes de enviar cualquier cambio de comportamiento.

## Explorar por sección

Comience con la sección que coincida con el tipo de trabajo que está realizando:

- [Descripción general](/es/docs/overview/) para contexto público, marco de plataforma y páginas de políticas.
- [Desarrollo](/es/docs/development/) para la configuración, arquitectura, personalización, incrustaciones, localización y trabajo de extensión de los contribuyentes.
- [Operaciones](/es/docs/operations/) para configuración de trabajadores, entornos locales, envío, seguridad, accesibilidad, SEO y preparación para fusiones.
- [Referencia](/es/docs/reference/) para edición de CMS, contexto de hoja de ruta, roles de agentes y plantillas de procesos compartidos.
