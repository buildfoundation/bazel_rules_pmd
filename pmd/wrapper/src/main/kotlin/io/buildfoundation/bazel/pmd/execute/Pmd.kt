package io.buildfoundation.bazel.pmd.execute

import java.io.PrintStream
import net.sourceforge.pmd.PMD
import net.sourceforge.pmd.cli.PMDCommandLineInterface

interface Pmd {

    fun execute(args: Array<String>)

    class Impl : Pmd {

        override fun execute(args: Array<String>) {
            when (PMD.run(args)) {
                PMDCommandLineInterface.ERROR_STATUS,
                PMDCommandLineInterface.VIOLATIONS_FOUND -> throw RuntimeException()

                else -> Unit
            }
        }
    }
}
