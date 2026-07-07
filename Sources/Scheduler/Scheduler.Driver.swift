// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-scheduler open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-scheduler project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Scheduler {
    /// The queue backend. v0 offers the Redis driver, matching the first consumer; a live backing
    /// engine ships no in-memory production driver, so in-process *execution* (see
    /// ``Scheduler/Execution``) still runs against a Redis backend.
    public enum Driver: Sendable, Hashable {
        case redis(url: String)
    }
}
