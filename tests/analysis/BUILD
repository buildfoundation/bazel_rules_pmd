load("//pmd:toolchain.bzl", "pmd_toolchain")
load(":tests.bzl", "test_suite")

pmd_toolchain(
    name = "custom_toolchain_impl",
    jvm_flags = [
        "-Xms16m",
        "-Dexample.property=value with spaces",
        "-Xmx128m",
    ],
)

toolchain(
    name = "custom_toolchain",
    toolchain = ":custom_toolchain_impl",
    toolchain_type = "//pmd:toolchain_type",
)

test_suite(
    name = "tests",
)
