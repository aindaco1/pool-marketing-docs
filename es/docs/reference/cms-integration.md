---
title: Integración con CMS
parent: Referencia
nav_order: 1
render_with_liquid: false
lang: es
---

# Integración con CMS

The Pool utiliza [Pages CMS](https://pagescms.org) para la edición visual de campañas sin necesidad de conocimientos de Git.

## Inicio rápido

1. Vaya a [app.pagescms.org](https://app.pagescms.org)
2. Iniciar sesión con GitHub
3. Conceder acceso al repositorio `your-org/your-project`
4. Abra el proyecto para ver el panel.

## Qué puedes editar

### Campañas

El tipo de contenido principal. Cada campaña incluye:

|Sección|Campos|
|---------|--------|
|**Núcleo**|Título, slug, nombre/imagen del creador, categoría|
|**Imágenes**|Héroe (cuadrado + ancho), vídeo, fondos|
|**Financiamiento**|Monto objetivo, fechas de inicio/finalización|
|**Contenido**|Anuncio breve, descripción larga (bloques enriquecidos)|
|**Niveles**|Niveles de recompensa con precios, límites y acceso|
|**Metas ambiciosas**|Umbrales de financiación con títulos|
|**Artículos de soporte**|Grupos de financiación con nombre (por ejemplo, "Presentación de festivales")|
|**Diario**|Actualizaciones de producción con contenido enriquecido.|
|**Decisiones**|Encuestas comunitarias para patrocinadores|

### paginas

- **Página Acerca de** (`about.md`) — Explicación de la plataforma
- **Página de términos** (`terms.md`) — Términos de servicio

### Configuración del sitio

- Título del sitio, lema, descripción (a través de `_config.yml`)

## Flujo de trabajo de edición de campañas

### Creando una nueva campaña

1. Vaya a **Campañas** → **Agregar entrada**
2. Complete los campos obligatorios:
   - Título (p. ej., "TECOLOTE · Cortometraje")
   - Slug (por ejemplo, `tecolote`): se convierte en la URL
   - Nombre del creador
   - categoría
   - Imagen de héroe
   - Monto objetivo, fecha de inicio, fecha de finalización
   - breve propaganda
3. Añade al menos un nivel
4. Haga clic en **Guardar**

Pages CMS envía el nuevo archivo a GitHub, lo que desencadena una reconstrucción del sitio.

### Bloques de contenido

El campo `long_content` utiliza **edición basada en bloques**: cada tipo de bloque muestra solo sus campos relevantes:

|Tipo|Campos mostrados|
|------|--------------|
|**Texto**|Editor de contenido Markdown (no se admite HTML sin formato más allá de simples etiquetas en línea como `<br>` y `<em>`)|
|**Imagen**|Carga de imagen, texto alternativo, título|
|**Cita**|Texto de cita, autor|
|**Galería**|Selector de diseño, lista de imágenes, título|
|**Divisor**|Ninguno (solo agrega una línea horizontal)|

El mismo sistema de bloques se utiliza para las entradas del **Diario de producción**.

Reglas de seguridad de contenido para bloques de campaña/diario:

- Prefiera Markdown para formatear.
- Los enlaces Markdown siguen siendo compatibles, pero solo se mantienen los destinos seguros. Los enlaces externos se abren en una nueva pestaña automáticamente.
- Se conserva un pequeño subconjunto HTML en línea por motivos de compatibilidad: `<br>`, `<em>`, `<strong>`, `<i>`, `<b>`, `<u>`.
- Las incrustaciones estructuradas deben utilizar URL de proveedor `https://` aprobadas, y la auditoría de contenido rechaza otras etiquetas HTML sin formato y no pasarán las pruebas locales/CI.

### Agregar niveles

Cada nivel necesita:
- **ID**: minúsculas con guiones (p. ej., `digital-screener`)
- **Nombre**: nombre para mostrar (p. ej., "Evaluador digital")
- **Precio** — En dólares
- **Descripción** — Lo que obtiene el patrocinador

Configuraciones de niveles opcionales:
- **Imagen**: imagen ancha que se muestra encima del nombre del nivel.
- **Categoría** — `digital` o `physical` (para envío)
- **¿Varias cantidades?** — ¿Pueden los patrocinadores agregar más de una?
- **Límite** — Máximo disponible (dejar vacío para ilimitado)
- **Umbral de desbloqueo**: solo visible después de que la campaña alcance $X
- **Soporte tardío**: disponible después de que finalice la campaña

### Agregar entradas del diario

1. Abrir una campaña
2. Desplácese hasta **Diario de producción**
3. Haga clic en **Agregar artículo**
4. Complete:
   - **Fecha** — Selector de fecha y hora (almacenado con zona horaria)
   - **Título** — Título de entrada
   - **Fase** — Fase de producción (recaudación de fondos, preproducción, etc.)
5. Agregue bloques de contenido (texto, imágenes): el mismo sistema de bloques que la Descripción de la campaña
6. Guardar

Las nuevas entradas del diario activan transmisiones por correo electrónico a los seguidores (a través de Worker cron).

## Cargas de medios

Las imágenes se cargan en `assets/images/campaigns/` y están organizadas por slug de campaña.

**Tamaños recomendados:**
- Héroe (cuadrado): 1000×1000px, <400KB
- Héroe (ancho): 1600×900px, <400KB
- Foto del creador: 400×400px

## Permisos y acceso

⚠️ **Limitación actual:** Pages CMS aún no admite permisos por usuario. Todos los colaboradores con acceso al repositorio pueden editar todas las campañas.

### Soluciones alternativas para el acceso de múltiples creadores

**Opción 1: flujo de trabajo basado en sucursales**
1. Cree una rama por creador (por ejemplo, `campaign/tecolote`)
2. El creador edita solo su rama a través de Pages CMS
3. El administrador revisa y fusiona los RP con `main`

**Opción 2: Repositorio de envíos**
1. Los creadores bifurcan el repositorio o utilizan un repositorio de "envíos" separado
2. Enviar ediciones de campaña mediante Pull Request
3. Revisiones y fusiones de administradores

**Opción 3: Modelo de Confianza**
- Invita a colaboradores de confianza con acceso completo
- Confíe en el historial de confirmaciones de GitHub para la responsabilidad

### Agregar un colaborador

1. Vaya a **Configuración** → **Colaboradores** en Pages CMS
2. Invitar por correo electrónico (no se requiere cuenta de GitHub)
3. Reciben un enlace mágico para acceder al panel.

## Archivo de configuración

El CMS está configurado en `.pages.yml` en la raíz del repositorio.

Secciones clave:
- `media` — Subir rutas
- `content` — Colecciones y campos

Para agregar un nuevo campo a las campañas, edite `.pages.yml` y agréguelo a la matriz `fields` en `campaigns`.

Nota de campo de operaciones de campaña actual:

- `runner_report_emails` es la lista de destinatarios por campaña para los informes de los ejecutores de campaña.
- dejarlo vacío significa que la campaña no recibe correos electrónicos de informes del ejecutor de la campaña.
- este campo sólo controla los destinatarios; la sincronización, los archivos adjuntos, la copia de resumen y el comportamiento del prefijo de asunto aún provienen de `_config.yml` en `reports.campaign_runner`

## Solución de problemas

### Los cambios no aparecen

1. Verifique las acciones de GitHub: es posible que la compilación haya fallado
2. Espere de 2 a 3 minutos para que se implementen las páginas de GitHub
3. Actualizar completamente el navegador (Cmd+Shift+R)
4. Si necesita validar localmente, prefiera el flujo actual de Podman:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

### Error al cargar la imagen

- Verifique el tamaño del archivo (se recomienda <400 KB)
- Asegúrese de que el archivo sea un formato compatible (PNG, JPG, WebP)
- Comprobar que `assets/images/campaigns/` existe

### Campo que no se guarda

- Los campos obligatorios deben tener valores.
- Los campos validados por patrón (slug, ID) deben coincidir con el formato
- Verifique la consola del navegador en busca de errores

### Las secciones se muestran vacías (a pesar de tener datos)

Por lo general, esto significa YAML no válido en el archivo de campaña. Causas comunes:

- **`---` en el contenido**: una línea con solo `---` dentro de un campo de texto de varias líneas interrumpirá el análisis de YAML (se interpreta como un separador de documentos). Retire o reemplace con un separador diferente.
- **Caracteres especiales sin escape**: es posible que sea necesario aplicar escape a los dos puntos, las comillas o los corchetes en el texto.

Pruebe su archivo de campaña localmente:
```bash
python3 -c "import yaml; print(yaml.safe_load(open('_campaigns/your-campaign.md').read().split('---')[1]))"
```

## Futuro: permisos por campaña

Pages CMS tiene "Permisos" en su hoja de ruta. Cuando se publique, lo actualizaremos para admitir:
- Rol de administrador: editar cualquier campaña y configuración del sitio
- Rol de escritor de campañas: editar solo campañas asignadas + cargar medios

---
