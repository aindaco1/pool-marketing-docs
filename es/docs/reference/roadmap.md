---
title: Hoja de ruta
parent: Referencia
nav_order: 2
render_with_liquid: false
lang: es
---

# Hoja de ruta

## Última actualización

19 de noviembre de 2026

## Trabajo de producto propuesto

### Cobertura fiscal e informes

Amplía los datos y adaptadores de impuestos compartidos de Platform descritos en [Calculadora de impuestos](/es/docs/operations/tax-calculator/#datos-compartidos-de-tarifas-locales-y-postales-de-ee-uu).

- [ ] Amplía la cobertura revisada de tasas locales públicas de Estados Unidos y los diagnósticos de jurisdicción, incluidas las carencias en territorios y distritos especiales. Identifica explícitamente como estimaciones los resultados con cobertura ausente o ambigua. Usa el flujo semanal de candidatos de Platform y las revisiones aprobadas de los consumidores; no añadas un segundo monitor en Pool ni hagas obligatorio un proveedor de pago.

- [ ] Amplía y actualiza en Platform el conjunto inicial de cinco localidades de Nuevo México. Conserva sus metadatos de fuente y generación, añade el periodo de vigencia y el tratamiento de datos obsoletos, y revisa los cambios frente al proveedor por dirección antes de adoptarlos.

- [ ] Define categorías fiscales por artículo y un contrato compartido de líneas fiscales para recompensas, apoyo, complementos y envío antes de añadir reglas fiscales por categoría. Conserva la autoridad del Worker, los importes en centavos enteros, los precios guardados de los aportes y la evidencia fiscal histórica.

- [ ] Unifica las explicaciones de datos faltantes, fallos del proveedor y alternativas en el proceso de pago, Gestionar aporte y los diagnósticos para operadores. Reutiliza los errores tipificados existentes, los metadatos de estimación y los plazos que cubren los cuerpos de respuesta; define por separado cualquier nueva política de caché o reintentos.

- [ ] Añade exportaciones de obligaciones fiscales agrupadas por jurisdicción, fuente, tasa, pertenencia a campaña o plataforma y diferencias por modificaciones o reembolsos guardados. Las exportaciones actuales de aportes cubren las comisiones de Stripe, no esta contabilidad por jurisdicción. Define la minimización y retención de datos de destino; no recalcules aportes antiguos con tasas actuales.

La ampliación internacional de IVA/GST, los certificados de exención, los identificadores fiscales, la inversión del sujeto pasivo, los precios con impuestos incluidos y la facturación dependen de un alcance comercial definido por el operador y de las obligaciones aplicables.

### Inventario compartido y punto de venta

Pool ya reserva recompensas limitadas mediante su Durable Object de inventario y los componentes compartidos de inventario. La propuesta pendiente es una autoridad de existencias entre Pool, Store y las ventas presenciales. El [diseño detallado](https://github.com/aindaco1/pool/blob/main/docs/proposals/shared-inventory-pos.md) define los requisitos de correspondencia, precios, seguridad y recuperación.

- [ ] Investiga en modo de prueba de Stripe las ventas de catálogo, reembolsos, cancelaciones y eventos retrasados o sin conexión de Payment for Stripe. Determina qué identidades verificadas de artículos pueden producir cambios de inventario de forma segura.

- [ ] Implementa un coordinador de existencias compartidas, opcional y desactivado por defecto, para artículos elegibles de Pool y Store con inventario limitado. Usa correspondencias exactas de SKU y variante, separadas por modo de prueba y producción. Establece las existencias iniciales una sola vez y conserva precios independientes en línea y presenciales después de la creación inicial.

- [ ] Amplía la gestión de reservas y variaciones entre canales con recepción de webhooks firmados atribuibles y conciliación acotada. Define retenciones por pagos fallidos, decisiones de reembolso y reposición, déficits por ventas sin conexión, márgenes de seguridad y comportamiento ante un servicio desactualizado antes de la activación en producción; no afirmes que se evita por completo la sobreventa presencial.

- [ ] Añade controles administrativos con permisos limitados, historial de auditoría, comprobación previa de solo lectura, migraciones seguras al desactivar o desvincular, copias de seguridad y pruebas de compatibilidad entre repositorios. Conserva los registros canónicos de aportes y pedidos, y rechaza cantidades nuevas o aumentadas cuando no se pueda confiar en las existencias compartidas.

## Decisiones de producto condicionadas

Estas propuestas necesitan un caso de uso concreto de campaña u operador antes de implementarse.

- [ ] Añade una interfaz de terminal si la incorporación necesita más orientación que [la CLI de configuración existente](https://github.com/aindaco1/pool/blob/main/scripts/setup-deploy.mjs). Reutiliza sus modos local y de producción, comprobaciones de preparación, simulaciones y operaciones de proveedores. Conserva el uso no interactivo, oculta secretos y muestra cambios previstos, progreso, reintentos y comandos alternativos sin crear otro ejecutor de pruebas.

- [ ] Diseña enlaces de gestión de aportes de menor duración junto con su reemisión y recuperación. Evalúa un intercambio de un solo uso que retire el token del patrocinador de la URL sin perder el alcance por pedido. No dupliques los flujos de sesión administrativa o vista previa protegida.

- [ ] Añade traducciones mantenidas del contenido de creadores cuando una campaña las necesite. Incorpora otro idioma de interfaz solo con una persona responsable, revisión competente y evidencia de versión específica del idioma; la interfaz en inglés y español ya dispone de su propio mantenimiento.

- [ ] Completa las correspondencias de beneficios de Podcast, su duración, selección de aportes, emisión y revocación, entrega persistente y correo al patrocinador sobre el puente firmado existente. Mantén la activación deshabilitada hasta superar un ejercicio controlado de concesión, revocación y recuperación entre servicios.

- [ ] Distingue las encuestas orientativas de los votos vinculantes solo si las campañas necesitan textos, informes o flujos de resultados diferentes. Conserva el contrato existente de almacenamiento y recuento limitado a patrocinadores.

La aceptación manual con tecnologías de asistencia, la cobertura de equipos físicos y la calibración de Jev se documentan en [Accesibilidad](/es/docs/operations/accessibility/#comprobaciones-manuales), [Podman](/es/docs/operations/podman-local-dev/#matriz-de-soporte) y [Pruebas](/es/docs/operations/testing/#piloto-orientativo-de-jev). Los lanzamientos específicos de campaña pertenecen a la [lista para creadores](https://github.com/aindaco1/pool/blob/main/creator-campaign-checklist.md).
