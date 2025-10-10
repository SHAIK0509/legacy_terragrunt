/**
 * ## ecs/fargate-task
 *
 * Module that defines an ECS fargate task, usable as a service or scheduled task.
 *
 * Usage:
 *
 * module "task" {
 *   source = "./modules/ecs/fargate-task"
 *
 *   name       = "test"
 *
 *   container_definitions = jsonencode([{
 *     name  = "test"
 *     image = "$${ecr_url}/test:latest"
 *   }])
 *
 *   tags = var.tags
 * }
 *
 */
locals {
  // This will almost always be the default ecr domain, in shared-services
  ecr_domain = "${var.ecr_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  ecr_url    = "${local.ecr_domain}/"

  images = toset([for container in module.container_definitions.data : container.image])

  //            account                region                     name
  //               v                     v                          v
  ecr_pattern = "(\\d+)\\.dkr\\.ecr\\.([\\w-]+)\\.amazonaws\\.com/(.*):"
  // rewrite the ecr repo urls into repo arns based on naming convention
  ecr_arns = [
    for match in [
      for image in local.images : regexall(local.ecr_pattern, image).0 if length(regexall(local.ecr_pattern, image)) > 0
    ] : "arn:aws:ecr:${match.1}:${match.0}:repository/${match.2}"
  ]

  log_group_parts = regexall("^(?P<env>${join("|", var.allowed_deployment_environments)})-(?P<service>.*)$", var.name)
  log_group_map   = length(local.log_group_parts) > 0 ? local.log_group_parts.0 : { env = "unknown", service = var.name }
  log_group_name  = "/ecs-fargate/${local.log_group_map.env}/${local.log_group_map.service}"
}


module "container_definitions" {
  source                = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/container-definitions-ms"
  command               = var.command
  container_definitions = var.container_definitions
  template_variables = merge(var.template_variables, {
    ecr_url    = local.ecr_url
    ecr_domain = local.ecr_domain
  })

  default_log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.aws_region
      "awslogs-group"         = local.log_group_name
      "awslogs-stream-prefix" = "/${local.log_group_map.service}"
    }
    secretOptions = null
  }
}


module "log_group" {
  source = "../../cloudwatch/log-group"

  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}


module "execution_role" {
  source = "../iam/ecs-task-execution-role"

  name = "${var.name}-execution"

  kms_arns = var.kms_arns
  log_arns = [module.log_group.log_group.arn]
  ecr_arns = local.ecr_arns

  secrets = flatten([for container in module.container_definitions.data : [
    for secret in lookup(container, "secrets", []) : secret.valueFrom
  ]])

  tags = var.tags
}

module "task_role" {
  source = "../../iam/iam-role"

  name = "${var.name}-task"

  statements         = var.task_role
  template_variables = var.template_variables

  assume_role_policy = jsonencode({
    AssumeRole = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
      }]
    }
  })

  tags = var.tags
}


module "efs" {
  source = "../../efs/file-system"

  name = var.name

  volumes = var.efs_volumes
  subnets = var.efs_subnets

  backup_schedule = var.efs_volumes_backup_schedule

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "efs" {
  count = module.efs.has_volumes ? 1 : 0

  role       = module.task_role.role.name
  policy_arn = module.efs.client_iam_policy.arn
}


resource "aws_ecs_task_definition" "this" {
  family = var.name

  execution_role_arn    = module.execution_role.role.arn
  task_role_arn         = module.task_role.role.arn
  container_definitions = module.container_definitions.json

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.cpu
  memory = var.memory


  dynamic "volume" {
    for_each = flatten([
      for container in module.container_definitions.data : container.mountPoints if length(container.mountPoints) > 0
    ])

    content {
      name = volume.value.sourceVolume

      efs_volume_configuration {
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = module.efs.access_points[volume.value.sourceVolume].id
          iam             = "ENABLED"
        }

        file_system_id = module.efs.file_system_id
      }
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
