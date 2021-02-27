def _helm_download_impl(ctx):
    ctx.report_progress("Downloading helm")

    ctx.download_and_extract(
        ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        stripPrefix = ctx.attr.strip_prefix,
    )

    ctx.report_progress("Creating Helm toolchain files")
    if ctx.attr.os == "darwin":
        os_constraint = "@platforms//os:osx"
    elif ctx.attr.os == "linux":
        os_constraint = "@platforms//os:linux"
    else:
        fail("Unsupported OS: " + ctx.attr.os)

    if ctx.attr.arch == "amd64":
        arch_constraint = "@platforms//cpu:x86_64"
    else:
        fail("Unsupported arch: " + ctx.attr.arch)

    constraints = [os_constraint, arch_constraint]
    constraint_str = ",\n        ".join(['"%s"' % c for c in constraints])

    substitutions = {
        "{exec_constraints}": constraint_str,
        "{target_constraints}": constraint_str,
    }
    ctx.template(
        "BUILD.bazel",
        ctx.attr._build_tpl,
        substitutions = substitutions,
    )

helm_download = repository_rule(
    implementation = _helm_download_impl,
    attrs = {
        "urls": attr.string_list(
            mandatory = True,
            doc = "List of mirror URLs where a Helm distribution archive can be downloaded",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "Expected SHA-256 sum of the downloaded archive",
        ),
        "os": attr.string(
            mandatory = True,
            values = ["darwin", "linux"],
            doc = "Host operating system for the Helm distribution",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["amd64"],
            doc = "Host architecture for the Helm distribution",
        ),
        "strip_prefix": attr.string(
            mandatory = True,
            doc = "Prefix to strip from helm distr tarballs",
        ),
        "_build_tpl": attr.label(
            default = "@slamdev_rules_helm//helm/private:BUILD.dist.bazel.tpl",
        ),
    },
    doc = "Downloads a standard Helm distribution and installs a build file",
)
