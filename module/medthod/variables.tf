variable "request_config" {
  type    = any
  default = {}
}
variable "response_config" {
  type    = any
  default = {}
}
variable "enable_resource" {
  type    = bool
  default = false
}

variable "api_authorizer_id" {
  type    = string
  default = null
}
variable "api_id" {
  type = string
}
variable "resource_id" {
  type = string
}

