import Scheduler
import Testing

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

@Test func `default job name is the type name`() {
    #expect(BulkTrackJob.name == "BulkTrackJob")
    #expect(PollJob.name == "PollJob")
    #expect(CacheRefreshJob.name == "CacheRefreshJob")
}

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

private final class RecordingInstaller: Scheduler.Installing {
    private(set) var installedJobs: [String] = []
    private(set) var installedPayloadTypes: [String] = []
    private(set) var installedScheduled: [String] = []

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

    #expect(installer.order == ["BulkTrackJob", "PollJob", "CacheRefreshJob"])
    #expect(installer.installedJobs == ["BulkTrackJob"])
    #expect(installer.installedScheduled == ["PollJob", "CacheRefreshJob"])

    #expect(installer.installedPayloadTypes == ["Payload"])
}

@Test func `install onto an empty registry visits nothing`() {
    let registry = Scheduler.Registry()
    let installer = RecordingInstaller()
    registry.install(into: installer)
    #expect(installer.order.isEmpty)
}
