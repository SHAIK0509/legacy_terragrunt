
resource "aws_api_gateway_usage_plan" "external" {
  for_each    = var.external_users
  name        = "external-${each.key}-${var.app_name}"
  description = "usage plan for ${each.key}"

  api_stages {
    api_id = var.api_id
    stage  = var.stage_name
  }

  throttle_settings {
    burst_limit = each.value.burst_limit
    rate_limit  = each.value.rate_limit
  }
}

resource "aws_api_gateway_api_key" "external" {
  for_each    = var.external_users
  name        = "external-${each.key}-${var.app_name}"
  description = "key used by ${each.key}"
}

resource "aws_api_gateway_usage_plan_key" "external" {
  for_each      = var.external_users
  key_id        = aws_api_gateway_api_key.external[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.external[each.key].id
}
