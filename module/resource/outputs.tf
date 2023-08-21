output "api_resource_id" {
  value = aws_api_gateway_resource.default[*].id
}
output "api_resource_path" {
  value = aws_api_gateway_resource.default[*].path
}
