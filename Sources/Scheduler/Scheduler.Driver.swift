extension Scheduler {

    public enum Driver: Sendable, Hashable {
        case redis(url: String)
    }
}
