"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//helm/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
def rules_helm_dependencies():
    # The minimal version of bazel_skylib we require
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "io_bazel_rules_docker",
        sha256 = "b1e80761a8a8243d03ebca8845e9cc1ba6c82ce7c5179ce2b295cd36f7e394bf",
        urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.25.0/rules_docker-v0.25.0.tar.gz"],
    )
    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "2b1641428dff9018f9e85c0384f03ec6c10660d935b750e3fa1492a281a53b0f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        ],
    )

_DOC = "TODO"
_ATTRS = {
    "helm_version": attr.string(mandatory = True),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
}

def _helm_repo_impl(repository_ctx):
    repository_ctx.report_progress("Downloading Helm releases info")
    repository_ctx.download(
        url = ["https://api.github.com/repos/helm/helm/releases"],
        output = "versions.json",
    )
    versions = repository_ctx.read("versions.json")
    version_found = False
    for v in json.decode(versions):
        version = v["tag_name"].lstrip("v")
        if version == repository_ctx.attr.helm_version:
            version_found = True
    if not version_found:
        fail("did not find {} version in https://api.github.com/repos/helm/helm/releases".format(repository_ctx.attr.helm_version))

    file_url = "https://get.helm.sh/helm-v{}-{}.tar.gz".format(repository_ctx.attr.helm_version, repository_ctx.attr.platform)

    repository_ctx.report_progress("Downloading Helm SHA-256 sums")
    repository_ctx.download(
        url = [file_url + ".sha256sum"],
        output = "sha256.sum",
    )
    sha256 = repository_ctx.read("sha256.sum").split(" ", 1)[0]

    repository_ctx.report_progress("Downloading and extracting Helm toolchain")
    repository_ctx.download_and_extract(
        url = file_url,
        stripPrefix = repository_ctx.attr.platform,
        sha256 = sha256,
    )

    build_content = """#Generated by helm/repositories.bzl
load("@slamdev_rules_helm//helm:toolchain.bzl", "helm_toolchain")
helm_toolchain(name = "helm_toolchain", target_tool = select({
        "@bazel_tools//src/conditions:host_windows": "helm.exe",
        "//conditions:default": "helm",
    }),
)
"""

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

helm_repositories = repository_rule(
    _helm_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def helm_register_toolchains(name, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "helm_linux_amd64" -
      this repository is lazily fetched when helm is needed for that platform.
    - TODO: create a convenience repository for the host platform like "helm_host"
    - create a repository exposing toolchains for each platform like "helm_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.

    Args:
        name: base name for all created repos, like "helm3_7_1"
        **kwargs: passed to each helm_repositories call
    """
    for platform in PLATFORMS.keys():
        helm_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
