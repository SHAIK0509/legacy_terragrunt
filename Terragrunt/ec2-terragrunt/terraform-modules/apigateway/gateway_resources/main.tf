
resource "aws_api_gateway_resource" "path_part0" {
  count       = length(var.path_parts) > 0 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = var.path_parts[0]
}

resource "aws_api_gateway_resource" "path_part1" {
  count       = length(var.path_parts) > 1 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.path_part0[0].id
  path_part   = var.path_parts[1]
}

resource "aws_api_gateway_resource" "path_part2" {
  count       = length(var.path_parts) > 2 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.path_part1[0].id
  path_part   = var.path_parts[2]
}

resource "aws_api_gateway_resource" "path_part3" {
  count       = length(var.path_parts) > 3 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.path_part2[0].id
  path_part   = var.path_parts[3]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = var.rest_api_id
  parent_id   = length(var.path_parts) == 0 ? var.root_resource_id : length(var.path_parts) == 1 ? aws_api_gateway_resource.path_part0[0].id : length(var.path_parts) == 2 ? aws_api_gateway_resource.path_part1[0].id : length(var.path_parts) == 3 ? aws_api_gateway_resource.path_part2[0].id : aws_api_gateway_resource.path_part3[0].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = var.rest_api_id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = "$${stageVariables.vpcLinkId}"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.servicesDomain}/{proxy}/"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
