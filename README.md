# Getting Started

## Helm example

Run Terraform with the example configuration.

```tf
module "aws_load_balancer_controller" {
  source = "dza89/irsa"

  policy_body  = tostring(file("${path.module}/aws-policy.json"))
  irsa_name    = "aws-load-balancer-controller"
  cluster_name = var.cluster_name
}

resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = "true"
  wait             = true
  version          = var.aws_load_balancer_controller_version
  values = [
    "${file("values.yaml")}",
  ]
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = tostring(module.aws_load_balancer_controller.iam_role_arn)
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller" # needs to match irsa_name
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
```

You need the aws and helm provider.
