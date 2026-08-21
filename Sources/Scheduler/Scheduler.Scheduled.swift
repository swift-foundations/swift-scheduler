extension Scheduler {

    public protocol Scheduled: Sendable {

        static var name: String { get }

        static var schedule: Scheduler.Schedule { get }

        @available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
        func run() async throws(Scheduler.Error)
    }
}

extension Scheduler.Scheduled {
    public static var name: String { "\(Self.self)" }
}
