#!/usr/bin/env python
from assertpy import assert_that


def test_ecs_fargate_task_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()                    \
            .succeeds()                                  \
            .modifies_resources(add=8)                   \
            .creates_resource('aws_ecs_task_definition') \
            .with_arguments(tags={'Name': 'test'})
