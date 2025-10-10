
resource "aws_api_gateway_usage_plan" "bbhq" {
  name        = "external-bbhq-edirectory-dev-services-nginx"
  description = "usage plan for bbhq and edir for fh-api"

  api_stages {
    api_id = var.api_id
    stage  = var.stage_name
  }

  throttle_settings {
    burst_limit = 5000
    rate_limit  = 10000
  }
}

resource "aws_api_gateway_usage_plan" "edir" {
  name        = "external-edirectory-dev-services-nginx"
  description = "usage plan for edir for fh-api"

  api_stages {
    api_id = var.api_id
    stage  = var.stage_name
  }

  throttle_settings {
    burst_limit = 5000
    rate_limit  = 10000
  }
}

resource "aws_api_gateway_api_key" "bbhq" {
  name        = "external-builtbyhq-edir-fh"
  description = "key used by bbhq-edir for fh-api"
  value       = "5B1IdUeS305Dip2EtYxt47pZp0iAuJME1u8ucGhW"
}

resource "aws_api_gateway_api_key" "edir" {
  name        = "external-edir-fh"
  description = "key used by edir for fh-api"
  value       = "3iuEGKFh9M54r346msu0LNC3FM0c2hrae9AicS32"
}

resource "aws_api_gateway_usage_plan_key" "bbhq" {
  key_id        = aws_api_gateway_api_key.bbhq.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.bbhq.id
}

resource "aws_api_gateway_usage_plan_key" "edir" {
  key_id        = aws_api_gateway_api_key.edir.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.edir.id
}
