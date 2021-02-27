# This template is used by helm_download to generate a build file for
# a downloaded Helm distribution.

load("@slamdev_rules_helm//helm:toolchain.bzl", "helm_toolchain")
package(default_visibility = ["//visibility:public"])

# tools contains executable files that are part of the toolchain.
filegroup(
    name = "runtime",
    srcs = glob(["**/*"]),
)

# toolchain_impl gathers information about the Helm toolchain.
# See the HelmToolchain provider.
helm_toolchain(
    name = "toolchain_impl",
    runtime = [":runtime"],
)

# toolchain is a Bazel toolchain that expresses execution and target
# constraints for toolchain_impl. This target should be registered by
# calling register_toolchains in a WORKSPACE file.
toolchain(
    name = "toolchain",
    exec_compatible_with = [
        {exec_constraints},
    ],
    target_compatible_with = [
        {target_constraints},
    ],
    toolchain = ":toolchain_impl",
    toolchain_type = "@slamdev_rules_helm//:toolchain_type",
)
