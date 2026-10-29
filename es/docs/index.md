---
title: Preguntas frecuentes
nav_order: 1
description: Preguntas frecuentes y ruta de lectura recomendada para The Pool.
lang: es
---

# Preguntas frecuentes

## Última actualización

28 de octubre de 2026

Esta página es la **forma más rápida de orientarse** antes de sumergirse en los documentos completos.

## Preguntas comunes

### ¿Qué es The Pool?

The Pool es una **plataforma de financiación colectiva de todo o nada** para películas, medios y otros proyectos impulsados ​​por artistas. Está diseñado para que los patrocinadores lo sientan *ligero* y, al mismo tiempo, brinda a los mantenedores una infraestructura real para aportes, cumplimiento y actualizaciones continuas.

Para ver el marco público completo, lea [Acerca de The Pool](/es/docs/overview/about-the-pool/).

### ¿Cómo funciona el aporte de todo o nada?

Durante la campaña, los patrocinadores guardan un método de pago mediante Stripe. Las tarjetas **solo se cobran después de la fecha límite de una campaña que haya alcanzado su meta**. Si no alcanza la meta, la campaña termina sin recaudar fondos. Un proceso de pago que incluya varias campañas crea aportes separados, que se liquidan por separado.

Esa explicación para los patrocinadores se encuentra en [Acerca de The Pool](/es/docs/overview/about-the-pool/), y los detalles de implementación se encuentran en [Arquitectura](/es/docs/development/architecture/).

### ¿Los patrocinadores necesitan una cuenta?

No. Los patrocinadores gestionan sus aportes a través de enlaces de correo electrónico seguros en lugar de nombres de usuario y contraseñas.

Si desea la versión técnica de ese flujo, comience con [Architecture](/es/docs/development/architecture/) y luego [Worker API](/es/docs/reference/worker-api/).

### ¿Cómo funcionan los enlaces mágicos?

Después de crear un aporte, el Worker envía al patrocinador un **enlace de acceso limitado** a ese aporte. Puede modificarlo o cancelarlo mientras la campaña esté abierta, incluso después de que alcance su meta. Estas modificaciones dejan de estar disponibles al llegar la fecha límite. Un retraso en el correo de confirmación no anula un aporte guardado; si el resultado no está claro, contacta con el soporte de la campaña antes de enviar otro aporte.

Lea [Acerca de The Pool](/es/docs/overview/about-the-pool/) para obtener una explicación en lenguaje sencillo y [Arquitectura](/es/docs/development/architecture/) más [Guía de seguridad](/es/docs/operations/security/) para ver el modelo de ingeniería.

### ¿Qué sucede cuando edito los detalles de pago?

Los campos de contacto y dirección siguen disponibles mientras se cargan los campos de pago. Al completar los datos, el pago se prepara automáticamente tras una breve pausa. Cambiar el correo o el destino actualiza la preparación del pago, los impuestos y el envío sin reemplazar el formulario. Preparar el pago no confirma un aporte ni cobra una tarjeta; el patrocinador todavía debe completar la confirmación.

Consulte [Procesador de pagos](/es/docs/operations/payment-processor/#pago-integrado-editable-y-funciones-compartidas) para conocer la preparación, la liberación de reservas y el comportamiento de reintento.

### ¿Los montos de impuestos y envío son siempre exactos?

El Worker calcula los totales del proceso de pago. El impuesto depende del proveedor configurado y de los datos disponibles del destino. Las tasas incluidas por código postal de Estados Unidos tienen cobertura parcial y siguen siendo estimaciones; una tasa estatal de respaldo puede omitir impuestos locales incluso con una dirección completa. Deben corregirse los conflictos conocidos entre código postal y estado; las sugerencias de ciudad son opcionales. El envío utiliza la cotización del transportista o las reglas de respaldo configuradas.

Consulta [Calculadora de impuestos](/es/docs/operations/tax-calculator/), [Envíos](/es/docs/operations/shipping/) y [Términos y pautas creativas](/es/docs/overview/terms-and-guidelines/). Actualizar los datos de referencia no cambia el precio de los aportes ya confirmados.

### ¿Guardar una campaña la publica?

No. **Guardar** almacena una copia de trabajo compartida; **Vista previa** permite que los revisores autorizados la examinen; **Publicar** la incorpora al sitio público. El panel sigue el despliegue de la revisión guardada antes de indicar que está en línea. Los borradores locales del navegador son copias de recuperación separadas. Los cambios en conflicto se conservan para compararlos, en lugar de sobrescribir una copia de trabajo más reciente.

Lea [Guardar y publicar](/es/docs/operations/admin-dashboard/#guardar-y-publicar) y [Recuperación de borrador](/es/docs/operations/admin-dashboard/#recuperar-un-borrador-perdido-del-navegador).

### ¿Cómo se protegen los aportes y el correo electrónico durante la recuperación?

Los registros de aportes y la entrega de correos electrónicos tienen ciclos de vida separados. The Pool pone en cola sus propios mensajes para reintentarlos sin revertir los aportes guardados cuando falla la entrega. Los correos electrónicos del diario de campaña enlazan con entradas individuales y las actualizaciones de la campaña incluyen una opción para cancelar la suscripción.

Los operadores pueden configurar instantáneas de producción cifradas cada cuatro horas, verificar el archivo remoto y seguir un proceso documentado de restauración y reconciliación Stripe. Una verificación de copia de seguridad exitosa no establece que se haya probado una restauración. Consulte [Sistema de correo electrónico](/es/docs/operations/email-system/) y [Copia de seguridad, restauración y recuperación](/es/docs/operations/backup-restore/).

### ¿Para quién es The Pool?

Está diseñado para creadores que desean **apoyo directo a la campaña** sin convertir la experiencia en una plataforma comercial convencional con muchas cuentas. También está diseñado para que las bifurcaciones puedan adaptar el sistema a otros proyectos de crowdfunding de marca.

El contexto público está en [Acerca de The Pool](/es/docs/overview/about-the-pool/) y la superficie de personalización orientada hacia la horquilla está en [Guía de personalización](/es/docs/development/customization-guide/).

### ¿Cómo se construye?

Jekyll genera el sitio público para GitHub Pages. Un Worker de Cloudflare gestiona los totales, el almacenamiento de aportes, la administración y la liquidación. Stripe guarda los métodos de pago y procesa los cobros, y Resend entrega el correo. Podman permite desarrollar en un entorno local. Los paquetes de Dust Wave Platform fijados a revisiones concretas proporcionan funciones compartidas de pago, referencias de códigos postales e impuestos, medios y otras utilidades; Pool conserva las reglas de campañas y aportes.

Comience con [Acerca de The Pool](/es/docs/overview/about-the-pool/) y [Arquitectura](/es/docs/development/architecture/) para el mapa del sistema.

### ¿Es de código abierto?

Sí. The Pool es **de código abierto** y cuenta con documentación para colaboradores, responsables de mantenimiento y proyectos derivados.

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
