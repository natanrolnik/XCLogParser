// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License .

import Foundation

struct Issues: Codable {
    let warnings: [Notice]
    let errors: [Notice]
}

public struct IssuesReporter: LogReporter {

    public func report(build: Any, output: ReporterOutput, rootOutput: String) throws {
        guard let steps = build as? BuildStep else {
            throw XCLogParserError.errorCreatingReport("Type not supported \(type(of: build))")
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(getIssues(from: steps))
        try output.write(report: json)
    }

}

private func getIssues(from step: BuildStep) -> Issues {
    return Issues(warnings: getIssues(from: step, keyPath: \.warnings),
                  errors: getIssues(from: step, keyPath: \.errors))
}

private func getIssues(from step: BuildStep, keyPath: KeyPath<BuildStep, [Notice]?>) -> [Notice] {
    return (step[keyPath: keyPath] ?? [])
        + step.subSteps.flatMap { getIssues(from: $0, keyPath: keyPath )}
}
