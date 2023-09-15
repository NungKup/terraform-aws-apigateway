resource "aws_api_gateway_vpc_link" "default" {
  count = var.enable_vpc_link ? var.config_vpc_link : 0

  name        = lookup(each.value, "name", "vpclink")
  description = lookup(each.value, "description", "")
  target_arns = lookup(each.value, "target_arns", null)
  tags        = { Name = lookup(each.value, "name", "vpclink") }
}


output "api_vpc_link" {
  value = aws_api_gateway_vpc_link.default[*].id
}

variable "enable_vpc_link" {
  default = true
}
variable "config_vpc_link" {}
