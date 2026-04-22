---
title: Acerca de The Pool
parent: Resumen
nav_order: 2
render_with_liquid: false
lang: es
---

# ¿Qué es The Pool?

**The Pool** es una plataforma de financiación colectiva de código abierto para proyectos creativos y cinematográficos independientes.

El hito del lanzamiento de la plataforma actual es **v0.9.4**. Dust Wave está reservando **v1.0** para un lanzamiento público más amplio una vez que se completen los elementos restantes de la hoja de ruta.

## Compromiso de todo o nada

Cuando respaldas un proyecto en The Pool, tu tarjeta se guarda de forma segura a través de Stripe, pero **no se te cobra hasta que la campaña alcanza su objetivo**. Si el proyecto no alcanza su objetivo de financiación antes de la fecha límite, nunca se realizará ningún cargo en su tarjeta.

Esto protege tanto a los patrocinadores como a los creadores: solo paga por los proyectos que realmente pueden alcanzar su objetivo de financiación.

## No se requiere cuenta

A diferencia de otras plataformas, The Pool no requiere que crees una cuenta. Cuando realiza una donación, recibe enlaces por correo electrónico a:

- **Administre su contribución**: cancele, modifique el monto o actualice su método de pago
- **Acceda a la comunidad de seguidores**: vote sobre las decisiones creativas publicadas y vea actualizaciones exclusivas

Si su pago incluye más de una campaña, recibirá correos electrónicos de confirmación por separado y enlaces de administración para cada campaña. Simplemente guarde esos correos electrónicos. Son tus llaves.

## Cómo funcionan los enlaces mágicos de correo electrónico

En lugar de pedirle que cree una contraseña, The Pool utiliza enlaces de correo electrónico seguros para demostrar que usted controla una promesa.

- **Cada compromiso tiene su propio enlace**: su correo electrónico de confirmación incluye un enlace de administración para ese compromiso de campaña específico.
- **Utilice el enlace de administración para realizar cambios**: desde allí puede revisar su contribución, ajustarla mientras la campaña aún está activa, cancelarla o actualizar su tarjeta guardada.
- **Los enlaces de la comunidad son solo para seguidores**: si una campaña tiene habilitada la votación comunitaria, el correo electrónico también incluye un enlace de la comunidad de seguidores para esa campaña.
- **Guarde el correo electrónico**: el enlace es la forma más rápida de regresar a su compromiso más adelante. Si abre la página de la comunidad en un nuevo navegador o después de que se restablece la sesión de su navegador, usar el enlace de correo electrónico nuevamente es la forma más segura de volver a ingresar.

Si realizó una copia de seguridad de varias campañas en un solo pago, aún podrá administrarlas por separado después.

Para el acceso a la comunidad de seguidores, The Pool mantiene la sesión de apoyo verificada en la sesión actual del navegador en lugar de una cookie de acceso de larga duración. Reabrir el enlace del correo electrónico es la forma más segura de regresar si esa sesión expira.

## Umm, entonces, ¿cómo funciona de nuevo?

1. **Buscar**: encuentre un proyecto que desee apoyar
2. **Compromiso**: agregue una o más campañas a su carrito, opcionalmente agregue una propina del 0% al 15% para el mantenimiento de la plataforma y continúe con el paso de pago seguro de The Pool impulsado por Stripe. Las recompensas físicas pueden agregar envío calculado por el trabajador durante el proceso de pago, incluidas cotizaciones respaldadas por USPS, tarifas alternativas configuradas o anulaciones de envío gratuito cuando una implementación las permita. Algunas implementaciones también pueden mostrar un selector de opciones de entrega limitado para actualizaciones de firmas nacionales. El impuesto puede aparecer como una estimación hasta que el proceso de pago tenga suficientes detalles de facturación o ubicación de envío para calcular un total final.
También puede ver complementos de plataforma opcionales. Estos apoyan directamente al operador de la plataforma, no cuentan para el objetivo de financiación de la campaña y pueden ser digitales o físicos. Cuando tienen un inventario limitado, el stock refleja las promesas guardadas en lugar de los carritos en progreso.
Algunas campañas también pueden ofrecer complementos de campaña. Estos usan la misma interfaz de usuario de tarjeta adicional, pero cuentan para el financiamiento total de esa campaña y siguen las reglas de envío de esa campaña.
3. **Guardar tarjeta**: Stripe guarda de forma segura tu método de pago dentro del flujo de pago (aún sin cargo)
4. **Espera**: la campaña continúa hasta la fecha límite (todos los horarios en horario de montaña)
5. **Resultado**: si se financia una campaña, se cobra su contribución para esa campaña. Si no es así, no pasa nada.

