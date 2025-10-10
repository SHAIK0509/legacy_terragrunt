data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["dev-private-app-0"]
  }
}

module "fargate-service" {
  source = "./modules/ecs/fargate-service"

  aws_account_id = "653506005559"
  name           = "test-service"
  cluster        = "dev-cluster"

  subnets = [data.aws_subnet.selected.id]

  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])

  load_balancer_associations = jsonencode({
    test = {
      port              = 9000
      host_headers      = ["test.legint.net"]
      health_check_path = "/ping"
    }
  })
  load_balancer_listener_arn = "arn:::lb"

  template_variables = {}

  security_groups = []
  task_role       = "{}"
}


# output "<output-name>" {
#   value = module.fargate-service.<output-name>
# }
