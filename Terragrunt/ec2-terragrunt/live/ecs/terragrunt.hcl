# locals {
#   #############################################################################
#   # AUDIT AND UPDATE SETTINGS IN THIS SECTION FOR DEPLOYMENT
#   # update forced
#   // The amount of cpu and memory units the task should be allocated. In fargate,
#   // this must match aws sanctioned values described here:
#   // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
#   task_cpu    = 1024
#   task_memory = 4096

#   // The number of tasks to run for this service, by environment name. The special `default` key
#   // will be used when a key is not defined for the given deployment environment.
#   desired_count = {
#      dev     = 1
#      stage   = 4
#      prod    = 24
#      default = 0
#   }

#   // flag for autoscaling 1=yes, 0=no
#   do_autoscaling = {
#     dev     = 1
#     stage   = 1
#     prod    = 1
#     default = 0
#   }

#   max_capacity = {
#     dev     = 2
#     stage   = 40
#     prod    = 60
#     default = 2
#   }

#   min_capacity = {
#     dev     = 1
#     stage   = 4
#     prod    = 24
#     default = 1
#   }

#   scale_target = {
#     dev     = 40
#     stage   = 40
#     prod    = 25
#     default = 40
#   }

#   cooldown_secs = {
#     default = 15
#   }


#   // The name of the rds cluster this application will use, without environment prefix.
#   rds_cluster_name = "db302"

#   // The additional security groups that should be added to the running service,
#   // for example, the database client secgroup, etc.
#   security_groups = {
#      dev     = ["sg-08dc5a12705df69e9"]
# #     stage   = ["sg-0eff90d2b209b9624"]
#      stage   = ["sg-0afb112300904248b"]
# #     prod    = ["sg-0d498a0fd9f6aafb1"]
#      prod    = ["sg-0ba388fc3960d4f12"]
#      default = []
#   }

#   v2_account_id = {
#     dev      = "061584698956"
#     stage    = "268343188862"
#     prod     = "069119825720"
#     default  = ""
#   }

#   v3_account_id = {
#     dev      = "653506005559"
#     stage    = "497101153738"
#     prod     = "701768016072"
#     default  = ""
#   }

#   redis_node_type = {
#     prod    = "cache.m6g.large"
#     default = "cache.t3.micro"
#   }

#   external_domain = {
#     dev   = "oi.sb-legacy.com"
#     stage = "oi.pp-legacy.com"
#     prod  = "oi.prd-legacy.com"
#   }

#   // A map of sns topics to create for this application
#   sns_topics = {
#     "Obituary-Update" = {
#       display_name = ""
#       allow_publish_accounts = []
#       allow_subscribe_accounts = []
#       allow_subscribe_protocols = []
#     },
#     "Organization-Update" = {
#       display_name = ""
#       allow_publish_accounts = []
#       allow_subscribe_accounts = []
#       allow_subscribe_protocols = []
#     },
#     "Platform-Events" = {
#       display_name = ""
#       allow_publish_accounts = []
#       allow_subscribe_accounts = []
#       allow_subscribe_protocols = []
#     }
#   }



