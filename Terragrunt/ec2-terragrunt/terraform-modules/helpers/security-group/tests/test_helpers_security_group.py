#!/usr/bin/env python
from assertpy import assert_that


def test_helpers_security_group_default(terraform_fixture):
    with terraform_fixture('./default') as terraform:
        # FIXME: This plan is exiting with status == 2, which I believe is a bug.
        #        In reality, the plan has 0 adds, changes and destroys, and should exit 0.
        rules = assert_that(terraform).plan()                \
                    .succeeds()                              \
                    .exits_with_status(2)                    \
                    .collect_outputs('security_group_rules')

        assert len(rules) == 2
        assert any(k == 'default|egress|all/all' for k in rules.keys()), \
            'The default egress rule is missing'
        assert any(k == 'dev-test|ingress|80/tcp' for k in rules.keys()), \
            'The configured ingress rule is missing'
