module "fargate_task" {
  source = "./modules/ecs/fargate-task"

  name = "test"

  aws_account_id = "653506005559"

  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])
}

output "log_groups" {
  value = module.fargate_task.log_group
}
