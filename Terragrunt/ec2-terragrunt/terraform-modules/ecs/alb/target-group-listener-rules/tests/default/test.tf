module "target_group_listener_rules" {
  source = "./modules/ecs/alb/target-group-listener-rules"

  load_balancer_associations = jsonencode({})

  load_balancer_listener_arn = "arn:::test"
  name                       = "test"
  vpc_id                     = "vpc-xxx"

  tags = {}
}


# output "<output-name>" {
#   value = module.target_group_listener_rules.<output-name>
# }
