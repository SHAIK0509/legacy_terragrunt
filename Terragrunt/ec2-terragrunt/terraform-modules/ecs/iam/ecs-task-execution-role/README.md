# ecs-task-execution-role

Semi-automatically defines an ECS task execution IAM role (task startup) suitable for use with ECS
Fargate, to automatically establish permission to access service-specific cloudwatch logs, ecr repos,
parameter store and secrets manager secrets and the KMS crypto resources necessary to decrypt them.
