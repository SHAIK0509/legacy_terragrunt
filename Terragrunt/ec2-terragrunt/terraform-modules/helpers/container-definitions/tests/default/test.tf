module "container_definitions" {
  source = "./modules/helpers/container-definitions"

  container_definitions = jsonencode([{
    name  = "test"
    image = "$${ecr_url}/test:latest"
  }])

  template_variables = {
    ecr_url = "whatever"
  }
}

output "data" {
  value = module.container_definitions.data
}