#   #############################################################################
#   service_name   = get_env("SERVICE_NAME", "obit-intake")
#   image_tag      = get_env("APP_BUILD_NUMBER", "latest")
#   environment    = get_env("ENVIRONMENT", "dev")
#   aws_account_id = get_env("AWS_ACCOUNT_ID", "")
#   hostname       = "${local.service_name}.${local.environment}.legint.net"
#   # scheduled_tasks = {
#   #    "obit-intake-populate-funeral-homes" = {
#   #       schedule_expression = "rate(1 hour)"
#   #       description = "hourly import of funeral home data from legacydb"
#   #       command = "[\"make\",\"populate-funeral-homes\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-populate-affiliates" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "daily import of affiliate data from legacydb"
#   #       command = "[\"make\",\"populate-affiliates\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-process-attr-auto-extract-queue" = {
#   #       schedule_expression = "rate(1 minute)"
#   #       description = "Extract data from text, process the new data for communities/text links/etc"
#   #       command = "[\"make\",\"CONCURRENCY_LIMIT=40\",\"LIMIT=100\",\"process-attribute-auto-extract-queue\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-update-location-data" = {
#   #       schedule_expression = "rate(24 hours)"
#   #       description = "Update location data based on driver provided by location-domain analysis"
#   #       command = "[\"make\",\"UPDATE_ENV=test\",\"DRY_RUN=1\",\"update-location-data\"]"
#   #       is_enabled = false
#   #    },
#   #    "obit-intake-community-person-inclusion" = {
#   #       schedule_expression = "rate(1 hour)"
#   #       description = "process changes in keyword normalizations and community rules"
#   #       command = "[\"make\",\"community-person-inclusion\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-new_active_1_process_obit_intake_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries"
#   #       command = "[\"make\",\"RUN_NAME='us-active-new-1'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-new_active_2_process_obit_intake_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries - dignitymemorial, batesville"
#   #       command = "[\"make\",\"RUN_NAME='us-active-new-2'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       # is_enabled = (local.environment == "prod" ? true : false )  <-- until ticket to fix legacydb-api not to pull empty obits
#   #       is_enabled = false
#   #    },
#   #    "obit-intake-new_active_3_process_obit_intake_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries"
#   #       command = "[\"make\",\"RUN_NAME='us-active-new-3'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-new_active_4_process_obit_intake_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries"
#   #       command = "[\"make\",\"RUN_NAME='us-active-new-4'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-archive_13_process_obit_intake_legacydb" = {
#   #       schedule_expression = "rate(10 minutes)"
#   #       description = "process legacydb obit intake job archive 13 - batesville, formerly tributes"
#   #       command = "[\"make\",\"RUN_NAME='us-all-archive-13'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = false
#   #    },
#   #    "obit-intake_new_active_canada_process_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries from Canadian affiliates"
#   #       command = "[\"make\",\"RUN_NAME='canada-active-new'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake_new_active_new_zealand_process_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries from New Zealand affiliates"
#   #       command = "[\"make\",\"RUN_NAME='new-zealand-active-new'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake_new_active_other_countries_process_legacydb" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "process legacydb obit intake job for new active obituaries from affiliates in countries other than US, CAN, or New Zealand"
#   #       command = "[\"make\",\"RUN_NAME='other-countries-active-new'\",\"process-obit-sources-legacydb-with-run-name\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-file-upload-sfmc-active-follows" = {
#   #       schedule_expression = "cron(0 13 * * ? *)"
#   #       description = "Generate the active follows listing and obituary files and ftp them to SFMC."
#   #       command = "[\"make\",\"process-active-follows-sfmc\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake_reindex-obits-aff-syndication-rules-changed" = {
#   #       schedule_expression = "rate(30 minutes)"
#   #       description = "A job to reindex obituaries when multi affiliate syndication rules are added or removed"
#   #       command = "[\"make\",\"process-multi-affiliate-syndication-rules-changed\"]"
#   #       is_enabled = (local.environment != "dev" ? true : false )
#   #    },
#   #    "obit-intake-calculate_owner_org_fh_counts" = {
#   #       schedule_expression = "cron(0 3 * * ? *)"
#   #       description = "nightly calculation of affiliate fh counts for endpoint"
#   #       command = "[\"make\",\"calculate-owner-org-fh-counts\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-refresh_modules_caches" = {
#   #       schedule_expression = "cron(30 3 * * ? *)"
#   #       description = "refresh caches related to Janus pages modules endpoints"
#   #       command = "[\"make\",\"refresh_modules_caches\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-move_obituary_data_to_sfmc" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "move obituary data from legacydb to sfmc"
#   #       command = "[\"make\",\"move-obituary-data-to-sfmc\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-move_guestbook_data_to_sfmc" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "move guestbook data from legacydb to sfmc"
#   #       command = "[\"make\",\"move-guestbook-data-to-sfmc\"]"
#   #       is_enabled = local.environment == "prod"
#   #    },
#   #    "obit-intake-move_service_data_to_sfmc" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "move service data from legacydb to sfmc"
#   #       command = "[\"make\",\"move-service-data-to-sfmc\"]"
#   #       is_enabled = local.environment == "prod"
#   #    },
#   #    "obit-intake-move_service_times_data_to_sfmc" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "move service times data from legacydb to sfmc"
#   #       command = "[\"make\",\"move-service-times-data-to-sfmc\"]"
#   #       is_enabled = local.environment == "prod"
#   #    },
#   #    "obit-intake-pull_unsubscribe_gb_entries_from_sfmc" = {
#   #       schedule_expression = "cron(30 * * * ? *)"
#   #       description = "pulls unsubscribe gb entries from SFMC and update legacydb"
#   #       command = "[\"make\",\"pull-unsubscribe-gb-entries-from-sfmc\"]"
#   #       is_enabled = local.environment == "prod"
#   #    },
#   #    "obit-intake-clean_community_person" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "cleaning up community person inclusions due to exclusion records"
#   #       command = "[\"make\",\"clean-community-person\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-process_community_person_updates" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "send updated community person records to legacydb"
#   #       command = "[\"make\",\"process-community-person-updates\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-purge-old-pipeline-request-json" = {
#   #       schedule_expression = "cron(0 23 * * ? *)"
#   #       description = "daily purge of oldest pipeline request json"
#   #       command = "[\"make\",\"purge-old-pipeline-request-json\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-process_legacy_person_id_updates" = {
#   #       schedule_expression = "rate(2 minutes)"
#   #       description = "get updated / new legacy person ids from legacydb for obituary"
#   #       command = "[\"make\",\"process-legacy-person-id-updates\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-process_search_index_update_queue" = {
#   #       schedule_expression = "rate(1 minute)"
#   #       description = "process queue to add/update/delete obituaries from search index"
#   #       command = "[\"make\",\"CONCURRENCY_LIMIT=10\", \"LIMIT=8000\", \"process-search-index-update-queue\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   #    "obit-intake-backfill_person_search_index" = {
#   #       schedule_expression = "rate(1 minute)"
#   #       description = "backfill person search index"
#   #       command = (local.environment == "stage" ? "[\"make\", \"CONCURRENCY_LIMIT=10\", \"SHOULD_OVERWRITE_DOCUMENTS=True\", \"LIMIT=8000\", \"MAX_PERSON_ID=18413949\", \"backfill-person-search-index\"]" : "[\"make\", \"CONCURRENCY_LIMIT=9\", \"SHOULD_OVERWRITE_DOCUMENTS=False\", \"LIMIT=8000\", \"MAX_PERSON_ID=59440307\", \"backfill-person-search-index\"]")
#   #       is_enabled = false
#   #    },
#   #    "obit-intake-backfill_person_group_index" = {
#   #       schedule_expression = "rate(24 hours)"
#   #       description = "backfill person group index"
#   #       command = "[\"make\",\"backfill-person-group-index\"]"
#   #       is_enabled = false
#   #    },
#   #    "obit-intake-process_obituary_template_text_queue" = {
#   #       schedule_expression = "rate(2 minutes)"
#   #       description = "process obituaries in AI template queue to generate the AI template and save"
#   #       command = "[\"make\",\"CONCURRENCY_LIMIT=5\", \"LIMIT=100\", \"process-obituary-template-text-queue\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-process_person_update_queue" = {
#   #       schedule_expression = "rate(2 minutes)"
#   #       description = "process updates to person data and save"
#   #       command = "[\"make\",\"CONCURRENCY_LIMIT=10\", \"LIMIT=15000\", \"process-person-update-queue\"]"
#   #       is_enabled = (local.environment != "dev" ? true : false )
#   #    },
#   #    "obit-intake-process_search_engine_index_queue" = {
#   #       schedule_expression = "rate(30 minutes)"
#   #       description = "process obituary updates in search engine index queue"
#   #       command = "[\"make\", \"process-search-engine-index-queue\"]"
#   #       is_enabled = (local.environment == "prod" ? true : false )
#   #    },
#   #    "obit-intake-process_obituary_updates_from_legacydb" = {
#   #       schedule_expression = "rate(5 minutes)"
#   #       description = "process obituary updates from legacydb"
#   #       command = "[\"make\", \"process-obituary-updates-from-legacydb\"]"
#   #       is_enabled = (local.environment != "dev" ? true : false )
#   #    },
#   #    "obit-intake-process_clio_updates_from_legacydb" = {
#   #       schedule_expression = "rate(60 minutes)"
#   #       description = "process clio updates from legacydb to Tukios and Notice Queue"
#   #       command = "[\"make\", \"process-clio-updates-from-legacydb\"]"
#   #       is_enabled = (local.environment != "dev" ? true : false )
#   #    },
#   #    "obit-intake-event_rvw_q_expirations" = {
#   #       schedule_expression = "rate(12 hours)"
#   #       description = "process event review queue expirations"
#   #       command = "[\"make\", \"process-event-review-queue-expirations\"]"
#   #       is_enabled = (local.environment != "dev" ? true : false )
#   #    },
#   #    "obit-intake-process_syndication_rule_updates" = {
#   #       schedule_expression = "rate(15 minutes)"
#   #       description = "send updated syndication rule records to legacydb"
#   #       command = "[\"make\",\"process-syndication-rules-synch-to-legacydb\"]"
#   #       is_enabled = (local.environment == "dev" ? false : true )
#   #    },
#   # }
#   gateways = {
#     "obit-intake" = {
#       set_params_for = []
#       external_users = {}
#       path_parts = []
#       external_users = {
#         "adn" = {
#           "burst_limit": 5000,
#           "rate_limit": 10000,
#         },
#         "adpay" = {
#           "burst_limit": 5000,
#           "rate_limit": 10000,
#         }
#       }
#     }
#     "organization" = {
#       path_parts = ["api", "organizations"]
#       set_params_for = []
#       external_users = {
#         "batesville" = {
#           "burst_limit": 500,
#           "rate_limit": 1000,
#         }
#       }
#     }
#   }
# }


