output "task" {
  value = aws_ecs_task_definition.this
}

output "task_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "execution_role" {
  value = module.execution_role.role
}

output "execution_role_arn" {
  value = module.execution_role.role.arn
}

output "execution_role_name" {
  value = module.execution_role.role.name
}

output "task_role" {
  value = module.task_role.role
}

output "task_role_arn" {
  value = module.task_role.role.arn
}

output "task_role_name" {
  value = module.task_role.role.name
}

output "efs_client_security_group" {
  value = module.efs.client_security_group
}

output "log_group" {
  value = module.log_group
}
