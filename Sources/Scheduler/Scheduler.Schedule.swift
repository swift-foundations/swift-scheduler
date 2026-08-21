extension Scheduler {

    public enum Schedule: Sendable, Hashable {

        case hourly(minute: Int)

        case daily(hour: Int, minute: Int)
    }
}
