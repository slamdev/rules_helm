workspace(name = "slamdev_rules_helm")

load("@slamdev_rules_helm//helm:repositories.bzl", "rules_helm_dependencies", "rules_helm_toolchains")

rules_helm_dependencies()

rules_helm_toolchains()

load("@io_bazel_rules_docker//repositories:repositories.bzl", container_repositories = "repositories")

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

container_pull(
    name = "nginx_base",
    registry = "index.docker.io",
    repository = "nginx",
    tag = "1.18.0-alpine",
)
