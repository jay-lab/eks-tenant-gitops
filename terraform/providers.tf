provider "aws" {
  region = var.region
}

# helm provider는 EKS가 만들어진 뒤에 붙어야 함
# 토큰은 aws cli로 그때그때 받아옴 (kubeconfig 파일 안 씀)
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}
