import Foundation

open class CallMock: CallInput {
    open var response: Result<Data?, ConnectionError>
    
    public init(response: Result<Data?, ConnectionError>) {
        self.response = response
    }
    
    public init(success data: Data?) {
        self.response = .success(data)
    }
    
    public init(failure error: ConnectionError) {
        self.response = .failure(error)
    }
    
    @discardableResult open func get(url: URL, completion: @escaping (Result<Data?, ConnectionError>) -> Void) -> Task {
        completion(response)
        return ComplitedTask()
    }
}

open class ComplitedTask: Task {
    public init() {}
    
    open var state: TaskState {
        .finished
    }
    
    open func cancel() {}
}
