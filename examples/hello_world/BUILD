package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//container:container.bzl", "container_image")

container_image(
    name = "image",
    base = "@nginx_base//image:image.tar",
    directory = "/app",
    ports = ["8081"],
    workdir = "/app",
)

load("@io_bazel_rules_docker//container:container.bzl", "container_push")

container_push(
    name = "pushed_image",
    format = "Docker",
    image = ":image",
    registry = "index.docker.io",
    repository = "slamdev/rules_helm-hello_world",
)

load("//helm:defs.bzl", "helm_install")

helm_install(
    name = "helm_release",
    srcs = glob(["chart/**"]),
    image_refs = {
        ":pushed_image": "image.ref",
    },
    release_name = "hello-world",
)
