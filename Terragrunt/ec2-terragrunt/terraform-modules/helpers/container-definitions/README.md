# container-definitions

This helper module simplifies generating proper container definitions for ECS Fargate services by providing
sensible default values and a consistent data structure shape (important to terraform's type system).

## Example

```hcl
module "container_definitions" {
    source = "./"

    container_definitions = jsonencode([{
        name = "test"
        image = "hello-world"
    }])
}

output "container_definitions" {
  value = module.container_definitions.data
}

output "jsonencoded" {
  value = module.container_definitions.json
}
``

```sh
$ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

container_definitions = [
  {
    "dependsOn" = []
    "dockerLabels" = {}
    "environment" = []
    "essential" = true
    "extraHosts" = []
    "image" = "hello-world"
    "mountPoints" = []
    "name" = "test"
    "portMappings" = []
    "privileged" = false
    "readonlyRootFilesystem" = false
    "secrets" = []
    "ulimits" = []
    "volumesFrom" = []
  },
]
jsonencoded = [{"command":null,"cpu":null,"dependsOn":[],"dockerLabels":{},"entryPoint":null,"environment":[],"essential":true,"extraHosts":[],"firelensConfiguration":null,"healthCheck":null,"image":"hello-world","logConfiguration":null,"memory":null,"memoryReservation":null,"mountPoints":[],"name":"test","portMappings":[],"privileged":false,"readonlyRootFilesystem":false,"secrets":[],"startTimeout":null,"stopTimeout":null,"ulimits":[],"user":null,"volumesFrom":[],"workingDirectory":null}]

```