Varias promesas del mismo correo electrónico se combinan en un solo cargo cuando la misma campaña tiene éxito. Los consejos y complementos de plataforma opcionales van al operador de la plataforma para ayudar a mantener la implementación y no cuentan para el objetivo de financiación de un proyecto.

## Para creadores

The Pool está diseñado para cineastas y otros creativos con características como:

- **Tarifa de plataforma del 0 % para los organizadores**: los partidarios pueden agregar opcionalmente una propina de plataforma del 0 % al 15 % para ayudar a mantener la plataforma sin reducir los fondos de la campaña.
- **Pago propio**: The Pool controla el carrito, los sidecars de pago y el flujo de revisión de promesas, mientras que Stripe maneja de forma segura los detalles de pago.
- **Niveles físicos y digitales**: ofrezca recompensas tangibles con captura de la dirección de envío en el momento del pago, soporte de cotizaciones respaldado por USPS, controles de política de envío alternativo/gratuito, actualizaciones de opciones de entrega limitadas y reglas impositivas configuradas para la implementación que pueden variar desde una tarifa fija hasta cálculos basados ​​en la ubicación respaldados por el proveedor.
- **Complementos de plataforma opcionales**: ofrece un pequeño catálogo global de productos junto con los compromisos de campaña, con inventario por variante, conocimiento de existencias bajas basado en los compromisos guardados y soporte de envío para complementos físicos.
- **Complementos de campaña opcionales**: permite que una campaña ofrezca productos de propiedad de la campaña a través del mismo carrito/interfaz de usuario del complemento Administrar promesa mientras se sigue contando ese producto para el subtotal de la campaña y se utilizan reglas de envío específicas de la campaña.
- **Informes de los ejecutores de la campaña**: envíe libros de contabilidad de compromisos diarios con alcance de campaña durante las campañas en vivo, además de exportaciones de cumplimiento posteriores a la fecha límite, con elementos gestionados por la plataforma enrutados por separado cuando sea necesario, para que los creadores puedan realizar un seguimiento del soporte y la entrega sin paneles de cuenta.
- **Widgets de campañas en vivo integrables**: brinde a los propietarios de campañas un generador de inserciones alojado que genera código iframe de copiar y pegar para compartir el progreso de la campaña en vivo en otros sitios.
- **Fases de producción**: divide tu presupuesto en fases que los seguidores pueden financiar directamente
- **Metas ambiciosas**: desbloquear posibilidades creativas adicionales a medida que aumenta la financiación
- **Decisiones de la comunidad**: deja que tus patrocinadores voten sobre las opciones creativas publicadas.
- **Diario de producción**: mantén a tu comunidad comprometida con las actualizaciones
- **Soporte continuo**: acepte contribuciones después de que finalice su campaña principal
- **Acceso para seguidores sin cuenta**: los patrocinadores gestionan sus promesas y se unen a páginas comunitarias exclusivas para seguidores a través de enlaces mágicos de correo electrónico en lugar de crear cuentas.
- **Flujos de seguidores preparados para la configuración regional**: las cadenas de interfaz de usuario compartidas, las páginas de resultados de promesas, `/manage/`, las rutas de la comunidad de seguidores y los correos electrónicos de los seguidores pueden seguir el modelo de idioma configurado de la implementación, con el inglés como valor predeterminado y configuraciones regionales adicionales en capas a través de la configuración más contenido traducido.
- **Contenido enriquecido más seguro**: el texto de la campaña y las entradas del diario admiten Markdown e incrustaciones aprobadas, mientras que el HTML sin formato inseguro y los enlaces o esquemas de incrustación peligrosos se bloquean en el momento de la renderización.
- **IU orientada a la accesibilidad**: los cuadros de diálogo fáciles de usar con el teclado, los enlaces para saltar, las pestañas, los controles deslizantes, los flujos de la comunidad de seguidores y las interacciones de campañas públicas son parte de la base de la plataforma, con comprobaciones de accesibilidad automatizadas que cubren páginas públicas críticas, estados de resultados de promesas y flujos de pago.

