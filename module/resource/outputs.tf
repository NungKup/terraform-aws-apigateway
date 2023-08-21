output "api_resource_id" {
  value = merge(try({ for k, v in aws_api_gateway_resource.default : k => v.id }, ""), try({ for k, v in aws_api_gateway_resource.parent_id : k => v.id }, ""))
}
