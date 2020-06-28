package io.buildfoundation.bazel.pmd.execute

sealed class Result {
    object Success : Result()
    data class Failure(val description: String = "unknown") : Result()

    val consoleStatusCode by lazy {
        when (this) {
            is Success -> 0
            is Failure -> 1
        }
    }
}
