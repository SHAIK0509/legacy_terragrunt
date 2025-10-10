#!/usr/bin/env python
from assertpy import assert_that


def test_helpers_container_definitions_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        data = assert_that(terraform).plan()    \
                    .succeeds() \
                    .collect_outputs('data')

        assert data[0]['image'] == 'whatever/test:latest'
