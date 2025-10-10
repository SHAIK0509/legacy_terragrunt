#!/usr/bin/env python
from assertpy import assert_that


def test_helpers_remote_state_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        states = assert_that(terraform).plan() \
            .succeeds()                        \
            .modifies_resources(add=0)         \
            .collect_outputs('states')

        assert states['vpc']['vpc_name'] == 'dev'
