module "fargate_application" {
  source = "./modules/ecs/fargate-application"

  aws_account_id = "653506005559"

  application_name = "test"
  environment      = "dev"

  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])
}
