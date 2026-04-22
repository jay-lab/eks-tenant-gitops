resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.11"
  wait             = true

  values = [
    yamlencode({
      global = {
        # 시스템 노드그룹 taint 통과
        tolerations = [{
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }]
      }
      configs = {
        params = {
          "server.insecure" = true # 실습이라 port-forward로만 접속
        }
      }
    })
  ]

  depends_on = [helm_release.karpenter]
}

# terraform이 만드는 Application은 이거 하나뿐 (app of apps)
# 나머지는 전부 platform/ 아래 yaml을 argocd가 sync
resource "helm_release" "argocd_root_app" {
  name       = "argocd-root"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"

  values = [
    yamlencode({
      applications = {
        platform = {
          namespace = "argocd"
          project   = "default"
          # destroy 때 root app 지우면 NodePool/테넌트까지 같이 지워지게
          finalizers = ["resources-finalizer.argocd.argoproj.io"]
          source = {
            repoURL        = var.gitops_repo_url
            targetRevision = var.gitops_revision
            path           = "platform"
            directory = {
              recurse = true
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}
