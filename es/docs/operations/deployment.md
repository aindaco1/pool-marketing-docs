---
title: Despliegue
parent: Operaciones
nav_order: 16
render_with_liquid: false
lang: es
---

# Despliegue

## Última actualización

6 de septiembre de 2026

Esta guía contiene el cableado de producción por primera vez y el flujo de trabajo de lanzamiento del sitio/Worker. Utilice [Podman](/es/docs/operations/podman-local-dev/) para contenedores locales, [Contributing](/es/docs/development/contributing/) para desarrollo y [Merge Smoke](/es/docs/operations/merge-smoke-checklist/) para la aprobación del operador.

## Configurar una bifurcación

1. Inicialice los submódulos grabados e instale las dependencias bloqueadas como se describe en [Contribuir](/es/docs/development/contributing/).
2. Establezca la identidad, las URL del sitio/Worker, los usuarios iniciales de administrador y las opciones de proveedor en `_config.yml` usando [Customization](/es/docs/development/customization-guide/). Mantenga `_config.local.yml` limitado a anulaciones locales.
3. Establezca el dominio personalizado de páginas de la bifurcación en las configuraciones `CNAME` y GitHub Pages, configure su asignación de DNS al host GitHub Pages y habilite HTTPS.
4. Obtenga una vista previa del asistente de configuración con `npm run setup:deploy -- --mode=production --dry-run`. Revise su cuenta, espacio de nombres, secreto, repositorio y plan de implementación antes de aplicarlo.
5. Configure las credenciales de pago y webhook a través de [Payment Processor](/es/docs/operations/payment-processor/), verificación de remitente/dominio a través de [Email](/es/docs/operations/email-system/) y cualquier proveedor de envío/impuestos habilitado a través de [Shipping](/es/docs/operations/shipping/) y [Tax Calculator](/es/docs/operations/tax-calculator/).
6. Verifique [Security](/es/docs/operations/security/), [Backup and Restore](/es/docs/operations/backup-restore/) y los requisitos de evidencia de publicación antes de un lanzamiento en vivo.

