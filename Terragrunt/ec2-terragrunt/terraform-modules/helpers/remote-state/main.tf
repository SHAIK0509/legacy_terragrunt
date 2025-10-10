/*
 * ## helpers/remote-state
 *
 * This helper module reduces the amount of terraform code one must write to utilize remote state
 * outputs from multiple terragrunt hierarchies.
 *
 * ### Usage
 *
 * We accept input in two forms, `regular` and `relative`. The `regular` form expects a value in the
 * `paths` input. For example,
 *
 *
 * ```hcl
 * # terragrunt.hcl
 * inputs = {
 *     paths = {
 *         vpc = "us-east-1/dev/vpc"
 *         lb = "us-east-1/dev/networking/alb-internal"
 *     }
 * }
 * ```
 *
 * While, the `relative` form expects values for both `relative_paths` and `relative_from`. If one is
 * missing or empty, an error is raised on apply. The `relative` form would look something like this:
 *
 * ```hcl
 * # terragrunt.hcl
 * inputs = {
 *     relative_paths = {
 *         vpc = "vpc"
 *         lb = "networking/alb-internal"
 *     }
 *     relative_from = "us-east-1/dev"
 * }
 * ```
 * ... or similarly ...
 *
 * ```hcl
 * # us-east-1/dev/applications/hubot/terragrunt.hcl
 * inputs = {
 *     relative_paths = {
 *         vpc = "../../vpc"
 *         lb = "../../networking/alb-internal"
 *     }
 *     relative_from = path_relative_to_include()
 * }
 * ```
 *
 * ### Advanced usage
 *
 * The `required` input takes a list of keys that are expected to exist by the calling module,
 * resulting in an error during applies, if not the case, thus short circuiting an apply that cannot
 * complete. Its purpose is to validate the proper configuration of the calling module, and avoid a
 * commonly difficult to troubleshoot condition. With `regular` form, one might use `required` in the following way:
 *
 * ```hcl
 * # main.tf
 * module "remote" {
 *     source = "./"
 *
 *     paths = var.remote_state_paths
 *     required = ["vpc", "lb"]
 * }
 * ```
 *
 * Although, `required` works the same way regardless of the form employed, `regular` or `relative`,
 * or both at once.
 *
 */

# variable "paths" {
#   description = "A map of state-name to 'dirname' path of the remote state key in s3"
#   type        = map(string)
#   default     = {}
# }

# variable "relative_paths" {
#   description = "A map of state-name to relative path, relative to `relative_from`"
#   type        = map(string)
#   default     = {}
# }

# variable "relative_from" {
#   description = "The base path of all `relative_path`s provided as input"
#   type        = string
#   default     = ""
# }

# variable "required" {
#   description = "The list of keys (basename of the remote state) that are expected to exist by the calling module"
#   type        = list(string)
#   default     = []
# }

# variable "terraform_state_aws_region" {
#   description = "The AWS region of the S3 bucket used to store Terraform remote state"
#   type        = string
# }

# variable "terraform_state_s3_bucket" {
#   description = "The name of the S3 bucket used to store Terraform remote state"
#   type        = string
# }


# locals {
#   // NOTE: We're taking advantage of the behavior of the terraform `dirname` function,
#   //       for normalizing relative paths (ex. dev/us-east-1/dev/services/hubot/../../vpc -> dev/us-east-1/dev/vpc)
#   normalized_relative_paths = { for name, path in var.relative_paths : name => "${dirname("${trim(var.relative_from, "/")}/${path}")}/${basename(path)}" }

#   // `paths` takes precedence over matching keys in `relative_paths`.
#   paths = { for name, path in merge(local.normalized_relative_paths, var.paths) : name => "${trim(path, "/")}/terraform.tfstate" }

#   // only used when var.required contains keys to verify
#   // mimics the setsubtract function, which is not available in terraform 0.12.17
#   missing_keys = [for key in var.required : key if ! contains(keys(local.paths), key)]

#   missing_in_s3 = [for name, output in data.external.exists : output.result.status if output.result.status != "ok"]
# }


# module "assert_relative_from_is_present_with_relative_paths" {
#   source = "../assert"

#   expected = var.relative_from != ""
#   actual   = length(var.relative_paths) > 0

#   errors = {
#     equals = "assertion failure: `relative_from` (${var.relative_from}) variable is required with `relative_paths` (count: ${length(var.relative_paths)})"
#   }
# }


# module "assert_required_remote_state_keys_are_present" {
#   source = "../assert"

#   expected = 0
#   actual   = var.required == [] ? 0 : length(local.missing_keys)

#   errors = {
#     equals = "assertion failure: configuration error missing required keys: ${join(", ", local.missing_keys)}"
#   }
# }


# module "assert_all_remote_state_keys_exist" {
#   source = "../assert"

#   expected = 0
#   actual   = length(local.missing_in_s3)

#   errors = {
#     equals = "assertion failure: one or more remote states were not present in s3:\n ===> ${join("\n ===> ", local.missing_in_s3)}"
#   }
# }

# data "external" "exists" {
#   for_each = local.paths

#   program = ["${path.module}/check-if-s3-object-exists.sh", var.terraform_state_aws_region, var.terraform_state_s3_bucket, each.value]
# }


# data "terraform_remote_state" "state" {
#   for_each = local.paths

#   backend = "s3"

#   config = {
#     region = var.terraform_state_aws_region
#     bucket = var.terraform_state_s3_bucket
#     key    = each.value
#   }
# }


# output "states" {
#   description = "A map of collected remote state data"
#   value       = { for name, state in data.terraform_remote_state.state : name => state.outputs }
# }
