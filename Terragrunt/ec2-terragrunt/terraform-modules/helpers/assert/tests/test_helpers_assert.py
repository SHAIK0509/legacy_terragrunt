#!/usr/bin/env python
from assertpy import assert_that


def test_helpers_assert_equals_success(terraform_fixture):
    with terraform_fixture('./equals_success') as terraform:
        assert_that(terraform).plan() \
            .succeeds_with_no_changes()


def test_helpers_assert_equals_failure(terraform_fixture):
    with terraform_fixture('./equals_failure') as terraform:
        assert_that(terraform).plan()  \
            .stderr_contains('assertion failure: <expected> == <actual>') \
            .fails()


def test_helpers_assert_contains_success(terraform_fixture):
    with terraform_fixture('./contains_success') as terraform:
        assert_that(terraform).plan() \
            .succeeds_with_no_changes()
