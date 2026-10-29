---
title: Copias de seguridad, restauración y recuperación
parent: Operaciones
nav_order: 10
render_with_liquid: false
lang: es
---

# Copias de seguridad, restauración y recuperación de The Pool

## Última actualización

28 de octubre de 2026

Este es el runbook del operador canónico para el estado propiedad de The Pool que no se puede recrear mediante una implementación normal. Cubre el historial de Git, Cloudflare KV, metadatos del proveedor, pedidos de restauración, retención y evidencia de recuperación. Nunca trata los valores secretos como contenido de respaldo.

## Política de recuperación

The Pool utiliza estos objetivos aprobados:

|Estado|RPO|RTO|Notas|
| --- | --- | --- | --- |
|Campaña/configuración/historial de medios respaldados por Git|Cada lanzamiento|1 hora|Paquete Git más evidencia de aporte/estado sucio|
|Aportes, votos, configuración administrativa, idempotencia y estado operativo|4 horas|4 horas|Se requiere una instantánea cifrada del valor capturado|
|Punto de recuperación previo al cambio|Inmediatamente antes de una operación riesgosa|1 hora|Requerido antes de la reparación masiva, la restauración de la producción, el restablecimiento del inventario, la recuperación de liquidaciones o la migración de proveedores|

La retención es 7 diarias, 5 semanales, 12 mensuales y cada instantánea de lanzamiento. Mantenga al menos una copia cifrada fuera de la cuenta o dispositivo principal. Verifique el cifrado y las sumas de verificación antes de contar una instantánea como recuperable.

