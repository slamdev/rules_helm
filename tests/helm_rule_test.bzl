"""Tests for helm rules."""

load("@bazel_tools//tools/build_rules:test_rules.bzl", "rule_test")

def _helm_install_test(package):
    rule_test(
        name = "hello_world_rule_test",
        generates = ["helm_release"],
        rule = package + "/hello_world:helm_release",
    )

def helm_rule_test(package):
    """Issue simple tests on helm rules."""
    _helm_install_test(package)
