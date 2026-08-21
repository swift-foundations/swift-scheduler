extension Scheduler {

    public enum Error: Swift.Error, Sendable {

        case driver(String)

        case dispatch(String)

        case execution(String)

        case run(String)
    }
}
