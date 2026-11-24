#!/usr/bin/env bash
# Installs the cluster add-ons for Project 1. Run against a DEV cluster first.
set -euo pipefail

command -v helm >/dev/null || { echo "helm required"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl required"; exit 1; }
kubectl config current-context

helm repo add argo https://argoproj.github.io/argo-helm
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace \
  --set configs.params."server\.insecure"=true

helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

helm upgrade --install cert-manager jetstack/cert-manager -n cert-manager --create-namespace \
  --set crds.enabled=true

cat <<'EOF'

Next:
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
  kubectl -n argocd port-forward svc/argocd-server 8080:80
  kubectl apply -f policies/
  kubectl apply -f argocd/project.yaml -f argocd/applicationset.yaml
EOF