# inputs = {
#   allowed_deployment_environments = "dev"

#   application_name = local.service_name
#   environment      = local.environment
#   aws_account_id   = local.aws_account_id

#   rds_cluster_name    = local.rds_cluster_name
#   postgres_extensions = ["hstore"]

#   do_autoscaling  = lookup(local.do_autoscaling, local.environment, local.do_autoscaling.default)
#   min_capacity    = lookup(local.min_capacity, local.environment, local.min_capacity.default)
#   max_capacity    = lookup(local.max_capacity, local.environment, local.max_capacity.default)
#   scale_target    = lookup(local.scale_target, local.environment, local.scale_target.default)
#   cooldown_secs   = lookup(local.cooldown_secs, local.environment, local.cooldown_secs.default)

#   sns_topics = local.sns_topics

#   redis_node_type  = lookup(local.redis_node_type, local.environment, local.redis_node_type.default)

#   security_groups = lookup(local.security_groups, local.environment, local.security_groups.default)
#   external_domain = lookup(local.external_domain, local.environment, local.external_domain.dev)

#   create_ecs_cluster = true
#   ecs_cluster_name   = "${local.environment}-${local.service_name}"

#   desired_count = lookup(local.desired_count, local.environment, local.desired_count.default)

#   container_definitions = [
#     {
#       name  = "app"
#       image = "$${ecr_domain}/${local.service_name}:${local.image_tag}"

