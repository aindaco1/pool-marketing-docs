---
title: Preguntas frecuentes
nav_order: 1
description: Preguntas frecuentes y ruta de lectura recomendada para The Pool.
lang: es
---

# Preguntas frecuentes

Esta página es la **manera más rápida de orientarte** antes de sumergirte en toda la documentación.

## Última actualización

21 de abril de 2026

## Preguntas comunes

### ¿Qué es The Pool?

The Pool es una **plataforma de crowdfunding todo-o-nada** para cine, medios y otros proyectos impulsados por artistas. Está diseñada para sentirse *liviana para supporters* y, al mismo tiempo, dar a quienes la mantienen una infraestructura real para pledges, fulfillment y actualizaciones continuas.

Para ver el marco público completo, lea [Acerca de The Pool](/es/docs/overview/about-the-pool/).

### ¿Cómo funciona la promesa de todo o nada?

Los supporters hacen pledges durante una ventana de campaña, pero las tarjetas **solo se cobran si la campaña alcanza su objetivo**. Si no se cumple la meta, la campaña se cierra sin recaudar fondos.

Esa explicación orientada a supporters está en [Acerca de The Pool](/es/docs/overview/about-the-pool/), y los detalles de implementación están en [Workflows](/es/docs/development/workflows/).

### ¿Los seguidores necesitan una cuenta?

No. The Pool está pensado para ser **liviano en cuentas**. Les supporters gestionan sus pledges mediante magic links por email en lugar de nombres de usuario y contraseñas.

Si quieres la versión técnica de ese flujo, ve de [Descripción general del proyecto](/es/docs/development/project-overview/) a [Flujos de trabajo](/es/docs/development/workflows/) y luego a [Pledge Worker](/es/docs/operations/worker/).

### ¿Cómo funcionan los enlaces mágicos?

Después de crear un pledge, el Worker envía al supporter un **link con token acotado** que le permite ver, modificar o cancelar ese pledge sin un sistema tradicional de cuentas. El navegador nunca se convierte en la fuente de verdad del estado del pledge.

Consulta [Acerca de The Pool](/es/docs/overview/about-the-pool/) para una explicación en lenguaje claro y [Flujos de trabajo](/es/docs/development/workflows/) más [Guía de seguridad](/es/docs/operations/security/) para el modelo técnico.

### ¿Para quién es The Pool?

Está diseñado para creadores que quieren **apoyo directo para sus campañas** sin convertir la experiencia en una plataforma comercial convencional cargada de cuentas. También está pensado para que los forks adapten el sistema a otros proyectos de crowdfunding con marca propia.

El contexto público está en [Acerca de The Pool](/es/docs/overview/about-the-pool/) y la superficie de personalización para forks está en [Guía de personalización](/es/docs/development/customization-guide/).

### ¿Cómo se construye?

The Pool combina [Jekyll](https://jekyllrb.com/), [Cloudflare Workers](https://workers.cloudflare.com/), [Stripe](https://stripe.com/), [Podman](https://podman.io/) y [GitHub Pages](https://pages.github.com/) en una stack que sigue siendo **relativamente simple de entender** y, al mismo tiempo, soporta flujos reales de pledges.

Comience con [Descripción general de la plataforma](/es/docs/overview/platform/) y [Descripción general del proyecto](/es/docs/development/project-overview/) para el mapa del sistema.

### ¿Es de código abierto?

Sí. The Pool es **de código abierto** y está documentado para contributors, maintainers y forks.

## Ruta de lectura recomendada

1. [Descripción general de la plataforma](/es/docs/overview/platform/) para conocer el alcance del producto, la pila y la forma de implementación.
2. [Descripción general del proyecto](/es/docs/development/project-overview/) para el mapa del sistema y los límites de la arquitectura.
3. [Flujos de trabajo](/es/docs/development/workflows/) para el ciclo de vida del pledge, el estado y las rutas del Worker.
4. [Pledge Worker](/es/docs/operations/worker/) para secretos, configuración de KV y endpoints de API.
5. [Guía de pruebas](/es/docs/operations/testing/) antes de enviar cualquier cambio de comportamiento.

## Explorar por sección

Comienza con la sección que coincida con el tipo de trabajo que estás haciendo:

- [Descripción general](/es/docs/overview/) para contexto público, framing de la plataforma y páginas de políticas.
- [Desarrollo](/es/docs/development/) para setup de contributors, arquitectura, personalización, embeds, localización y trabajo de extensión.
- [Operaciones](/es/docs/operations/) para configuración del Worker, entornos locales, shipping, seguridad, accesibilidad, SEO y preparación para merge.
- [Referencia](/es/docs/reference/) para edición en CMS, contexto de roadmap y plantillas de proceso compartidas.
