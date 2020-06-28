package io.buildfoundation.bazel.pmd

import kotlin.system.exitProcess

internal interface Platform {

    fun exit(code: Int)

    class Impl : Platform {

        override fun exit(code: Int) = exitProcess(code)
    }
}
