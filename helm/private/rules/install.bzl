load("@io_bazel_rules_docker//container:providers.bzl", "PushInfo")

def _helm_install_impl(ctx):
    toolchain = ctx.toolchains["@slamdev_rules_helm//:toolchain_type"].helm_runtime
    interpreter = toolchain.interpreter

    chart_root_path = ""

    # locate chart root path trying to find Chart.yaml file
    for _, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            chart_root_path = srcfile.dirname
            break

    args = ["upgrade"]
    args += [ctx.attr.release_name]
    args += [chart_root_path]
    args += ["--install"]
    if ctx.attr.namespace:
        args += ["--namespace={}".format(ctx.attr.namespace)]

    runfiles = ctx.runfiles(files = ctx.files.srcs + [interpreter])

    push_binaries = []

    for target, ref in ctx.attr.image_refs.items():
        registry = target[PushInfo].registry
        repo = target[PushInfo].repository
        tag = target[PushInfo].tag
        digest_file = target[PushInfo].digest

        push_binaries += [target[DefaultInfo].files_to_run.executable.short_path]

        img_runfiles = ctx.runfiles(files = target[DefaultInfo].files.to_list() + [digest_file])
        img_runfiles = img_runfiles.merge(target[DefaultInfo].default_runfiles)

        runfiles = runfiles.merge(img_runfiles)

        args += ["--set", "{}={}/{}:{}@$(cat {})".format(ref, registry, repo, tag, digest_file.short_path)]

    ctx.actions.expand_template(
        template = ctx.file._wrapper_template,
        output = ctx.outputs.executable,
        substitutions = {
            "%{args}": " ".join(args),
            "%{push_binaries}": "\n".join(push_binaries),
            "%{binary}": interpreter.short_path,
        },
        is_executable = True,
    )

    return DefaultInfo(
        executable = ctx.outputs.executable,
        runfiles = runfiles,
    )

helm_install = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "release_name": attr.string(mandatory = True),
        "namespace": attr.string(),
        "image_refs": attr.label_keyed_string_dict(providers = [PushInfo, DefaultInfo]),
        "_wrapper_template": attr.label(
            allow_single_file = True,
            default = "binary_wrapper.tpl",
        ),
    },
    executable = True,
    implementation = _helm_install_impl,
    toolchains = ["@slamdev_rules_helm//:toolchain_type"],
)
