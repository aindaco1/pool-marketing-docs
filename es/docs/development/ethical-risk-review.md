---
title: Revisión de riesgos éticos
parent: Desarrollo
nav_order: 12
render_with_liquid: false
lang: es
---

# Revisión de riesgos éticos

## Última actualización

25 de agosto de 2026

Esta guía adapta el Ethical OS Toolkit del Institute for the Future y Omidyar Network a las superficies de crowdfunding, pagos, correo electrónico, administración y uso compartido público de The Pool. Úselo como una revisión práctica de riesgos, no como un reemplazo de la seguridad, accesibilidad, privacidad o revisión legal.

Contexto fuente: el conjunto de herramientas pide a los equipos que imaginen consecuencias a más largo plazo, comparen las nuevas funciones con zonas de riesgo recurrentes y conviertan los hallazgos en mitigaciones concretas antes del envío. El kit de herramientas original tiene licencia CC BY-NC-SA 4.0 y está disponible en `ethicalOS.org`.

## Cuando usar esto

Ejecute una revisión de riesgos éticos cuando un cambio agregue o cambie materialmente:

- pago, gestión de aportes, liquidación, impuestos, envío, tarifas, propinas o informes financieros
- correo electrónico de soporte, recordatorios de lanzamiento, recordatorios de pago abandonado, Blast, transmisiones diarias u otros flujos de notificación
- roles de administrador, creación de campañas, vistas previas protegidas, gestión de usuarios, análisis, informes, enlaces de marketing, códigos QR, incrustaciones o tarjetas para compartir
- visibilidad de campaña pública, metadatos SEO, vistas previas sociales, localización o reglas de representación de contenido
- recopilación, retención, exportaciones, integraciones de proveedores, análisis o comportamiento de copia de seguridad/restauración de datos
- puntuación, automatización, personalización, recomendación, detección de fraude o flujos de trabajo asistidos por IA

Los cambios en textos pequeños, estilos o solo documentos generalmente no necesitan una revisión completa a menos que afecten el consentimiento, la privacidad, las afirmaciones públicas o la comprensión del usuario.

## Principios operativos

- El consentimiento es explícito cuando se trata de atención, datos o dinero de los patrocinadores.
- El Worker sigue teniendo autoridad para totales, estado, permisos y persistencia; La interfaz de usuario del navegador es una capa de explicación, no un límite de confianza.
- Recopile solo los datos que el producto actual necesita, guárdelos solo donde estén documentados y mantenga explicable el comportamiento de retención/restauración.
- Prefiera metadatos públicos honestos y conscientes del estado a trucos de crecimiento, escasez vaga o vistas previas sociales engañosas.
- Ofrezca a los patrocinadores y administradores un recurso claro: administre enlaces, cancele rutas de suscripción, obtenga una vista previa del vencimiento, mensajes de conflicto, rutas de exportación/informes y contacto de soporte.
- Trate el abuso, el spam, el acoso, el fraude y el diseño coercitivo como riesgos del producto, no sólo como errores de seguridad.
- Revise cómo se ven afectados los diferentes grupos, incluidos los usuarios con discapacidades, los usuarios localizados, los creadores con audiencias pequeñas, los patrocinadores con fondos limitados y las personas que comparten dispositivos o redes.
- Cree métricas de plataforma saludables en torno a la finalización exitosa, el consentimiento claro, la confiabilidad de la entrega, la reducción del abuso y los resultados de soporte, no solo los clics, los envíos o el volumen de participación.

## Zonas de riesgo

Utilice estas zonas de riesgo como indicaciones durante el diseño, la implementación y la revisión.

