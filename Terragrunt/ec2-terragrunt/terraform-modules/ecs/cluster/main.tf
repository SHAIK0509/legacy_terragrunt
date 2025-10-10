/**
 * ## ecs/cluster
 *
 * Module that creates an ECS cluster without the baggage.
 *
 */
variable "name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Whether to enable container insights for this cluster"
  type        = bool
  default     = false
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  dynamic "setting" {
    for_each = var.enable_container_insights ? ["enabled"] : []

    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }
}

output "cluster" {
  value = aws_ecs_cluster.this
}
