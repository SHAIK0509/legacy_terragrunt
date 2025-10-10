// NOTE: By accepting a jsonencoded string here, we avoid the terraform
//       type system and can process maps with different shapes.
variable "security_groups" {
  description = "A jsonencoded map of security group names -> settings"
  type        = string
  default     = "{}"
}

variable "add_default_egress_rules" {
  description = "Add a default (open) egress rule to each group when absent"
  type        = bool
  default     = true
}


locals {
  // Reshape groups with default values
  _security_groups = { for name, group in jsondecode(var.security_groups) : name => {
    // required
    vpc_id = group.vpc_id

    // optional
    // FIXME: The jsondecode here appears to be needed for terraform 0.12.17 alone, which has no `try()` function.
    rules = length(lookup(group, "rules", [])) > 0 ? [for rule in jsondecode(group.rules) : {
      // required within rules
      port = rule.port // replaces to_port and from_port

      // optional with defaults
      type     = lookup(rule, "type", "ingress")
      protocol = lookup(rule, "protocol", "tcp")

      // optional without defaults
      self                     = lookup(rule, "self", null)
      cidr_blocks              = lookup(rule, "cidr_blocks", null)
      source_security_group_id = lookup(rule, "source_security_group_id", null)
      // NOTE: this is a special custom attribute, used for lookup of the associated security group id by its name
      source_security_group_name = lookup(rule, "source_security_group_name", null)

      description = lookup(rule, "description", "Managed by terraform")
    }] : []
  } }

  // Add default egress for groups that do not define them if `add_default_egress_rules` is true.
  security_groups = (
    var.add_default_egress_rules
    ? { for name, group in local._security_groups : name => {
      vpc_id = group.vpc_id

      rules = (
        contains([for rule in group.rules : rule.type if rule.type == "egress"], "egress")
        ? group.rules
        : concat(
          group.rules, [{
            port                       = 0
            type                       = "egress"
            protocol                   = "all"
            self                       = null
            cidr_blocks                = ["0.0.0.0/0"]
            source_security_group_id   = null
            source_security_group_name = null
            description                = "Default egress rule managed by terraform"
          }]
        )
      )
    } }
    : local._security_groups
  )

  // Reshape and flatten individual rules, key'ed with a nicely formatted label for display in plan output
  security_group_rules = merge(flatten([[
    for name, attrs in local.security_groups : {
      for rule in attrs.rules : "${name}|${rule.type}|${rule.port == 0 ? "all" : rule.port}/${rule.protocol}" => merge(rule, {
        parent_security_group = name
      })
    }
  ]])...)
}

data "aws_security_group" "source_security_group" {
  for_each = { for name, rule in local.security_group_rules : name => rule if rule.source_security_group_name != null }

  name   = each.value.source_security_group_name
  vpc_id = local.security_groups[each.value.parent_security_group].vpc_id
}

output "security_groups" {
  value = local.security_groups
}

output "security_group_rules" {
  // NOTE: We're returning a data structure suitable for use with `aws_security_group_rule` resources,
  //       by injecting a value for `source_security_group_id` from a data source lookup of the
  //       value provided in the special `source_security_group_name` attribute, when present.
  value = { for name, rule in local.security_group_rules : name => (
    rule.source_security_group_name == null
    ? rule
    : merge(rule, { source_security_group_id = data.aws_security_group.source_security_group[name].id })
  ) }
}
