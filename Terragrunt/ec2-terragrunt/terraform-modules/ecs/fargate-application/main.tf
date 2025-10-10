/*
 * ## ecs/fargate-application
 *
 * Module that deploys an application as an ecs service, with ancilary infrastructure such as efs
 * volumes, load balancers and route53 records.
 *
 * Usage:
 *
 * module "application" {
 *   source = "./modules/ecs/fargate-application"
 *
 *   application_name = "test"
 *   environment      = "dev"
 *
 *   container_definitions = jsonencode([{
 *     name  = "test"
 *     image = "$${ecr_url}/test:latest"
 *   }])
 * }
 *
 */


terraform {
  backend "s3" {}
}

locals {
  service_name           = "${var.environment}-${var.application_name}"
  is_load_balanced       = length(jsondecode(var.load_balancer_associations)) > 0
  deploy_scheduled_tasks = (length(var.scheduled_tasks) > 0)
  deploy_gateway         = (length(var.gateways) > 0)
  network_lb             = (length(var.gateways) > 0 ? module.apigateway[0].aws_lb_target_group_arn : "")
  external_lb            = (length(var.external_domain) > 0 ? module.external_lb[0].aws_lb_target_group_arn : "")
  security_groups        = (length(var.external_domain) > 0 ? flatten([module.security_group.security_group.id, module.external_lb[0].aws_lb_sec_group_id, [var.security_groups]]) : flatten([module.security_group.security_group.id, [var.security_groups]]))
  do_external            = (length(var.external_domain) > 0 ? 1 : 0)

  template_variables = merge({
    aws_region     = var.aws_region,
    aws_account_id = var.aws_account_id,
    environment    = var.environment,
  }, var.template_variables)

  task_role = var.add_core_task_role_policy ? jsonencode(merge(
    jsondecode(var.task_role),
    {
      DescribeAllParameters = {
        actions   = ["ssm:DescribeParameters"]
        resources = ["*"]
      },
      ReadServiceParameters = {
        actions   = ["ssm:GetParametersByPath", "ssm:GetParameters", "ssm:GetParameterHistory", "ssm:GetParameter"]
        resources = ["arn:aws:ssm:us-east-1:${var.aws_account_id}:parameter/${var.environment}/${var.application_name}*"]
      }
      ListAllSecrets = {
        actions   = ["secretsmanager:ListSecrets", "secretsmanager:GetRandomPassword"]
        resources = ["*"]
      }

      ReadServiceSecrets = {
        actions = [
          "secretsmanager:ListSecretVersionIds", "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy", "secretsmanager:DescribeSecret",
        ]
        resources = [
          "arn:aws:secretsmanager:us-east-1:${var.aws_account_id}:secret:/${var.environment}/${var.application_name}/*"
        ]
      }

      SSMSecureChannelSession = {
        actions = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        resources = ["*"]
      }
    }
  )) : var.task_role
}


# module "assert_allowed_deployment_environment" {
#   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/assert"

#   actual    = "${join("|", var.allowed_deployment_environments)}|"
#   expected  = "${var.environment}|"
#   condition = "contains"

#   errors = {
#     contains = "The environment ${var.environment} is not allowed for this application [${join(", ", var.allowed_deployment_environments)}]."
#   }
# }

# module "remote" {
#   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/remote-state"

#   relative_paths = merge({
#     // sensible default values based on the file layout in infrastructure-live
#     vpc = "vpc"
#     ecs = "services/ecs-cluster"
#     lb  = "networking/alb-internal"
#   }, var.remote_state_paths)

#   relative_from = "${var.aws_region}/${var.environment}"

#   terraform_state_s3_bucket = (
#     var.terraform_state_s3_bucket == null
#     ? "legacy-com-${var.environment}-terraform-state"
#     : var.terraform_state_s3_bucket
#   )
#   terraform_state_aws_region = var.terraform_state_aws_region
# }

module "load_balancer_associations" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/load-balancer-associations"

  associations = var.load_balancer_associations
}

module "security_group" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ec2/security-group"

  name   = local.service_name
  vpc_id = "default"

  rules              = var.security_group_rules
  template_variables = local.template_variables

  tags = var.tags
}


resource "aws_security_group_rule" "lb_ingress" {
  for_each = module.load_balancer_associations.associations

  security_group_id = module.security_group.security_group.id

  type = "ingress"

  protocol  = "tcp"
  to_port   = each.value.container_port
  from_port = each.value.container_port

  source_security_group_id = module.remote.states.lb.alb_security_group_id
}

