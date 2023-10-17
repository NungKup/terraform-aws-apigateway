resource "aws_api_gateway_vpc_link" "default" {
  for_each = var.enable_vpc_link ? var.config_vpc_link : {}

  name        = try(each.value.name, "vpclink")
  description = try(each.value.description, "")
  target_arns = try(each.value.target_arns, null)
  tags        = { Name = try(each.value.name, "vpclink") }
}


output "api_vpc_link" {
  value = try(aws_api_gateway_vpc_link.default[each.key].id, "")
}

variable "enable_vpc_link" {
  default = true
}
variable "config_vpc_link" {
  default = {}
}
