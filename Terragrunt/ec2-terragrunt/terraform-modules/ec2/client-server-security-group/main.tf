/*
 * ## ec2/client-server-security-group
 *
 * Creates a linked pair of security groups for use with resources that fit a client/server model.
 *
 * Usage:
 *
 * module "client_server_security_group" {
 *   source = "./modules/ec2/client-server-security-group"
 *
 *   name   = "test"
 *   vpc_id = "vpc-xxx"
 *
 *   ports = ["80/tcp"]
 * }
 *
 * module "client_server_security_group" {
 *   source = "./modules/ec2/client-server-security-group"
 *
 *   name   = "test"
 *   vpc_id = "vpc-xxx"
 *
 *   ports = ["80/tcp"]
 *
 *   client_rules = jsonencode([{
 *     port        = 8080
 *     cidr_blcoks = ["0.0.0.0/0"]
 *   }])
 *
 *   server_rules = jsonencode([{
 *     port                     = 8080
 *     source_security_group_id = "sg-xxx"
 *   }])
 * }
 */
variable "name" {
  description = "The name of the service/resource-group that will use this pair of security groups"
  type        = string
}

variable "vpc_id" {
  description = "The VPC id in which to create both security groups"
  type        = string
}

variable "ports" {
  description = "A list of ports with protocol that will be allowed from clients (e.g. 80/tcp, 53/udp, etc) in the server security group"
  type        = list(string)
}

variable "create" {
  description = "Whether to create resources defined in this module"
  type        = bool
  default     = true
}

variable "server_rules" {
  description = "Optional jsonencoded list of additional security group rules to apply to the server security group"
  type        = string
  default     = "[]"
}

variable "client_rules" {
  description = "Optional jsonencoded list of security group rules to apply to the client security group"
  type        = string
  default     = "[]"
}

variable "template_variables" {
  description = "A map of placeholder values that should be rendered in security-group rules"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map for tags to apply to resources created in this module"
  type        = map(string)
  default     = {}
}


locals {
  client_server_ports_and_protocols = { for value in var.ports : value => {
    port     = split("/", value).0
    protocol = split("/", value).1
  } }
}


module "client_security_group" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/security-group"

  name   = "${var.name}-client"
  vpc_id = var.vpc_id

  rules              = var.client_rules
  template_variables = var.template_variables
}


module "server_security_group" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/security-group"

  name   = "${var.name}-server"
  vpc_id = var.vpc_id

  rules              = var.server_rules
  template_variables = var.template_variables
}


resource "aws_security_group" "client" {
  count = var.create ? 1 : 0

  name = "${var.name}-client"

  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-client"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "server" {
  count = var.create ? 1 : 0

  name = "${var.name}-server"

  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-server"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "client" {
  for_each = var.create ? module.client_security_group.security_group_rules : {}

  security_group_id = aws_security_group.client.0.id

  to_port                  = each.value.port
  from_port                = each.value.port
  type                     = each.value.type
  protocol                 = each.value.protocol
  self                     = each.value.self
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  description              = each.value.description
}

resource "aws_security_group_rule" "server" {
  for_each = var.create ? module.server_security_group.security_group_rules : {}

  security_group_id = aws_security_group.server.0.id

  to_port                  = each.value.port
  from_port                = each.value.port
  type                     = each.value.type
  protocol                 = each.value.protocol
  self                     = each.value.self
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  description              = each.value.description
}

resource "aws_security_group_rule" "client_server" {
  for_each = var.create ? local.client_server_ports_and_protocols : {}

  type = "ingress"

  security_group_id = aws_security_group.server.0.id
  to_port           = each.value.port
  from_port         = each.value.port
  protocol          = each.value.protocol

  source_security_group_id = aws_security_group.client.0.id
}

output "client_security_group" {
  value = length(aws_security_group.client) > 0 ? aws_security_group.client.0 : null
}

output "server_security_group" {
  value = length(aws_security_group.server) > 0 ? aws_security_group.server.0 : null
}
