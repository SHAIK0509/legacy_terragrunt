output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}

output "aws_lb_sec_group_id" {
  value = aws_security_group.ext.id
}
