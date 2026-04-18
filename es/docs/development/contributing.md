---
title: Cómo contribuir
parent: Desarrollo
nav_order: 1
render_with_liquid: false
lang: es
---

# Contribuyendo a The Pool

## Empezando

### Requisitos previos
- Podman para la ruta local recomendada, o:
- Ruby + Bundler (para el anfitrión Jekyll)
- Node.js (para scripts de trabajador +)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/) (para el desarrollo del trabajador anfitrión)
- opcional: [Stripe CLI](https://stripe.com/docs/stripe-cli) (para pruebas de webhook)

### Desarrollo Local

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Ése es el camino predeterminado para el desarrollo local. Mantiene los puertos locales estándar y los archivos de estado locales, pero ejecuta Jekyll y Wrangler dentro de contenedores, por lo que las nuevas forks no necesitan alojar Ruby o Wrangler solo para iniciar la aplicación.

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

`./scripts/test-e2e.sh --podman` ahora es una cobertura de navegador totalmente automatizada. `./scripts/test-checkout.sh --podman` sigue siendo el asistente interactivo manual cuando desea realizar un pago real en su propio navegador.

Borre el caché si los estilos no se actualizan:
```bash
bundle exec jekyll clean
```

### Lea los documentos (en orden)

1. Root `README.md`: propósito y arquitectura de alto nivel
2. `docs/PROJECT_OVERVIEW.md` — Cómo encajan todas las piezas
3. `docs/WORKFLOWS.md`: ciclo de vida de la promesa, enlaces mágicos y flujo de carga
4. `docs/DEV_NOTES.md`: notas de integración, modelo de contenido y errores
5. `docs/TESTING.md`: guía de prueba completa (incluye configuración de secretos)
6. `docs/ROADMAP.md` — Funciones planificadas
7. `docs/CMS.md` — Configuración de Pages CMS y edición de campañas

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

## Estado actual (abril de 2026)

✅ **Completado:**
- Jekyll + estructura del sitio de carrito propio
- Sistema de estilo Sass (parciales modulares compartidos, cuadrícula de 8px)
- Complemento de formato de dinero (estilo `$3,800`)
- Tarjetas de campaña, diseño de dos columnas, variantes de héroe
- Fases de producción, decisiones comunitarias, diario de producción.
- Pledge UX, ícono de carrito, revisión de pago propia
- Flujo de pago nativo de Stripe en el sidecar de pago existente
- Gestión de promesas sin cuenta (enlaces mágicos, página `/manage/`)
- Flujo `Update Card` in situ en `/manage/`
- Página comunitaria exclusiva para seguidores con votación
- Soporte de niveles no apilable (ocultar controles de cantidad en el carrito)
- Manejo móvil de superposición de carritos/hamburguesas
- Trabajador de Cloudflare (almacenamiento de promesas, estadísticas, inventario, correos electrónicos)
- Activador cron del trabajador para liquidación automática (medianoche MT)
- Cobro agregado (un cargo por partidario por campaña)
- Flujo de datos de artículos de soporte y montos personalizados (carrito → Trabajador → KV → estadísticas)
- Pre-renderizado del temporizador de cuenta regresiva (sin flash "00 00 00 00")
- Compatibilidad con compromisos de varios niveles (`additionalTiers`)
- Pruebas unitarias (Vitest) y pruebas E2E (Dramaturgo)
- Cobertura E2E de pago totalmente automatizado
- Lanzamiento de campaña de producción (Hand Relations)
- Ruta de desarrollo/pruebas local respaldada por Podman
- Protección más explícita contra la sobreventa de inventario a través de la coordinación de objetos duraderos
- Integración de Pages CMS para la edición visual de campañas

🚧 **En progreso:**
- Rediseño de tipografía, elementos y diseños.
  - tokens compartidos, jerarquía de tipos y primitivas de superficie/botón/campo reutilizables están en su lugar
  - Las páginas públicas, las superficies de campaña, el pago y la gestión de promesas se están alineando con el mismo sistema visual más tranquilo.

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
- Complete la plantilla de relaciones públicas, incluya capturas de pantalla para los cambios en la interfaz de usuario
- Problemas de enlace con `Closes #123`

### Etiquetas
- `feature`, `bug`, `task`, `infra`, `docs`, `security`

---

## Lista de verificación de la primera contribución

- [] Clonar repositorio, ejecutar `npm run podman:doctor`
- [] Inicie el desarrollo local con `./scripts/dev.sh --podman`
- [] Utilice únicamente la ruta Jekyll/Wrangler de host exclusivo si la necesita intencionalmente
- [] Hojee `_layouts/` y `_includes/` para ver la integración del carrito propio
- [] Revisar los scripts de carrito y compromiso de `assets/js/`
- [] Lea `worker/src/` para comprender el backend (almacenamiento de promesas, estadísticas, carga)
- [] Verifique que `CNAME` esté configurado en el dominio de su sitio público

---

## Secretos y configuración (primero en modo de prueba)

- **Acciones de GitHub**: Agregar prueba `STRIPE_SECRET_KEY` + `CHECKOUT_INTENT_SECRET`
- **Cloudflare Worker**: Los mismos secretos que env vars; establecer `SITE_BASE`
- **Stripe**: para entornos alojados, cree un webhook para `https://worker.example.com/webhooks/stripe`
- **Pago personalizado local**: agregue `STRIPE_PUBLISHABLE_KEY_TEST` a `worker/.dev.vars`

Consulte [TESTING.md](/es/docs/operations/testing/) para obtener una referencia completa de los secretos.

---

## Notas de seguridad

- Los secretos solo se encuentran en GitHub Actions + Cloudflare vars; nunca en repositorio
- Validar firmas de webhooks de Stripe
- Nunca confirmes claves o tokens API

---

## Glosario

|Término|Definición|
|------|------------|
|**Promesa**|Pedido realizado sin cargo inmediato; tarjeta guardada a través de Stripe SetupIntent|
|**Todo o nada**|Tarjetas cargadas solo si `pledged_amount >= goal_amount` en la fecha límite|
|**Intención de configuración**|Stripe se opone a guardar un método de pago para cargos posteriores fuera de la sesión|
|**Enlace mágico**|URL firmada por HMAC enviada por correo electrónico para la gestión de promesas sin cuenta|
|**The Pool**|Nombre de la plataforma para el sitio de crowdfunding|
|**Operador de plataforma**|Nombre de la empresa o estudio para su implementación|

---

## Contacto y propiedad

Utilice los documentos del proyecto y el historial de Git existente como contexto, y mantenga el alcance de los cambios y bien probados antes de abrir un PR.

---
