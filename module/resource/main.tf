resource "aws_api_gateway_resource" "default" {
  for_each = var.resource_config

  rest_api_id = lookup(each.value, "rest_api_id")
  parent_id   = lookup(each.value, "parent_id")
  path_part   = lookup(each.value, "path_part", "")
}

resource "aws_api_gateway_model" "default" {
  for_each = var.enable_model_count ? var.resource_config : {}

  rest_api_id  = lookup(each.value, "rest_api_id")
  name         = lookup(each.value, "name_model", "")
  description  = lookup(each.value, "description_model", "")
  content_type = lookup(each.value, "content_type_model", "")

  schema = lookup(each.value, "model_schemas", jsonencode({ type = "object" }))
}
