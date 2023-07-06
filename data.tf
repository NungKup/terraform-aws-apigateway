data "aws_vpc_endpoint" "api" {
  for_each = var.enable_apigw && var.enable_apigw_private ? var.apigw_name : {}

  vpc_id       = lookup(each.value, "vpc_id", "")
  service_name = "com.amazonaws.ap-southeast-1.execute-api"
}

data "aws_iam_policy_document" "apigw_policy" {
  for_each = var.enable_apigw && var.enable_apigw_private ? var.apigw_name : {}

  statement {
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      values   = [data.aws_vpc_endpoint.api[each.key].id]
      variable = "aws:SourceVpce"
    }
  }

  statement {
    actions = ["execute-api:Invoke"]
    effect  = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["*"]
  }
}
