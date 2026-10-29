---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

28 de octubre de 2026

## Trabajo de producto propuesto

### Cobertura fiscal e informes

Usa [Calculadora de impuestos](/es/docs/operations/tax-calculator/) como referencia de lo ya implementado. Amplía los datos y adaptadores compartidos de tax-core en Platform en lugar de duplicarlos en Pool.

- [ ] Amplía la cobertura revisada de tasas locales públicas de Estados Unidos y los diagnósticos de jurisdicción, incluidas las carencias en territorios y distritos especiales. Identifica explícitamente como estimaciones los resultados con cobertura ausente o ambigua. Usa el flujo semanal de candidatos de Platform y las revisiones aprobadas de los consumidores; no añadas un segundo monitor en Pool ni hagas obligatorio un proveedor de pago.

- [ ] Amplía y actualiza en Platform el conjunto inicial de cinco localidades de Nuevo México. Conserva sus metadatos de fuente y generación, añade el periodo de vigencia y el tratamiento de datos obsoletos, y revisa los cambios frente al proveedor por dirección antes de adoptarlos.

- [ ] Define categorías fiscales por artículo y un contrato compartido de líneas fiscales para recompensas, apoyo, complementos y envío antes de añadir reglas fiscales por categoría. Conserva la autoridad del Worker, los importes en centavos enteros, los precios guardados de los aportes y la evidencia fiscal histórica.

- [ ] Distingue de forma coherente entre datos incompletos, fallos del proveedor y uso de tasas de respaldo en el pago, la gestión de aportes y los diagnósticos del operador. Parte de los metadatos de estimación y cobertura y de los tiempos límite existentes; añade caché, reintentos limitados o suspensión temporal de consultas solo con reglas definidas para datos obsoletos y fallos.

- [ ] Añade exportaciones de obligaciones fiscales agrupadas por jurisdicción guardada, fuente, tasa, pertenencia a campaña o plataforma y diferencias por modificaciones o reembolsos. Define la minimización y retención de los datos de destino junto con las necesidades de entrega y contabilidad; no recalcules aportes anteriores con las tasas actuales.

La ampliación internacional de IVA/GST, los certificados de exención, los identificadores fiscales, la inversión del sujeto pasivo, los precios con impuestos incluidos y la facturación dependen de un alcance comercial definido por el operador y de las obligaciones aplicables.

### Configuración guiada en terminal

- [ ] Añade una interfaz pequeña de terminal sobre [la CLI de configuración existente](https://github.com/aindaco1/pool/blob/main/scripts/setup-deploy.mjs). Reutiliza sus modos local y de producción, comprobaciones, simulaciones y operaciones con proveedores; conserva el uso directo no interactivo.

- [ ] Muestra los cambios previstos, el progreso, las comprobaciones omitidas, las opciones de reintento y comandos alternativos que puedan copiarse. Oculta los secretos y exporta únicamente evidencia sin datos sensibles. Enlaza los comandos existentes de desarrollo y pruebas en lugar de crear otro ejecutor.

### Inventario compartido y punto de venta

Sigue siendo una propuesta entre proyectos. El [diseño detallado](https://github.com/aindaco1/pool/blob/main/docs/proposals/shared-inventory-pos.md) conserva los requisitos de correspondencia, precios, inventario, seguridad y recuperación; el comportamiento del proveedor debe verificarse antes de implementarlo.

- [ ] Investiga en modo de prueba de Stripe las ventas de catálogo, reembolsos, cancelaciones y eventos retrasados o sin conexión de Payment for Stripe. Determina qué identidades verificadas de artículos pueden producir cambios de inventario de forma segura.

- [ ] Implementa un coordinador de existencias compartidas, opcional y desactivado por defecto, para artículos elegibles de Pool y Store con inventario limitado. Usa correspondencias exactas de SKU y variante, separadas por modo de prueba y producción. Establece las existencias iniciales una sola vez y conserva precios independientes en línea y presenciales después de la creación inicial.

- [ ] Añade reservas y movimientos atómicos e idempotentes, recepción de webhooks firmados atribuibles y conciliación limitada. Define las retenciones por pagos fallidos, decisiones de reembolso y reposición, déficits por ventas sin conexión, márgenes de seguridad y comportamiento ante servicios desactualizados antes de activar producción; no afirmes que se impiden todas las ventas presenciales sin existencias.

- [ ] Añade controles administrativos con permisos limitados, historial de auditoría, comprobación previa de solo lectura, migraciones seguras al desactivar o desvincular, copias de seguridad y pruebas de compatibilidad entre repositorios. Conserva los registros canónicos de aportes y pedidos, y rechaza cantidades nuevas o aumentadas cuando no se pueda confiar en las existencias compartidas.

## Validación pendiente

- [ ] Registra comprobaciones manuales con VoiceOver/NVDA del carrito, pago, gestión de aportes, comunidad y administración cuando una versión incluya ese alcance de aceptación. Distínguelas de la cobertura automatizada existente de teclado, axe, adaptación y localización. Consulta [Accesibilidad](/es/docs/operations/accessibility/).

- [ ] Valida el desarrollo sin privilegios en equipos físicos representativos de Linux y Windows y registra los resultados en [Podman](/es/docs/operations/podman-local-dev/). La integración continua en contenedores Linux y el asistente de pago en el navegador del equipo no prueban todas las configuraciones físicas.

- [ ] Calibra el piloto orientativo de Jev para mensajes a patrocinadores mediante revisión competente en inglés y español, ejemplos separados de calibración y evaluación, y estabilidad entre ejecuciones antes de considerarlo un requisito de integración continua. Mantén deterministas los cálculos de pago, los permisos y la aceptación de proveedores. Consulta [Pruebas](/es/docs/operations/testing/#piloto-orientativo-de-jev).

## Decisiones de producto condicionadas

Estas propuestas necesitan un caso de uso concreto de campaña u operador antes de implementarse.

- [ ] Diseña enlaces de gestión de aportes de menor duración junto con su reemisión y recuperación. Evalúa un intercambio de un solo uso que retire el token del patrocinador de la URL sin perder el alcance por pedido. No dupliques los flujos de sesión administrativa o vista previa protegida.

- [ ] Añade traducciones mantenidas del contenido de creadores cuando una campaña las necesite. Incorpora otro idioma de interfaz solo con una persona responsable, revisión competente y evidencia de versión específica del idioma; la interfaz en inglés y español ya dispone de su propio mantenimiento.

- [ ] Completa las correspondencias de beneficios de Podcast, su duración, selección de aportes, emisión y revocación, entrega persistente y correo al patrocinador sobre el puente firmado existente. Mantén la activación deshabilitada hasta superar un ejercicio controlado de concesión, revocación y recuperación entre servicios.

- [ ] Distingue las encuestas orientativas de los votos vinculantes solo si las campañas necesitan textos, informes o flujos de resultados diferentes. Conserva el contrato existente de almacenamiento y recuento limitado a patrocinadores.

Las comprobaciones habituales de SEO, regresiones de accesibilidad, localización de controles nuevos y verificación de versiones corresponden a las guías de [pruebas](/es/docs/operations/testing/), [SEO](/es/docs/operations/seo/) y [publicación](/es/docs/operations/merge-smoke-checklist/). Los lanzamientos de distribución de campañas concretas corresponden a la [lista de creadores](https://github.com/aindaco1/pool/blob/main/creator-campaign-checklist.md) y al plan operativo de la campaña.
