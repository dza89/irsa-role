resource "aws_iam_policy" "irsa" {
  name        = "${var.cluster_name}-${var.irsa_name}"
  description = ""

  policy = var.policy_body
}

resource "aws_iam_policy_attachment" "irsa" {
  name       = "${var.cluster_name}-${var.irsa_name}"
  roles      = [aws_iam_role.irsa.name]
  policy_arn = aws_iam_policy.irsa.arn
}

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cpt:${var.irsa_name}"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "irsa" {
  name               = "${var.cluster_name}-${var.irsa_name}"
  description        = ""
  assume_role_policy = data.aws_iam_policy_document.irsa.json

}