|Zona de riesgo|Cómo aparece en The Pool|Mejores prácticas|
|-----------|-----------------------------|---------------|
|Verdad, desinformación y propaganda|Los reclamos de campaña, las publicaciones del diario, Blast, las tarjetas compartidas, los metadatos de SEO, las incrustaciones, los enlaces sociales y las vistas previas generadas pueden difundir rápidamente reclamos públicos engañosos.|Los metadatos públicos deben coincidir con el contenido visible de la página y el estado actual de la campaña. No infle el estado de la financiación, la escasez, los plazos, la identidad del creador o la certeza de impuestos/envío.|
|Adicción y presión de atención.|Los recordatorios, las cuentas atrás, el inventario limitado, los correos electrónicos sobre hitos y los paneles de marketing pueden convertirse en tácticas de presión.|Mantenga los recordatorios habilitados y limitados. Evite bucles infinitos, urgencia manipuladora, valores predeterminados ocultos o volumen de notificaciones que existe principalmente para maximizar la atención.|
|Desigualdad económica y de activos|Las tarifas, propinas, envíos, impuestos, complementos, niveles limitados y límites de proveedores pueden afectar a los patrocinadores y creadores de manera desigual.|Muestre claramente el subtotal, los impuestos, el envío, propina de plataforma y el total. Mantenga los ingresos adicionales de la plataforma separados del progreso de la campaña. Pruebe rutas de bajo ancho de banda, móviles, localizadas y de solo teclado.|
|Ética de las máquinas y sesgo algorítmico|Los análisis, las comprobaciones de fraude, las recomendaciones futuras, la moderación automatizada y las señales de preparación de los proveedores pueden convertirse en sistemas de decisión opacos.|Mantenga las decisiones automatizadas explicables, auditables y reversibles cuando afecten el acceso, los precios, la visibilidad o la acción administrativa. Evite puntuar usuarios o campañas sin un recurso claro.|
|Vigilancia y riesgo reputacional a largo plazo|Los registros de aportes, los enlaces mágicos, las listas de revisores de vista previa, los datos de referencias/UTM, los datos de carritos abandonados y los registros de auditorías administrativas pueden revelar comportamientos sensibles.|Minimice la PII, evite el seguimiento amplio, mantenga las rutas tokenizadas/privadas fuera de la indexación y la captación previa, y no exponga las identidades de los patrocinadores o revisores en artefactos públicos.|
|Control de datos y monetización|Los datos de patrocinadores, creadores, campañas y análisis podrían exportarse, venderse, restaurarse incorrectamente o reutilizarse después de un cambio de proveedor/cuenta.|Documente las expectativas de propósito, almacenamiento, exportación, restauración y eliminación de los datos. No venda ni reutilice los datos de sus patrocinadores sin una nueva decisión explícita sobre el producto y un modelo de consentimiento.|
|Confianza implícita y comprensión del usuario|Los flujos de publicación de administradores, las vistas previas protegidas, la recuperación de pagos, los enlaces para compartir, los borradores y los estados alternativos de los proveedores pueden sorprender a los usuarios si los efectos secundarios están ocultos.|Utilice un lenguaje de estado claro para borrador versus publicado, vista previa versus público, estimado versus final, ejecución en seco versus envío en vivo y comportamiento solo local versus producción.|
|Actores odiosos y criminales|Se puede abusar de las páginas públicas, incrustaciones, enlaces de referencia, códigos QR, envíos masivos de correos electrónicos de patrocinadores, invitaciones de vista previa y enlaces sin cuentas para acoso, spam, fraude o doxxing.|Mal uso del equipo rojo antes del lanzamiento. Limite las rutas de mutación, limite el alcance de los permisos, mantenga registros de auditoría y evite funciones que faciliten el daño dirigido sin mitigación.|

## Bucle de revisión

Para un trabajo de funciones significativo, registre la revisión en el PR, edición, notas de la versión o notas de diseño:

1. Nombra la característica y los grupos de usuarios afectados.
2. Elija las dos o tres zonas de riesgo más relevantes para la característica.
3. Imagine modos de mal uso o falla de primer, segundo y tercer orden.
4. Identifique qué facilita la función a un actor malintencionado, descuidado o presionado financieramente.
5. Decida qué mitigaciones deben enviarse ahora y cuáles son seguimientos aceptables.
6. Agregue pruebas, documentos, ayuda del panel o actualizaciones del runbook del operador para las mitigaciones aceptadas.
7. Si el riesgo no se puede explicar de forma sencilla, suspenda el cambio hasta que el propietario pueda explicar la compensación.

## Banderas rojas

Trátelos como bloqueadores de liberación hasta que se resuelva explícitamente:

