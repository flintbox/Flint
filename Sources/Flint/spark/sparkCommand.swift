//
//  sparkCommand.swift
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
import Bouncer

/// Spark command.
/// `flint spark [<template-name>] [--template | -t <template-path>]
/// [--output | -o <output-path>] [--input | -i <input-file-path>]
/// [--force | -f] [--verbose | -v]`
let sparkCommand = Command(name: ["spark"],
                           operandType: .optionalEqual(1),
                           options: sparkCommandOptions,
                           handler: sparkCommandHandler)

/// Spark command alias.
/// `flint s [<template-name>] [--template | -t <template-path>]
/// [--output | -o <output-path>] [--input | -i <input-file-path>]
/// [--force | -f] [--verbose | -v]`
let sparkCommandAlias = Command(name: ["s"],
                                operandType: .optionalEqual(1),
                                options: sparkCommandOptions,
                                handler: sparkCommandHandler)