La clasificación y la política legibles por máquina se encuentran en [`config/pool-data-inventory.json`](https://github.com/aindaco1/pool/blob/main/config/pool-data-inventory.json). Auditelo después de cualquier nuevo prefijo KV, Durable Object, cola, marcador de idempotencia o flujo de trabajo de pago:

```bash
npm run backup:inventory:audit
```

## Fronteras estatales

- Git tiene autoridad para campañas, configuración de plataformas, plantillas, medios, flujos de trabajo y este runbook.
- `PLEDGES` contiene verdad del aporte, configuración de administración, índices de campaña, proyecciones, colas, eventos de auditoría y marcadores de pago/idempotencia.
- `VOTES` contiene votos de los patrocinadores y proyecciones de resultados publicadas.
- `RATELIMIT` y el estado de inicio de sesión/sesión/vista previa del navegador están en cuarentena y no se restauran normalmente. `admin-login-history:*` con privacidad minimizada es evidencia de incidente, no una sesión activa, y se restaura solo cuando un incidente lo requiere.
- Stripe sigue teniendo autoridad para los objetos de proveedores de pagos. Una instantánea The Pool registra identificadores y los compara como de solo lectura; no reemplaza los registros Stripe.
- El almacenamiento Durable Object nunca se importa. La evidencia de finalización/nonce de pago, el inventario de nivel escaso y la coordinación de acuerdos deben revalidarse o reconstruirse a partir de la veracidad del aporte, la configuración de la campaña, el estado de Stripe y las verificaciones de proyección.
- Los secretos son solo de inventario: la evidencia instantánea puede incluir nombres de secretos configurados y estados faltantes/configurados, nunca valores.

## Comandos de preparación e instantáneas

Primero ejecute la verificación de preparación para no mutaciones:

```bash
npm run backup:readiness
npm run backup:plan
```

Cree una instantánea de solo metadatos para evidencia local:

```bash
node scripts/pool-backup.mjs --output=/secure/path/pool-backup --skip-build
```

Cree la instantánea de valor capturado cifrada de nivel de producción:

```bash
export POOL_BACKUP_ENCRYPTION_RECIPIENT='age1...'
export POOL_BACKUP_AGE_IDENTITY='/secure/age-identity.txt'
node scripts/pool-backup.mjs \
  --output=/secure/path/pool-backup \
  --remote \
  --kv-values \
  --acknowledge-sensitive=POOL_SENSITIVE_BACKUP \
  --encryption-recipient="$POOL_BACKUP_ENCRYPTION_RECIPIENT" \
  --encryption-backend=age
```

Agregue `--release-snapshot` para obtener un punto de recuperación de versión. Se admite GPG como motor de cifrado alternativo. La ruta de salida no debe estar dentro del repositorio ni ser accesible a través de un enlace simbólico al mismo.

Una instantánea exitosa incluye:

- Git commit/status/diff y un paquete Git;
- archivos de configuración y documentación seleccionados;
- evidencia de compilación aislada Jekyll/Worker a menos que se omita explícitamente;
- Cloudflare implementación/recursos e inventario de nombres secretos;
- metadatos de punto final CLI Stripe autenticados cuando estén disponibles;
- inventario de claves KV y, sólo con el reconocimiento sensible, valores familiares aprobados;
- un manifiesto y sumas de verificación SHA-256;
- un archivo cifrado cuya descifrabilidad se verificó antes de la eliminación del texto sin formato;
- un recibo que no contiene credenciales ni datos del cliente.

No confirme directorios de instantáneas, archivos descifrados, manifiestos que contengan valores capturados, identidades o credenciales de recuperación.

## Copias y retención fuera del dispositivo

Copie una instantánea cifrada verificada en un destino montado por separado:

```bash
POOL_BACKUP_AGE_IDENTITY=/secure/age-identity.txt \
node scripts/pool-backup-offsite-copy.mjs \
  --source=/secure/path/pool-backup \
  --destination=/Volumes/Recovery/Pool \
  --acknowledge=POOL_BACKUP_OFF_DEVICE_COPY
```

De forma predeterminada, la copia solo se puede agregar, rechaza rutas inseguras, vuelve a verificar las sumas de verificación y verifica el descifrado. Se requiere un sistema de archivos diferente a menos que un operador elija explícitamente una excepción documentada.

Obtenga una vista previa de las decisiones de retención antes de la poda:

```bash
npm run backup:retention -- --root=/secure/path/pool-snapshots --dry-run
```

Aplicar solo después de revisar el conjunto de conservación/eliminación:

```bash
npm run backup:retention -- \
  --root=/secure/path/pool-snapshots \
  --acknowledge=POOL_BACKUP_RETENTION_PRUNE
```

La poda de retención funciona solo en directorios de instantáneas con suma de verificación válida en la raíz proporcionada y sigue la política de lanzamiento aprobada el 5/7/12.

### Archivo R2 configurado fuera de cuenta

El flujo de trabajo de recuperación protegido de The Pool utiliza el depósito privado `pool-recovery-archive` en una cuenta Cloudflare separada de la cuenta de producción `example.com`. El depósito utiliza almacenamiento estándar y el punto final compatible con S3 configurado en `POOL_RECOVERY_ARCHIVE_S3_ENDPOINT`; no tiene URL de desarrollo público ni dominio personalizado.

El entorno `production-recovery` de GitHub contiene las credenciales de lectura y escritura de objetos con ámbito de depósito y el URI de archivo `s3://pool-recovery-archive/pool-recovery`. La variable del repositorio `POOL_RECOVERY_ARCHIVE_REGION=auto` selecciona la región S3 de R2. No amplíe el token a permisos de administración de depósitos ni a depósitos adicionales.

Una regla de bloqueo de depósito `pool-recovery-400d` habilitada cubre el prefijo `pool-recovery/` durante 400 días. Esta ventana inmutable es deliberadamente más larga que el mínimo de 12 meses y evita la sobrescritura o eliminación; no elige qué instantáneas satisfacen el calendario de publicación de 7 días/5 semanas/12 meses. La selección de retención sigue siendo tarea de las herramientas de instantáneas/retención de The Pool, y cada archivo remoto debe utilizar un prefijo de ejecución o lanzamiento único.

La verificación de arranque inicial del 12 de julio de 2026 pasó la carga cifrada, la lista, la lectura de bytes idénticos, el descifrado, la comparación de texto sin formato y el rechazo de eliminación con bloqueo. Esa verificación de conectividad no reemplaza la primera instantánea de publicación de valor capturado cifrada ni un simulacro protegido trimestral.

## Restaurar orden

Utilice este orden para minimizar el riesgo de doble cargo, envío duplicado y proyección:

1. Declare el mantenimiento y detenga la automatización que afecta el dinero. Pausar la liquidación orientada a Stripe y el envío de liquidación programado.
2. Capture y verifique de forma independiente una instantánea cifrada previa a la restauración.
3. Restaure o consulte el historial de campaña/configuración/medios de Git y constrúyalo.
4. Verifique el manifiesto de instantánea y el plan de suma de verificación sin escribir el estado del proveedor.
5. Restaure la configuración del administrador y luego autorice la verdad del aporte.
6. Restaurar los votos por separado.
7. Restaure las familias de idempotencia y control de envío aprobadas solo después de la revisión de envío/carga duplicada.
8. Reconstruya el correo electrónico/índice de la campaña, las estadísticas, el inventario de niveles, el inventario de complementos y las proyecciones de resultados a partir de datos fiables.
9. No importe registros de sesión, inicio de sesión, revisor de vista previa, límite de velocidad, borrador pendiente de pago, token de reanudación o estado cron.
10. Concilie el estado de aporte/pago de The Pool con Stripe con credenciales de solo lectura.
11. Verifique los informes, las proyecciones, las vistas de los administradores, el humo del proceso de pago y la observabilidad antes de reanudar la automatización.

## Planificación y restauración preliminar

Comience siempre con un plan:

```bash
npm run restore:plan -- --snapshot=/secure/decrypted/pool-snapshot --target=preview
```

Ejecute en enlaces KV de vista previa aislados, verifique la lectura y luego elimine solo las claves que pertenecen a esa instantánea:

```bash
node scripts/pool-restore.mjs --snapshot=/secure/decrypted/pool-snapshot --target=preview --execute
node scripts/pool-restore.mjs --snapshot=/secure/decrypted/pool-snapshot --target=preview --verify
node scripts/pool-restore.mjs \
  --snapshot=/secure/decrypted/pool-snapshot \
  --target=preview \
  --cleanup-preview \
  --acknowledge-preview-cleanup=POOL_PREVIEW_RESTORE_CLEANUP
```

El planificador de restauración valida las claves de aporte, los ID de pedidos, los estados, la propiedad de la campaña, las funciones de administrador, los correos electrónicos y los registros de votación. Las familias derivadas se convierten en acciones de reconstrucción. Se omiten las familias en cuarentena. La auditoría de administración y el historial de inicio de sesión con privacidad minimizada también se omiten a menos que un plan específico para incidentes agregue `--include-incident-evidence`. Durable Objects nunca se importan. El proveedor detiene las escrituras ante el primer error y la verificación lee los valores restaurados en lotes limitados.

## Conciliación Stripe

Utilice una clave Stripe restringida y de solo lectura que coincida con el modo de instantánea:

```bash
STRIPE_SECRET_KEY="$STRIPE_RECOVERY_READ_KEY" \
npm run recovery:reconcile -- \
  --snapshot=/secure/decrypted/pool-snapshot \
  --stripe-mode=live \
  --output=/secure/evidence/pool-reconciliation.json
```

La conciliación realiza lecturas de PaymentIntent de solo GET en lotes limitados. La evidencia contiene categorías agregadas de motivos/recuentos, no ID de PaymentIntent ni datos de clientes. Investigue las discrepancias en cantidades, estados, objetos faltantes o modos antes de restaurar cualquier producción o reanudar la liquidación.

## Puertas de restauración de producción.

Una restauración de la producción es intencionalmente difícil. No continúe a menos que todo esto sea cierto:

- el modo de mantenimiento está activo;
- Las operaciones orientadas a Stripe están en pausa;
- el envío de liquidación está en pausa;
- se revisó el impacto del inventario/proyección;
- se revisó y aceptó la política de conflicto de sobrescritura explícita para esta instantánea;
- existe una instantánea previa a la restauración distinta y verificada de forma independiente;
- la misma instantánea pasó una restauración de vista previa y una verificación de lectura;
- Se revisó la conciliación Stripe;
- el propietario/operador de The Pool aprobó la ventana de recuperación.

El script de restauración requiere el reconocimiento de producción exacto `POOL_PRODUCTION_RESTORE` además de esas puertas. Nunca pases por alto una puerta editando el guión durante un incidente; registre la excepción y cree un cambio de recuperación revisado en su lugar.

## evidencia automatizada

- `.github/workflows/recovery-readiness.yml` realiza ensayos semanales de preparación sintética y restauración. Contiene únicamente datos sintéticos y es seguro mantenerlo activo.
- `.github/workflows/recovery-operations.yml` ejecuta la verificación previa trimestral de poco tráfico. La exploración protegida de producción capturada permanece deshabilitada a menos que `RECOVERY_DRILL_ENABLED=true` y el entorno `production-recovery` proporcionen las credenciales de archivo compatibles con S3 antiguas, Stripe, Cloudflare y restringidas.
- Los ejecutores de Ubuntu alojados en GitHub proporcionan AWS CLI v2. El trabajo protegido instala `age` a través de apt y verifica el binario alojado `aws` con `aws --version`; no solicite el paquete apt `awscli` no disponible/obsoleto en esa imagen del corredor.
- El simulacro protegido carga el archivo cifrado y el manifiesto en el almacenamiento fuera de la cuenta, descarga ambos, prueba la igualdad de bytes, descifra, concilia Stripe, restaura la vista previa, verifica y limpia las claves exactas de la instantánea.
- Deposite en custodia la identidad de edad por separado de GitHub y el proveedor de archivo antes de habilitar las exploraciones de datos capturados. Una identidad privada que existe sólo como secreto de entorno GitHub es suficiente para la automatización, pero no es una copia independiente de recuperación ante desastres.
- Ningún flujo de trabajo realiza una restauración de producción.

Generar un ensayo sintético local en cualquier momento:

```bash
npm run restore:rehearse -- --output=/secure/evidence/pool-restore-rehearsal.json
```

## Verificación posterior a la restauración

En ejecución mínima:

```bash
npm run backup:inventory:audit
npm run test:premerge
npm run release:pledge-evidence
npm run release:payment-smoke
./scripts/check-projections.sh
./scripts/check-observability.sh
```

Luego revise Campañas, Análisis, Informes, Colaboradores, Usuarios, Marketing, medios, complementos, revisión de sesiones y búsqueda de auditoría como las funciones de administrador adecuadas. Confirme que no se reanudó ningún acuerdo o mensaje de apoyo antes de que se aceptaran los datos restaurados y la comparación de proveedores.

## evidencia del incidente

Registre el hash de recepción de instantáneas, la confirmación de origen, el destino de restauración, la hora de inicio/finalización, el operador/aprobador, la verificación previa del tráfico, los recuentos de conciliación, la verificación de vista previa, las decisiones de la puerta de producción, las claves/familias restauradas o reconstruidas, las discrepancias residuales y la hora exacta en que se reanudó la automatización. La evidencia no debe contener valores secretos, contenidos de respaldo completo, cargas útiles del proveedor sin procesar ni datos innecesarios del cliente.

## Copias de trabajo de campaña

El paquete de recuperación del repositorio incluye `_campaign_drafts/` con las fuentes de la campaña publicadas. Restaure ambos antes de reabrir la edición. El acceso a la vista previa sigue siendo información de KV de corta duración y no se restaura. Una copia de trabajo guardada contiene su base de creación pública; Después de una restauración divergente, Publish informa un conflicto de revisión en lugar de reemplazar el contenido público restaurado. Al archivar una campaña se conserva su copia de trabajo y se tienen en cuenta los borradores de referencias de los medios. Los borradores de contenido local del navegador y las copias de `:recovery-v1` permanecen separados y requieren recuperación en el navegador/perfil original; consulte [Recuperación del panel](/es/docs/operations/admin-dashboard/#recuperar-un-borrador-perdido-del-navegador).

## Verificar el archivo R2 actual sin restaurar

Ejecuta **Verify Recovery Archive** manualmente desde `main`. El entorno `production-recovery` conserva sus restricciones de revisión y de ramas. El trabajo utiliza las credenciales de R2 y la identidad de recuperación configuradas para listar y descargar la instantánea cifrada más reciente, comprobar que su antigüedad no supera cuatro horas, verificar su tamaño y SHA-256, descifrarla y validar todas las sumas de verificación internas. No restaura registros, escribe en R2, modifica la programación del simulacro ni envía mensajes.

La herramienta compartida de auditoría se fija a un commit inmutable de Platform, independiente de la revisión usada por la aplicación. Los archivos ausentes, obsoletos, dañados, indescifrables o incompletos hacen fallar la ejecución. Solo se conservan recuentos y estados sin datos sensibles como artefacto; se eliminan los archivos temporales de claves y texto sin cifrar. Esto verifica el archivo con la clave configurada, pero no verifica la custodia independiente de claves, la política de bloqueo del bucket, la cobertura histórica de retención ni el comportamiento de restauración de la aplicación.


## Copias de producción cada cuatro horas

**Capture Production Backup** se ejecuta cada cuatro horas, en el minuto 37 UTC, y también puede iniciarse manualmente desde `main`. `BACKUP_SCHEDULE_ENABLED=true` habilita la captura programada. El entorno `production-backup` solo admite `main` y no exige revisión por ejecución, para que las capturas automáticas no queden esperando la aprobación de restauración. Se conservan el revisor de `production-recovery` y la configuración desactivada del simulacro trimestral de restauración.

Cada ejecución utiliza la herramienta de instantáneas de Pool para capturar el historial y la configuración de Git, además de todos los valores KV autorizados por el inventario como datos canónicos o de control. Cifra con el destinatario age existente, verifica localmente el descifrado, todas las sumas de verificación y la cobertura de datos, y sube la copia a un prefijo nuevo y único del archivo R2. Publica el comprobante al final y después descarga y verifica de nuevo ese mismo archivo. No escribe en producción, restaura datos, modifica pagos, envía notificaciones ni elimina archivos antiguos. La captura de KV en vivo no es una instantánea transaccional de base de datos; durante la recuperación sigue siendo necesario el procedimiento de restauración y conciliación.

Solo se conserva `backup-verification.json`, sin datos sensibles, como artefacto de GitHub durante 90 días. El archivo cifrado permanece en R2 bajo el bloqueo existente de 400 días; los archivos temporales privados de identidad y texto sin cifrar se eliminan tanto al completar como al fallar. Un fallo de captura o verificación hace fallar la ejecución de Actions. Los operadores deben mantener activadas las notificaciones de fallos de GitHub Actions. Las tareas programadas pueden retrasarse y no garantizan un intervalo máximo de pérdida de datos: revisa la fecha registrada en la instantánea e investiga ejecuciones fallidas o ausentes. La programación UTC mantiene el intervalo durante los cambios de horario de verano.

El flujo de trabajo de captura utiliza la credencial de origen Cloudflare existente del repositorio para operaciones de lectura y cinco secretos de entorno: `RECOVERY_AGE_IDENTITY`, `RECOVERY_ENCRYPTION_RECIPIENT`, `RECOVERY_ARCHIVE_URI`, `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`. No se necesita ningún inicio de sesión de administrador ni credencial Stripe.

Para la configuración inicial o la rotación, crea el entorno `production-backup` limitado a `main`, lee su clave pública de entorno de GitHub y configura las variables del repositorio `BACKUP_ENV_PUBLIC_KEY` y `BACKUP_ENV_KEY_ID`. Inicia **Provision Backup Credentials** mediante la aprobación existente de `production-recovery`. Instala los cinco valores cifrados con la API de secretos de entorno de GitHub solo después de comprobar el identificador de la clave de destino contra una nueva lectura de la clave pública. Solo GitHub puede descifrar estos sobres LibSodium; no contienen secretos en texto sin cifrar. Elimina el artefacto de transferencia después de instalarlo. Ejecuta una captura manual y verifica su resultado antes de activar la programación. Se utilizan los destinos R2 y las identidades existentes; la custodia independiente de claves y otros destinos de respaldo quedan fuera del alcance aprobado por el operador.

Los comandos locales para crear, cifrar y descifrar archivos tienen un tiempo límite de cinco minutos para admitir paquetes de repositorio más grandes; las lecturas de proveedores conservan sus límites más breves. El ejecutor compartido informa las fases de captura, subida y verificación y categorías de fallo fijas, sin registrar la salida de error del proveedor ni los valores capturados. Una ejecución fallida no habilita la programación ni cuenta como punto de recuperación verificado.
