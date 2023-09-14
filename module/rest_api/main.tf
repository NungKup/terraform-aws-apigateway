resource "aws_api_gateway_rest_api" "default" {
  name                     = var.name
  description              = var.description
  minimum_compression_size = var.minimum_compression_size
  api_key_source           = var.api_key_source

  dynamic "endpoint_configuration" {
    for_each = var.endpoint_configuration
    content {
      types            = endpoint_configuration.value.types == ["PRIVATE"] ? ["PRIVATE"] : ["Regional"]
      vpc_endpoint_ids = endpoint_configuration.value.types == ["PRIVATE"] ? [data.aws_vpc_endpoint.api[0].id] : null
    }
  }
  tags = { Name = var.name }
}

### Resource AWS API Gateway Policy
resource "aws_api_gateway_rest_api_policy" "default" {
  count = var.enable_private_api ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.default.id
  policy      = data.aws_iam_policy_document.apigw_policy[0].json
}

data "aws_vpc_endpoint" "api" {
  count = var.enable_private_api ? 1 : 0

  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-southeast-1.execute-api"
}

data "aws_iam_policy_document" "apigw_policy" {
  count = var.enable_private_api ? 1 : 0

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
      values   = [data.aws_vpc_endpoint.api[0].id]
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

resource "aws_api_gateway_vpc_link" "default" {
  count = var.enable_vpc_link ? 1 : 0

  name        = try(var.vpc_link_name, "")
  description = try(var.vpc_link_description, "")
  target_arns = try(var.nlb_target_arn, "")

  tags = { Name = var.vpc_link_name }
}
