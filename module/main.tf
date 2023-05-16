resource "aws_api_gateway_rest_api" "default" {
  for_each = var.apigw_name

  name                     = lookup(each.value, "name", local.default_apigw_name)
  description              = lookup(each.value, "description", local.default_description)
  minimum_compression_size = lookup(each.value, "minimum_compression_size", -1)
  api_key_source           = lookup(each.value, "api_key_source", "HEADER")

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }

  tags = {
    Name = lookup(each.value, "name", local.default_apigw_name)
  }
  # tags = (merge(local.tags_default, tomap({
  #   Name = "${var.rest_api_name}-landingzone"
  # })))
}

# Resource AWS API Gateway Policy
resource "aws_api_gateway_rest_api_policy" "default" {

  # for_each = var.apigw_name
  rest_api_id = aws_api_gateway_rest_api.default[*].id
  policy      = data.aws_iam_policy_document.apigw_policy.json
}

resource "aws_api_gateway_resource" "default" {
  count = length(var.config_path_parts) > 0 ? length(var.config_path_parts) : 0

  rest_api_id = aws_api_gateway_rest_api.default[*].id
  parent_id   = var.new_parent_resource == null ? aws_api_gateway_rest_api.default[*].root_resource_id : var.new_parent_resource
  path_part   = try(var.config_path_parts[count.index].path_part, null)

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default
  ]
}

resource "aws_api_gateway_resource" "new_parent" {
  for_each = [
    for parent in try(var.config_parent_resource[count.index].path_part) :
    parent
    if length(parent.path_part) > 0
  ]
  # count = var.enable_parent_resource > 0 ? length(var.config_parent_resource) : 0

  rest_api_id = aws_api_gateway_rest_api.default[*].id
  parent_id   = aws_api_gateway_rest_api.default[*].root_resource_id
  path_part   = try(parent.path_part, null)

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default
  ]
}

resource "" "name" {

}
