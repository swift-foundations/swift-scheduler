extension Scheduler {

    public enum Execution: Sendable, Hashable {

        case workers

        case inProcess
    }
}
