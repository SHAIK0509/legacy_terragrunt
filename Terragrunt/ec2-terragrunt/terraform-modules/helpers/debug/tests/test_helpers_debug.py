#!/usr/bin/python
from assertpy import assert_that


def test_helpers_debug(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        assert_that(terraform).plan() \
            .succeeds_with_no_changes()
