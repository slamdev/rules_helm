"""Toolchains for Helm rules.
helm_toolchain creates a provider as described in HelmToolchainInfo in
providers.bzl. toolchains and helm_toolchains are declared in the build file
generated in helm_download in repo.bzl.
"""

HelmRuntimeInfo = provider(
    doc = "Information about a Helm interpreter, related commands and libraries",
    fields = {
        "interpreter": "A label which points to the Helm interpreter",
        "runtime": "A list of labels which points to runtime libraries",
    },
)

def _find_tool(ctx, name):
    cmd = None
    for f in ctx.files.runtime:
        if f.path.endswith("/%s" % name) or f.path.endswith("/%s.exe" % name):
            cmd = f
            break
    if not cmd:
        fail("could not locate `%s` tool" % name)

    return cmd

def _helm_toolchain_impl(ctx):
    # Find important files and paths.
    interpreter_cmd = _find_tool(ctx, "helm")

    return [platform_common.ToolchainInfo(
        helm_runtime = HelmRuntimeInfo(
            interpreter = interpreter_cmd,
            runtime = ctx.files.runtime,
        ),
    )]

helm_toolchain = rule(
    implementation = _helm_toolchain_impl,
    attrs = {
        "runtime": attr.label_list(
            mandatory = True,
            allow_files = True,
            cfg = "target",
        ),
    },
    doc = "Gathers functions and file lists needed for a Helm toolchain",
)
