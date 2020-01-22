workspace(name = "rules_pmd")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Java

rules_java_version = "0.1.1"

rules_java_sha = "220b87d8cfabd22d1c6d8e3cdb4249abd4c93dcc152e0667db061fb1b957ee68"

http_archive(
    name = "rules_java",
    sha256 = rules_java_sha,
    url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
)

load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")

rules_java_dependencies()

rules_java_toolchains()

# JVM External

rules_jvm_external_version = "3.0"

rules_jvm_external_sha = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a"

http_archive(
    name = "rules_jvm_external",
    sha256 = rules_jvm_external_sha,
    strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.zip".format(v = rules_jvm_external_version),
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "net.sourceforge.pmd:pmd-dist:6.20.0",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
