---
title: Internacionalización
parent: Desarrollo
nav_order: 6
render_with_liquid: false
lang: es
---

# Internacionalización (i18n)

## Última actualización

16 de julio de 2026

Este documento registra la estructura de localización actual de The Pool y el flujo de trabajo admitido para agregar idiomas en una bifurcación.

La ubicación secundaria enviada inmediatamente es español, pero el objetivo real es hacer que la localización futura sea sencilla sin código personalizado para las superficies compartidas propiedad del sitio.

## Lo que existe ahora

El modelo i18n actual cubre:

- configuración regional estructurada en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- catálogos de traducción compartidos en [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n)
- asistentes de URL con reconocimiento regional y un selector de idioma de pie de página compartido
- rutas públicas localizadas para:
  - `/`
  - `/about/`
  - `/terms/`
  - `/campaigns/:slug/`
  - `/embed/campaign/`
  - `/pledge-success/`
  - `/pledge-cancelled/`
  - `/manage/`
  - `/community/`
  - `/admin/`
  - `/creator-campaign-checklist/`
  - páginas de la comunidad de patrocinadores
- copia localizada en tiempo de ejecución propiedad del sitio para carrito, pago, gestión de aporte, autenticación de administrador/panel de control/vistas previas de informes/exploración de patrocinadores/vista previa de contenido, creación de nuevas campañas, vistas previas de campañas protegidas, flujos de la comunidad, cuentas regresivas de campañas (incluido el estado del tiempo restante del lector de pantalla), recordatorios de lanzamiento de próximas campañas, videos destacados/estados de carga y títulos insertados, avance de la comunidad de patrocinadores en Chrome, pestañas de diario, controles de fase de producción, etiquetas de galería, estadísticas en vivo texto de estado y el widget/creador de inserción de campaña
- El cambio de idioma del administrador conserva el estado de vista seguro, como los filtros de campaña y los hashes, pero elimina los tokens de enlace mágico `admin_login` antes de vincularlos al idioma alternativo.
- etiquetas de sección de complementos de campaña localizadas tanto en el carrito como en Manage Pledge, además de una copia de ayuda para el pago, como resúmenes de los botones del carrito, etiquetas de ubicación fiscal y una copia del siguiente paso del pago alojado
- Cambio de pie de página de campaña localizado y formato de fecha de campaña localizado para Chrome de campaña pública
- Etiquetas localizadas de enlaces para compartir de campañas, además de texto de intención de compartir con conocimiento del estado para campañas próximas, activas, financiadas y finalizadas.
- Correos electrónicos de soporte/administrador de Worker localizados y enlaces de vista previa protegidos `/manage/`, `/community/:slug/`, `/admin/` y protegidos según el idioma persistente o solicitado relevante
- rutas localizadas de tarjetas compartidas de campañas de trabajadores como `/share/campaign/:slug.png?lang=es`
- metadatos públicos localizados y sugerencias de lenguaje de datos estructurados en páginas públicas y páginas de campaña localizadas

El inglés sigue siendo la configuración regional predeterminada. El español es el lugar secundario preclasificado.

## Modelo de configuración

La configuración regional canónica se encuentra en [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml):

```yml
i18n:
  default_lang: en
  supported_langs:
    - en
    - es
  language_labels:
    en: English
    es: Español
  pages:
    home:
      en: /
      es: /es/
    about:
      en: /about/
      es: /es/about/
    terms:
      en: /terms/
      es: /es/terms/
    manage:
      en: /manage/
      es: /es/manage/
    admin:
      en: /admin/
      es: /es/admin/
    community_index:
      en: /community/
      es: /es/community/
    creator_campaign_checklist:
      en: /creator-campaign-checklist/
      es: /es/creator-campaign-checklist/
    pledge_success:
      en: /pledge-success/
      es: /es/pledge-success/
    pledge_cancelled:
      en: /pledge-cancelled/
      es: /es/pledge-cancelled/
```

Este modelo mantiene intencionalmente la localización predecible para las bifurcaciones:

