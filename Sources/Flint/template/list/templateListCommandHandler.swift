//
//  templateListCommandHandler.swift
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

/// Template list command handler.
let templateListCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let verbose = optionValues.have(templateListVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input Summary
            └╴Verbose: \(verbose)
            """
        )
    }

    // Prepare paths.
    let templateHomePath: Path
    do {
        templateHomePath = try getTemplateHomePath()
    } catch {
        printError(error.localizedDescription)
        return
    }

    // List available templates.
    if verbose {
        printVerbose(templateHomePath.path)
    }
    do {
        for content in try templateHomePath.enumerated() {
            guard let template = try? Template(path: content) else { continue }

            let templateName: String
            if verbose {
                templateName = content.path
            } else {
                templateName = String(content.relativePath)
            }

            let output: String
            if let description = template.manifest.description {
                output = "\(templateName.boldOutput) - \(description)"
            } else {
                output = templateName.boldOutput
            }

            print(output)
        }
    } catch {
        printError(error.localizedDescription)
        return
    }
}
