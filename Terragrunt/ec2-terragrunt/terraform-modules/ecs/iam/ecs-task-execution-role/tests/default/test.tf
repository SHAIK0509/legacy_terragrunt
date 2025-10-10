module "ecs_task_execution_role" {
  source = "./modules/ecs/iam/ecs-task-execution-role"

  name = "test"

  log_arns = ["arn:log:::whatever"]
  ecr_arns = ["arn:ecr:::whatever"]
  secrets = [
    "/path/to/test/secret1",
    "/path/to/test/secret2",
  ]
}
