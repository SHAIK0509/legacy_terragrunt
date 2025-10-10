resource "aws_api_gateway_rest_api" "funeralhome" {

  name = "funeralhome-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

resource "aws_api_gateway_deployment" "funeralhome" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  stage_name  = var.stage_name

  variables = {
    "servicesDomain" = var.services_domain
    "vpcLinkId"      = var.connection_id
  }

  depends_on = [
    aws_api_gateway_method.fhobits-get,
    aws_api_gateway_integration.fhobits-get,
    aws_api_gateway_method.fhservices-get,
    aws_api_gateway_integration.fhservices-get,
    aws_api_gateway_method.fhupcomingservices-get,
    aws_api_gateway_integration.fhupcomingservices-get
  ]

}

resource "aws_api_gateway_usage_plan" "external-edir-fh" {

  name        = "external-edir-${var.environment}-fh"
  description = "external-edir-${var.environment}-fh"

  api_stages {

    api_id = aws_api_gateway_rest_api.funeralhome.id
    stage  = aws_api_gateway_deployment.funeralhome.stage_name

  }

  throttle_settings {

    burst_limit = var.burst_limit
    rate_limit  = var.rate_limit

  }
}

resource "aws_api_gateway_usage_plan" "external-bbhq-fh" {

  name        = "external-bbhq-${var.environment}-fh"
  description = "external-bbhq-${var.environment}-fh"

  api_stages {

    api_id = aws_api_gateway_rest_api.funeralhome.id
    stage  = aws_api_gateway_deployment.funeralhome.stage_name

  }

  throttle_settings {

    burst_limit = var.burst_limit
    rate_limit  = var.rate_limit

  }
}

resource "aws_api_gateway_usage_plan" "internal-edir-fh" {

  name        = "internal-edir-${var.environment}-fh"
  description = "internal-edir-${var.environment}-fh"

  api_stages {

    api_id = aws_api_gateway_rest_api.funeralhome.id
    stage  = aws_api_gateway_deployment.funeralhome.stage_name

  }

  throttle_settings {

    burst_limit = var.burst_limit
    rate_limit  = var.rate_limit

  }
}

resource "aws_api_gateway_api_key" "external-bbhq" {
  name = "external-bbhq-${var.environment}-fh"
}

resource "aws_api_gateway_api_key" "external-edir" {
  name = "external-edir-${var.environment}-fh"
}

resource "aws_api_gateway_usage_plan_key" "external-edir-fh" {
  key_type      = "API_KEY"
  key_id        = aws_api_gateway_api_key.external-edir.id
  usage_plan_id = aws_api_gateway_usage_plan.external-edir-fh.id
}

resource "aws_api_gateway_usage_plan_key" "external-bbhq-fh" {
  key_type      = "API_KEY"
  key_id        = aws_api_gateway_api_key.external-bbhq.id
  usage_plan_id = aws_api_gateway_usage_plan.external-bbhq-fh.id
}

resource "aws_api_gateway_method" "fhobits-get" {
  rest_api_id      = aws_api_gateway_rest_api.funeralhome.id
  resource_id      = aws_api_gateway_resource.fh-obits.id
  authorization    = "NONE"
  http_method      = "GET"
  api_key_required = "true"
  depends_on = [
    aws_api_gateway_resource.fh-obits
  ]

  request_parameters = {
    "method.request.path.count"      = false
    "method.request.path.flowerCode" = true
    "method.request.path.offset"     = false
  }
}

resource "aws_api_gateway_method" "fhservices-get" {
  rest_api_id      = aws_api_gateway_rest_api.funeralhome.id
  resource_id      = aws_api_gateway_resource.fh-services.id
  authorization    = "NONE"
  http_method      = "GET"
  api_key_required = "true"
  depends_on = [
    aws_api_gateway_resource.fh-services
  ]
  request_parameters = {
  }
}

resource "aws_api_gateway_method" "fhupcomingservices-get" {
  rest_api_id      = aws_api_gateway_rest_api.funeralhome.id
  resource_id      = aws_api_gateway_resource.fh-upcomingservices.id
  authorization    = "NONE"
  http_method      = "GET"
  api_key_required = "true"
  depends_on = [
    aws_api_gateway_resource.fh-upcomingservices
  ]
  request_parameters = {
    "method.request.path.flowerCode" = true
  }
}

resource "aws_api_gateway_resource" "fh-funeralhome" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_rest_api.funeralhome.root_resource_id
  path_part   = "funeralhome"
}

resource "aws_api_gateway_resource" "fh-version" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_resource.fh-funeralhome.id
  path_part   = "{version}"
}

resource "aws_api_gateway_resource" "fh-fhid" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_resource.fh-version.id
  path_part   = "{fhid}"
}

resource "aws_api_gateway_resource" "fh-obits" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_resource.fh-fhid.id
  path_part   = "obits"
}

resource "aws_api_gateway_resource" "fh-services" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_resource.fh-fhid.id
  path_part   = "services"
}

resource "aws_api_gateway_resource" "fh-upcomingservices" {
  rest_api_id = aws_api_gateway_rest_api.funeralhome.id
  parent_id   = aws_api_gateway_resource.fh-fhid.id
  path_part   = "upcoming-services"
}

resource "aws_api_gateway_integration" "fhobits-get" {
  rest_api_id             = aws_api_gateway_rest_api.funeralhome.id
  resource_id             = aws_api_gateway_resource.fh-obits.id
  http_method             = aws_api_gateway_method.fhobits-get.http_method
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = var.connection_id
  type                    = "HTTP_PROXY"
  uri                     = var.connection_uri
  depends_on = [
    aws_api_gateway_method.fhobits-get
  ]
  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

resource "aws_api_gateway_integration" "fhservices-get" {
  rest_api_id             = aws_api_gateway_rest_api.funeralhome.id
  resource_id             = aws_api_gateway_resource.fh-services.id
  http_method             = aws_api_gateway_method.fhservices-get.http_method
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = var.connection_id
  type                    = "HTTP_PROXY"
  uri                     = var.connection_uri_two
  depends_on = [
    aws_api_gateway_method.fhservices-get
  ]
  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

resource "aws_api_gateway_integration" "fhupcomingservices-get" {
  rest_api_id             = aws_api_gateway_rest_api.funeralhome.id
  resource_id             = aws_api_gateway_resource.fh-upcomingservices.id
  http_method             = aws_api_gateway_method.fhupcomingservices-get.http_method
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = var.connection_id
  type                    = "HTTP_PROXY"
  uri                     = var.connection_uri_three
  depends_on = [
    aws_api_gateway_method.fhupcomingservices-get
  ]
  request_parameters = {
    "integration.request.path.fhid"    = "method.request.path.fhid"
    "integration.request.path.version" = "method.request.path.version"
  }
}

