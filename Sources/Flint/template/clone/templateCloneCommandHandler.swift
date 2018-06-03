//
//  templateCloneCommandHandler.swift
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
import Motor
import Work

/// Template clone command handler.
let templateCloneCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let gitURLOperand = operandValues[0]
    let templateNameOperand = operandValues[optional: 1]
    let branch = optionValues.findOptionalArgument(for: templateCloneBranchOption)
    let force = optionValues.have(templateCloneForceOption)
    let verbose = optionValues.have(templateCloneVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input summary
            └╴Repository URL: \(gitURLOperand)
            └╴Template Name : \(templateNameOperand ?? "nil")
            └╴Branch        : \(branch ?? "HEAD")
            └╴Force         : \(force)
            └╴Verbose       : \(verbose)
            """
        )
    }

    // Prepare paths.
    let pathToCloneTemplate: Path
    do {
        guard let gitURL = URL(string: gitURLOperand) else {
            printError("\(gitURLOperand) is not a valid url.")
            return
        }
        let templateName = templateNameOperand ?? gitURL.deletingPathExtension().lastPathComponent
        pathToCloneTemplate = try getTemplateHomePath()[templateName]
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Check existing template.
    if pathToCloneTemplate.exists {
        if force {
            do {
                try pathToCloneTemplate.remove()
            } catch {
                printError(error.localizedDescription)
                return
            }
        } else {
            printWarning("Template already exists at \(pathToCloneTemplate.path)")
            printWarning("Use --force/-f option to override")
            return
        }
    }

    // Prepare cloning.
    let spinner = Spinner(pattern: Patterns.dots, delay: 2)
    var gitCommand = "git clone \(gitURLOperand) \"\(pathToCloneTemplate.path)\" --single-branch --depth 1"
    if let branch = branch {
        gitCommand.append(" -b \(branch)")
    }
    let gitClone = Work(command: gitCommand)

    // Start cloning.
    if verbose {
        printVerbose("Execute: \(gitCommand)")
    }
    spinner.start(message: "Downloading...")
    gitClone.start()

    // Clean up.
    switch gitClone.result! {
    case .success(_):
        spinner.stop(message: "✓".color(.green) + " Done")
    case .failure(_, _):
        spinner.stop(message: "✗".color(.red) + " Failed: \(gitClone.standardError)")
    }
}
