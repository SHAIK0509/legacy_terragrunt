#!/usr/bin/env python
import json

from assertpy import assert_that


def test_helpers_iam_policy_document_without_variables_success(terraform_fixture):
    with terraform_fixture('./without_variables') as terraform:
        assert_that(terraform).plan() \
            .succeeds_with_no_changes()


def test_helpers_iam_policy_document_with_variables_success(terraform_fixture):
    with terraform_fixture('./with_valid_variables') as terraform:
        policy = assert_that(terraform).plan()  \
                .succeeds()                     \
                .collect_outputs('policy_json')

        data = json.loads(policy)
        assert data['Statement'][0]['Resource'] == 'arn:aws:ecr:::whatever'


def test_helpers_iam_policy_document_with_variables_failure(terraform_fixture):
    with terraform_fixture('./with_invalid_variables') as terraform:
        assert_that(terraform).plan().fails()
