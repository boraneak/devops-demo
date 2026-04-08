#!/bin/bash
set -e

echo "==> Provisioning cluster with Terraform..."
cd terraform && terraform init && terraform apply -auto-approve && cd ..

echo "==> Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "==> Installing observability stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace --wait --timeout 5m

echo "==> Loading app image into Kind..."
kind load docker-image ghcr.io/boraneak/devops-demo:latest --name devops-demo

echo "==> Deploying app..."
helm upgrade --install devops-demo ./helm/devops-demo \
  --set image.tag=latest \
  --set image.pullPolicy=IfNotPresent

echo "==> Done. Run: kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