El asistente de configuración se encuentra en [`scripts/setup-deploy.mjs`](https://github.com/aindaco1/pool/blob/main/scripts/setup-deploy.mjs). Proporciona una configuración de nodo libre de dependencias para modos locales y de producción. Sus pruebas de proveedores falsos validan el comportamiento del ayudante; El aprovisionamiento real de la cuenta y la preparación del proveedor requieren pruebas separadas.

Los secretos de tiempo de ejecución de Worker pertenecen a Cloudflare. Acciones de suministro de secretos del repositorio GitHub; no se convierten automáticamente en secretos Worker. Mantenga los valores del proveedor y de firma local en `worker/.dev.vars` ignorados, no una copia de seguridad de las credenciales de producción. Los enlaces KV necesarios incluyen `PLEDGES`, `VOTES` y `RATELIMIT`; las rutas de escritura fallan al cerrarse si el almacenamiento con límite de velocidad no está disponible.

## Flujo de trabajo de lanzamiento

Envíe los cambios revisados ​​a `main` para actualizar el sitio de producción GitHub Pages:

```bash
git push origin main
```

Las versiones de Worker utilizan el flujo de trabajo de acciones **Implementar producción** GitHub enviado manualmente con una rama, etiqueta o confirmación revisada en su entrada `ref`. Ambos trabajos verifican esa entrada, así que use una confirmación exacta cuando el sitio y Worker deban reproducir la misma revisión inmutable. Ese flujo de trabajo implementa ambos:

- el sitio GitHub Pages
- el Cloudflare Worker de `worker/wrangler.toml`

Las ejecuciones rutinarias de **Actualizar páginas de producción**, incluidas las actualizaciones programadas del estado de la campaña, no implementan Worker. El respaldo manual exclusivo de Worker desde la raíz del repositorio es `npm run deploy:worker`.

La compilación de páginas ejecuta Jekyll primero, luego `npm run assets:minify` contra el CSS/JavaScript `_site/assets` generado y las copias generadas de los scripts del navegador Site Shell anclados antes de cargar el artefacto. Las raíces seleccionadas son explícitas y seguras para el recorrido; Los archivos fuente permanecen legibles en el repositorio. Cloudflare todavía maneja la compresión gzip/Brotli/Zstandard en el borde, por lo que Cloudflare Auto Minify permanece deshabilitado.

Credenciales del repositorio GitHub utilizadas por la implementación y los flujos de trabajo relacionados:

- `CLOUDFLARE_API_TOKEN` a partir de un **token de API de usuario** creado en **Mi perfil -> Tokens de API**, utilizando la plantilla **Editar Cloudflare Workers** y con alcance en esta cuenta y la zona `example.com`. No utilice un token API propiedad de la cuenta; Wrangler todavía llama a puntos finales de ámbito de usuario, como membresías, durante la implementación.
- `CLOUDFLARE_ACCOUNT_ID`
- `ADMIN_SECRET` para la verificación del diario posterior a la implementación
- `ADMIN_BROADCAST_SECRET` opcional para la verificación del diario posterior a la implementación cuando Worker usa credenciales de transmisión con alcance
- `CLOUDFLARE_CACHE_PURGE_TOKEN` opcional con permisos de purga de caché de zona si desea que la purga de caché utilice un token más estrecho que el token de implementación. Esto es recomendable; de lo contrario, también se debe permitir que el token de implementación purgue la caché.
- `CLOUDFLARE_DNS_API_TOKEN`, `CLOUDFLARE_ZONE_ID` y `CLOUDFLARE_ZONE` opcionales para el flujo de trabajo de publicación de evidencia del proveedor. El token DNS utiliza acceso de zona/DNS/lectura de solo lectura para la zona de producción.
- `CLOUDFLARE_CACHE_RULES_API_TOKEN` más `CLOUDFLARE_ZONE_ID` para aplicar/conciliar la regla de respuesta del administrador con alcance de ruta. Utilice un token dedicado con Edición de reglas de caché; La verificación pública posterior a la implementación no necesita credenciales.
- `DIARY_CHECK_BYPASS_SECRET` opcional si Cloudflare WAF desafía la verificación del diario posterior a la implementación

Para una configuración guiada por primera vez, ejecute:

```bash
npm run setup:deploy -- --mode=production --dry-run
npm run setup:deploy -- --mode=production --deploy
```

Revise el ensayo antes de aplicar los cambios. La ayuda automatiza la configuración repetitiva, pero no reemplaza la revisión de los alcances de los tokens Cloudflare, los permisos del repositorio GitHub, los puntos finales del webhook Stripe, la verificación del remitente Resend, los widgets Turnstile, las credenciales del proveedor USPS/ZIP.TAX y la lista de verificación de humo de fusión.

Establezca los secretos `ADMIN_BROADCAST_SECRET` o `ADMIN_SETTLEMENT_SECRET` coincidentes en Cloudflare Worker antes de confiar en la aplicación de rutas con alcance en producción. Agregue `ADMIN_SETTLEMENT_SECRET` a los secretos del repositorio GitHub solo si una acción GitHub o un flujo de trabajo del operador realmente llama a puntos finales de liquidación. Mantenga valores locales separados en `worker/.dev.vars`; no copie los valores de producción allí como copia de seguridad.

El flujo de trabajo también necesita permisos de implementación GitHub Pages. Mantenga `pages: write` y `id-token: write` explícitos en el trabajo de implementación de páginas si copia o refactoriza `.github/workflows/deploy.yml`.

Las cargas de paneles solicitan el flujo de trabajo separado **Optimizar medios del panel**. Sus solicitudes de extracción de optimización conservan los archivos fuente; el flujo de trabajo no implementa el código Worker. Consulte [Performance](/es/docs/operations/performance/#optimización-de-medios) y [Dashboard Media](/es/docs/operations/admin-dashboard/#medios-de-comunicación) para conocer el canal de medios.

## Comprobación del diario posterior a la implementación

Si la verificación del diario registra una página de desafío HTTP `403` Cloudflare, la solicitud se detiene antes de que llegue a Worker. Agregue una regla personalizada WAF Cloudflare que omita los desafíos administrados para:

- anfitrión es igual a `worker.example.com`
- ruta es igual a `/admin/diary/check`
- método es igual a `POST`
- encabezado `X-Pool-Diary-Check` es igual al valor `DIARY_CHECK_BYPASS_SECRET`

Expresión sugerida:

```text
(http.host eq "worker.example.com" and http.request.method eq "POST" and http.request.uri.path eq "/admin/diary/check" and any(http.request.headers["x-pool-diary-check"][*] eq "your-bypass-secret"))
```

Worker aún requiere `Authorization: Bearer ADMIN_BROADCAST_SECRET` cuando se configuran las credenciales de transmisión con alcance; de ​​lo contrario, `Authorization: Bearer ADMIN_SECRET`; el encabezado de omisión solo permite que la automatización de acciones GitHub llegue a ese punto final autenticado.

## Verificación y límite de artefactos

Utilice [Testing](/es/docs/operations/testing/) para la puerta local y [Merge Smoke](/es/docs/operations/merge-smoke-checklist/) para obtener la lista de verificación exacta del operador y la plantilla de aprobación. Registre el entorno, la revisión, las verificaciones requeridas del proveedor, las omisiones y los resultados en [evidencia de publicación](https://github.com/aindaco1/pool/tree/main/docs/release-evidence). Una compilación local o un envío de flujo de trabajo no establece la aceptación de la implementación o del proveedor.

El artefacto público excluye `docs/`, `AGENTS.md` y `CHANGELOG.md`, junto con README, LICENCIA, pruebas, herramientas y medios temporales generados. Los archivos raíz Acerca de, Términos, Administrador y Markdown de la lista de verificación del creador siguen siendo fuentes del sitio; sus URL localizadas y reglas de indexación se verifican por separado de los documentos del mantenedor.
