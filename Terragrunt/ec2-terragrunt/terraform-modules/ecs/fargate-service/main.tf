
/**
 * ## ecs/fargate-service
 *
 * Module to create a fargate-service, its task definition, load balancer associations, etc.
 *
 * AWS documentation for service definitions
 * https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
 *
 * Usage:
 *
 * module "service" {
 *   source = "./module/ecs/fargate-service"
 *
 *   name    = "test-service"
 *   cluster = "dev-cluster"
 *
 *   subnets = ["subnet-xxx01", "subnet-xxx02"]
 *
 *   container_definitions = [{
 *     name  = "test"
 *     image = "$${ecr_url}/test:latest"
 *   }]
 * }
 */
locals {
  is_load_balanced = length(jsondecode(var.load_balancer_associations)) > 0
  # value = local.has_volumes ? module.client_server_security_groups.client_security_group : null 
}

data "aws_subnet" "vpc" {
  id = element(var.subnets, 0)
}

module "task" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ecs/fargate-task"

  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
  name           = var.name

  allowed_deployment_environments = var.allowed_deployment_environments

  task_role             = var.task_role
  container_definitions = var.container_definitions
  template_variables    = var.template_variables

  cpu    = var.task_cpu
  memory = var.task_memory

  kms_arns = var.kms_arns

  log_retention_in_days = var.log_retention_in_days

  efs_subnets = var.efs_subnets == null ? var.subnets : var.efs_subnets

  efs_volumes                 = var.efs_volumes
  efs_volumes_backup_schedule = var.efs_volumes_backup_schedule

  tags = var.tags
}


module "target_group_listener_rules" {
  source = "../alb/target-group-listener-rules"

  name   = var.name
  vpc_id = data.aws_subnet.vpc.vpc_id

  load_balancer_listener_arn = var.load_balancer_listener_arn
  load_balancer_associations = var.load_balancer_associations
}


resource "aws_ecs_service" "this" {
  name            = var.name
  task_definition = module.task.task_arn
  cluster         = var.cluster

  platform_version = var.platform_version

  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = var.subnets
    security_groups = (
      module.task.efs_client_security_group == null
      ? var.security_groups
      : flatten([module.task.efs_client_security_group.id, var.security_groups])
    )
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = module.target_group_listener_rules.associations

    content {
      target_group_arn = module.target_group_listener_rules.target_groups[load_balancer.key].arn
      container_name   = load_balancer.key
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.network_lb == "" ? toset([]) : toset([var.network_lb])

    content {
      target_group_arn = var.network_lb
      container_name   = var.network_lb_container_name
      container_port   = var.network_lb_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.external_lb == "" ? toset([]) : toset([var.external_lb])

    content {
      target_group_arn = var.external_lb
      container_name   = var.network_lb_container_name
      container_port   = var.network_lb_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.external_lb_443 == "" ? toset([]) : toset([var.external_lb_443])

    content {
      target_group_arn = var.external_lb_443
      container_name   = var.network_lb_container_name
      container_port   = var.network_lb_port
    }
  }

  health_check_grace_period_seconds = local.is_load_balanced ? var.health_check_grace_period_seconds : null

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  enable_execute_command = var.enable_execute_command

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [module.target_group_listener_rules]
}

resource "aws_appautoscaling_target" "this" {
  count = var.do_autoscaling > 0 ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster}/${aws_ecs_service.this.name}"
  role_arn           = aws_iam_role.autoscaling[count.index].arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]
}


resource "aws_appautoscaling_policy" "this" {
  count = var.do_autoscaling > 0 ? 1 : 0

  name               = "${aws_ecs_service.this.name}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.scale_target
    scale_in_cooldown  = var.cooldown_secs
    scale_out_cooldown = var.cooldown_secs

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_iam_role" "autoscaling" {
  count              = var.do_autoscaling > 0 ? 1 : 0
  name               = "${var.cluster}-appautoscaling-role"
  assume_role_policy = file("${path.module}/policies/appautoscaling-role.json")
}

resource "aws_iam_role_policy" "autoscaling" {
  count  = var.do_autoscaling > 0 ? 1 : 0
  name   = "${var.cluster}-appautoscaling-policy"
  policy = file("${path.module}/policies/appautoscaling-role-policy.json")
  role   = aws_iam_role.autoscaling[0].id
}
