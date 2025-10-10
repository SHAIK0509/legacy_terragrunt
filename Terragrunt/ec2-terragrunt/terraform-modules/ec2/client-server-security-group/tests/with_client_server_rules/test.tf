module "client_server_security_group" {
  source = "./modules/ec2/client-server-security-group"

  name   = "test"
  vpc_id = "vpc-xxx"

  ports = ["80/tcp"]

  client_rules = jsonencode([{
    port        = 8080
    cidr_blcoks = ["0.0.0.0/0"]
  }])

  server_rules = jsonencode([{
    port                     = 8080
    source_security_group_id = "sg-xxx"
  }])
}
