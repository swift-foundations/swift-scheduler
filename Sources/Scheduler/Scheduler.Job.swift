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
    /// An on-demand job: a `Codable` payload plus the work to run when it is dequeued.
    ///
    /// Mirrors the first consumer's `AutoTrackAllReposJob` — a job dispatched with a typed payload
    /// (an identity and a status id) and processed by a worker. Register with
    /// ``Scheduler/Registry`` and enqueue through the Live backing's dispatch surface.
    public protocol Job: Sendable {
        associatedtype Payload: Codable & Sendable
        /// The stable name used to key this job on the queue. Defaults to the type name.
        static var name: String { get }
        /// Runs the job for a dequeued payload.
        @available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
        func run(_ payload: Payload) async throws(Scheduler.Error)
    }
}

extension Scheduler.Job {
    public static var name: String { "\(Self.self)" }
}
