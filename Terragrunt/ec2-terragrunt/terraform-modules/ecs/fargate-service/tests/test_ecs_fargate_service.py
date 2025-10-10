#!/usr/bin/env python
from assertpy import assert_that


def test_ecs_fargate_service_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()            \
            .succeeds()                          \
            .modifies_resources(add=9)           \
            .creates_resource('aws_ecs_service') \
            .with_arguments(launch_type='FARGATE')


def test_ecs_fargate_service_with_load_balancer_associations(terraform_fixture):
    with terraform_fixture('./with_load_balancer_associations') as terraform:
        assert_that(terraform).plan().succeeds() \
            .modifies_resources(add=11) \
            .creates_resource('aws_lb_listener_rule') \
            .with_arguments(listener_arn='arn:::lb') \
            .creates_resource('aws_lb_target_group') \
            .with_arguments(name='test-service-test')
