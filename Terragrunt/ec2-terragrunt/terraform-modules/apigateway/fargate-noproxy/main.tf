/**
 * ## apigateway/fargate-proxy
 *
 * Module that creates all the resources for an aws api gateway proxying to a fargate task
 *
 * `module "apigateway" {
 *   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/fargate-proxy"
 *   gateways = {
 *    "obit-intake" = {
 *       set_params_for = []
 *       external_users = {}
 *       path_parts = []
 *    }
 *    "organization" = {
 *       path_parts = ["api", "organizations"]
 *       set_params_for = []
 *       external_users = {
 *         "batesville" = {
 *         "burst_limit": 500,
 *         "rate_limit": 1000,
 *         }
 *       }
 *    }
 *  }
 *   subnets = ["subnet-1","subnet-2"]
 *   environment = "environment"
 *   cluster_name = "fargate-cluster"
 *   vpc_id = "vpc-id"
 *  }`
 *
 *
 */
module "vpc_link" {
  source   = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/vpc_link/"
  lb_arn   = aws_lb.ecs.arn
  app_name = "${var.cluster_name}-gw"
}


resource "aws_lb" "ecs" {
  name               = "${var.cluster_name}-gw"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnets

  enable_deletion_protection = var.delete_protection

  tags = {
    Environment = var.environment,
    Creator     = "Terraform",
    Name        = "${var.cluster_name}-gw",
  }
}

resource "aws_security_group_rule" "nlb_ingress" {

  security_group_id = var.application_security_group_id

  type = "ingress"

  protocol  = "tcp"
  to_port   = var.port
  from_port = var.port

  cidr_blocks = [var.application_subnet_cidr]
}

# create listener
resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create target group for lb
resource "aws_lb_target_group" "ecs" {
  name        = "${var.cluster_name}-gw"
  port        = var.port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  stickiness {
    enabled = false
    type    = "source_ip"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "external_users" {
  source         = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/external_users_noproxy"
  for_each       = var.gateways
  api_id         = aws_api_gateway_rest_api.gateway[each.key].id
  stage_name     = aws_api_gateway_stage.api[each.key].stage_name
  app_name       = var.cluster_name
  external_users = var.gateways[each.key].external_users
}

resource "aws_api_gateway_account" "cloudwatch" {
  for_each            = var.gateways
  cloudwatch_role_arn = "arn:aws:iam::${var.aws_account_id}:role/LegacyAPIGatewayPushToCloudWatchLogs"
}




resource "aws_api_gateway_rest_api" "gateway" {
  for_each    = var.gateways
  name        = each.key
  description = each.key

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

module "gateway_resources" {
  for_each         = var.gateways
  source           = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/gateway_resources_noproxy/"
  rest_api_id      = aws_api_gateway_rest_api.gateway[each.key].id
  path_parts       = var.gateways[each.key].path_parts
  root_resource_id = aws_api_gateway_rest_api.gateway[each.key].root_resource_id
}

resource "aws_api_gateway_stage" "api" {
  for_each      = var.gateways
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.gateway[each.key].id
  deployment_id = aws_api_gateway_deployment.gateway[each.key].id
  description   = var.environment
  variables = {
    "servicesDomain" = aws_lb.ecs.dns_name
    "vpcLinkId"      = module.vpc_link.vpc_link_id
  }

}

resource "aws_api_gateway_method_settings" "general_settings" {
  for_each    = var.gateways
  rest_api_id = aws_api_gateway_rest_api.gateway[each.key].id
  stage_name  = aws_api_gateway_stage.api[each.key].stage_name
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# https://medium.com/coryodaniel/til-forcing-terraform-to-deploy-a-aws-api-gateway-deployment-ed36a9f60c1a

resource "aws_api_gateway_deployment" "gateway" {
  for_each    = var.gateways
  depends_on  = [module.gateway_resources]
  rest_api_id = aws_api_gateway_rest_api.gateway[each.key].id

  variables = {
    deployed_version = "0.1"
  }
  description = "0.1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "legacy-internal" {
  for_each    = var.gateways
  name        = "legacy-internal-${each.key}"
  description = "usage plan for internal use"

  api_stages {
    api_id = aws_api_gateway_rest_api.gateway[each.key].id
    stage  = aws_api_gateway_stage.api[each.key].stage_name
  }
}

resource "aws_api_gateway_api_key" "legacy-internal" {
  for_each    = var.gateways
  name        = "legacy-internal-${each.key}"
  description = "key used by internal-users"
  value       = "zKZD65ZYgc6XAGnYSAvam4aCIks5o0Vl5MfmdnDl"
}

resource "aws_api_gateway_usage_plan_key" "legacy-internal" {
  for_each      = var.gateways
  key_id        = aws_api_gateway_api_key.legacy-internal[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.legacy-internal[each.key].id
}

module "set_params" {
  for_each       = var.gateways
  source         = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/apigateway/set_params/"
  set_params_for = var.gateways[each.key].set_params_for
  api_name       = each.key
  environment    = var.environment
  token          = aws_api_gateway_api_key.legacy-internal[each.key].value
  invoke_url     = aws_api_gateway_stage.api[each.key].invoke_url
}
