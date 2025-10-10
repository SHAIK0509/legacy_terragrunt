#!/usr/bin/env python
from assertpy import assert_that


def test_helpers_load_balancer_associations_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan().succeeds()
