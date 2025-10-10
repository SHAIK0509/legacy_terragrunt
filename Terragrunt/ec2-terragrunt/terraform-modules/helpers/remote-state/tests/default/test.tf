module "remote_state" {
  source = "./modules/helpers/remote-state"


  relative_paths = {
    vpc = "vpc"
  }

  relative_from = "us-east-1/dev"

  terraform_state_aws_region = "us-east-1"
  terraform_state_s3_bucket  = "legacy-com-dev-terraform-state"
}

output "states" {
  value = module.remote_state.states
}
