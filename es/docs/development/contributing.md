---
title: Cómo contribuir
parent: Desarrollo
nav_order: 1
render_with_liquid: false
lang: es
---

# Contribuyendo a The Pool

## Última actualización

25 de agosto de 2026

## Empezando

### Requisitos previos
- Podman para la ruta local recomendada, o:
- Ruby + Bundler (para el anfitrión Jekyll)
- Se prefiere Node.js 24, Node.js 22 mínimo para Wrangler 4 (para scripts Worker +)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/) (para el desarrollo del trabajador anfitrión)
- opcional: [Stripe CLI](https://stripe.com/docs/stripe-cli) (para pruebas de webhook)

### Desarrollo Local

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Ése es el camino predeterminado para el desarrollo local. Mantiene los puertos locales estándar y los archivos de estado locales, pero ejecuta Jekyll y Wrangler dentro de contenedores, por lo que las nuevas bifurcaciones no necesitan alojar Ruby o Wrangler solo para iniciar la aplicación.

El contenedor Podman Worker ejecuta el nodo 24, que coincide con las acciones GitHub. El desarrollo de Worker solo de host utiliza el Nodo 24 cuando es posible; El nodo 22 es el tiempo de ejecución mínimo admitido para Wrangler 4.

Si en su lugar necesita la ruta de solo host:

```bash
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml
```

Si desea ejecutar el asistente de pago o el paquete de navegador en la misma pila respaldada por Podman:

```bash
./scripts/test-checkout.sh --podman
./scripts/test-e2e.sh --podman
./scripts/test-worker.sh --podman
./scripts/smoke-pledge-management.sh --podman
./scripts/pledge-report.sh --podman --local
./scripts/fulfillment-report.sh --podman --local
npm run test:e2e:headless:podman
npm run podman:doctor
npm run podman:self-check
```

`./scripts/test-e2e.sh --podman` es una cobertura de navegador totalmente automatizada. `./scripts/test-checkout.sh --podman` sigue siendo el asistente interactivo manual cuando desea realizar un pago real en su propio navegador.

Borre el caché si los estilos no se actualizan:
```bash
bundle exec jekyll clean
```

### Lea los documentos (en orden)

1. Root `README.md`: propósito y arquitectura de alto nivel
2. `docs/PROJECT_OVERVIEW.md` — Cómo encajan todas las piezas
3. `docs/WORKFLOWS.md`: ciclo de vida del aporte, enlaces mágicos y flujo de carga
4. `docs/PAYMENT_PROCESSOR.md`: configuración, pago, webhooks, liquidación y conciliación de Stripe
5. `docs/EMAIL.md`: configuración de Resend, tipos de correo electrónico, localización y comportamiento de entrega
6. `docs/ETHICAL_RISK.md`: Solicitudes de revisión de riesgos éticos para datos, dinero, mensajería, automatización, uso compartido público y poder administrativo
7. `docs/DEV_NOTES.md`: notas de integración, modelo de contenido y errores
8. `docs/TESTING.md`: guía de prueba completa (incluye configuración de secretos)
9. `docs/ROADMAP.md`: solo trabajo prospectivo
10. `docs/DASHBOARD.md` — Operaciones y edición del panel de administración

Para cambios en la interfaz de usuario del tablero, lea también `docs/ACCESSIBILITY.md`, `docs/I18N.md`, `docs/SECURITY.md` y `docs/SEO.md`; el shell de administración tiene requisitos explícitos para el acceso al teclado, cadenas en español, normalización de entrada y `noindex`.

### Configuración de páginas de GitHub

1. Crear repositorio y agregar archivos
2. Agregue un archivo `CNAME` para el dominio de su sitio público
3. DNS (Cloudflare):

|Tipo|Nombre|Valor|
|------|------|--------|
|CNOMBRE|piscina|`<username>.github.io`|

4. Habilite HTTPS en la configuración del repositorio
5. Verificar las cargas de carritos propios y el procesamiento de las campañas
6. Verifique que la configuración de inicio de pago respaldada por el trabajador esté presente

---

## Estado actual del proyecto

El [README](/es/docs/development/platform-readme/) describe la situación operativa y de cara al usuario actual.
línea de base. Los [Changelog](/es/docs/reference/changelog/) registros completos e inéditos
cambios, mientras que [Roadmap](/es/docs/reference/roadmap/) contiene trabajos potenciales. no
Mantenga una segunda lista de capacidades o enfoque activo fechada en esta guía.

---

## Ramificación y relaciones públicas

### Nomenclatura de sucursales
- Ramas de funciones: `feat/<short-name>` (p. ej., `feat/pledge-hook`)
- Arreglar ramas: `fix/<short-name>`
- Ramas de documentos: `docs/<short-name>`

### Estilo de confirmación
- Prefijos convencionales: `feat`, `fix`, `docs`, `chore`, `infra`

### Solicitudes de extracción
- Mantenga las relaciones públicas enfocadas y por debajo de ~300 líneas cuando sea posible
- Complete la plantilla de relaciones públicas, incluya capturas de pantalla para los cambios en la interfaz de usuario e incluya capturas de pantalla de escritorio/tableta/móvil para los cambios en el diseño del panel de administración.
- Incluya una revisión de riesgo ético cuando un RP cambie dinero, recopilación de datos, mensajes de apoyo, acceso de administrador, intercambio público, automatización, análisis o mecanismos de participación.
- Problemas de enlace con `Closes #123`

### Etiquetas
- `feature`, `bug`, `task`, `infra`, `docs`, `security`

---

## Lista de verificación de la primera contribución

- [ ] Clonar repositorio, ejecutar `npm run podman:doctor`
- [ ] Inicie el desarrollo local con `./scripts/dev.sh --podman`
- [ ] Confirme que el desarrollo local del trabajador se esté ejecutando en el nodo 24 a través de la ruta Podman
- [ ] Utilice únicamente la ruta Jekyll/Wrangler de host exclusivo si la necesita intencionalmente
- [ ] Hojee `_layouts/` y `_includes/` para ver la integración del carrito propio
- [ ] Revisar los scripts de carrito y aporte de `assets/js/`
- [ ] Lea `worker/src/` para comprender el backend (almacenamiento de aportes, estadísticas, carga)
- [ ] Abra `/admin/` localmente con la ruta de correo electrónico predeterminada del administrador de desarrollo y comprenda la división de publicación del panel versus KV-save
- [] Lea `docs/ETHICAL_RISK.md` antes de cambiar el pago, los correos electrónicos, los análisis, el poder administrativo, la visibilidad pública o la retención de datos.
- [ ] Verifique que `CNAME` esté configurado en el dominio de su sitio público

---

## Secretos y configuración (primero en modo de prueba)

- **Acciones de GitHub**: Agregar prueba `STRIPE_SECRET_KEY` + `CHECKOUT_INTENT_SECRET`
- **Cloudflare Worker**: Los mismos secretos que env vars; establecer `SITE_BASE`
- **Stripe**: para entornos alojados, cree un webhook para `https://worker.example.com/webhooks/stripe`
- **Pago personalizado local**: agregue `STRIPE_PUBLISHABLE_KEY_TEST` a `worker/.dev.vars`
- **Panel de administración**: el desarrollador local otorga acceso de superadministrador de arranque a través de `ADMIN_BOOTSTRAP_EMAILS` en `worker/.dev.vars` ignorado; Los administradores de la bifurcación colocan el acceso de producción en `_config.yml` `admin.users`, `ADMIN_USERS_JSON` o en la pantalla de usuarios del panel. La pantalla de usuarios se guarda en KV, no en GitHub.

Consulte [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/), [EMAIL.md](/es/docs/operations/email-system/) y [TESTING.md](/es/docs/operations/testing/) para obtener las referencias completas sobre pagos, correos electrónicos y secretos.

---

## Notas de seguridad

- Los secretos solo se encuentran en GitHub Actions + Cloudflare vars; nunca en repositorio
- La sección **Secretos y credenciales** del panel de control tiene un estado de solo lectura. No agregue edición secreta ni persistencia secreta a `_config.yml`, campaña YAML, registros de usuarios de KV o borradores del panel.
- Validar firmas de webhooks de Stripe
- Mantenga los dominios de remitente Resend alineados con `PLEDGES_EMAIL_FROM` y `UPDATES_EMAIL_FROM`
- Nunca confirmes claves o tokens API

---

## Glosario

|Término|Definición|
|------|------------|
|**Aporte**|Pedido realizado sin cargo inmediato; tarjeta guardada a través de Stripe SetupIntent|
|**Todo o nada**|Tarjetas cargadas solo si `pledged_amount >= goal_amount` en la fecha límite|
|**Intención de configuración**|Stripe se opone a guardar un método de pago para cargos posteriores fuera de la sesión|
|**Enlace mágico**|URL firmada por HMAC enviada por correo electrónico para la gestión de aportes sin cuenta|
|**The Pool**|Nombre de la plataforma para el sitio de crowdfunding|
|**Operador de plataforma**|Nombre de la empresa o estudio para su implementación|

---

## Contacto y propiedad

Utilice los documentos del proyecto y el historial de Git existente como contexto, y mantenga el alcance de los cambios y bien probados antes de abrir un PR.