## La tecnología

La piscina se ejecuta en una arquitectura estática moderna:

|capa|Plataforma|Rol|
|-------|----------|------|
|Interfaz|[Páginas de GitHub](https://docs.github.com/en/pages)|Sitio estático de Jekyll|
|Carrito|The Pool|Carrito propio, sidecars de pago y revisión de compromisos|
|Pagos|[Raya](https://stripe.com)|Campos de pago seguros, tarjetas guardadas y cargos fuera de sesión|
|backend|[Trabajadores de Cloudflare](https://workers.cloudflare.com)|Precios canónicos, almacenamiento de promesas, estadísticas en vivo, datos de cumplimiento, liquidación|
|Correo electrónico|[Reenviar](https://resend.com)|Confirmaciones, actualizaciones, notificaciones.|

La plataforma se basa en servicios que ofrecen niveles gratuitos, y The Pool fue diseñado desde el principio para operar de manera efectiva dentro de esos niveles gratuitos siempre que sea posible.

Para las bifurcaciones, eso significa que las páginas estáticas permanecen en las páginas de GitHub, las lecturas públicas en vivo se combinan agresivamente y se almacenan en caché del navegador, y la mayor parte del uso de Cloudflare Worker está reservado para las partes sensibles a la seguridad del ciclo de vida del compromiso, mientras que las configuraciones de impuestos, envío, SEO, localización y registro permanecen reflejadas o limitadas a través de la configuración para que la interfaz de usuario local, el pago, los informes, los correos electrónicos y los metadatos públicos permanezcan alineados.

Las bifurcaciones también pueden cambiar el nombre del sitio público, el estilo de pago en el sitio y los correos electrónicos de los seguidores a través de la configuración sin cambiar la mecánica de compromiso subyacente. El objetivo es permitir que los creadores o estudios adapten la presentación manteniendo constante el modelo de financiación de todo o nada y el flujo de acceso de los seguidores.

Esa arquitectura también deja espacio para reforzar la accesibilidad sin sacrificar el modelo de seguridad de la plataforma: los flujos circundantes de carrito, pago y administración utilizan una semántica más sólida de diálogo, enfoque, teclado, región en vivo y puntos de referencia, mientras que Stripe continúa siendo propietario de los campos de pago sensibles dentro de su interfaz de usuario segura.

El lado público también es intencionalmente fácil de rastrear sin exponer el acceso exclusivo de los seguidores: las páginas públicas y las páginas de campaña emiten metadatos consistentes y datos estructurados conservadores, mientras que las páginas privadas con enlaces mágicos, como Manage Pledge y los flujos de la comunidad de seguidores, permanecen fuera de la indexación de búsqueda.

## Código abierto

El grupo es de código abierto. Toda la plataforma (frontend, Worker, automatización y superficie de personalización de la bifurcación) está disponible en GitHub.

**Código fuente:** [github.com/your-org/your-project](https://github.com/your-org/your-project)

---
