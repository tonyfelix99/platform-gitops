# Project 1 – GitOps on AKS (Helm + Argo CD + Kyverno)

**Goal:** a Git commit alone deploys, promotes and rolls back a service; only signed images are admitted.

## What is here
```
charts/webapp/            Reusable Helm chart (Deployment, Service, Ingress, HPA, PDB, probes, security context)
envs/{dev,staging,prod}/  Per-environment values (image tag, replicas, host)
argocd/project.yaml       Argo CD AppProject (what repos/namespaces are allowed)
argocd/applicationset.yaml  One Argo app per environment from the folders above
policies/verify-images.yaml Kyverno: only Cosign-signed images (GitHub OIDC keyless)
policies/baseline.yaml      Kyverno: no root, no :latest, requests/limits required
scripts/bootstrap.sh      Installs Argo CD + Kyverno + ingress-nginx + cert-manager on an AKS cluster
```

## Steps (≈ 6 hours)
1. **Cluster:** use an existing dev AKS cluster (`az aks get-credentials ...`) or create one with your Terraform module.
2. **Fork/push this folder** into a Git repo (e.g. `platform-gitops`). Edit `REPO_URL` in `argocd/applicationset.yaml`.
3. `./scripts/bootstrap.sh` – installs Argo CD, Kyverno, ingress-nginx, cert-manager.
4. `kubectl apply -f policies/` – start with `validationFailureAction: Audit`, then flip to `Enforce`.
5. `kubectl apply -f argocd/project.yaml -f argocd/applicationset.yaml` – dev/staging/prod apps appear.
6. **Test the loop:** change `image.tag` in `envs/dev/values.yaml`, commit, watch Argo sync. Break it on purpose, `git revert`, watch it roll back.
7. **Prove policy:** deploy an unsigned or `:latest` image → admission is denied (screenshot it for your write-up).
8. **Real service:** replace the sample image (`podinfo`) with one client service. Keep the old pipeline deploy for 1 week in parallel.

## Done when
- A commit rolls out and a revert rolls back with no manual `kubectl`.
- HPA scales under load (`kubectl get hpa -w` while using `hey`/`k6`).
- Unsigned image rejected by Kyverno.

## Stretch (skip if short on time)
- App-of-apps for platform add-ons · Argo CD Image Updater · Sealed Secrets or External Secrets with Key Vault.

## Commands to remember for CKA
`kubectl rollout status/undo`, `kubectl top`, `kubectl drain`, `kubectl auth can-i`, `kubectl explain`.
