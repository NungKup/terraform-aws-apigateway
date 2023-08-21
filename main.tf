module "reat_api" {
  source = "./module/rest_api"

  name                     = var.name
  description              = var.description
  minimum_compression_size = var.minimum_compression_size
  api_key_source           = var.api_key_source
  enable_private_api       = var.enable_private_api
  endpoint_configuration   = var.endpoint_configuration
}
