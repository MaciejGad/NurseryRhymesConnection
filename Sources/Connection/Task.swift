import Foundation

public enum TaskState {
    case pending
    case running
    case finished
}

public protocol Task {
    var state: TaskState { get }
    func cancel()
}


class CallTask: Task {
    let task: URLSessionDataTask

    var state: TaskState {
        switch task.state {
        case .suspended:
            return .pending
        case .canceling, .completed:
            return .finished
        case .running:
            return .running
        @unknown default:
            assertionFailure("Unknown URLSessionDataTask state: \(task.state.rawValue)")
            return .pending
        }
    }
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
}
