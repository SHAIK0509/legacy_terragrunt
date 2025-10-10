locals {
  #############################################################################
  # AUDIT AND UPDATE SETTINGS IN THIS SECTION FOR DEPLOYMENT
  # update forced
  // The amount of cpu and memory units the task should be allocated. In fargate,
  // this must match aws sanctioned values described here:
  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  task_cpu    = 1024
  task_memory = 2048

  // The number of tasks to run for this service, by environment name. The special `default` key
  // will be used when a key is not defined for the given deployment environment.
  desired_count = {
    dev     = 1
    stage   = 1
    prod    = 3
    default = 0
  }

  // flag for autoscaling 1=yes, 0=no
  do_autoscaling = {
    dev     = 1
    stage   = 1
    prod    = 1
    default = 0
  }

  max_capacity = {
    dev     = 2
    stage   = 2
    prod    = 5
    default = 2
  }

  min_capacity = {
    dev     = 1
    stage   = 1
    prod    = 3
    default = 1
  }

  scale_target = {
    dev     = 65
    stage   = 65
    prod    = 65
    default = 10
  }

  security_groups = {
    dev = ["sg-0fed1ee1eef14c567"]
    stage = ["sg-00e9bc43348a6dfd9"]
    prod  = ["sg-0e58c7e63b731cc4b"]
    default = []
  }

  external_domain = {
    dev   = "lai.sb-legacy.com"
    stage = "lai.pp-legacy.com"
    prod  = "lai.prd-legacy.com"
    default = ""
  }



  #############################################################################
  service_name   = get_env("SERVICE_NAME", "auth_depot")
  image_tag      = get_env("APP_BUILD_NUMBER", "latest")
  environment    = get_env("ENVIRONMENT", "dev")
  aws_account_id = get_env("AWS_ACCOUNT_ID", "")
  hostname       = "${local.service_name}.${local.environment}.legint.net"
}

inputs = {
  allowed_deployment_environments = ["dev", "stage", "prod"]

  application_name = local.service_name
  environment      = local.environment
  aws_account_id   = local.aws_account_id

  do_autoscaling  = lookup(local.do_autoscaling, local.environment, local.do_autoscaling.default)
  min_capacity    = lookup(local.min_capacity, local.environment, local.min_capacity.default)
  max_capacity    = lookup(local.max_capacity, local.environment, local.max_capacity.default)
  scale_target    = lookup(local.scale_target, local.environment, local.scale_target.default)
  security_groups = lookup(local.security_groups, local.environment, local.security_groups.default)
  external_domain = lookup(local.external_domain, local.environment, local.external_domain.default)

  cidr_block = "192.168.0.0/16"

  create_ecs_cluster = true
  ecs_cluster_name   = "${local.environment}-${local.service_name}"

  desired_count = lookup(local.desired_count, local.environment, local.desired_count.default)

  container_definitions = [
    {
      name  = "app"
      image = "$${ecr_domain}/${local.service_name}:${local.image_tag}"

      portMappings = [{ containerPort = 80 }]

      environment = {
        ENVIRONMENT     = local.environment
        APP_ENV         = local.environment
        AWS_REGION_NAME = "us-east-1"
      }
      ulimits = [{
          name = "nofile",
          softLimit = 20000,
          hardLimit = 20000
        }]

    }
  ]

  task_cpu    = local.task_cpu
  task_memory = local.task_memory

  task_role = jsonencode({
    LegacyOpenAIS3Profiling = {
      actions   = [
        "s3:PutObject"
      ]
      resources = ["arn:aws:s3:::legacy-com-core-profiler-data*"]
    },
    AWSBedrockFullAccess = {
      actions = [
        "bedrock:*"
        ]
        resources = ["*"]
    }
  })

  add_core_task_role_policy = true

  health_check_grace_period_seconds = 59
  load_balancer_associations = {
    app = {
      port              = 80
      host_headers      = ["${local.hostname}"]
      health_check_path = "/version"
    }
  }

  log_retention_in_days = local.environment == "dev" ? 7 : 365

  create_redis = false

  tags = {
    Environment = local.environment
    Platform    = "Django"
    Product     = "OpenAI"
  }
}

terraform {
  source = "git::ssh://git@github.com/legacydevteam/infrastructure-modules.git//deployment/fargate-application?ref=v0.0.222"
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "legacy-com-${local.environment}-terraform-state"
    key            = "deployment/fargate/us-east-1/${local.environment}/${local.service_name}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}