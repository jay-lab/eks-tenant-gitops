variable "region" {
  type    = string
  default = "ap-northeast-2"
}

# platform/karpenter/ec2nodeclass.yaml 의 태그, role 이름이랑 맞춰야 함
variable "cluster_name" {
  type    = string
  default = "eks-tenant-gitops"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "gitops_repo_url" {
  type    = string
  default = "https://github.com/jay-lab/eks-tenant-gitops.git"
}

variable "gitops_revision" {
  type    = string
  default = "main"
}
