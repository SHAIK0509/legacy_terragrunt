variable "name" {
  description = "The name given to resources created in this module"
  type        = string
}

variable "vpc_id" {
  description = "The id of the vpc in which the load balancer listener resides"
  type        = string
}

variable "load_balancer_listener_arn" {
  description = "The arn of the load balancer listener where we will attach rules"
  type        = string
}

variable "load_balancer_associations" {
  description = "A jsonencoded map of maps, container name to lb target group and listener rule settings"
  type        = string
  default     = "{}"
}

variable "tags" {
  description = "A map of tags to be added to resources created in this module"
  type        = map(string)
  default     = {}
}



module "load_balancer_associations" {
  source = "..//Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/load-balancer-associations"

  associations = var.load_balancer_associations
}


resource "aws_lb_target_group" "this" {
  for_each = module.load_balancer_associations.associations

  // unfortunately the aws api has a hard limit at 32 characters for the name
  // ideally we could reference the service name and the container name here, but alas ¯\_(ツ)_/¯
  // name   = substr("${var.name}-${index(keys(module.load_balancer_associations.associations), each.key)}", 0, 32)
  name   = substr("${var.name}-${each.key}", 0, 32)
  vpc_id = var.vpc_id

  port        = "80" // FIXME: This always works, but why? Find the documentation. Is this the port the lb sends traffic to the target group?
  protocol    = "HTTP"
  target_type = "ip"

  slow_start           = each.value.slow_start
  deregistration_delay = each.value.deregistration_delay

  health_check {
    protocol = each.value.health_check_protocol
    port     = each.value.health_check_port

    path                = each.value.health_check_path
    matcher             = each.value.health_check_matcher
    timeout             = each.value.health_check_timeout
    interval            = each.value.health_check_interval
    healthy_threshold   = each.value.health_check_healthy_threshold
    unhealthy_threshold = each.value.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = module.load_balancer_associations.associations

  listener_arn = var.load_balancer_listener_arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  dynamic "condition" {
    for_each = length(each.value.source_ips) > 0 ? [each.value.source_ips] : []

    content {
      source_ip {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.path_patterns) > 0 ? [each.value.path_patterns] : []


    content {
      path_pattern {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.host_headers) > 0 ? [each.value.host_headers] : []

    content {
      host_header {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.http_request_methods) > 0 ? [each.value.http_request_methods] : []

    content {
      http_request_method {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.query_strings

    content {
      dynamic "query_string" {
        for_each = condition.value

        content {
          key   = query_string.key
          value = query_string.value
        }
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.http_headers

    content {
      dynamic "http_header" {
        for_each = condition.value

        content {
          http_header_name = http_header.key
          values           = http_header.value
        }
      }
    }
  }
}

output "associations" {
  value = module.load_balancer_associations.associations
}

output "target_groups" {
  value = aws_lb_target_group.this
}

output "load_balancer_listener_rules" {
  value = aws_lb_listener_rule.this
}
