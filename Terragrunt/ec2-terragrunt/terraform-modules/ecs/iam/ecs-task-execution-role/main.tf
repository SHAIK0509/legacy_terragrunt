/**
 * ## ecs/iam/ecs-task-execution-role
 *
 * Module that creates an iam-role suitable for assigning as the excution role assigned to a fargate
 * task.
 *
 * Usage:
 *
 * module "execution_role" {
 *   source = "./modules/ecs/iam/ecs-task-execution-role"
 *
 *   name = "test"
 *
 *   log_arns = ["arn:log:::whatever"]
 *   ecr_arns = ["arn:ecr:::whatever"]
 *   secrets = [
 *     "/path/to/test/secret1",
 *     "/path/to/test/secret2",
 *   ]
 * }
 *
 */
locals {
  resource_actions = {
    SSMReadParameters = {
      actions   = ["ssm:GetParameters"]
      resources = var.secrets
    }

    KMSDecryptSecrets = {
      actions   = ["kms:Decrypt"]
      resources = var.kms_arns
    }

    CloudwatchLogsWriteStream = {
      actions = [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
      ]
      resources = [for arn in var.log_arns : "${arn}:*"]
    }

    ECRAuth = {
      actions   = ["ecr:GetAuthorizationToken"]
      resources = ["*"] // just the way it must be
    }

    ECRImagePull = {
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
      resources = var.ecr_arns
    }
  }
}

module "iam_role" {
  source = "../../../iam/iam-role"

  name = var.name

  // This constructs a map of AWS service-specific actions and resources
  // based on the presenece a known set of resource types in provided input.
  statements = jsonencode({ for k, v in local.resource_actions : k => {
    resources = v.resources
    actions   = v.actions
  } if length(v.resources) > 0 })

  template_variables = var.template_variables

  managed_policies = var.managed_policies

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
