/**
 * ## ec2/security-group
 *
 * Module to create a security group and rules from given inputs.
 *
 * Usage:
 *
 * module "security_group" {
 *   source = "../module/helpers/security-group"
 *
 *   name   = "test"
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
  description = "The name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The AWS VPC id in which to create this security group"
  type        = string
}

variable "rules" {
  description = "A jsonencoded list of rules to associate with the security group"
  default     = "[]"
}

variable "template_variables" {
  description = "A map of placeholder values that should be rendered in security-group rules"
  type        = map(string)
  default     = {}
}

variable "add_default_egress_rules" {
  description = "Add a default (open) egress rule when not provided in `rules`"
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

variable "tags" {
  description = "A map of tags to apply to resources created in this module"
  type        = map
  default     = {}
}


module "security_group" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/security-group"

  name   = var.name
  vpc_id = var.vpc_id

  rules                    = var.rules
  template_variables       = var.template_variables
  add_default_egress_rules = var.add_default_egress_rules
  default_egress_rules     = var.default_egress_rules
}


resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_security_group_rule" "this" {
  for_each = module.security_group.security_group_rules

  security_group_id = aws_security_group.this.id

  to_port                  = each.value.port
  from_port                = each.value.port
  type                     = each.value.type
  protocol                 = each.value.protocol
  self                     = each.value.self
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  description              = each.value.description
}

output "security_group" {
  value = aws_security_group.this
}
