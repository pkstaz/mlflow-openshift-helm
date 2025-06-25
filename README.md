# MLflow Helm Chart for OpenShift

A simple and production-ready Helm chart to deploy MLflow on OpenShift 4.18+ with external PostgreSQL and MinIO integration.

**Author:** Carlos Estay (cestay@redhat.com)  
**GitHub:** pkstaz

## Features

- ✅ MLflow 2.8.1 tracking server
- ✅ OpenShift 4.18+ compatible with SCC compliance
- ✅ External PostgreSQL backend store
- ✅ External MinIO artifact store
- ✅ Optional OAuth integration with OpenShift login
- ✅ Production-ready security context
- ✅ No external dependencies

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenShift     │    │   PostgreSQL    │    │     MinIO       │
│    MLflow       │◄──►│   (External)    │    │   (External)    │
│   Tracking      │    │                 │    │                 │
│    Server       │    │  Backend Store  │    │ Artifact Store  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Start

### Prerequisites

- OpenShift 4.18+ cluster
- External PostgreSQL database
- External MinIO instance
- Helm 3.x installed

### Installation

#### Option 1: Using Helm (Recommended)

```bash
helm install mlflow . \
  --set postgresql.host="my-postgres-host.example.com" \
  --set postgresql.password="my-secret-password" \
  --set minio.endpoint="my-minio-host.example.com" \
  --set minio.accessKey="my-access-key" \
  --set minio.secretKey="my-secret-key"
```

#### Option 2: With OAuth Integration

```bash
helm install mlflow . \
  --set mlflow.oauth.enabled=true \
  --set postgresql.host="my-postgres-host.example.com" \
  --set postgresql.password="my-secret-password" \
  --set minio.endpoint="my-minio-host.example.com" \
  --set minio.accessKey="my-access-key" \
  --set minio.secretKey="my-secret-key" \
  --set route.host="mlflow.apps.my-cluster.example.com"
```

#### Option 3: Using values.yaml

```bash
# Create and edit your values file
cp values.yaml my-values.yaml
vim my-values.yaml

# Install with custom values
helm install mlflow . -f my-values.yaml
```

## Configuration Parameters

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `postgresql.host` | PostgreSQL hostname | `my-postgres-host.example.com` |
| `postgresql.password` | PostgreSQL password | `my-secret-password` |
| `minio.endpoint` | MinIO endpoint (without protocol) | `my-minio-host.example.com` |
| `minio.accessKey` | MinIO access key | `my-access-key` |
| `minio.secretKey` | MinIO secret key | `my-secret-key` |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mlflow.replicaCount` | Number of replicas | `1` |
| `mlflow.oauth.enabled` | Enable OpenShift OAuth | `false` |
| `postgresql.port` | PostgreSQL port | `5432` |
| `postgresql.database` | Database name | `mlflow` |
| `postgresql.username` | Database username | `mlflow` |
| `minio.bucket` | MinIO bucket for artifacts | `mlflow` |
| `minio.secure` | Use HTTPS for MinIO | `true` |
| `route.enabled` | Create OpenShift Route | `true` |
| `route.host` | Custom hostname for Route | `""` (auto-generated) |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mlflow.resources.requests.cpu` | CPU request | `500m` |
| `mlflow.resources.requests.memory` | Memory request | `512Mi` |
| `mlflow.resources.limits.cpu` | CPU limit | `1000m` |
| `mlflow.resources.limits.memory` | Memory limit | `1Gi` |

## Usage Examples

### Basic Installation

```bash
helm install mlflow . \
  --set postgresql.host="postgres.my-company.com" \
  --set postgresql.password="my-db-secret" \
  --set minio.endpoint="minio.my-company.com" \
  --set minio.accessKey="my-minio-user" \
  --set minio.secretKey="my-minio-password"
```

### Production Setup with OAuth

```bash
helm install mlflow-prod . \
  --namespace mlflow \
  --create-namespace \
  --set mlflow.oauth.enabled=true \
  --set mlflow.replicaCount=2 \
  --set postgresql.host="postgres-prod.my-company.com" \
  --set postgresql.password="my-production-secret" \
  --set postgresql.database="mlflow_production" \
  --set minio.endpoint="minio-prod.my-company.com" \
  --set minio.bucket="mlflow-production-artifacts" \
  --set minio.accessKey="my-prod-access-key" \
  --set minio.secretKey="my-prod-secret-key" \
  --set route.host="mlflow-prod.apps.my-cluster.com" \
  --set mlflow.resources.requests.cpu="1000m" \
  --set mlflow.resources.requests.memory="1Gi"
```

