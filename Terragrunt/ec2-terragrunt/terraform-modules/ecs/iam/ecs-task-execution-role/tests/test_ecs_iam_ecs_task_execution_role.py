#!/usr/bin/env python
from assertpy import assert_that


def test_ecs_iam_ecs_task_execution_role_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()                 \
            .succeeds()                               \
            .modifies_resources(add=3)                \
            .stdout_contains('arn:log:::whatever')    \
            .stdout_contains('arn:ecr:::whatever')    \
            .stdout_contains('/path/to/test/secret1') \
            .stdout_contains('/path/to/test/secret2') \
            .creates_resource('aws_iam_role')          \
            .with_arguments(name='test')
