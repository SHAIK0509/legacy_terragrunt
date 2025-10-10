module "security_group" {
  source = "./modules/helpers/security-group"

  name   = "dev-test"
  vpc_id = "vpc-xxx"

  rules = jsonencode([{
    port = 80
    self = true
  }])
}

output "security_group_rules" {
  value = module.security_group.security_group_rules
}
