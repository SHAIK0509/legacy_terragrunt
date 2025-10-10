/*
 * ## helpers/security-group
 *
 * Helper module that facilitates the generation of a security group, with sensible default values,
 * and automatic source_security_group id lookup, by security-group name.
 *
 * By default, an egress rule (full outbound) is added if not other egress rule is provided in
 * in the `rules` input.
 *
 * Usage:
 *
 * module "security_group" {
 *   source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/security-group"
 *
 *   name   = "dev-test"
 *   vpc_id = "vpc-xxx"
 *
 *   rules = jsonencode([{
 *     port = 80
 *     self = true
 *   }])
 * }
 *
 */
variable "name" {
  description = "The name for the security-group to be created"
  type        = string
}

variable "vpc_id" {
  description = "The vpc id in which this security-group will be created"
  type        = string
}

variable "rules" {
  description = "A jsonencoded list of rules to include in the created security-group"
  type        = string
  default     = "[]"
}

variable "template_variables" {
  description = "A map of placeholder values that should be rendered in security-group rules"
  type        = map(string)
  default     = {}
}

variable "add_default_egress_rules" {
  description = "Add a default (open) egress rule to each group when no other is defined"
  type        = bool
  default     = true
}


variable "default_egress_rules" {
  description = "The default egress rules to add if `add_default_egress_rules` is set to true (the default)"

  type = list(object({
    port                       = number
    type                       = string
    protocol                   = string
    description                = string
    self                       = bool
    cidr_blocks                = list(string)
    source_security_group_id   = string
    source_security_group_name = string
    unique_name                = string
  }))

  default = [{
    port                       = 0
    type                       = "egress"
    protocol                   = "all"
    description                = "Default egress rule managed by terraform"
    self                       = null
    cidr_blocks                = ["0.0.0.0/0"]
    source_security_group_id   = null
    source_security_group_name = null
    unique_name                = "default|egress|all/all"
  }]
}


data "template_file" "rules" {
  template = var.rules
  vars     = var.template_variables
}


locals {
  // Reshape rule with sensible default values
  _rules = [for rule in jsondecode(data.template_file.rules.rendered) : {
    // required
    port = rule.port

    // optional with defaults
    type                     = lookup(rule, "type", "ingress")
    protocol                 = lookup(rule, "protocol", "tcp")
    description              = lookup(rule, "description", "Managed by terraform")
    self                     = lookup(rule, "self", null)
    cidr_blocks              = lookup(rule, "cidr_blocks", null)
    source_security_group_id = lookup(rule, "source_security_group_id", null)

    //NOTE: This is a custom attribute used to lookup the associated source
    //      security-group id by its given name.
    source_security_group_name = lookup(rule, "source_security_group_name", null)

    // NOTE: This is a custom attribute used to uniquely identify terraform security
    //       group rule resources.
    unique_name = join("", [
      "${var.name}|${lookup(rule, "type", "ingress")}|",
      "${rule.port == 0 ? "all" : rule.port}/${lookup(rule, "protocol", "tcp")}",
    ])
  }]

  rules = (
    var.add_default_egress_rules && ! contains([for rule in local._rules : rule.type if rule.type == "egress"], "egress")
    ? concat(local._rules, var.default_egress_rules)
    : local._rules
  )
}



data "aws_security_group" "source_security_group" {
  for_each = { for rule in local.rules : rule.unique_name => {
    source_security_group_name = rule.source_security_group_name
  } if rule.source_security_group_name != null }

  name   = each.value.source_security_group_name
  vpc_id = var.vpc_id
}


output "security_group_rules" {
  // NOTE: Here we're returning a data structure suitable for use with `aws_security_group_rule`
  //       resources, by injecting a value for `source_security_group_id` from a data source
  //       lookup of the value provided in the special `source_security_group_name` attribute,
  //       when present.
  //
  //       The reason this is done in the output, and not locals above, is that terraform can
  //       sometimes fail at order of operations when locals are involved; and if this runs into
  //       problems down the road we can add an explicit `depends_on` to this block.
  value = { for rule in local.rules : rule.unique_name => (
    rule.source_security_group_name == null
    ? rule
    : merge(rule, { source_security_group_id = data.aws_security_group.source_security_group[rule.unique_name].id })
  ) }
}
