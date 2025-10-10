/**
 * ## helpers/iam-policy-document
 *
 * Helper module to construct an iam policy document data source with sensible defaults, closely
 * matching the AWS api.
 *
 * Usage:
 *
 * module "assume_role" {
 *   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/iam-policy-document"
 *
 *   statements = jsonencode({
 *     AssumeRole = {
 *       actions = ["sts:AssumeRole"]
 *       principals = [{
 *         type        = "Service"
 *         identifiers = ["backup.amazonaws.com"]
 *       }]
 *     }
 *   })
 * }
 *
 *
 * module "policy" {
 *   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/iam-policy-document"
 *
 *   statements = jsonencode({
 *     AllowReadOnlyS3Bucket = {
 *       actions   = ["s3:Get*", "s3:List"]
 *       resources = ["arn:aws:s3:::some-s3-bucket"]
 *     }
 *   })
 * }
 *
 * With template variables:
 *
 * module "templated_policy" {
 *   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/iam-policy-document"
 *
 *   statements = jsonencode({
 *     AllowECRImagePull = {
 *       actions = [
 *         "ecr:BatchCheckLayerAvailability",
 *         "ecr:GetDownloadUrlForLayer",
 *         "ecr:BatchGetImage",
 *       ]
 *       resources = ["$${ecr_url}"]
 *     }
 *   })
 *
 *   template_variables = {
 *     ecr_url = "arn:aws:ecr:::"
 *   }
 * }
 *
 */
variable "statements" {
  description = "A jsonencoded map of IAM policy document statements (key as sid)"
  type        = string
  default     = "{}"
}

variable "template_variables" {
  description = "A map of placeholder values to interpolate in the provided IAM policy statements"
  type        = any
  default     = {}
}


data "template_file" "statements" {
  template = var.statements
  vars     = var.template_variables
}


locals {
  statements = { for sid, statement in jsondecode(data.template_file.statements.rendered) : sid => {
    // This data structure matches the current terraform interface for IAM policy statements defined at
    // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document,
    // and provides sensible defaults for use with `for_each`.

    actions   = lookup(statement, "actions", [])
    resources = lookup(statement, "resources", [])

    effect = lookup(statement, "effect", "Allow") // incoming statements are "Allow" unless set explicitly

    not_actions   = lookup(statement, "not_actions", [])
    not_resources = lookup(statement, "not_resources", [])

    principals = [for principal in lookup(statement, "principals", []) : {
      type        = principal.type
      identifiers = principal.identifiers
    }]

    not_principals = [for not_principal in lookup(statement, "not_principals", []) : {
      type        = not_principal.type
      identifiers = not_principal.identifiers
    }]

    conditions = [for condition in lookup(statement, "conditions", []) : {
      test     = condition.test
      variable = condition.variable
      values   = condition.values
    }]

  } }
}


data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = local.statements

    content {
      sid       = statement.key
      actions   = statement.value.actions
      resources = statement.value.resources

      effect = statement.value.effect

      not_actions   = statement.value.not_actions
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}


// NOTE: This is effectively a no-op, since sts:GetCallerIdentity is always allowed, even when
// explicitly denied. See https://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html
//
// The circumstances when an iam policy is created without statements should be relatively rare.
data "aws_iam_policy_document" "default" {
  statement {
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}


output "document" {
  value = (
    jsondecode(data.aws_iam_policy_document.this.json).Statement == null
    ? data.aws_iam_policy_document.default.json
    : data.aws_iam_policy_document.this.json
  )
}

output "is_empty" {
  value = jsondecode(data.aws_iam_policy_document.this.json).Statement == null
}
