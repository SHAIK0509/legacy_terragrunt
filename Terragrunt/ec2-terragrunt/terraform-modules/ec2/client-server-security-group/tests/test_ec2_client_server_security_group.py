#!/usr/bin/env python
from assertpy import assert_that


def test_ec2_client_server_security_group_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan()               \
            .succeeds()                             \
            .modifies_resources(add=5)              \
            .creates_resource('aws_security_group') \
            .with_arguments(name="test-client")     \
            .creates_resource('aws_security_group') \
            .with_arguments(name="test-server")


def test_ec2_client_server_security_group_with_client_server_rules(terraform_fixture):
    with terraform_fixture('./with_client_server_rules') as terraform:
        assert_that(terraform).plan()                    \
            .succeeds()                                  \
            .modifies_resources(add=7)                   \
            .creates_resource('aws_security_group_rule') \
            .with_arguments(to_port=8080, from_port=8080, source_security_group_id='sg-xxx')
