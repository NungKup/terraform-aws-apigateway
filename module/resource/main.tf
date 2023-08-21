resource "aws_api_gateway_resource" "default" {
  for_each = var.resource_config

  rest_api_id = lookup(each.value, "rest_api_id", var.api_id)
  parent_id   = lookup(each.value, "parent_id", var.api_parend_id)
  path_part   = lookup(each.value, "path_part", "")
}

resource "aws_api_gateway_resource" "parent_id" {
  for_each = var.enable_parent ? var.resource_parent_config : {}

  rest_api_id = lookup(each.value, "rest_api_id", var.api_id)
  parent_id   = aws_api_gateway_resource.default[lookup(each.value, "parent_id", "")].id
  path_part   = lookup(each.value, "path_part", "")

  depends_on = [aws_api_gateway_resource.default]
}

resource "aws_api_gateway_model" "default" {
  for_each = var.enable_model_count ? var.resource_config : {}

  rest_api_id  = lookup(each.value, "rest_api_id", var.api_id)
  name         = lookup(each.value, "name_model", "")
  description  = lookup(each.value, "description_model", "")
  content_type = lookup(each.value, "content_type_model", "")

  schema = lookup(each.value, "model_schemas", jsonencode({ type = "object" }))
}

# module "medthod" {
#   source = "../medthod"

#   for_each = var.resource_config

#   api_id      = var.api_id
#   resource_id = aws_api_gateway_resource.default[each.key].id

#   request_config  = var.request_config
#   response_config = var.response_config

#   depends_on = [aws_api_gateway_resource.default]
# }

# module "medthod_parent" {
#   source = "../medthod"

#   for_each = var.resource_parent_config

#   api_id      = var.api_id
#   resource_id = aws_api_gateway_resource.parent_id[each.key].id

#   depends_on = [aws_api_gateway_resource.default]
# }
