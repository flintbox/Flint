//
//  inputCommandHandler.swift
//  Flint
//
//  Copyright (c) 2018 Jason Nam (https://jasonnam.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import PathFinder
import Bouncer

/// Input command handler.
let inputCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let templateNameOperand = operandValues[optional: 0]
    let templatePathOptionValue = optionValues.findOptionalArgument(for: inputTemplatePathOption)
    let outputPathOptionValue = optionValues.findOptionalArgument(for: inputOutputPathOption)
    let yaml = optionValues.have(inputYAMLOption)
    let force = optionValues.have(inputForceOption)
    let verbose = optionValues.have(inputVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input summary
            └╴Template Name: \(templateNameOperand ?? "nil")
            └╴Template Path: \(templatePathOptionValue ?? "nil")
            └╴Output Path  : \(outputPathOptionValue ?? "nil")
            └╴YAML         : \(yaml)
            └╴Force        : \(force)
            └╴Verbose      : \(verbose)
            """
        )
    }

    // Prepare template.
    let template: Template
    do {
        let templatePath: Path
        if let templateName = templateNameOperand {
            templatePath = try getTemplateHomePath()[templateName]
            if let templatePathOptionValue = templatePathOptionValue {
                printWarning("Ignore \(templatePathOptionValue)")
            }
        } else if let templatePathOptionValue = templatePathOptionValue {
            templatePath = Path(fileURLWithPath: templatePathOptionValue)
        } else {
            printError("Template not specified")
            return
        }
        template = try Template(path: templatePath)
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Output path.
    let outputPath: Path
    let fileName = yaml ? "variables.yml" : "variables.json"
    if let outputPathOptionValue = outputPathOptionValue {
        outputPath = Path(fileURLWithPath: outputPathOptionValue)[fileName]
    } else {
        outputPath = Path(fileURLWithPath: FileManager.default.currentDirectoryPath)[fileName]
    }

    // Check if output path is valid.
    if outputPath.exists {
        if force {
            do {
                try outputPath.remove()
            } catch {
                printError(error.localizedDescription)
                return
            }
        } else {
            printWarning("\(outputPath.path) is not empty")
            return
        }
    }

    // Create directory path.
    if !outputPath.parent.exists {
        do {
            try outputPath.parent.createDirectory()
        } catch {
            printError(error.localizedDescription)
            return
        }
    }

    // Write file.
    if verbose {
        printVerbose("Generate variable input file at \(outputPath.path)")
    }
    if yaml {
        var output = ""
        for variable in template.manifest.variables ?? [] {
            if let defaultValue = variable.defaultValue {
                output.append("\(variable.name): \(defaultValue)\n")
            } else {
                output.append("\(variable.name):\n")
            }
        }
        do {
            try output.write(to: outputPath.rawValue, atomically: true, encoding: .utf8)
        } catch {
            printError(error.localizedDescription)
            return
        }
    } else {
        var output = "{\n"
        for variable in template.manifest.variables ?? [] {
            if let defaultValue = variable.defaultValue {
                output.append("  \"\(variable.name)\": \"\(defaultValue)\",\n")
            } else {
                output.append("  \"\(variable.name)\":,\n")
            }
        }
        output.append("}\n")
        do {
            try output.write(to: outputPath.rawValue, atomically: true, encoding: .utf8)
        } catch {
            printError(error.localizedDescription)
            return
        }
    }

    print("✓".color(.green) + " Variable Input File Generated")
}