- un idioma predeterminado
- una lista de idiomas admitidos
- un mapa con etiqueta de visualización
- un mapa de ruta seleccionado para páginas compartidas con reconocimiento regional

Las páginas de campaña son la principal excepción: se generan a partir de la colección de campañas, por lo que sus rutas localizadas se derivan de slugs de campaña y generan `localized_paths` en lugar de entradas `i18n.pages` escritas a mano.

## Fuentes de traducción

### 1. UI compartida y copia en tiempo de ejecución

Las cadenas compartidas propiedad del sitio se encuentran en un archivo YAML por configuración regional:

- [/_data/i18n/en.yml](https://github.com/your-org/your-project/blob/main/_data/i18n/en.yml)
- [/_data/i18n/es.yml](https://github.com/your-org/your-project/blob/main/_data/i18n/es.yml)

Esto incluye:

- etiquetas de navegación
- botones
- etiquetas de estado
- progreso/metatexto
- carrito/pagar/Administrar copia en tiempo de ejecución de aporte
- Pestañas del panel de administración, filtros, etiquetas de formulario generadas, etiquetas de opciones, texto de ayuda, copia de carga de medios, copia de informe/soporte/análisis/marketing, copia de diálogo de nueva campaña, copia de diálogo de vista previa protegida y controles del editor de contenido
- Etiquetas de la sección de complementos de la campaña y copia auxiliar de pago alojada/personalizada.
- copia en tiempo de ejecución de la comunidad
- cuenta regresiva de la campaña / video-heroe / comunidad-de-patrocinadores / diario / fase-de-producción / galería / copia de estadísticas en vivo
- Formulario de recordatorio del lanzamiento de la próxima campaña, estado y copia por correo electrónico
- Etiquetas para compartir de campaña y mensajes con intención de compartir para Bluesky, X, Threads, Facebook, SMS y correo electrónico.
- creador de inserción de campaña/copia de widget
- Copia del correo electrónico del patrocinador del trabajador

El inglés es el archivo fuente canónico y la configuración regional alternativa.

### 2. Páginas escritas de formato largo

La copia de página de formato largo debe utilizar archivos fuente localizados en lugar de intentar forzar cada párrafo en YAML.

Ejemplos:

- [acerca de.md](/es/docs/overview/about-the-pool/)
- [es/about.md](/es/docs/overview/about-the-pool/)
- [términos.md](/es/docs/overview/terms-and-guidelines/)
- [es/terms.md](/es/docs/overview/terms-and-guidelines/)
- [lista-de-verificación-de-campaña-de-creadores.md](https://github.com/your-org/your-project/blob/main/creator-campaign-checklist.md)
- [es/creator-campaign-checklist.md](https://github.com/your-org/your-project/blob/main/es/creator-campaign-checklist.md)

Ese mismo patrón debería usarse para futuras páginas con mucho contenido.

## Modelo de enrutamiento

El sitio utiliza un modelo estático de prefijo local:

- el idioma predeterminado permanece en las URL canónicas
  - `/`
  - `/about/`
  - `/terms/`
  - `/manage/`
  - `/community/`
  - `/creator-campaign-checklist/`
- Los idiomas no predeterminados viven bajo un prefijo local.
  - `/es/`
  - `/es/about/`
  - `/es/terms/`
  - `/es/campaigns/{slug}/`
  - `/es/campaigns/{slug}/rewards/{tier-id}/` cuando un producto de Shopping está habilitado explícitamente
  - `/es/embed/campaign/`
  - `/es/manage/`
  - `/es/community/`
  - `/es/creator-campaign-checklist/`

Esto mantiene el modelo de implementación de Jekyll/GitHub Pages simple y predecible.

Las rutas de recopilación de campañas ahora se generan en ambas configuraciones regionales, por lo que el selector de idioma del pie de página puede permanecer disponible en las páginas de la campaña en lugar de desaparecer o vincularse nuevamente a la ruta del idioma predeterminado.

Las páginas de productos de Focused Shopping siguen el mismo modelo de par local generado. Los datos del producto, como el nombre y la descripción de la recompensa creados por la campaña, siguen siendo contenido de autor; Las divulgaciones compartidas sobre pedidos anticipados, envíos y ventas finales provienen del catálogo local.

## Ayudantes y plomería en tiempo de ejecución

Ayudantes locales compartidos:

- [/_includes/t.html](https://github.com/your-org/your-project/blob/main/_includes/t.html)
- [/_includes/localized-url.html](https://github.com/your-org/your-project/blob/main/_includes/localized-url.html)
- [/_includes/language-switcher.html](https://github.com/your-org/your-project/blob/main/_includes/language-switcher.html)
- [/_includes/fecha-localizada.html](https://github.com/your-org/your-project/blob/main/_includes/localized-date.html)
- [/_includes/localized-datetime.html](https://github.com/your-org/your-project/blob/main/_includes/localized-datetime.html)

Cargas útiles de configuración regional en tiempo de ejecución:

- [/assets/i18n.json](https://github.com/your-org/your-project/blob/main/assets/i18n.json)
- [/_includes/runtime-messages-json.html](https://github.com/your-org/your-project/blob/main/_includes/runtime-messages-json.html)
- [activos/js/pool-config.js](https://github.com/your-org/your-project/blob/main/assets/js/pool-config.js)

Localización del panel de administración:

- La copia estática del shell de administración en [/_layouts/admin.html](https://github.com/your-org/your-project/blob/main/_layouts/admin.html) usa el asistente de traducción Liquid compartido
- La copia de administración en tiempo de ejecución está incluida en el catálogo de administración completo emitido por `runtime-messages-json.html`.
- Los campos de Configuración y Campañas generados provienen de Worker JSON, pero [assets/js/admin-dashboard.js](https://github.com/your-org/your-project/blob/main/assets/js/admin-dashboard.js) los localiza con claves deterministas:
  - `settings_section_*` para secciones de la barra lateral de configuración de nivel superior
  - `settings_field_*_label`, `settings_field_*_help` y `settings_field_*_placeholder` para configuraciones de plataforma editables
  - `settings_readonly_*_label` y `settings_readonly_*_help` para diagnósticos de solo lectura de plataforma y filas de estado secreto
  - `campaign_field_*_label` y `campaign_field_*_help` para configuraciones de campaña y colecciones propiedad de la campaña
  - `campaign_readonly_*_label` y `campaign_readonly_*_help` para filas de solo lectura de campaña
  - Teclas `settings_option_*`, `campaign_option_*` y genéricas `option_*` para opciones de selección/casilla de verificación
- Los controles del editor de contenido, el estado/errores de carga de medios por etapas, las etiquetas de configuración de medios/texto de ayuda, la configuración de la galería y los controles de subtítulos flotantes de la galería también están localizados en tiempo de ejecución; actualice inglés y español juntos al agregar un nuevo control de medios de administración
- Los widgets de tiempo de ejecución de solo lectura, como Configuración -> El uso del plan, deben devolver ID de carga útil estables o valores `labelKey` opcionales del trabajador, mientras que las cadenas de visualización del navegador se encuentran en `_data/i18n/{lang}.yml`.
- el trabajador debe seguir devolviendo valores estables del campo `path`; el cliente deriva claves i18n de esas rutas para que las bifurcaciones puedan agregar campos sin duplicar el código de renderizado
- los datos de campaña creados por el creador, los cuerpos del diario, los nombres de complementos, las opciones de decisión y otro contenido guardado se muestran como creados; el catálogo compartido solo localiza la interfaz de usuario del panel circundante

Comportamiento actual importante:

- el selector de idioma del pie de página es la superficie de cambio de configuración regional compartida
- conserva la cadena de consulta actual y el hash
- Las URL tokenizadas como `/manage/?t=...` pueden cambiar a `/es/manage/?t=...` sin perder el acceso al aporte.
- Stripe se inicializa con la configuración regional actual donde sea compatible, por lo que las etiquetas de campo propiedad de Stripe y la validación también se pueden localizar
- Los resúmenes de activación del carrito y la copia auxiliar de ubicación de impuestos provienen del catálogo local compartido, por lo que el pago personalizado sigue siendo traducible sin cadenas codificadas separadas.
- Las plantillas de campañas públicas ahora enrutan cadenas de Chrome compartidas a través de datos locales en lugar de inglés codificado cuando sea práctico, incluido el CTA/estado de carga del video principal, títulos insertados de video principal, copia de adelanto de la comunidad de patrocinadores, copia de estado/formulario de recordatorio de lanzamiento, diario cromado, etiquetas de la fase de producción, etiquetas de accesibilidad de la galería, copia del aporte de la barra lateral de la campaña, texto de estado del lector de pantalla de cuenta regresiva y fechas de la campaña localizadas.
- Las páginas de campaña utilizan etiquetas para compartir localizadas y texto de intención de compartir con reconocimiento del estado, al tiempo que dejan los títulos y anuncios publicitarios de las campañas escritos por los creadores tal como fueron escritos.
- Las páginas de campaña ahora exponen el cambio de idioma del pie de página localizado a través de la campaña generada `localized_paths`
- el generador de inserción de campaña alojada y el widget extraen sus cadenas de generador/tiempo de ejecución del catálogo de configuración regional compartido y conservan los enlaces de retorno de la campaña que tienen en cuenta la configuración regional.
- Los metadatos públicos y JSON-LD ahora también siguen el idioma de la página activa, la ruta de inicio localizada y el conjunto de idiomas admitidos para que las páginas localizadas no emitan sugerencias de rastreo solo en inglés por accidente.
- Las páginas localizadas de formato largo, como Acerca de y Términos, aún usan traducciones de archivos fuente, por lo que los barridos de documentos/contenido deben mantener esos archivos específicos de la configuración regional sincronizados manualmente.

## Comportamiento del correo electrónico del trabajador

Los correos electrónicos de apoyo de los trabajadores reutilizan el mismo catálogo local y persisten `preferredLang`.

Archivos relevantes:

- [trabajador/src/email.js](https://github.com/your-org/your-project/blob/main/worker/src/email.js)
- [trabajador/src/index.js](https://github.com/your-org/your-project/blob/main/worker/src/index.js)

Comportamiento práctico:

- Si no se captura ninguna preferencia local, los correos electrónicos vuelven al inglés.
- si un patrocinador se compromete o administra desde `/es/...`, el trabajador puede persistir `preferredLang=es`
- Los correos electrónicos de los patrocinadores y las URL de enlaces mágicos utilizan el modelo de ruta en español, como `/es/manage/?t=...`.
- Los correos electrónicos de recordatorio de lanzamiento utilizan el `preferredLang` persistente del registro y se vinculan a la ruta de la campaña localizada cuando hay una disponible.
- los correos electrónicos de asignaciones de campaña y los correos electrónicos de revisores de vista previa protegidos utilizan el tema de correo electrónico compartido y el catálogo local; La copia del correo electrónico de vista previa del revisor debe indicar que el enlace caduca en 24 horas.
- Las tarjetas compartidas de campaña también se pueden solicitar según la configuración regional, como `/share/campaign/sunder.png?lang=es`

## Qué hace y qué no hace un archivo YAML de configuración regional

Agregar un nuevo archivo YAML de configuración regional es suficiente para:

- sitio compartido chrome
- mensajes compartidos de tiempo de ejecución/navegador
- Copia del correo electrónico de apoyo del trabajador

No es suficiente para un sitio completamente traducido por sí solo.

El soporte completo de idiomas también necesita:

- el idioma agregado a `i18n.supported_langs`
- su etiqueta agregada a `i18n.language_labels`
- rutas localizadas agregadas a `i18n.pages`
- páginas de origen localizadas para cualquier contenido de formato largo que realmente desee traducir

## Flujo de trabajo de bifurcación recomendado

1. Copie [/_data/i18n/en.yml](https://github.com/your-org/your-project/blob/main/_data/i18n/en.yml) a `/_data/i18n/{lang}.yml`.
2. Agregue el idioma al bloque `i18n` en [/_config.yml](https://github.com/your-org/your-project/blob/main/_config.yml).
3. Agregue rutas de páginas públicas localizadas a `i18n.pages`.
4. Agregue páginas de origen localizadas para contenido de formato largo como `/about/`, `/terms/`, `/manage/` o páginas de índice de la comunidad seleccionadas cuando sea necesario.
5. Verifique las rutas de recopilación generadas, como `/es/campaigns/{slug}/`, y cualquier ruta de inserción con reconocimiento regional que exponga su implementación.
6. Para cambios en el panel de administración, agregue claves `admin` coincidentes en cada archivo local antes del envío. En particular, los campos generados necesitan las claves deterministas `settings_field_*`, `settings_readonly_*`, `campaign_field_*` o `campaign_readonly_*` descritas anteriormente; Los flujos creados manualmente, como **Crear nueva campaña** y **Vista previa**, necesitan claves de diálogo/acción/ayuda explícitas.
7. Ejecute `npm run test:i18n` antes del envío para verificar que los catálogos de locales compatibles mantengan la misma cobertura de claves anidadas que inglés.
8. Ejecute la pila local y verifique tanto la copia de la IU compartida como las rutas localizadas, incluidas `/admin/` y `/es/admin/` cuando las cadenas de la IU del administrador cambiaron:

```bash
npm run test:i18n
npm run podman:doctor
./scripts/dev.sh --podman
```

## Guía neutral en español de EE. UU./Latinoamérica

La configuración regional en español mantenida apunta a un español claro y neutral para audiencias de Estados Unidos y América Latina. Prefiera términos directos y de amplia comprensión a la jerga regional, la sintaxis literal del inglés o la jerga de producto inexplicable.

Utilice este glosario de forma coherente en páginas públicas y en copias de interfaces compartidas:

|concepto ingles|Español preferido|Evitar en copia pública|
| --- | --- | --- |
|aporte|aporte|*aporte*|
|patrocinador / patrocinador|patrocinador / persona que apoya|*patrocinador*|
|nivel de recompensa|nivel de recompensa|*nivel*|
|complemento|complemento|*complemento*|
|pagar|proceso de pago|*pagar*|
|cumplimiento|preparación y entrega|*cumplimiento*|
|envío|envío|*envío*|
|volver|devolución|*regreso*|
|reembolso|reembolso|*reembolso*|
|vista previa|vista previa|*vista previa*|
|tablero|panel|*tablero*|
|analítica|analisis|*análisis*|

La documentación técnica del desarrollador puede conservar identificadores exactos como `runtime`, nombres de rutas, rutas de configuración o nombres de productos de proveedores cuando la traducción haría que la implementación fuera ambigua. La política orientada al usuario y la copia Acerca de no deben depender de esos identificadores en inglés.

Para cambios importantes en las políticas, mantenga los títulos, anclajes, obligaciones, períodos de tiempo, recursos y vías de contacto en inglés y español en paridad directa. La integridad de las claves automatizadas no reemplaza una revisión humana fluida; registre el revisor y la fecha en la evidencia de divulgación cuando se realice esa revisión.

## Límites actuales

La integridad local automatizada y las comprobaciones i18n/SEO representadas siguen siendo puertas de liberación. La copia v1.1.2 Acerca de, Términos, Compras, envío y sin devoluciones está dirigida al español neutral de EE. UU. y Latinoamérica, y el propietario confirmó la finalización de la revisión fluida final el 14 de julio de 2026. Exija un plan explícito de revisión de traductor/hablante nativo antes de agregar idiomas más allá del inglés y el español.

Todavía intencionalmente fuera del alcance de este modelo:

- traducción automática de cuerpos de campaña, entradas de diario o contenido de publicaciones de la comunidad escritos por creadores
- traducción automática de configuraciones de campaña guardadas creadas por el administrador, nombres de complementos, opciones de decisión, etiquetas de referencia u otro contenido almacenado como datos de campaña/plataforma
- reglas de impuestos, envío o precios específicos de la localidad
- un canal de traducción automática en el repositorio
