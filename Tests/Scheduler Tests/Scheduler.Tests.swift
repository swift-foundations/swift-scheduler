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

import Scheduler
import Testing

// The first consumer's three jobs, modeled: on-demand bulk work (payload), and two scheduled jobs.

private struct BulkTrackJob: Scheduler.Job {}

extension BulkTrackJob {
    struct Payload: Codable, Sendable {
        let identityId: String
        let statusId: String
    }

    func run(_ payload: Payload) async throws(Scheduler.Error) {}
}

private struct PollJob: Scheduler.Scheduled {}

extension PollJob {
    static var schedule: Scheduler.Schedule { .hourly(minute: 0) }
    func run() async throws(Scheduler.Error) {}
}

private struct CacheRefreshJob: Scheduler.Scheduled {}

extension CacheRefreshJob {
    static var schedule: Scheduler.Schedule { .hourly(minute: 5) }
    func run() async throws(Scheduler.Error) {}
}

// MARK: - Default names

@Test func `default job name is the type name`() {
    #expect(BulkTrackJob.name == "BulkTrackJob")
    #expect(PollJob.name == "PollJob")
    #expect(CacheRefreshJob.name == "CacheRefreshJob")
}

// MARK: - Schedule / Driver / Execution vocabulary

@Test func `Schedule cases compare by cadence`() {
    #expect(Scheduler.Schedule.hourly(minute: 5) == .hourly(minute: 5))
    #expect(Scheduler.Schedule.hourly(minute: 0) != .hourly(minute: 5))
    #expect(Scheduler.Schedule.daily(hour: 9, minute: 30) == .daily(hour: 9, minute: 30))
    #expect(Scheduler.Schedule.daily(hour: 9, minute: 30) != .daily(hour: 10, minute: 30))
    #expect(PollJob.schedule == .hourly(minute: 0))
    #expect(CacheRefreshJob.schedule == .hourly(minute: 5))
}

@Test func `Driver and Execution cases compare by value`() {
    #expect(
        Scheduler.Driver.redis(url: "redis://localhost:6379")
            == .redis(url: "redis://localhost:6379")
    )
    #expect(Scheduler.Driver.redis(url: "redis://a") != .redis(url: "redis://b"))
    #expect(Scheduler.Execution.inProcess != .workers)
    #expect(Scheduler.Execution.workers == .workers)
}

// MARK: - Registry accumulation (pure — no engine)

@Test func `Registry starts empty`() {
    let registry = Scheduler.Registry()
    #expect(registry.count == 0)
    #expect(registry.jobNames.isEmpty)
    #expect(registry.scheduledNames.isEmpty)
}

@Test func `Registry records names and count across mixed register and schedule`() {
    var registry = Scheduler.Registry()
    registry.register(BulkTrackJob())
    registry.schedule(PollJob())
    registry.schedule(CacheRefreshJob())
    #expect(registry.jobNames == ["BulkTrackJob"])
    #expect(registry.scheduledNames == ["PollJob", "CacheRefreshJob"])
    #expect(registry.count == 3)
}

// MARK: - Installing seam (typed replay + registration order + full type recovery)

/// A test double conforming to ``Scheduler/Installing``. It records each install with full type
/// information: the job's name, and — proving no type is lost through the erased registry entries —
/// the concrete `Payload` type recovered from the generic parameter.
private final class RecordingInstaller: Scheduler.Installing {
    private(set) var installedJobs: [String] = []
    private(set) var installedPayloadTypes: [String] = []
    private(set) var installedScheduled: [String] = []
    /// Full registration order, jobs and scheduled jobs interleaved as replayed.
    private(set) var order: [String] = []
}

extension RecordingInstaller {
    func install<J: Scheduler.Job>(_ job: J) {
        installedJobs.append(J.name)
        installedPayloadTypes.append("\(J.Payload.self)")
        order.append(J.name)
    }

    func install<S: Scheduler.Scheduled>(_ scheduled: S) {
        installedScheduled.append(S.name)
        order.append(S.name)
    }
}

@Test func `install replays registration order with full type recovery`() {
    var registry = Scheduler.Registry()
    registry.register(BulkTrackJob())
    registry.schedule(PollJob())
    registry.schedule(CacheRefreshJob())

    let installer = RecordingInstaller()
    registry.install(into: installer)

    // Registration order is preserved across the mixed register/schedule calls.
    #expect(installer.order == ["BulkTrackJob", "PollJob", "CacheRefreshJob"])
    #expect(installer.installedJobs == ["BulkTrackJob"])
    #expect(installer.installedScheduled == ["PollJob", "CacheRefreshJob"])
    // The concrete Payload type survives the erased registry entry — the visitor recovers it.
    #expect(installer.installedPayloadTypes == ["Payload"])
}

@Test func `install onto an empty registry visits nothing`() {
    let registry = Scheduler.Registry()
    let installer = RecordingInstaller()
    registry.install(into: installer)
    #expect(installer.order.isEmpty)
}
