#!/usr/bin/env python
from assertpy import assert_that


def test_ecs_fargate_application_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()                     \
            .succeeds()                                   \
            .modifies_resources(add=11)                   \
            .creates_resource('aws_iam_role')             \
            .with_arguments(name='dev-test-task')         \
            .creates_resource('aws_cloudwatch_log_group') \
            .with_arguments(name='/ecs-fargate/dev/test') \
            .creates_resource('aws_ecs_task_definition')  \
            .with_arguments(family='dev-test')            \
            .creates_resource('aws_ecs_service')          \
            .with_arguments(cluster='dev')


def test_ecs_fargate_application_with_load_balancer_associations(terraform_fixture):
    with terraform_fixture('./with_load_balancer_associations') as terraform:
        assert_that(terraform).plan().succeeds() \
            .modifies_resources(add=14) \
            .creates_resource('aws_lb_listener_rule') \
            .creates_resource('aws_lb_target_group') \
            .with_arguments(name='dev-test-test')
