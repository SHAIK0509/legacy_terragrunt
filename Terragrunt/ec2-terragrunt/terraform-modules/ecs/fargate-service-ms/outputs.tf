output "log_groups" {
  value = module.task.log_group
}

output "task_role_arn" {
  value = module.task.task_role_arn
}

output "network_configuration" {
  value = {
    awsvpcConfiguration = {
      subnets = var.subnets
      securityGroups = (
        module.task.efs_client_security_group == null
        ? var.security_groups
        : flatten([module.task.efs_client_security_group.id, var.security_groups])
      )
      assignPublicIp = var.assign_public_ip ? "ENABLED" : "DISABLED"
    }
  }
}

output "subnets" {
  value = var.subnets
}

output "task_definition_arn" {
  value = module.task.task_definition_arn
}

output "load_balancer_listener_arn" {
  value = var.load_balancer_listener_arn
}
