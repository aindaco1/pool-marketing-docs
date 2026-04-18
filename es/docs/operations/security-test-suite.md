---
title: Suite de pruebas de seguridad
parent: Operaciones
nav_order: 6
render_with_liquid: false
lang: es
---

# Pruebas de penetración de seguridad

Este directorio contiene pruebas centradas en la seguridad para la API de trabajador. Ejecútelos antes de implementarlos en producción.

## Inicio rápido

```bash
# Audit local secret exposure first
npm run test:secrets

# 1. Start the local Worker (in worker/ directory)
cd worker && npx wrangler dev --port 8787

# 2. Run security tests (in project root)
npm run test:security

# Run against staging
WORKER_URL=https://pledge-staging.example.com npm run test:security

# Run against production (read-only tests only)
WORKER_URL=https://worker.example.com PROD_MODE=true npm run test:security
```

## Configuración de desarrollo local

Para las comprobaciones del webhook del trabajador en vivo, el secreto del webhook de Stripe debe configurarse localmente.

- `STRIPE_WEBHOOK_SECRET`

La forma más sencilla de obtener una configuración local coincidente es:

```bash
./scripts/dev.sh
```

o la puerta de fusión:

```bash
npm run test:premerge
```

`npm run test:premerge` ahora incluye la auditoría secreta automáticamente ante las suites Worker, Smoke y Browser.

Para que las pruebas de limitación de velocidad funcionen localmente, asegúrese de que el espacio de nombres `RATELIMIT` KV esté configurado en `wrangler.toml`:

```toml
# In [[kv_namespaces]] section (production)
[[kv_namespaces]]
binding = "RATELIMIT"
id = "YOUR_RATELIMIT_KV_ID"
preview_id = "YOUR_RATELIMIT_PREVIEW_ID"

# Also in [[env.dev.kv_namespaces]] section (development)
[[env.dev.kv_namespaces]]
binding = "RATELIMIT"
id = "YOUR_RATELIMIT_KV_ID"
preview_id = "YOUR_RATELIMIT_PREVIEW_ID"
```

**Nota:** Reinicie el Worker después de realizar cambios para restablecer los contadores de límite de velocidad (KV se simula localmente y se reinicia al reiniciar).

## Categorías de prueba

### 1. Omisión de autenticación (`auth-bypass.test.ts`)
- Omisión del token de desarrollo en puntos finales `/votes`
- Tokens de enlace mágico faltantes o no válidos
- Fichas caducadas
- Firmas de tokens manipuladas

### 2. Seguridad del webhook (`webhook-security.test.ts`)
- Firmas de rayas no válidas
- Repetir ataques (mismo ID de evento)
- Cargas útiles de webhooks con formato incorrecto
- Faltan encabezados de firma
- La superficie del webhook de Stripe requiere firmas válidas

### 3. Autorización (`authorization.test.ts`)
- Intentos de acceso a promesas de usuarios cruzados
- Acceso al punto final del administrador sin secreto
- Pruebe el acceso al punto final en modo de producción

### 4. Validación de entrada (`input-validation.test.ts`)
- Cargas útiles sobredimensionadas
- Babosas de campaña maliciosas
- Patrones de inyección SQL/NoSQL
- Cargas útiles XSS en campos de usuario

### 5. Limitación de tasa (`rate-limiting.test.ts`)
- Las solicitudes de ráfaga a `/checkout-intent/start` no deberían cerrarse limpiamente
- Votar intentos de spam (límite de 30 solicitudes/min)
- Simulación de fuerza bruta del administrador (límite de 5 solicitudes/min)
- Resiliencia DoS y prevención del agotamiento de recursos
- Seguridad de operación concurrente

## Configuración

Establezca estas variables de entorno:

|variable|Predeterminado|Descripción|
|----------|---------|-------------|
|`WORKER_URL`|`http://localhost:8787`|Punto final del trabajador para probar|
|`PROD_MODE`|`false`|Saltar pruebas destructivas|
|`ADMIN_SECRET`|(ninguno)|Secreto de administrador para pruebas de autenticación|
|`TEST_TOKEN`|(ninguno)|Token de enlace mágico válido para pruebas de autenticación|

## Integración de CI

Agregar a acciones de GitHub:

```yaml
security-tests:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    - run: npm ci
    - run: npm run test:security
      env:
        WORKER_URL: ${{ secrets.STAGING_WORKER_URL }}
```

## Escribir nuevas pruebas

```typescript
import { test, expect, describe } from 'vitest';
import { securityFetch, expectUnauthorized } from './helpers';

describe('My Security Test', () => {
  test('should reject invalid input', async () => {
    const res = await securityFetch('/endpoint', {
      method: 'POST',
      body: JSON.stringify({ malicious: '<script>alert(1)</script>' })
    });
    
    // Test should pass if properly rejected
    expect(res.status).toBe(400);
  });
});
```
