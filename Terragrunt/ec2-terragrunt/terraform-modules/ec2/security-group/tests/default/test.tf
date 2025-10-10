module "security_group" {
  source = "./modules/ec2/security-group"

  name   = "test"
  vpc_id = "vpc-xxx"

  rules = jsonencode([{
    port = 8080
    self = true
  }])
}
