@file:JvmName("Main")

package io.buildfoundation.bazel.pmd

import io.buildfoundation.bazel.pmd.execute.Pmd
import io.buildfoundation.bazel.pmd.execute.Executable
import io.buildfoundation.bazel.pmd.execute.WorkerExecutable
import io.buildfoundation.bazel.pmd.stream.Streams
import io.buildfoundation.bazel.pmd.stream.WorkerStreams
import io.reactivex.rxjava3.schedulers.Schedulers

fun main(arguments: Array<String>) {
    val executable = Executable.PmdImpl(Pmd.Impl())
    val streams = Streams.system()

    val application = if ("--persistent_worker" in arguments) {
        Application.Worker(WorkerExecutable.Impl(executable), WorkerStreams.Impl(streams), Schedulers.io())
    } else {
        Application.OneShot(executable, streams, Platform.Impl())
    }

    application.run(arguments)
}
