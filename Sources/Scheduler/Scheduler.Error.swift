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
    /// The typed error domain thrown by job registration, dispatch, and execution.
    public enum Error: Swift.Error, Sendable {
        /// Configuring the queue driver failed (e.g. an invalid Redis URL).
        case driver(String)
        /// Dispatching a job onto the queue failed.
        case dispatch(String)
        /// Starting the in-process workers failed.
        case execution(String)
        /// A job's `run` failed; the string carries the underlying description.
        case run(String)
    }
}
