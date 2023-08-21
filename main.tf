module "reat_api" {
  source = "./module/rest_api"

  name                     = var.name
  description              = var.description
  minimum_compression_size = var.minimum_compression_size
  api_key_source           = var.api_key_source
  enable_private_api       = var.enable_private_api
  endpoint_configuration   = var.endpoint_configuration
  vpc_id                   = var.vpc_id

  vpc_link_name        = var.vpc_link_name
  vpc_link_description = var.vpc_link_description
  nlb_target_arn       = var.nlb_target_arn
}

module "resource" {
  source = "./module/resource"

  for_each = { for k, v in var.resource : k => v }

  api_id                 = module.reat_api.api_id
  api_parend_id          = module.reat_api.api_root_resource_id
  resource_config        = try(each.value.resource_config, {})        # var.resource_config
  resource_parent_config = try(each.value.resource_parent_config, {}) # var.resource_parent_config
  enable_parent          = try(each.value.enable_parent, false)       # var.enable_parent
  enable_model_count     = try(each.value.enable_model_count, false)  # var.enable_model_count

  request_config  = try(each.value.request_config, {})
  response_config = try(each.value.response_config, {})

  depends_on = [module.reat_api]
}
