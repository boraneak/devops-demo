# devops-demo

A DevOps pipeline demonstrating end-to-end CI/CD, infrastructure as code, and observability on a local Kubernetes cluster.

## Stack

| Concern | Tool |
|---|---|
| App | FastAPI (Python) |
| Containerization | Docker |
| Infrastructure as Code | Terraform |
| Cluster | Kubernetes (Kind) |
| CI/CD | GitHub Actions |
| Package Registry | GitHub Container Registry (GHCR) |
| Deployment | Helm |
| Security Scanning | Trivy |
| Metrics | Prometheus |
| Visualization | Grafana |

## Pipeline

```
git push → build image → Trivy scan → push to GHCR → deploy to K8s via Helm
```

## Architecture

- FastAPI app exposes `/health` and `/metrics` endpoints
- Terraform provisions a Kind cluster with 1 control-plane and 1 worker node
- GitHub Actions runs CI/CD on every push to master
- Trivy blocks deployment if CRITICAL vulnerabilities are found
- Helm manages app deployment and upgrades
- Prometheus scrapes app metrics via ServiceMonitor
- Grafana visualizes cluster and app metrics

## Run Locally

### Prerequisites

- Docker
- Terraform
- Kind
- kubectl
- Helm

### Setup

```bash
# Provision cluster
cd terraform && terraform init && terraform apply -auto-approve

# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install observability stack
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Deploy app
helm upgrade --install devops-demo ./helm/devops-demo \
  --set image.tag=latest \
  --set image.pullPolicy=IfNotPresent
```

### Access

**Grafana:** `kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring`
Open http://localhost:3000 with username `admin`.
Get password:
```bash
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

**App:** `kubectl port-forward svc/devops-demo 8080:8000`
- http://localhost:8080/health
- http://localhost:8080/metrics

## Note

Runs on Kind for local development. Production deployment targets EKS/GKE with the same Helm charts and pipeline.