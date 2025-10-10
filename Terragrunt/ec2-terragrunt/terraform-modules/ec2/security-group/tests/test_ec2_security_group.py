#!/usr/bin/env python
from assertpy import assert_that


def test_ec2_security_group_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()                    \
            .succeeds()                                  \
            .modifies_resources(add=3)                   \
            .creates_resource('aws_security_group_rule') \
            .with_arguments(to_port=8080)
