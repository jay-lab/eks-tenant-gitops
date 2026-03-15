# IAM role(컨트롤러/노드), 인터럽션 SQS, EventBridge 룰을 한번에 만들어줌
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.31"

  cluster_name = module.eks.cluster_name

  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true

  # EC2NodeClass(platform/karpenter)에서 이름으로 참조하니까 prefix 없이 고정
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "${var.cluster_name}-karpenter-node"

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.1.1"
  wait       = true

  values = [
    yamlencode({
      settings = {
        clusterName       = module.eks.cluster_name
        clusterEndpoint   = module.eks.cluster_endpoint
        interruptionQueue = module.karpenter.queue_name
      }
      serviceAccount = {
        name = module.karpenter.service_account
      }
      # coredns 뜨기 전에도 동작하게
      dnsPolicy = "Default"
      nodeSelector = {
        "karpenter.sh/controller" = "true"
      }
      tolerations = [{
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      }]
    })
  ]
}
