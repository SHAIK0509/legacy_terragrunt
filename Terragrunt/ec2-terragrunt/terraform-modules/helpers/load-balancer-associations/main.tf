variable "associations" {
  description = "A jsonencoded map of load balancer associations"
  type        = string
  default     = "{}"
}

locals {
  load_balancer_associations = { for name, attrs in jsondecode(var.associations) : name => {
    // required
    container_port = attrs.port

    // optional (unless noted, the default values represent AWS defaults)
    // See: https://github.com/legacydevteam/infrastructure-docs/blob/master/articles/aws/ecs/fargate/health-checks.md
    priority = lookup(attrs, "priority", null) // allows ordering of listener rules

    slow_start           = lookup(attrs, "slow_start", 0)
    deregistration_delay = lookup(attrs, "deregistration_delay", 30)

    source_ips           = lookup(attrs, "source_ips", [])
    host_headers         = lookup(attrs, "host_headers", [])
    http_headers         = lookup(attrs, "http_headers", [])
    path_patterns        = lookup(attrs, "path_patterns", [])
    query_strings        = lookup(attrs, "query_strings", [])
    http_request_methods = lookup(attrs, "http_request_methods", [])

    health_check_path                = lookup(attrs, "health_check_path", "/")
    health_check_timeout             = lookup(attrs, "timeout", 5)
    health_check_interval            = lookup(attrs, "interval", 30)
    health_check_matcher             = lookup(attrs, "matcher", 200)
    health_check_port                = lookup(attrs, "port", "traffic-port")
    health_check_protocol            = lookup(attrs, "protocol", "HTTP")
    health_check_healthy_threshold   = lookup(attrs, "healthy_threshold", 5)
    health_check_unhealthy_threshold = lookup(attrs, "unhealthy_threshold", 2)
  } }
}


output "associations" {
  value = local.load_balancer_associations
}