### Internal MinIO (within cluster)

```bash
helm install mlflow . \
  --set postgresql.host="postgresql.database.svc.cluster.local" \
  --set postgresql.password="my-cluster-secret" \
  --set minio.endpoint="minio.storage.svc.cluster.local" \
  --set minio.secure=false \
  --set minio.accessKey="my-internal-key" \
  --set minio.secretKey="my-internal-secret"
```

## Verification

### Check Installation Status

```bash
# Check pods
oc get pods -l app.kubernetes.io/name=mlflow

# Check services
oc get svc -l app.kubernetes.io/name=mlflow

# Check routes
oc get routes

# Get MLflow URL
oc get route mlflow -o jsonpath='{.spec.host}'
```

### View Logs

```bash
# Follow MLflow logs
oc logs -l app.kubernetes.io/name=mlflow -f

# Check init container logs
oc logs -l app.kubernetes.io/name=mlflow -c install-dependencies
```

## Client Configuration

### Python Client Setup

```python
import mlflow
import os

# Configure MinIO credentials
os.environ['AWS_ACCESS_KEY_ID'] = 'my-access-key'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'my-secret-key'
os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'https://my-minio-host.example.com'

# Set MLflow tracking URI
mlflow.set_tracking_uri("https://mlflow.apps.my-cluster.example.com")

# Use MLflow normally
with mlflow.start_run():
    mlflow.log_param("algorithm", "random_forest")
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_artifact("model.pkl")
```

### Environment Variables

```bash
export MLFLOW_TRACKING_URI="https://mlflow.apps.my-cluster.example.com"
export AWS_ACCESS_KEY_ID="my-access-key"
export AWS_SECRET_ACCESS_KEY="my-secret-key"
export MLFLOW_S3_ENDPOINT_URL="https://my-minio-host.example.com"
```

## OAuth Integration

When OAuth is enabled (`mlflow.oauth.enabled=true`), MLflow will be protected by OpenShift authentication:

- Users must log in with their OpenShift credentials
- Access is controlled by OpenShift RBAC
- SSL/TLS termination is handled automatically
- Session management via OAuth proxy

### OAuth Setup

```bash
# Install with OAuth enabled
helm install mlflow . \
  --set mlflow.oauth.enabled=true \
  [other parameters...]

# Users access MLflow through OpenShift login
# No additional authentication required for cluster users
```

## Troubleshooting

### Common Issues

#### Pod Fails to Start
```bash
# Check pod events
oc describe pod -l app.kubernetes.io/name=mlflow

# Check security context constraints
oc get scc
oc describe scc restricted-v2
```

#### Database Connection Issues
```bash
# Test database connectivity
oc exec deployment/mlflow -- python3 -c "
import psycopg2
conn = psycopg2.connect(
    host='my-postgres-host.example.com',
    port=5432,
    database='mlflow',
    user='mlflow',
    password='my-secret-password'
)
print('Database connection successful')
conn.close()
"
```

#### MinIO Connection Issues
```bash
# Test MinIO connectivity
oc exec deployment/mlflow -- python3 -c "
import boto3
client = boto3.client(
    's3',
    endpoint_url='https://my-minio-host.example.com',
    aws_access_key_id='my-access-key',
    aws_secret_access_key='my-secret-key'
)
print('MinIO connection successful')
"
```

### Debugging Commands

```bash
# Get detailed pod information
oc get pods -o wide

# Check resource usage
oc top pods

# View all MLflow resources
oc get all -l app.kubernetes.io/name=mlflow

# Check secrets
oc get secrets -l app.kubernetes.io/name=mlflow
```

## Upgrade

```bash
# Upgrade to latest version
helm upgrade mlflow .

# Upgrade with new values
helm upgrade mlflow . -f new-values.yaml
```

## Uninstall

```bash
# Remove MLflow installation
helm uninstall mlflow

# Clean up remaining resources (if any)
oc delete all,secrets,configmaps -l app.kubernetes.io/name=mlflow
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint .`
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Email: cestay@redhat.com
- GitHub: [pkstaz](https://github.com/pkstaz)