package io.buildfoundation.bazel.pmd.execute

interface Executable {

    fun execute(args: Array<String>): Result

    class PmdImpl(private val pmd: Pmd) : Executable {

        override fun execute(args: Array<String>): Result {
            return try {
                pmd.execute(args)

                Result.Success
            } catch (e: Exception) {
                Result.Failure()
            }
        }
    }
}
