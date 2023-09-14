module "reat_api" {
  source = "./module/rest_api"

  name                     = var.name
  description              = var.description
  minimum_compression_size = var.minimum_compression_size
  api_key_source           = var.api_key_source
  enable_private_api       = var.enable_private_api
  endpoint_configuration   = var.endpoint_configuration
  vpc_id                   = var.vpc_id
  enable_vpc_link          = var.enable_vpc_link
  vpc_link_name            = var.vpc_link_name
  vpc_link_description     = var.vpc_link_description
  nlb_target_arn           = var.nlb_target_arn
}

module "resource" {
  source = "./module/resource"

  api_id                 = module.reat_api.api_id
  api_parend_id          = module.reat_api.api_root_resource_id
  resource_config        = var.resource_config
  resource_parent_config = var.resource_parent_config
  enable_parent          = var.enable_parent
  enable_model_count     = var.enable_model_count
  # enable_resource        = var.enable_resource
  enable_create_double_medthod = var.enable_create_double_medthod
  resource_double_medthod      = var.resource_double_medthod

  vpc_link = module.reat_api.api_vpc_link[0]

  # request_config  = try(each.value.request_config, {})
  # response_config = try(each.value.response_config, {})

  depends_on = [module.reat_api]
}

# API Key
module "api_key" {
  source = "./module/api_key"

  enable_api_key = var.enable_api_key
  api_id         = module.reat_api.api_id
  api_key        = var.api_key
}
module "deploy_api" {
  source = "./module/deployment"

  api_id                = module.reat_api.api_id
  deploy                = var.deploy
  stage                 = var.stage
  enable_stage_log      = var.enable_stage_log
  enable_domain_name    = var.enable_domain_name
  domain_name           = var.domain_name
  enable_method_setting = var.enable_method_setting
  method_setting        = var.method_setting
  depends_on            = [module.resource]
}
