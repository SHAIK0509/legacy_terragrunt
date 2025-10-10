module "fargate-application" {
  source = "./modules/ecs/fargate-application"

  application_name = "test"
  environment      = "dev"

  aws_account_id   = "653506005559"
  ecs_cluster_name = "dev-cluster"
  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])

  create_route53_records = false
  load_balancer_associations = jsonencode({
    test = {
      port              = 9000
      host_headers      = ["test.legint.net"]
      health_check_path = "/ping"
    }
  })

  task_role            = "{}"
  security_group_rules = "[]"
  security_groups      = []
  template_variables   = {}
}


# output "<output-name>" {
#   value = module.fargate-application.<output-name>
# }
