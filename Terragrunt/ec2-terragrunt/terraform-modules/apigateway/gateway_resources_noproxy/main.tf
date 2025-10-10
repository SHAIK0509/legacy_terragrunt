
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

resource "aws_api_gateway_resource" "path2_part3" {
  count       = length(var.path_parts) > 3 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.path_part2[0].id
  path_part   = var.path_parts[4]
}

resource "aws_api_gateway_resource" "path3_part3" {
  count       = length(var.path_parts) > 3 ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.path_part2[0].id
  path_part   = var.path_parts[5]
}

resource "aws_api_gateway_method" "noproxy" {
  rest_api_id          = var.rest_api_id
  resource_id          = aws_api_gateway_resource.path_part3[0].id
  http_method          = "GET"
  authorization        = "NONE"
  api_key_required     = true
  request_validator_id = aws_api_gateway_request_validator.this.id
  request_parameters = {
    "method.request.path.fhid"              = true
    "method.request.path.version"           = true
    "method.request.querystring.count"      = false
    "method.request.querystring.flowerCode" = true
    "method.request.querystring.offset"     = false
  }
}

resource "aws_api_gateway_method" "noproxy2" {
  rest_api_id      = var.rest_api_id
  resource_id      = aws_api_gateway_resource.path2_part3[0].id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.fhid"    = true
    "method.request.path.version" = true
  }
}

resource "aws_api_gateway_method" "noproxy3" {
  rest_api_id          = var.rest_api_id
  resource_id          = aws_api_gateway_resource.path3_part3[0].id
  http_method          = "GET"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.this.id
  api_key_required     = true
  request_parameters = {
    "method.request.path.fhid"              = true
    "method.request.path.version"           = true
    "method.request.querystring.flowerCode" = true
  }
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.path_part3[0].id
  http_method             = aws_api_gateway_method.noproxy.http_method
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = "$${stageVariables.vpcLinkId}"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.servicesDomain}/funeral-home/{version}/funeral-home/{fhid}/obituaries"
  cache_key_parameters    = ["method.request.querystring.count", "method.request.querystring.flowerCode", "method.request.querystring.offset"]

  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

resource "aws_api_gateway_integration" "api2" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.path2_part3[0].id
  http_method             = aws_api_gateway_method.noproxy2.http_method
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = "$${stageVariables.vpcLinkId}"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.servicesDomain}/funeral-home/{version}/funeral-home/{fhid}/upcoming-services"

  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

resource "aws_api_gateway_integration" "api3" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.path3_part3[0].id
  http_method             = aws_api_gateway_method.noproxy3.http_method
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = "$${stageVariables.vpcLinkId}"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.servicesDomain}/funeral-home/v1/funeral-home/{fhid}/upcoming-services"

  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

resource "aws_api_gateway_request_validator" "this" {
  name                        = "Validate query string parameters and headers"
  rest_api_id                 = var.rest_api_id
  validate_request_body       = true
  validate_request_parameters = true
}
