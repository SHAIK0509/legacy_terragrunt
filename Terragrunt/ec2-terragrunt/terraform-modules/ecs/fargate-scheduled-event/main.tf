/**
 * ## ecs/fargate-scheduled-event
 *
 * Module that creates scheduled events and rules to run in fargate containers
 *
 * Usage:
 *
 * module "scheduled_task" {
 *   source = "./modules/ecs/fargate-scheduled-event"
 *    application_name = test
 *    container_name = test
 *    environment = dev
 *    subnets = [ subnets ]
 *    aws_account_id = 999999999
 *    ecs_cluster_name = test
 *    task_definition_arn = ARN 
 *    security_groups = [sg-99999]
 *    scheduled_tasks = {
 *        "taskOne" = {
 *          schedule_expression = "rate(15 minutes)",
 *          description = "process legacyadn obit intake job"
 *          command = "[\"make\",\"process-obit-sources-legacyadn\"]"
 *          is_enabled = "true"
 *        }
 *        "taskTwo" = {
 *          schedule_expression = "rate(1 minute)"
 *          description = "task 2"
 *          command = "[\"do\", \"something\"]"
 *          is_enabled = "true"
 *        }
 *      }
 * }
 *
 *
 */

locals {
  ecs_cluster_name = (
    var.ecs_cluster_name == ""
    ? var.environment
    : var.ecs_cluster_name
  )

}

resource "aws_cloudwatch_event_rule" "rule" {
  for_each            = var.scheduled_tasks
  name                = each.key
  description         = var.scheduled_tasks[each.key].description
  is_enabled          = var.scheduled_tasks[each.key].is_enabled
  schedule_expression = var.scheduled_tasks[each.key].schedule_expression
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  for_each  = var.scheduled_tasks
  target_id = each.key
  arn       = "arn:aws:ecs:us-east-1:${var.aws_account_id}:cluster/${local.ecs_cluster_name}"
  rule      = aws_cloudwatch_event_rule.rule[each.key].name
  role_arn  = "arn:aws:iam::${var.aws_account_id}:role/ecsEventsRole"

  ecs_target {
    task_count          = 1
    task_definition_arn = var.task_definition_arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = true
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "${var.container_name}",
      "command": ${var.scheduled_tasks[each.key].command} 
    }
  ]
}
DOC
}


