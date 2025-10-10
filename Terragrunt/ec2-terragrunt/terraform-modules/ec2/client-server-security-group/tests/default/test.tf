module "client_server_security_group" {
  source = "./modules/ec2/client-server-security-group"

  name   = "test"
  vpc_id = "vpc-xxx"

  ports = ["80/tcp"]
}
