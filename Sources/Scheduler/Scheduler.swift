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

/// The engine-free background-jobs interface.
///
/// `Scheduler` is the namespace for a queue-agnostic jobs surface: an on-demand job protocol
/// (``Scheduler/Job``), a scheduled-job protocol (``Scheduler/Scheduled``), a cadence vocabulary
/// (``Scheduler/Schedule``), a backend selector (``Scheduler/Driver``), a worker-placement selector
/// (``Scheduler/Execution``), and an accumulation registry (``Scheduler/Registry``). It carries no
/// engine dependency — a live backing at Layer 4 (e.g. a vapor/queues adapter) conforms to the
/// ``Scheduler/Installing`` seam and receives each registered job with full type information.
///
/// Models the first consumer's three jobs — an hourly scheduled poll, a scheduled cache refresh,
/// and on-demand queued bulk work — as ``Scheduler/Job`` (payload-carrying, dispatched) and
/// ``Scheduler/Scheduled`` (cadence-owning) conformers accumulated in a ``Scheduler/Registry``.
/// Because the seam depends on nothing but the standard library, consumers compile and test against
/// it with no queue engine present.
public enum Scheduler {}
