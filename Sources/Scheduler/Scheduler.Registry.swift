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
    /// Accumulates the jobs and scheduled jobs an application should run, then replays them onto a
    /// ``Scheduler/Installing`` conformer. Its public surface (``register(_:)`` / ``schedule(_:)`` /
    /// ``jobNames`` / ``scheduledNames`` / ``count`` / ``install(into:)``) is engine-free; the
    /// erased entries it holds are internal.
    ///
    /// Each entry captures its concrete job and, when replayed, calls `installer.install(job)` with
    /// full type information intact — so a Live backing recovers the exact job type (and its
    /// `Payload`) without the registry ever naming an engine.
    public struct Registry: Sendable {
        /// The names of registered on-demand jobs, in registration order.
        public private(set) var jobNames: [String]
        /// The names of registered scheduled jobs, in registration order.
        public private(set) var scheduledNames: [String]
        // Deliberate erasure: entries replay onto whichever engine-specific
        // Scheduler.Installing conformer is wired at boot; the existential keeps
        // the registry engine-free (documented type-recovery design above).
        // swiftlint:disable no_any_protocol_existential
        /// Erased registration steps, in registration order across both jobs and scheduled jobs.
        var entries: [@Sendable (any Scheduler.Installing) -> Void]
        // swiftlint:enable no_any_protocol_existential

        public init() {
            self.jobNames = []
            self.scheduledNames = []
            self.entries = []
        }
    }
}

extension Scheduler.Registry {
    /// The total number of registered jobs (on-demand plus scheduled). Pure — testable.
    public var count: Int { jobNames.count + scheduledNames.count }

    /// Registers an on-demand job.
    public mutating func register<J: Scheduler.Job>(_ job: J) {
        jobNames.append(J.name)
        entries.append { installer in
            installer.install(job)
        }
    }

    /// Registers a scheduled job at its declared cadence.
    public mutating func schedule<S: Scheduler.Scheduled>(_ scheduled: S) {
        scheduledNames.append(S.name)
        entries.append { installer in
            installer.install(scheduled)
        }
    }

    /// Replays every registration, in order, onto the given ``Scheduler/Installing`` conformer.
    public func install(into installer: some Scheduler.Installing) {
        for entry in entries {
            entry(installer)
        }
    }
}
