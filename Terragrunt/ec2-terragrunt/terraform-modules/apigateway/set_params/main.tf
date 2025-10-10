
resource "aws_ssm_parameter" "store" {
  for_each  = toset(var.set_params_for)
  name      = "/${var.environment}/${each.value}/${replace(upper(var.api_name), "-", "_")}_BASE_URL"
  value     = var.invoke_url
  type      = "String"
  overwrite = "true"
}



resource "aws_secretsmanager_secret" "secret" {
  for_each = toset(var.set_params_for)
  name     = "/${var.environment}/${each.value}/${replace(upper(var.api_name), "-", "_")}_TOKEN"
}

resource "aws_secretsmanager_secret_version" "secret" {
  for_each      = toset(var.set_params_for)
  secret_id     = aws_secretsmanager_secret.secret[each.value].id
  secret_string = var.token
}