#       portMappings = [{ containerPort = 80 }]

#       environment = {
#         ENVIRONMENT     = local.environment
#         AWS_REGION_NAME = "us-east-1"
#       }
#       ulimits = [{
#           name = "nofile",
#           softLimit = 50000,
#           hardLimit = 50000
#         }]

#     }
#   ]

#   task_cpu    = local.task_cpu
#   task_memory = local.task_memory

#   task_role = {
#     ObitIntakeSNSPublish = {
#       actions   = ["sns:Publish"]
#       resources = [
#         "arn:aws:sns:us-east-1:${lookup(local.v2_account_id, local.environment, local.v2_account_id.default)}:Platform-Events",
#         "arn:aws:sns:us-east-1:${lookup(local.v3_account_id, local.environment, local.v3_account_id.default)}:Platform-Events",
#         "arn:aws:sns:us-east-1:${lookup(local.v2_account_id, local.environment, local.v2_account_id.default)}:Obituary-Update",
#         "arn:aws:sns:us-east-1:${lookup(local.v3_account_id, local.environment, local.v3_account_id.default)}:Obituary-Update",
#         "arn:aws:sns:us-east-1:${lookup(local.v2_account_id, local.environment, local.v2_account_id.default)}:Organization-Update",
#         "arn:aws:sns:us-east-1:${lookup(local.v3_account_id, local.environment, local.v3_account_id.default)}:Organization-Update"

#       ]
#     },
#     ObitIntakeS3LegacyEnvObitIntake = {
#       actions   = [
#         "s3:PutObject",
#         "s3:ListBucket",
#         "s3:GetObject",
#         "s3:DeleteObject"
#       ]
#       resources = ["arn:aws:s3:::legacy-${local.environment}-obit-intake*"]
#     },
#     ObitIntakeS3Profiling = {
#       actions   = [
#         "s3:PutObject"
#       ]
#       resources = ["arn:aws:s3:::legacy-com-core-profiler-data*"]
#     },
#     ObitIntakeOpenSearch = {
#       actions   = [
#         "es:ESHttpDelete",
#         "es:ESHttpGet",
#         "es:ESHttpPut"
#       ]
#       resources = ["arn:aws:es:us-east-1:497101153738:domain/test"]
#     }
#   }

#   add_core_task_role_policy = true

