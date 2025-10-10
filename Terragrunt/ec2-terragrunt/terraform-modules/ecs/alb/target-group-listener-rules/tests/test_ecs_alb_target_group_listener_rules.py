#!/usr/bin/env python
from assertpy import assert_that


def test_ecs_alb_target_group_listener_rules_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan().succeeds_with_no_changes()


def test_ecs_alb_target_group_listener_rules_with_associations(terraform_fixture):
    with terraform_fixture('./with_associations') as terraform:
        associations = assert_that(terraform).plan()            \
            .succeeds()                                         \
            .modifies_resources(add=2)                          \
            .creates_resource('aws_lb_listener_rule')           \
            .with_arguments(listener_arn='arn:::test')          \
            .creates_resource('aws_lb_target_group')            \
            .with_arguments(vpc_id='vpc-xxx', name='test-test') \
            .collect_outputs('associations')

        assert associations.get('test', {}).get('host_headers', []) == ['test.example.com']
