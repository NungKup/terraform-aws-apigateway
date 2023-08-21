variable "enable_private_api" {
  type    = bool
  default = true
}
variable "name" {
  type = string
}
variable "description" {
  type    = string
  default = null
}
variable "minimum_compression_size" {
  default = -1
}
variable "api_key_source" {
  type    = string
  default = "HEADER"
}
variable "vpc_id" {
  type = string
}
