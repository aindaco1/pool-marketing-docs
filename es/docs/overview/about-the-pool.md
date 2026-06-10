---
title: Acerca de The Pool
parent: Resumen
nav_order: 1
render_with_liquid: false
lang: es
---

# Acerca de The Pool

## Última actualización

9 de junio de 2026

**The Pool** es una plataforma de financiación colectiva de código abierto y estática primero para películas independientes, medios y otros proyectos impulsados por artistas.

Está diseñada alrededor de una promesa simple: los seguidores pueden comprometer apoyo a un proyecto creativo sin crear una cuenta, y sus tarjetas solo se cobran si la campaña alcanza su objetivo. Detrás de esa experiencia ligera para seguidores, The Pool da a creadores y operadores infraestructura real para pago de promesas, cumplimiento, actualizaciones, informes, edición administrativa, localización y despliegue.

Hito de versión actual: **v1.0.3**. El conjunto de funciones v1.0 y el pase de endurecimiento de lanzamiento están completos, incluidos zona horaria configurable de plataforma, recordatorios de lanzamiento, mejoras de rendimiento móvil en páginas de campaña, secretos de automatización administrativa con alcance, bloqueo de liquidación por campaña, manejo más seguro del ciclo de vida de medios y menor uso estable de escrituras/listados en KV.

## Promesas de todo o nada

Cuando respaldas un proyecto en The Pool, tu tarjeta se guarda de forma segura mediante Stripe, pero **no se te cobra hasta que la campaña alcanza su objetivo**. Si el proyecto no alcanza su meta de financiación antes de la fecha límite, tu tarjeta nunca se cobra.

Esto protege tanto a seguidores como a creadores: solo pagas por proyectos que realmente pueden alcanzar su objetivo de financiación.

## Experiencia para seguidores

A diferencia de otras plataformas, The Pool no requiere que crees una cuenta. Cuando haces una promesa, recibes enlaces por correo electrónico para:

- **Administrar tu promesa**: cancelar, modificar el monto o actualizar tu método de pago
- **Acceder a la comunidad de seguidores**: votar sobre decisiones creativas publicadas y ver actualizaciones exclusivas

Si tu pago incluye más de una campaña, recibirás correos de confirmación y enlaces de administración separados para cada campaña. Guarda esos correos. Son tus llaves.

Para campañas que todavía no se han lanzado, también puedes registrarte para recibir un recordatorio de lanzamiento único sin crear una cuenta ni iniciar una promesa.

El flujo de promesa funciona así:

1. **Explora**: encuentra una campaña que quieras ayudar a hacer realidad.
2. **Arma tu promesa**: agrega una o más campañas al carrito, elige recompensas o complementos y decide si quieres incluir una propina opcional para la plataforma.
3. **Guarda tu método de pago**: ingresa los detalles de pago mediante la interfaz segura de Stripe. Tu tarjeta queda guardada, no cobrada.
4. **Sigue la campaña**: la campaña permanece abierta hasta su fecha límite, mostrada en la zona horaria configurada de la plataforma.
5. **Ve el resultado**: si la campaña alcanza su objetivo, tu promesa se cobra después de que termina la campaña. Si no lo alcanza, no se te cobra.

Algunos pagos pueden incluir complementos de plataforma, complementos de campaña, mejoras de entrega, tarifas de envío, impuestos o una propina opcional para la plataforma. El proceso de pago explica qué cuenta para el objetivo de la campaña y qué apoya a la plataforma por separado.

Varias promesas del mismo correo se combinan en un solo cargo cuando la misma campaña tiene éxito. Si más de una campaña del mismo pago tiene éxito, esos cargos se mantienen separados por campaña. Las propinas opcionales de plataforma y los complementos de plataforma apoyan al equipo que opera la plataforma y no cuentan para el objetivo de financiación de un proyecto.

## Herramientas para creadores y operadores

The Pool está diseñado para cineastas y equipos creativos que necesitan una campaña que puedan operar sin enviar a los seguidores por un laberinto de cuentas, plugins o herramientas desconectadas.

