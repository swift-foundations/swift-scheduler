extension Scheduler {

    public struct Registry: Sendable {

        public private(set) var jobNames: [String]

        public private(set) var scheduledNames: [String]

        var entries: [@Sendable (any Scheduler.Installing) -> Void]

        public init() {
            self.jobNames = []
            self.scheduledNames = []
            self.entries = []
        }
    }
}

extension Scheduler.Registry {

    public var count: Int { jobNames.count + scheduledNames.count }

    public mutating func register<J: Scheduler.Job>(_ job: J) {
        jobNames.append(J.name)
        entries.append { installer in
            installer.install(job)
        }
    }

    public mutating func schedule<S: Scheduler.Scheduled>(_ scheduled: S) {
        scheduledNames.append(S.name)
        entries.append { installer in
            installer.install(scheduled)
        }
    }

    public func install(into installer: some Scheduler.Installing) {
        for entry in entries {
            entry(installer)
        }
    }
}
