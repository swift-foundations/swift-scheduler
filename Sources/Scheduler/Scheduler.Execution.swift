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
    /// Where the queue workers run.
    public enum Execution: Sendable, Hashable {
        /// Workers run in separate processes (the production shape); registration only.
        case workers
        /// Workers run in this process (the development shape) — starts in-process job and
        /// scheduled-job workers, mirroring the first consumer's `startInProcessJobs()` /
        /// `startScheduledJobs()` in the `ENV == development` branch.
        case inProcess
    }
}