- **Sin tarifa de plataforma para organizadores**: los fondos de campaña permanecen con el proyecto. Los seguidores pueden elegir una propina opcional de plataforma del 0% al 15% que ayuda a sostener The Pool sin reducir la financiación de la campaña.
- **Pago de promesas integrado**: los seguidores hacen promesas mediante el carrito y el flujo de revisión de The Pool, mientras Stripe maneja de forma segura los detalles de pago para cualquier cargo posterior de campaña.
- **Niveles de recompensa que se ajustan al proyecto**: ofrece niveles digitales o físicos, recopila datos de envío cuando sea necesario, establece límites de cantidad y usa las reglas de impuestos y envío configuradas para la campaña.
- **Complementos opcionales de plataforma**: ofrece productos de plataforma junto con promesas cuando estén habilitados, con inventario y manejo de envío separados que no cuentan para el objetivo de financiación de una campaña.
- **Complementos de campaña**: vende productos o extras específicos de campaña en el mismo flujo de promesa y mantén ingresos, inventario y envíos vinculados a esa campaña.
- **Panel de administración privado**: da a miembros confiables del equipo un espacio enfocado para ajustes de campaña, contenido de página, recompensas, actualizaciones, decisiones, informes, seguidores, analítica, enlaces de marketing, complementos y usuarios.
- **Zona horaria configurable de plataforma**: los superadministradores pueden elegir la zona horaria IANA usada para fechas límite de campaña, cuentas regresivas, informes programados y automatización del ciclo de vida.
- **Cargas de medios desde el panel**: prepara imágenes, video y audio de campaña y diario con vistas previas, publícalos en rutas de recursos de campaña mediante el flujo revisable normal, activa optimización de imagen/video y limpia medios del panel que ya no están referenciados.
- **Informes cuando los necesitas**: previsualiza y descarga CSV de promesas o cumplimiento desde el panel, con correos opcionales para operadores de campaña durante campañas activas.
- **Recordatorios de próximas campañas**: permite que posibles seguidores opten por un correo de lanzamiento antes de que abra una campaña, sin crear cuentas ni dependencias de listas de correo.
- **Embeds para promoción**: genera widgets de campañas en vivo para sitios asociados, páginas de prensa, portafolios de creadores o páginas de patrocinadores.
- **Enlaces para compartir y vistas previas sociales**: ofrece a seguidores destinos claros para compartir mientras las imágenes y descripciones de vista previa social permanecen alineadas con el estado actual de la campaña.
- **Fases de producción**: muestra a los seguidores qué partes del presupuesto pueden ayudar a financiar.
- **Metas adicionales**: haz visibles hitos creativos adicionales a medida que crece el apoyo.
- **Decisiones comunitarias**: invita a patrocinadores a votar sobre opciones creativas seleccionadas.
- **Diario de producción**: comparte actualizaciones que mantengan a los seguidores involucrados desde el lanzamiento hasta el cumplimiento.
- **Apoyo continuo**: sigue aceptando apoyo después de que termine la campaña principal, cuando la campaña esté configurada para ello.
- **Acceso de seguidores sin cuenta**: los patrocinadores administran sus promesas y visitan páginas exclusivas mediante enlaces seguros de correo en lugar de crear otra contraseña.
- **Flujos de seguidores listos para varios idiomas**: comienza con inglés y agrega páginas de soporte, correos, contenido de campaña y pantallas de administración traducidas cuando una implementación necesite más idiomas.
- **Contenido enriquecido más seguro**: escribe páginas de campaña y publicaciones de diario con Markdown e incrustaciones de medios aprobadas, con HTML inseguro y enlaces peligrosos bloqueados al renderizar.
- **Experiencia orientada a accesibilidad**: las páginas de campaña, el proceso de pago, diálogos, pestañas, controles deslizantes y flujos de seguidores se construyen y prueban para uso con teclado y lector de pantalla.

## Arquitectura

The Pool es una pila de financiación colectiva estática primero. Las páginas públicas se generan con anticipación, mientras el trabajo confiable de servidor permanece detrás de Cloudflare Workers para precios, promesas, acceso administrativo, datos de cumplimiento y liquidación serializada.

