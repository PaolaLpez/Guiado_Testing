# 10. Pruebas de Rendimiento y Carga de Forma Segura (k6)

## Objetivo
Entender el tiempo de respuesta, la tasa de error y el comportamiento del servicio bajo una carga de trabajo planificada y controlada en un entorno de pruebas dedicado, sin afectar sistemas de producción.

---

## Script de Carga con k6 (`performance/health-test.js`)

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 5,            // 5 usuarios virtuales concurrentes
  duration: '30s',   // duración total de la prueba: 30 segundos
  thresholds: {
    // Menos del 1% de peticiones fallidas permitido
    http_req_failed: ['rate<0.01'],
    // El 95% de las peticiones debe responder en menos de 500ms
    http_req_duration: ['p(95)<500'],
  },
};

export default function () {
  const baseUrl = __ENV.BASE_URL || 'http://localhost:3000';
  const response = http.get(`${baseUrl}/health`);
  check(response, {
    'health returns 200': (r) => r.status === 200,
  });
  sleep(1);
}
```

---

## Instrucciones de Ejecución Local

1. Iniciar la API del backend:
   ```bash
   cd backend
   npm start
   ```

2. Ejecutar k6 apuntando al entorno local:
   ```bash
   k6 run --env BASE_URL=http://localhost:3000 performance/health-test.js
   ```

---

## Ejercicio Práctico (Sección 10): Modificación de Umbral y Análisis del Reporte

> **Instrucción:** *Ejecutar el health check contra la API local. Cambiar un umbral (*threshold*), volver a ejecutar y explicar qué indica el reporte resultante.*

### Modificación Realizada:
Cambiamos el umbral de duración del percentil 95 (`p(95)`) a un valor intencionalmente ultra exigente e irreal para evaluar el comportamiento ante fallos:
```javascript
thresholds: {
  http_req_failed: ['rate<0.01'],
  // Umbral original: 'p(95)<500'
  // Umbral modificado (estricto):
  http_req_duration: ['p(95)<2'], // Exige que el 95% de respuestas tarde menos de 2 milisegundos
}
```

### Reporte Resultante de k6 (Ejemplo representativo):
```text
          /\      |‾‾| /‾‾/   /‾‾/   
     /\  /  \     |  |/  /   /  /    
    /  \/    \    |     (   /   ‾‾\  
   /          \   |  |\  \ |  (‾)  | 
  / __________ \  |__| \__\ \_____/ .io

  execution: local
     script: performance/health-test.js
     output: -

     scenarios: (100.00%) 1 scenario, 5 max VUs, 1m0s max duration (incl. graceful stop):
              * default: 5 looping VUs for 30s (gracefulStop: 30s)

     ✓ health returns 200

     checks.........................: 100.00% ✓ 150      ✗ 0  
   ✗ http_req_duration..............: avg=6.12ms min=1.8ms med=5.2ms max=24.5ms p(90)=9.1ms p(95)=12.4ms
       { expected_response:true }...: avg=6.12ms min=1.8ms med=5.2ms max=24.5ms p(90)=9.1ms p(95)=12.4ms
     ✓ http_req_failed..............: 0.00%   ✓ 0        ✗ 150
     vus............................: 5       min=5      max=5
     vus_max........................: 5       min=5      max=5

ERRO[0031] some thresholds have failed
exit status 99
```

### Explicación del Reporte:
1. **`checks: 100.00%`**: Todas las 150 peticiones enviadas retornaron código de estado HTTP 200. Ninguna falló en la verificación lógica.
2. **`http_req_failed: 0.00%`**: El umbral de tasa de fallos se cumplió exitosamente (0 errores).
3. **Fallo del umbral `✗ http_req_duration (p(95)<2)`**:
   - El percentil 95 real obtenido fue de **`12.4ms`**.
   - Al haber configurado el umbral en `p(95)<2ms`, k6 marca la prueba con una cruz roja (`✗`), imprime `some thresholds have failed` y finaliza con código de salida `99`.
4. **Utilidad en CI/CD:**
   Los umbrales en k6 permiten automatizar compuertas de calidad (*quality gates*). Si una nueva versión del backend introduce una consulta a la base de datos no indexada o bloqueos síncronos que elevan la latencia por encima del acuerdo de nivel de servicio (SLA), el pipeline de integración continua fallará automáticamente impidiendo el despliegue a producción.
