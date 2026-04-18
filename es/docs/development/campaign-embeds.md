---
title: Embeds de campaña
parent: Desarrollo
nav_order: 7
render_with_liquid: false
lang: es
---

# Embeds de campaña

Este documento describe la función de inserción de campaña alojada de The Pool y cómo se relaciona con el trabajo de vista previa enriquecida/tarjeta compartida de la campaña más reciente.

## ¿Cuál es la característica?

The Pool incluye un widget de campaña integrado y alojado que los creadores pueden pegar en otro sitio como `iframe`.

El constructor sigue vivo:

- `/embed/campaign/`
- `/es/embed/campaign/`

Las páginas de la campaña se vinculan a ese creador a través de la barra lateral de la campaña, y el creador genera un fragmento de copiar y pegar para la campaña actual.

## Lo que no es

La inserción no es lo mismo que una vista previa rica en redes sociales.

- la inserción es una superficie `iframe` interactiva en vivo destinada a sitios web y cualquier host que permita pegar HTML
- La vista previa social es una superficie de metadatos e imágenes utilizada por plataformas como X, Slack, Discord, iMessage y objetivos desplegables similares.

Esas plataformas no mostrarán el widget de inserción completo. En su lugar, utilizan metadatos de página y el SVG de tarjeta compartida de campaña generado por los trabajadores.

## Contrato de URL actual

La ruta del constructor alojado es:

- `/embed/campaign/?slug={campaign-slug}`
- `/es/embed/campaign/?slug={campaign-slug}`

El iframe generado también puede contener opciones de presentación como parámetros de consulta:

- `layout=full|compact`
- `theme=default|warm|ocean`
- `media=show|hide`
- `cta=show|hide`

## Cambiar tamaño del modelo

El fragmento copiado incluye el iframe más un pequeño oyente de cambio de tamaño.

El widget publica un mensaje `pool-campaign-embed:resize` y el asistente pegado lo escucha y actualiza la altura del iframe. Esto evita que los creadores tengan que cablear manualmente una lógica de cambio de tamaño personalizada.

## Modelo de datos en vivo

El widget no es una tarjeta estática. Extrae el estado de la campaña en vivo de la instantánea pública de la campaña respaldada por los trabajadores y refleja:

- estado efectivo (`upcoming`, `live`, `funded`, `ended`)
- total comprometido en vivo
- estado financiado/no financiado
- estado de cuenta regresiva para campañas en vivo
- marcadores de progreso y presentación de objetivos ambiciosos
- creador/categoría/título/publicidad/metadatos multimedia

Eso mantiene las incrustaciones alineadas con la misma verdad de la campaña en vivo utilizada en otras partes del sitio.

## Comportamiento de localización

La superficie de inserción sigue el modelo local del sitio:

- `/es/embed/campaign/` renderiza el shell del constructor español.
- Las cadenas del constructor/tiempo de ejecución provienen del catálogo de configuración regional compartido.
- el cierre `X` y el widget CTA regresan a la ruta de la campaña localizada cuando corresponda
- Las URL de iframe copiadas conservan la ruta local actual

Las rutas de campaña localizadas se generan como:

- `/campaigns/{slug}/`
- `/es/campaigns/{slug}/`

## Relación con las vistas previas enriquecidas

Para mantener los enlaces compartidos alineados con el lenguaje visual de la inserción, las páginas de la campaña también emiten:

- metadatos de descripción/título de campaña conscientes del estado
- metadatos localizados en idiomas alternativos
- una ruta SVG de tarjeta compartida generada por el trabajador en `/share/campaign/{slug}.svg?lang={lang}`

Esa tarjeta compartida es el complemento de vista previa social de la inserción, no un reemplazo.

## Archivos principales de implementación

- `_layouts/campaign-embed.html`
- `embed/campaign/index.html`
- `es/embed/campaign/index.html`
- `assets/js/campaign-embed.js`
- `assets/partials/_embed.scss`
- `worker/src/index.js`

## Lista de verificación de validación

Al validar la inserción manualmente:

- el botón de la barra lateral de la campaña abre el generador de configuración regional correcto
- el fragmento de iframe copiado conserva la configuración regional y las opciones seleccionadas
- el widget cambia de tamaño automáticamente después de pegarlo
- el widget CTA y cerrar `X` apuntan a la página de campaña localizada correcta
- Los estados compacto/completo y de medios ocultos aún se muestran limpiamente en dispositivos móviles.
- el widget refleja los totales de la campaña en vivo y los cambios de estado
