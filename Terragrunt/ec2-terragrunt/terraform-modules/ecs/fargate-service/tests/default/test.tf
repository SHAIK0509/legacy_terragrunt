data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["dev-private-app-0"]
  }
}

module "fargate_service" {
  source = "./modules/ecs/fargate-service"

  aws_account_id = "653506005559"

  name    = "test-service"
  cluster = "dev-cluster"

  subnets = [data.aws_subnet.selected.id]

  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])
}
