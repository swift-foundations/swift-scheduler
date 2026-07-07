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
    /// The engine-free erasure seam onto which a ``Scheduler/Registry`` replays its accumulated
    /// jobs. A Live backing (e.g. a vapor/queues adapter at Layer 4) conforms and receives each
    /// registered job or scheduled job with full type information — the registry stays engine-free
    /// while no type information is lost. This is a visitor: the registry holds the concrete jobs
    /// and hands each, still typed, to the conformer's ``install(_:)-(J)`` /
    /// ``install(_:)-(S)`` methods.
    ///
    /// The seam is class-constrained (reference semantics). Each `install` call is a side effect on
    /// the backing — the sole real conformer (swift-server's installer) holds a Vapor `Application`
    /// (itself a reference type) and forwards each typed job to `application.queues.add`. Reference
    /// semantics avoid the existential-box writeback a value-type `inout` seam would require to
    /// bridge the registry's erased entries back onto a concrete conformer. See
    /// ``Scheduler/Registry`` for the accumulation side.
    public protocol Installing: AnyObject {
        /// Receives one registered on-demand job with full type information.
        func install<J: Scheduler.Job>(_ job: J)
        /// Receives one registered scheduled job with full type information.
        func install<S: Scheduler.Scheduled>(_ scheduled: S)
    }
}