- nuevos identificadores ocultos de recopilación, seguimiento o análisis de datos
- Nuevo comportamiento público de indexación, uso compartido, incrustación o captación previa para superficies privadas/tokenizadas.
- comportamiento de mensajería masiva o recordatorios sin consentimiento explícito, límites de velocidad, validación de prueba y manejo de cancelación/supresión cuando corresponda
- cambios de dinero, impuestos, envío, tarifas, inventario o progreso de campaña visibles para el usuario sin verificación canónica Worker
- automatización que cambia el acceso, los precios, la visibilidad, la moderación, la liquidación o los informes sin auditabilidad ni recurso
- cambios en la función de administrador o en el alcance de la campaña que dependen de los controles del navegador en lugar de la aplicación de Worker
- Contenido de campaña o creador que puede crear XSS almacenado, incrustaciones inseguras, afirmaciones engañosas o HTML sin formato no compatible.
- vista previa social o cambios SEO que pueden implicar un estado de campaña diferente al de la página visible
- integraciones de proveedores que agregan secretos, PII o rutas de exportación de datos sin almacenamiento ni documentos de respuesta a incidentes
- Experimentos de crecimiento o participación que dificultan que los usuarios se detengan, opten por no participar, comprendan el costo o se vayan.

## Plantilla de revisión

```markdown
### Ethical Risk Review

- Feature:
- Affected users:
- Relevant risk zones:
- What could go wrong:
- Data collected or exposed:
- Consent, opt-out, and recourse:
- Abuse/misuse mitigations:
- Accessibility/i18n impact:
- Tests or evidence:
- Follow-ups accepted:
```

## Orientación específica del proyecto

- Cambios en el proceso de pago y pago: comience desde [PAYMENT_PROCESSOR.md](/es/docs/operations/payment-processor/), [WORKFLOWS.md](/es/docs/development/workflows/) y [SECURITY.md](/es/docs/operations/security/). Verifique los totales canónicos, la idempotencia, la comprensión de los patrocinadores y las rutas de recuperación.
- Correo electrónico y recordatorios: comience desde [EMAIL.md](/es/docs/operations/email-system/). Verifique el consentimiento explícito, el alcance de la audiencia, los ensayos, la copia localizada, el comportamiento de supresión/cancelación de suscripción y la evidencia de no envío.
- Cambios en el panel de administración: comience desde [DASHBOARD.md](/es/docs/operations/admin-dashboard/). Documente si la característica es de solo lectura, local del navegador, respaldada por KV o respaldada por GitHub, y mantenga el alcance de rol/campaña aplicado por Worker.
- Uso compartido público, SEO e incrustaciones: comience desde [SEO.md](/es/docs/operations/seo/) y [EMBEDS.md](/es/docs/development/campaign-embeds/). Las vistas previas públicas son veraces, tienen en cuenta el estado y nunca filtran datos tokenizados o de vistas previas protegidas.
- Accesibilidad y localización: comience desde [ACCESSIBILITY.md](/es/docs/operations/accessibility/) y [I18N.md](/es/docs/development/internationalization/). Revise quién queda excluido cuando la copia, los controles o la evidencia solo funcionan en un idioma, ventana gráfica, modo de entrada o perfil de habilidad.
- Rendimiento y captación previa: comience desde [PERFORMANCE.md](/es/docs/operations/performance/). La carga especulativa sigue siendo solo pública y no presiona la acción del usuario ni los flujos privados en segundo plano.
- Copias de seguridad, exportaciones y rutas de restauración: clases de datos de documentos, minimización de PII, retención, orden de restauración y riesgos de envío/cobro duplicados antes de agregar un nuevo comportamiento de copia de seguridad.

## Hábitos de mantenimiento

- Agregue señales de alerta éticas a las relaciones públicas desde el principio, mientras los cambios aún sean fáciles de remodelar.
- Acepte informes de riesgo ético de la misma manera que el proyecto acepta informes de seguridad o accesibilidad: específicos, reproducibles y vinculados a un daño realista.
- Mantenga visible el estado de la plataforma a través de evidencia operativa, como envíos fallidos, presión de límite de velocidad, desviación de la proyección, cobertura de accesibilidad, integridad de i18n, preparación del proveedor y pruebas de ruta de abuso.
- Revise esta guía cuando el producto agregue nuevas audiencias, nuevos usos de datos, nueva automatización o nuevos canales de distribución.

Los registros de revisión ética específicos de la liberación pertenecen a la correspondiente
[publicar evidencia](https://github.com/your-org/your-project/tree/main/docs/release-evidence) en lugar de en esta guía del estado actual.
