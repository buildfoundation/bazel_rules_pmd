package io.buildfoundation.bazel.pmd;

import net.sourceforge.pmd.PMD;
import net.sourceforge.pmd.renderers.TextColorRenderer;
import net.sourceforge.pmd.renderers.TextPadRenderer;
import net.sourceforge.pmd.renderers.TextRenderer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public final class Main {

    /**
     * Entry point of the application.
     * Processes input arguments, runs PMD, prints errors, and writes the execution result to a file.
     */
    public static void main(String[] args) {
        List<String> inputArgs = Arrays.asList(args);
        String executionResultOutputPath = getExecutionResultOutputPath(inputArgs);

        String[] pmdArgs = sanitizePmdArguments(inputArgs);

        PMD.StatusCode result = PMD.runPmd(pmdArgs);

        if (!result.equals(PMD.StatusCode.OK)) {
            printError(pmdArgs);
        }

        writeExecutionResultToFile(result, executionResultOutputPath);

        System.exit(0);
    }

    /**
     * Prints the error report to the console if the specified report format and file path are provided.
     */
    private static void printError(String[] pmdArgs) {
        List<String> pmdArguments = Arrays.asList(pmdArgs);
        String reportFormat = getArgument(pmdArguments, "--format");
        String reportFilePath = getArgument(pmdArguments, "--report-file");

        if (reportFormat != null && reportFilePath != null) {
            List<String> supportedFormats = Arrays.asList(TextRenderer.NAME, TextColorRenderer.NAME, TextPadRenderer.NAME);
            if (supportedFormats.contains(reportFormat)) {
                printFile(reportFilePath);
            }
        }
    }

    /**
     * Writes the execution result to a file
     */
    private static void writeExecutionResultToFile(PMD.StatusCode statusCode, String executionResultOutputPath) {
        String content;

        content = String.format("#!/bin/bash\n\nexit %d\n", statusCode.toInt());

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(executionResultOutputPath))) {
            writer.write(content);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Retrieves the output path for the test result from the input arguments.
     */
    private static String getExecutionResultOutputPath(List<String> inputArgs) {
        String outputPath = getArgument(inputArgs, "--execution-result");
        if (outputPath == null) {
            System.exit(1);
        }
        return outputPath;
    }

    /**
     * Sanitizes PMD arguments by removing unsupported arguments from the input arguments.
     */
    private static String[] sanitizePmdArguments(List<String> inputArgs) {
        Set<String> excludeArgs = new HashSet<>(Collections.singletonList("--execution-result"));
        return filterOutArgValuePairs(inputArgs, excludeArgs);
    }

    /**
     * Filters out specified arguments and their corresponding values from the input argument list.
     */
    public static String[] filterOutArgValuePairs(List<String> args, Set<String> excludeArgs) {
        List<String> filteredList = new ArrayList<>();

        int index = 0;

        while (index < args.size()) {
            String value = args.get(index);
            if (!excludeArgs.contains(value)) {
                filteredList.add(value);
            } else {
                // Skip the arg-value pair since matching argument was found
                index += 1;
            }
            index += 1;
        }

        return filteredList.toArray(new String[0]);
    }

    /**
     * Retrieves the value associated with the given argument name from the input arguments list.
     *
     * @param inputArgs List of input arguments.
     * @param argName The name of the argument whose value needs to be fetched.
     * @return The value associated with the given argument name or null if the argument is not found.
     */
    private static String getArgument(List<String> inputArgs, String argName) {
        try {
            // Get the index of the argument and return the value at the next index.
            return inputArgs.get(inputArgs.indexOf(argName) + 1);
        } catch (IndexOutOfBoundsException ignored) {
            // Return null if the argument is not found or there's no value after it.
            return null;
        }
    }

    /**
     * Prints the content of a file line by line to the standard error output.
     *
     * @param filePath The path of the file to be printed.
     */
    private static void printFile(String filePath) {
        // Use try-with-resources to ensure the BufferedReader is closed after use.
        try (BufferedReader fileReader = new BufferedReader(new FileReader(filePath))) {
            // Read and print each line from the file to the standard error output.
            fileReader.lines().forEach(System.err::println);
        } catch (IOException ignored) {
            // If there's an issue reading the file, do nothing.
        }
    }
}