module "cluster" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ecs/cluster"

  name                      = var.ecs_cluster_name
  enable_container_insights = var.enable_container_insights

  count = var.create_ecs_cluster ? 1 : 0
}

module "service" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ecs/fargate-service"

  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
  network_lb     = local.network_lb
  external_lb    = local.external_lb

  external_domain = var.external_domain

  do_autoscaling = var.do_autoscaling
  max_capacity   = var.max_capacity
  min_capacity   = var.min_capacity
  scale_target   = var.scale_target
  cooldown_secs  = var.cooldown_secs


  allowed_deployment_environments = var.allowed_deployment_environments

  enable_execute_command = var.service_enable_execute_command

  platform_version = var.platform_version

  name = local.service_name

  cluster = (
    var.create_ecs_cluster
    ? module.cluster.0.cluster.name
    : (
      var.ecs_cluster_name == ""
      ? module.remote.states.ecs.ecs_cluster_name
      : var.ecs_cluster_name
    )
  )

  task_cpu    = var.task_cpu
  task_memory = var.task_memory

  security_groups = local.security_groups
  #flatten([module.security_group.security_group.id, [var.security_groups]])

  desired_count         = var.desired_count
  container_definitions = var.container_definitions

  template_variables = local.template_variables

  assign_public_ip = var.assign_public_ip

  subnets = (
    var.assign_public_ip
    ? module.remote.states.vpc.public_subnet_ids
    : module.remote.states.vpc.private_app_subnet_ids
  )

  efs_subnets = module.remote.states.vpc.private_persistence_subnet_ids

  efs_volumes                 = var.efs_volumes
  efs_volumes_backup_schedule = var.efs_volumes_backup_schedule

  kms_arns = var.kms_arns

  task_role = local.task_role

  log_retention_in_days = var.log_retention_in_days

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  load_balancer_associations = var.load_balancer_associations
  load_balancer_listener_arn = local.is_load_balanced ? module.remote.states.lb.listener_arns["443"] : null

  tags = var.tags
}


locals {
  fqdns = var.create_route53_records ? toset(flatten([
    for name, settings in jsondecode(var.load_balancer_associations) : settings.host_headers if length(lookup(settings, "host_headers", [])) > 0
  ])) : toset([])
}

data "aws_route53_zone" "selected" {
  for_each = local.fqdns

  name         = element(regexall("[\\w-]+\\.[\\w-]+\\.[\\w-]+\\.?$", each.value), 0)
  private_zone = true
}

resource "aws_route53_record" "this" {
  for_each = local.fqdns

  zone_id = data.aws_route53_zone.selected[each.key].zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 3600

  records = [module.remote.states.lb.alb_dns_name]

  allow_overwrite = true
}

###############################################################################
# Scheduled Events
#
module "scheduled_tasks" {
  source              = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ecs/fargate-scheduled-event"
  count               = local.deploy_scheduled_tasks ? 1 : 0
  application_name    = var.application_name
  environment         = var.environment
  aws_account_id      = var.aws_account_id
  ecs_cluster_name    = var.ecs_cluster_name
  subnets             = module.service.subnets
  task_definition_arn = module.service.task_definition_arn
  security_groups     = flatten([module.security_group.security_group.id, [var.security_groups]])
  scheduled_tasks     = var.scheduled_tasks
}


module "apigateway" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/fargate-proxy"
  count  = local.deploy_gateway ? 1 : 0

  gateways       = var.gateways
  subnets        = module.service.subnets
  environment    = var.environment
  cluster_name   = var.ecs_cluster_name
  vpc_id         = "default"
  aws_account_id = var.aws_account_id

  application_security_group_id = module.security_group.security_group.id
  application_subnet_cidr       = module.remote.states.vpc.private_app_subnet_cidr
}

module "external_lb" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/ecs/external_lb"
  count  = local.do_external

  subnets        = module.remote.states.vpc.public_subnet_ids
  environment    = var.environment
  cluster_name   = var.ecs_cluster_name
  vpc_id         = "default"
  aws_account_id = var.aws_account_id
  cidr_block     = var.cidr_block


  external_domain            = var.external_domain
  load_balancer_associations = var.load_balancer_associations

  application_security_group_id = module.security_group.security_group.id
  application_subnet_cidr       = module.remote.states.vpc.private_app_subnet_cidr
}








