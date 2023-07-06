output "rest_api_id" {
  value = "%{for v in aws_api_gateway_rest_api.default}${~v.id~}%{~endfor~}"
}
output "root_resource_id" {
  value = "%{for v in aws_api_gateway_rest_api.default}${~v.root_resource_id~}%{~endfor~}"
}
