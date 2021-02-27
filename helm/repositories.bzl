load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//helm/private:repo.bzl", _helm_download = "helm_download")

helm_download = _helm_download

def rules_helm_toolchains():
    helm_download(
        name = "helm_linux_amd64",
        arch = "amd64",
        os = "linux",
        strip_prefix = "linux-amd64",
        sha256 = "01b317c506f8b6ad60b11b1dc3f093276bb703281cb1ae01132752253ec706a2",
        urls = [
            "https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz",
        ],
    )

    helm_download(
        name = "helm_darwin_amd64",
        arch = "amd64",
        os = "darwin",
        strip_prefix = "darwin-amd64",
        sha256 = "68040e9a2f147a92c2f66ce009069826df11f9d1e1c6b78c7457066080ad3229",
        urls = [
            "https://get.helm.sh/helm-v3.5.2-darwin-amd64.tar.gz",
        ],
    )

    native.register_toolchains(
        "@helm_darwin_amd64//:toolchain",
        "@helm_linux_amd64//:toolchain",
    )

def rules_helm_dependencies():
    """Declares external repositories that rules_helm depends on.
    This function should be loaded and called from WORKSPACE of any project
    that uses rules_helm.
    """

    maybe(
        http_archive,
        name = "io_bazel_rules_docker",
        sha256 = "1698624e878b0607052ae6131aa216d45ebb63871ec497f26c67455b34119c80",
        strip_prefix = "rules_docker-0.15.0",
        urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.15.0/rules_docker-v0.15.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        ],
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    )
