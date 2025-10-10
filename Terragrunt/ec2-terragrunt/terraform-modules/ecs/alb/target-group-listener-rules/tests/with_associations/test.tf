module "target_group_listener_rules" {
  source = "./modules/ecs/alb/target-group-listener-rules"

  load_balancer_associations = jsonencode({
    test = {
      port         = 9000
      host_headers = ["test.example.com"]
    }
  })

  load_balancer_listener_arn = "arn:::test"
  name                       = "test"
  vpc_id                     = "vpc-xxx"

  tags = {}
}

output "associations" {
  value = module.target_group_listener_rules.associations
}
