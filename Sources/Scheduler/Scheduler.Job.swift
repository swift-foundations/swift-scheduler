extension Scheduler {

    public protocol Job: Sendable {
        associatedtype Payload: Codable & Sendable

        static var name: String { get }

        @available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
        func run(_ payload: Payload) async throws(Scheduler.Error)
    }
}

extension Scheduler.Job {
    public static var name: String { "\(Self.self)" }
}
