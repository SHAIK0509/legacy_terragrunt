## ecs/fargate-application

Module that deploys an application as an ecs service, with ancilary infrastructure such as efs  
volumes, load balancers and route53 records.

Usage:

module "application" {  
  source = "./modules/ecs/fargate-application"

  application\_name = "test"  
  environment      = "dev"

  container\_definitions = jsonencode([{  
    name  = "test"  
    image = "$${ecr\_url}/test:latest"
  }])
}

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application\_name | The name of the application to deploy | `string` | n/a | yes |
| assign\_public\_ip | Whether to assign a public ip address to this service | `bool` | `false` | no |
| aws\_ecr\_registry\_account\_profile | The name of the aws profile used to lookup ecr repositories for inclusion in the execution role | `string` | `"shared-services"` | no |
| cluster\_name | The name of the ecs cluster that will host this application | `string` | `null` | no |
| container\_definitions | A jsonencoded list of ECS Fargate container definitions | `string` | n/a | yes |
| create\_route53\_records | Whether to create route53 records from load balancer associations | `bool` | `false` | no |
| deployment\_maximum\_percent | The percentage of (desired\_count) tasks that can be running during deployment | `number` | `200` | no |
| deployment\_minimum\_healthy\_percent | The percentage of (desired\_count) running tasks for the service to be considered healthy | `number` | `100` | no |
| desired\_count | The number of tasks that should be running as part of this service | `number` | `1` | no |
| environment | The name of the environment to deploy | `string` | n/a | yes |
| health\_check\_grace\_period\_seconds | The time in seconds to ignore failing lb health checks on newly started tasks | `number` | `60` | no |
| kms\_arns | A list of kms arns that this task needs to decrypt secrets | `list(string)` | `[]` | no |
| load\_balancer\_associations | A map of maps, container name to lb target group and listener rule settings | `any` | `{}` | no |
| log\_retention\_in\_days | The number of days to retain logs streamed to the log group | `number` | `365` | no |
| platform\_version | The ECS Fargate platform version | `string` | `"LATEST"` | no |
| remote\_state\_paths | A map of names to paths relative to region/vpc-name | `map(string)` | `{}` | no |
| security\_group\_rules | A jsonencoded list of security group rules to associate with the service | `string` | `"[]"` | no |
| security\_groups | List of security group ids to associate with the service | `list(string)` | `[]` | no |
| tags | A map of custom tags to apply to the vpc and its related resources | `map(string)` | `{}` | no |
| task\_cpu | The CPU assignment for the ECS Fargate task | `number` | `256` | no |
| task\_memory | The MEMORY assignment for the ECS Fargate task | `number` | `512` | no |
| task\_role | The jsonencoded IAM policy rules (i.e. iam-role) to associate with the ECS Fargate task | `string` | `"{}"` | no |
| template\_variables | A map of placeholder values to interpolate in various helper module resources | `any` | `{}` | no |
| terraform\_state\_aws\_region | The AWS region of the S3 bucket used to store terraform remote state | `string` | `"us-east-1"` | no |
| terraform\_state\_s3\_bucket | The name of the S3 bucket used to store terraform remote state | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| log\_groups | n/a |
| service\_security\_group\_id | n/a |
| service\_task\_role\_arn | n/a |

