---
title: Plantilla de pull request
parent: Referencia
nav_order: 3
render_with_liquid: false
lang: es
---

# Solicitud de extracción

## Última actualización

16 de julio de 2026

## Propósito
<!-- ¿Qué problema resuelve este PR? -->

## Cambios
<!-- Lista de cambios clave con rutas de archivo cuando sea útil -->
-

## Capturas de pantalla/demostraciones
<!-- Agregue imágenes o GIF para cambios en la interfaz de usuario. -->
<!-- Para los cambios en la interfaz de usuario del panel de administración, incluya capturas de pantalla de computadoras de escritorio, tabletas y dispositivos móviles. Incluya `/es/admin/` cuando cambien cadenas o menús responsivos. -->

## Plan de prueba
- [ ] `npm run test:premerge`
- [] `npm run podman:doctor` pasa al validar flujos locales respaldados por Podman
- [] La misma puerta previa a la fusión se ejecuta contra `main` en un árbol de trabajo limpio cuando la lógica de trabajador o de pago cambió
- [ ] Lista de verificación de humo manual completada para el cambio de caja/flujos de trabajadores (puesta en escena cuando esté disponible; de lo contrario, respaldo de humo local documentado)
- [] Jekyll local compilado correctamente
- [] `./scripts/test-e2e.sh --podman` pasa cuando el comportamiento de pago del navegador cambió
- [] `npx playwright test tests/e2e/admin-dashboard.spec.ts --project=chromium` pasa cuando la interfaz de usuario del panel de administración, i18n, la accesibilidad, el comportamiento receptivo o los contratos de los trabajadores administrativos cambiaron
- [] `node --check assets/js/admin-dashboard.js` pasa cuando el JavaScript del panel cambió
- [] Se abre el carrito propio, no hay errores de consola
- [] El trabajador `/checkout-intent/start` devuelve el arranque de sesión personalizada en el sitio esperado o la respuesta alternativa alojada (modo de prueba)
- [] La persistencia de aportes almacena niveles, elementos de soporte, monto personalizado y totales activos que se actualizan correctamente
- [] El flujo de actualización de la tarjeta aún se realiza correctamente para los aportes activos y `payment_failed` cuando se tocan
- [] Los temporizadores de cuenta regresiva muestran los valores correctos al cargar la página (sin flash "00 00 00 00")
- [] Cron `workflow_dispatch` carga aportes de prueba fuera de sesión
- [] Documentos actualizados (si el comportamiento o la configuración cambiaron)

## Seguridad / Secretos
- [] No hay secretos comprometidos
- [] Utiliza únicamente secretos de repositorio/trabajador
- [] Los cambios en el panel de administración no exponen ni editan valores secretos; **Secretos y credenciales** sigue siendo solo estado
- [] Las mutaciones del administrador conservan la ruta de almacenamiento prevista: publicación respaldada por GitHub, guardado de usuarios solo de KV, códigos de referencia guardados solo de KV o exploración/exportación de solo lectura

## Revisión de riesgos éticos
- [] Revisado `docs/ETHICAL_RISK.md` si esto cambia el dinero, los datos de los patrocinadores, los mensajes, los análisis, la automatización, el intercambio público o el poder administrativo.
- [] No hay nueva recopilación de datos ocultos, seguimiento, indexación pública ni comportamiento de captación previa privada/tokenizada
- [ ] El comportamiento de consentimiento, exclusión voluntaria, supresión, ejecución en seco o recurso se conserva cuando el cambio afecta al correo electrónico, recordatorios, vistas previas, marketing o gestión de aportes.
- [] Se consideraron casos de abuso o uso indebido para páginas públicas, incrustaciones, QR/enlaces de referencia, Blast, funciones de administrador, pago e informes cuando se tocaron.
- [] Las afirmaciones de los usuarios sobre el estado de la campaña, la escasez, los impuestos, el envío, las tarifas, las propinas o los totales aún coinciden con la verdad canónica de Worker.

## Compatibilidad con versiones anteriores
- [] Sin cambios importantes en el modelo de contenido
- [] Si el esquema cambia, `docs/DEV_NOTES.md` actualizado y campañas de muestra
- [] Los ID de campaña/complemento/nivel/variante existentes se conservan a menos que la migración los cambie intencionalmente.
