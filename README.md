# Helm rules for [Bazel](https://bazel.build)

![CI](https://github.com/slamdev/rules_helm/workflows/build/badge.svg?branch=main)

Bazel rules to work with [Helm](https://helm.sh/) releases.

## Usage

Add the following to your WORKSPACE file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_HELM_VERSION = "49148fce1906e82d44b5375813b58e9989e492c0"
RULES_HELM_SHA256 = "2e43dfeb0f0a330aa7668847ae03a1454c37baadd86875a9ae6dc3379febe3ef"

http_archive(
    name = "slamdev_rules_helm",
    strip_prefix = "rules_helm-%s" % RULES_HELM_VERSION,
    url = "https://github.com/slamdev/rules_helm/archive/%s.tar.gz" % RULES_HELM_VERSION,
    sha256 = RULES_HELM_SHA256
)

load("@slamdev_rules_helm//helm:repositories.bzl", "rules_helm_dependencies", "rules_helm_toolchains")

rules_helm_dependencies()

rules_helm_toolchains()
```

Then in your BUILD file, just add the following so the rules will be available:

```starlark
load("@slamdev_rules_helm//helm:defs.bzl", "helm_install")
```