| Área | Qué lo ejecuta | Por qué importa para las bifurcaciones |
|------|----------------|----------------------------------------|
| Sitio público | [GitHub Pages](https://docs.github.com/en/pages) y Jekyll | Las páginas de campaña, documentos, contenido traducido y metadatos públicos siguen siendo fáciles de alojar y revisar en Git. |
| Experiencia de promesa | El runtime de carrito de The Pool | El carrito, la selección de recompensas, los complementos, la revisión de promesa y la administración por enlaces mágicos siguen siendo propios. |
| Pagos | [Stripe](https://stripe.com) | Stripe posee los campos de pago sensibles, métodos de pago guardados y cargos posteriores. |
| Backend | [Cloudflare Workers](https://workers.cloudflare.com) y KV | El Worker valida totales, almacena promesas, sirve estadísticas en vivo, potencia las API administrativas y maneja cumplimiento más estado de liquidación con alcance de campaña. |
| Panel de administración | El panel privado de The Pool | Usuarios autorizados pueden administrar campañas, contenido, informes, seguidores, analítica, enlaces de marketing, complementos y usuarios sin editar archivos directamente. |
| Correo electrónico | [Resend](https://resend.com) | Correos de confirmación, enlaces de seguidores, recordatorios de lanzamiento, actualizaciones de campaña y notificaciones de cargo usan una sola ruta transaccional. |

Los límites clave son intencionalmente claros: el contenido estático pertenece al sitio, las matemáticas confiables de promesa pertenecen al Worker, los detalles de pago pertenecen a Stripe, el correo transaccional pertenece a Resend y las operaciones con alcance de rol pertenecen al panel de administración.

## Rendimiento y costos

La pila está diseñada para ser práctica para equipos pequeños y bifurcaciones. Cada servicio principal tiene un nivel gratuito, y la plataforma evita trabajo dinámico innecesario siempre que puede. Las páginas públicas de campaña son estáticas, los datos públicos en vivo se combinan y se almacenan en caché del navegador, y el Worker se reserva para operaciones que necesitan confianza del lado del servidor.

El modelo de rendimiento de páginas públicas se mantiene estático primero. El sitio minimiza artefactos generados de compilación, deja que Cloudflare maneje la compresión de transferencia, reserva espacio estable para progreso y medios de campaña, sirve variantes de imagen responsivas generadas cuando existen, difiere los embeds remotos de YouTube hasta la intención de reproducción y retrasa el código de carrito propio más pesado hasta que realmente se necesita.

El panel de administración sigue la misma disciplina de costos. Navegación, filtros, vistas previas, analítica, informes y borradores locales evitan escrituras en KV. Las escrituras duraderas ocurren solo cuando un administrador guarda explícitamente estado del panel o publica un cambio de campaña/plataforma.

Con el endurecimiento de presupuesto de listados de v1.0.3, la entrega inactiva de recordatorios de lanzamiento, el reintento de correos a seguidores y las rutas de inventario de complementos de plataforma usan estado de cola o proyecciones de conteo vendido para evitar escaneos innecesarios de namespaces KV durante rutas normales de lectura.

## Bifurcación, desarrollo y despliegue

La personalización se basa principalmente en configuración. Impuestos, envío, SEO, localización, zona horaria de plataforma, registro, identidad de correo, ajustes del panel, marca pública, estilo de pago y presentación de correos para seguidores se mantienen alineados mediante configuración para que una bifurcación pueda cambiar la presentación sin reescribir el modelo de promesas.

Para desarrollo local, la ruta recomendada es el flujo rootless de Podman documentado en [Desarrollo local con Podman](/es/docs/operations/podman-local-dev/). Inicia Jekyll y el Worker con límites de servicio parecidos a producción mientras mantiene secretos en archivos env locales.

Para despliegue, los pushes a `main` compilan el sitio de GitHub Pages y despliegan el Cloudflare Worker cuando los secretos requeridos del repositorio y del Worker están configurados. Usa [Worker de promesas](/es/docs/operations/worker/) para configurar el Worker, [Guía de personalización](/es/docs/development/customization-guide/) para la configuración orientada a bifurcaciones, [Guía de pruebas](/es/docs/operations/testing/) para verificaciones de lanzamiento y [Guía de seguridad](/es/docs/operations/security/) para secretos, control de acceso y expectativas sobre rutas de abuso.

La misma arquitectura admite accesibilidad y SEO sin debilitar la seguridad. Las páginas públicas emiten metadatos rastreables y datos estructurados conservadores, mientras que las páginas privadas con enlaces mágicos, como Administrar promesa, páginas de comunidad de seguidores y el panel de administración, permanecen fuera de la indexación de búsqueda. Los flujos de pago y administración agregan comportamiento de teclado, foco, diálogo, región en vivo y puntos de referencia alrededor de la interfaz de pago segura de Stripe en lugar de reemplazarla.

## Código abierto

The Pool es de código abierto. Toda la plataforma — frontend, Worker, automatización y superficie de personalización para bifurcaciones — está disponible en GitHub.

**Código fuente:** [github.com/your-org/your-project](https://github.com/your-org/your-project)

---
