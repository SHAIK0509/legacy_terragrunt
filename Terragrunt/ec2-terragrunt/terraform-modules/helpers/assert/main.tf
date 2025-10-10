/**
 * ## helpers/assert
 *
 * Terraform's existing input validation is rather inflexible and does not provide a mechanism for
 * custom error handling or messaging. This module leverages the `jq` program for this purpose.
 *
 * This approach was shamelessly stolen from https://github.com/ahl/terrassert with slight
 * modifications.
 *
 * Usage:
 *
 * ```hcl
 * // check that an input list is of an expected length
 * module "assert_input_has_2_subnets" {
 *   source = "../helpers/assert"
 *
 *   actual   = length(var.subnets)
 *   expected = 2
 * }
 * ```
 *
 */
variable "actual" {
  description = "The actual value to be checked"
  type        = string
}

variable "expected" {
  description = "The expected value to be compared with actual"
  type        = string
}

variable "condition" {
  description = "The type of check to perform, 'equals', 'contains'"
  type        = string
  default     = "equals"
}

variable "errors" {
  description = "A map of assertion errors to display if an assertion fails (dollar signs must be escaped with `$$`)"
  type        = map(string)

  default = {
    equals   = "assertion failure: <expected> == <actual>\n  expected: $${expected}\n  actual:   $${actual}"
    contains = "assertion failure: <actual> contains <expected>\n  expected: $${expected}\n  actual:   $${actual}"
  }
}

locals {
  expressions = {
    equals = <<EXPR
      if .actual == .expected then
        {"status": "ok"}
      else
        error("${data.template_file.error.rendered}")
      end
EXPR

    contains = <<EXPR
      .expected as $expected | if .actual | contains($expected) then
        {"status": "ok"}
      else
        error("${data.template_file.error.rendered}")
      end
EXPR

    default = <<EXPR
    error("${data.template_file.error.rendered}")
EXPR
  }

  check         = lookup(local.expressions, var.condition, local.expressions.default)
  default_error = "invalid assertion: condition '$${condition}' not in [equals, contains]"
}


data "external" "assert" {
  program = ["jq", local.check]

  query = {
    actual   = var.actual
    expected = var.expected
  }
}

data "template_file" "error" {
  template = lookup(var.errors, var.condition, local.default_error)

  vars = {
    actual    = var.actual
    expected  = var.expected
    condition = var.condition
  }
}


output "status" {
  value = data.external.assert.result.status
}
