variable "container_definitions" {
  type        = string
  description = "A json encoded list of container definitions (pass a data structure wrapped in jsonencode(...))"
  default     = "[]"
}

variable "command" {
  type        = list(string)
  description = "start up command for container def"
  default     = null
}

variable "template_variables" {
  description = "A map of placeholder values to interpolate in the rendered container_definitions"
  type        = any
  default     = {}
}

variable "default_log_configuration" {
  type = object({
    logDriver = string
    options   = map(string)
    secretOptions = list(object({
      name      = string
      valueFrom = string
    }))
  })

  default = null
}


data "template_file" "container_definitions" {
  template = var.container_definitions
  vars     = var.template_variables
}


locals {
  // Here we construct a list of maps from a much more concise input, injecting sensible defaults
  // for a fargate-based service. The resulting container definitions are given the default values
  // outlined in the AWS documentation, unless otherwise noted. For more information, see:
  // https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html
  container_definitions = [for container in jsondecode(data.template_file.container_definitions.rendered) : {
    // required attributes
    name  = container.name
    image = container.image

    // optional attributes
    repositoryCredentials = length(lookup(container, "repositoryCredentials", {})) > 0 ? {
      credentialsParameter = container.repositoryCredentials.credentialsParameter
    } : null

    cpu = lookup(container, "cpu", 0)

    memory            = lookup(container, "memory", null)
    memoryReservation = lookup(container, "memoryReservation", null)

    portMappings = [
      for mapping in lookup(container, "portMappings", []) : {
        containerPort = mapping.containerPort
        hostPort      = lookup(mapping, "hostPort", mapping.containerPort)
        protocol      = lookup(mapping, "protocol", "tcp") // a sensible default
    }]

    essential = lookup(container, "essential", true) // all tasks must have at least one essential container

    entryPoint       = lookup(container, "entryPoint", null)
    command          = var.command != null ? var.command : lookup(container, "command", null)
    workingDirectory = lookup(container, "workingDirectory", null)

    user       = lookup(container, "user", null)
    privileged = lookup(container, "privileged", false)

    ulimits = [for limit in lookup(container, "ulimits", []) : {
      name      = limit.name // fargate uses the image defaults for everything except `nofile`
      hardLimit = limit.hardLimit
      softLimit = limit.softLimit
    }]

    readonlyRootFilesystem = lookup(container, "readonlyRootFilesystem", false)

    mountPoints = [for mount in lookup(container, "mountPoints", []) : {
      sourceVolume  = mount.sourceVolume
      containerPath = mount.containerPath
      readOnly      = lookup(mount, "readOnly", false)
      // A custom attribute for assigning uid/gid perms to mounted EFS volumes when defined
      users = lookup(mount, "users", {}),
      // A custom attribute for configuring AWS Backup on EFS volumes automatically when defined
      backup_schedule = lookup(mount, "backup_schedule", ""),
    }]

    volumesFrom = [for volume in lookup(container, "volumesFrom", []) : {
      sourceContainer = volume.sourceContainer
      readOnly        = lookup(volume, "readOnly", false)
    }]

    dependsOn = (
      length(lookup(container, "dependsOn", [])) > 0
      ? [for dependency in lookup(container, "dependsOn", []) : {
        containerName = dependency.containerName
        condition     = dependency.condition
      }]
      : null
    )

    stopTimeout  = lookup(container, "stopTimeout", null)
    startTimeout = lookup(container, "startTimeout", null)

    healthCheck = length(lookup(container, "healthCheck", {})) > 0 ? {
      command     = lookup(container.healthCheck, "command", ["CMD-SHELL", "exit 0"])
      interval    = lookup(container.healthCheck, "interval", 30)
      timeout     = lookup(container.healthCheck, "timeout", 5)
      retries     = lookup(container.healthCheck, "retries", 3)
      startPeriod = lookup(container.healthCheck, "startPeriod", 60) // 0 is the ECS default
    } : null

    logConfiguration = length(lookup(container, "logConfiguration", {})) > 0 ? {
      logDriver = container.logConfiguration.logDriver
      options   = lookup(container.logConfiguration, "options", {})
      secretOptions = [for option in lookup(container.logConfiguration, "secretOptions", []) : {
        name      = option.name
        valueFrom = option.valueFrom
      }]
    } : var.default_log_configuration

    firelensConfiguration = length(lookup(container, "firelensConfiguration", {})) > 0 ? {
      type    = container.firelensConfiguration.type
      options = lookup(container.firelensConfiguration, "options", {})
    } : null

    dockerLabels = lookup(container, "dockerLabels", {})

    // FIXME: If we ever need to pass linuxParameters to multiple containers in a task definition,
    //        and the maps have a different shape, this will likely result in a type mismatch. In that
    //        case, we should expand this section to include all of the likely to be used parameters.
    //        Currently, the only planned usage is `initProcessEnabled`, which is adventageous for
    //        killing zombie ssm remote command management procs.
    linuxParameters = lookup(container, "linuxParameters", {})

    // The AWS API expects the `environment` and `secrets` attributes to have the shape of
    // `{ name  = "ENV_VAR_1", value = "value" }` and `{ name = "ENV_VAR_1", valueFrom = "ssm:arn" }`,
    // respectively. Instead we allow the form `{ ENV_VAR_1 = "value" }` to simplify configuration,
    // and reshape the data for the API.
    environment = [for k, v in lookup(container, "environment", {}) : { name = k, value = v }]
    secrets     = [for k, v in lookup(container, "secrets", {}) : { name = k, valueFrom = v }]

    // Similarly, `extraHosts` is expected to have the keys `hostname` and `ipAddress`, instead we
    // accept input in the form `{ "somehost.domain" = "127.0.0.1" }`.
    extraHosts = [for k, v in lookup(container, "extraHosts", []) : { hostname = k, ipaddress = v }]

  }]
}


output "data" {
  value = local.container_definitions
}

output "json" {
  value = jsonencode(local.container_definitions)
}
