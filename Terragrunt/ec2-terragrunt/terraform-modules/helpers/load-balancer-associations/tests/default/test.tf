module "load_balancer_associations" {
  source = "./modules/helpers/load-balancer-associations"

  associations = jsonencode({})
}


# output "<output-name>" {
#   value = module.load_balancer_associations.<output-name>
# }
