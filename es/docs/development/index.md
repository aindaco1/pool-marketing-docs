---
title: Desarrollo
nav_order: 3
has_children: true
lang: es
---

# Desarrollo

## Última actualización

6 de septiembre de 2026

El flujo de contribución, las notas de arquitectura, los problemas de implementación y los puntos de extensión orientados hacia la bifurcación se encuentran aquí.

## Ruta recomendada

1. [Plataforma README](/es/docs/development/platform-readme/) para una breve introducción y un inicio rápido.
2. [Contribuyendo](/es/docs/development/contributing/) para dependencias, configuración local, flujo de trabajo de contribución y convenciones de implementación.
3. [Arquitectura](/es/docs/development/architecture/) para propiedad, almacenamiento, ciclo de vida de campaña y aporte, y el mapa de códigos.
4. [Modelo de contenido de campaña](/es/docs/development/content-model/) para campos, niveles, medios, entradas de diario y decisiones de campaña.
5. [Worker API](/es/docs/reference/worker-api/) para contratos de terminales y ejemplos de solicitud/respuesta.
6. [Implementación](/es/docs/operations/deployment/) para configuración inicial, credenciales y páginas separadas y flujos de lanzamiento de Worker.
7. [Guía de agentes y operadores](/es/docs/development/agents-operator-guide/) para conocer las reglas del repositorio y los límites de la fuente de la verdad.

## Propiedad de la guía

Mantenga los procedimientos detallados en la guía propietaria. La arquitectura posee las relaciones del sistema; El modelo de contenido de campaña posee campos de creación; La API Worker posee contratos de punto final. La personalización posee configuraciones y espejos. La configuración del proveedor pertenece al Procesador de pagos, Calculadora de impuestos, Envío y Correo electrónico. La implementación es propietaria del cableado de liberación, las pruebas son propietarias de la ejecución de las pruebas y Merge Smoke es propietaria de la aprobación del operador. La Plataforma y los README Worker son puntos de entrada a estas guías.

## Configuración y extensión

- [Guía de personalización](/es/docs/development/customization-guide/) para la superficie `_config.yml` compatible, tokens de diseño, precios, envío y perillas de marca de horquilla.
- [Internacionalización](/es/docs/development/internationalization/) para configuración local, enrutamiento, catálogos de traducción y flujo de trabajo de adición de idiomas.
- [Campaña Embeds](/es/docs/development/campaign-embeds/) para rutas de inserción alojadas, comportamiento de cambio de tamaño y reglas de localización.
- [Productos complementarios](/es/docs/development/add-on-products/) para el catálogo de productos de toda la plataforma, el modelo de inventario, el contrato de ejecución y el comportamiento de envío.
- [Flujo de trabajo de vídeo del producto](/es/docs/development/product-video-workflow/) para captura, representación, verificación y límites de publicación locales.
- [Revisión de riesgos éticos](/es/docs/development/ethical-risk-review/) para evaluar cambios relacionados con dinero, datos, mensajería, automatización, poder administrativo, visibilidad y uso compartido.
- [Guía para agentes y operadores](/es/docs/development/agents-operator-guide/) para obtener invariantes de repositorio, orientación sobre fuentes de verdad y flujos de trabajo seguros para colaboradores/LLM.

## Uso diario

Esta sección es la base de operaciones adecuada cuando abre su primer PR, asigna una característica a una arquitectura existente o adapta The Pool a una bifurcación de marca.
