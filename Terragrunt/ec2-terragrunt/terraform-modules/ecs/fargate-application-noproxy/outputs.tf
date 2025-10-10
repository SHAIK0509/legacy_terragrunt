output "log_groups" {
  value = module.service.log_groups
}

output "service_security_group_id" {
  value = module.security_group.security_group.id
}

output "service_task_role_arn" {
  value = module.service.task_role_arn
}

output "network_configuration" {
  value = module.service.network_configuration
}

output "task_definition_arn" {
  value = module.service.task_definition_arn
}

output "ecs_cluster_name" {
  value = (
    var.create_ecs_cluster
    ? module.cluster.0.cluster.name
    : (
      var.ecs_cluster_name == ""
      ? module.remote.states.ecs.ecs_cluster_name
      : var.ecs_cluster_name
    )
  )
}
