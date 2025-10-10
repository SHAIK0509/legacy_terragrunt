output "vpc_link_id" {
  description = "id of the vpc link"
  value       = aws_api_gateway_vpc_link.link.id
}
