output "api_id" {
  value = aws_api_gateway_rest_api.default.id
}

output "api_root_resource_id" {
  value = aws_api_gateway_rest_api.default.root_resource_id
}

output "api_arn" {
  value = aws_api_gateway_rest_api.default.arn
}

output "api_vpc_link" {
  value = aws_api_gateway_vpc_link.default.id
}