#   health_check_grace_period_seconds = 60
#   load_balancer_associations = {
#     app = {
#       port              = 80
#       host_headers      = ["${local.hostname}"]
#       health_check_path = "/health"
#     }
#   }

#   log_retention_in_days = local.environment == "dev" ? 7 : 365

#   # scheduled_tasks = local.scheduled_tasks
#   gateways = local.gateways
#   create_redis = false

#   tags = {
#     Environment = local.environment
#     Platform    = "Django"
#     Product     = "Intake"
#   }

# }


# locals {
#   service_name   = get_env("SERVICE_NAME", "obit-intake")
#   image_tag      = get_env("APP_BUILD_NUMBER", "latest")
#   environment    = get_env("ENVIRONMENT", "dev")
#   aws_account_id = get_env("AWS_ACCOUNT_ID", "165446266030")
# } 

# inputs = {
#     create_ecs_cluster  = true
#     create_ecs_service  = false
#     create_postgres     = false
#     create_redis        = false
#     create_apigateway   = false
#     container_definitions = [
#     {
#       name  = "app"
#       image = "$${ecr_domain}/${local.service_name}:${local.image_tag}"

#       portMappings = [{ containerPort = 80 }]

#       environment = {
#         ENVIRONMENT     = local.environment
#         AWS_REGION_NAME = "us-east-1"
#       }
#       ulimits = [{
#           name = "nofile",
#           softLimit = 50000,
#           hardLimit = 50000
#         }]

#     }
#   ]

#   application_name = local.service_name
#   environment      = local.environment
#   aws_account_id   = local.aws_account_id
#   tags = {
#     Environment = local.environment
#     Platform    = "Django"
#     Product     = "Intake"
#   }
# }


# terraform {
#   # source = "git::ssh://git@github.com/legacydevteam/infrastructure-modules.git//deployment/fargate-application?ref=v0.0.222"
#   # source = "../../../ec2-terragrunt/terraform-modules/ecs/fargate-application"
# }

# remote_state {
#   backend = "s3"
#   config = {
#     encrypt        = true
#     bucket         = "my-demo-1234"
#     key            = "deployment/fargate/us-east-1/${local.environment}/${local.service_name}/terraform.tfstate"
#     region         = "us-east-1"
#     # dynamodb_table = "terraform-locks"
#   }
# }
# vim: ft=terraform


locals {
  service_name     = get_env("SERVICE_NAME", "obit-intake")
  image_tag        = get_env("APP_BUILD_NUMBER", "latest")
  environment      = get_env("ENVIRONMENT", "dev")
  aws_account_id   = get_env("AWS_ACCOUNT_ID", "165446266030")
  ecs_cluster_name = get_env("ECS_CLUSTER_NAME", "sampleCluster")
  hostname         = "${local.service_name}.${local.environment}.legint.net"
  # repo_root        = get_repo_root()
}


inputs = {
  create_ecs_cluster = true
  create_ecs_service = false
  create_postgres    = false
  create_redis       = false
  create_apigateway  = false
  scheduled_tasks = false
  load_balancer_associations = {
    app = {
      port              = 80
      host_headers      = ["${local.hostname}"]
      health_check_path = "/version"
    }
  }
  # --- ECS Container definition ---
  container_definitions = [
    {
      name  = "app"
      image = "$${ecr_domain}/${local.service_name}:${local.image_tag}"

      portMappings = [
        { containerPort = 80 }
      ]

      environment = {
        ENVIRONMENT     = local.environment
        AWS_REGION_NAME = "us-east-1"
      }

      ulimits = [
        {
          name      = "nofile"
          softLimit = 50000
          hardLimit = 50000
        }
      ]
    }
  ]

  # --- Variable mappings for Terraform module ---
  application_name = local.service_name
  environment      = local.environment
  aws_account_id   = local.aws_account_id
  ecs_cluster_name = local.ecs_cluster_name

  # --- Tags ---
  tags = {
    Environment = local.environment
    Platform    = "Django"
    Product     = "Intake"
  }
}

# terraform {
#   # Example local module source
#   source = "../../../ec2-terragrunt/terraform-modules/ecs/fargate-application"
# }

terraform {
  source = "${path_relative_from_include()}/../../../ec2-terragrunt/terraform-modules/ecs/fargate-application"
}


remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "my-demo-1234"
    key     = "deployment/fargate/us-east-1/${local.environment}/${local.service_name}/terraform.tfstate"
    region  = "us-east-1"
    # dynamodb_table = "terraform-locks"
  }
}
