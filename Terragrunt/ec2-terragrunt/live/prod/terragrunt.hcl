include {
  path = find_in_parent_folders()
}


terraform {
  source = "../../../terraform-modules/ec2/"
}

inputs = {
  aws_region    = "us-east-1"
  ami_id        = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  instance_name = "TerragruntEC2-Staging"
}
