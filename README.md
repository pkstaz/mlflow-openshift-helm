# MLflow Helm Chart (Simple)

MLflow para OpenShift 4.18+ con PostgreSQL y MinIO externos.

**Autor:** Carlos Estay (cestay@redhat.com)

## Características

- ✅ MLflow 2.9.2
- ✅ OpenShift 4.18+ compatible
- ✅ PostgreSQL externa
- ✅ MinIO externa
- ✅ Sin dependencias de Helm
- ✅ Configuración por parámetros

## Estructura

```
mlflow/
├── Chart.yaml           # Metadatos del chart
├── values.yaml          # Valores por defecto
├── install.sh           # Script de instalación con parámetros
├── templates/
│   ├── deployment.yaml  # Deployment de MLflow
│   ├── service.yaml     # Service
│   ├── route.yaml       # OpenShift Route
│   ├── NOTES.txt        # Instrucciones post-instalación
│   └── _helpers.tpl     # Template helpers
└── README.md           # Este archivo
```

## Instalación Rápida

### Opción 1: Script con parámetros (Recomendado)

```bash
./install.sh \
  --postgres-host postgres.example.com \
  --postgres-password mypassword \
  --minio-endpoint minio.poc-kaggle.svc.cluster.local \
  --minio-access-key AKIA123 \
  --minio-secret-key secret123
```

### Opción 2: Helm directo

```bash
helm install mlflow . \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.password="mypassword" \
  --set minio.endpoint="minio.poc-kaggle.svc.cluster.local" \
  --set minio.accessKey="AKIA123" \
  --set minio.secretKey="secret123"
```

### Opción 3: Archivo de valores

```bash
# Editar values.yaml con tus valores
vim values.yaml

# Instalar
helm install mlflow . -f values.yaml
```

## Parámetros Requeridos

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `--postgres-host` | Host de PostgreSQL | `postgres.example.com` |
| `--postgres-password` | Password de PostgreSQL | `mypassword` |
| `--minio-endpoint` | Endpoint de MinIO | `minio.example.com` |
| `--minio-access-key` | Access Key de MinIO | `AKIA123456` |
| `--minio-secret-key` | Secret Key de MinIO | `secret123` |

## Parámetros Opcionales

| Parámetro | Descripción | Default |
|-----------|-------------|---------|
| `--name` | Nombre del release | `mlflow` |
| `--namespace` | Namespace | `default` |
| `--postgres-port` | Puerto PostgreSQL | `5432` |
| `--postgres-database` | Nombre de la DB | `mlflow` |
| `--postgres-username` | Usuario de la DB | `mlflow` |
| `--minio-port` | Puerto MinIO | `9000` |
| `--minio-secure` | Usar HTTPS | `false` |
| `--minio-bucket` | Bucket de MinIO | `mlflow-artifacts` |
| `--replicas` | Número de réplicas | `1` |
| `--cpu-request` | CPU request | `250m` |
| `--memory-request` | Memory request | `512Mi` |

## Ejemplos de Uso

### Instalación básica

```bash
./install.sh \
  --postgres-host postgres.company.com \
  --postgres-password secret123 \
  --minio-endpoint minio.company.com \
  --minio-access-key AKIA123 \
  --minio-secret-key secret456
```

### Con configuración personalizada

```bash
./install.sh \
  --name mlflow-prod \
  --namespace mlflow \
  --postgres-host postgres.company.com \
  --postgres-password secret123 \
  --postgres-database mlflow_prod \
  --minio-endpoint minio.company.com \
  --minio-secure true \
  --minio-bucket mlflow-prod-artifacts \
  --minio-access-key AKIA123 \
  --minio-secret-key secret456 \
  --replicas 2 \
  --cpu-request 500m \
  --memory-request 1Gi
```

### MinIO interno del cluster

```bash
./install.sh \
  --postgres-host postgres.default.svc.cluster.local \
  --postgres-password secret123 \
  --minio-endpoint minio.poc-kaggle.svc.cluster.local \
  --minio-secure false \
  --minio-access-key minioadmin \
  --minio-secret-key minioadmin
```

## Verificar Instalación

```bash
# Ver pods
oc get pods

# Ver route
oc get routes

# Obtener URL de MLflow
oc get route mlflow -o jsonpath='{.spec.host}'

# Ver logs
oc logs -l app.kubernetes.io/name=mlflow -f
```

## Configuración de Cliente Python

```python
import mlflow
import os

# Configurar credenciales MinIO
os.environ['AWS_ACCESS_KEY_ID'] = 'tu-access-key'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'tu-secret-key'
os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'http://minio.endpoint.com:9000'

# Configurar MLflow
mlflow.set_tracking_uri("https://your-mlflow-route.apps.cluster.com")

# Usar MLflow normalmente
with mlflow.start_run():
    mlflow.log_param("param1", 5)
    mlflow.log_metric("metric1", 0.85)
    mlflow.log_artifact("model.pkl")
```

## Desinstalar

```bash
helm uninstall mlflow
```

## Troubleshooting

### Ver logs detallados
```bash
oc logs -l app.kubernetes.io/name=mlflow -f
```

### Verificar conectividad
```bash
# Test PostgreSQL
oc exec deployment/mlflow -- pg_isready -h postgres.host.com -p 5432

# Test MinIO
oc exec deployment/mlflow -- curl -I http://minio.endpoint.com:9000
```

### Problemas comunes
- **Error de conexión DB**: Verificar host, puerto y credenciales PostgreSQL
- **Error de conexión MinIO**: Verificar endpoint, puerto y credenciales MinIO
- **Pod no inicia**: Verificar security context y resources