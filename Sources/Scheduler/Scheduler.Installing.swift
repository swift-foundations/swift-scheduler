extension Scheduler {

    public protocol Installing: AnyObject {

        func install<J: Scheduler.Job>(_ job: J)

        func install<S: Scheduler.Scheduled>(_ scheduled: S)
    }
}
