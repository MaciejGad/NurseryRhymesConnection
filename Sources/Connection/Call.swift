import Foundation

public protocol CallInput {
    func get(url: URL, completion: @escaping (Result<Data?, ConnectionError>) -> Void)
}

final class Call: CallInput {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    //In the real-life application I should handle more HTTP methods, not only GET. I should also use dataTask with a request to provide the ability to add headers (i.e. with authorization) or body (i.e. for POST)
    func get(url: URL, completion: @escaping (Result<Data?, ConnectionError>) -> Void) {
        let task = session.dataTask(with: url) { (data, aResponse, anError) in
            if let error = anError {
                completion(.failure(.response(error)))
                return
            }
            guard let response = aResponse as? HTTPURLResponse else {
                assertionFailure("Bad response type")
                completion(.failure(.wrongResponseType))
                return
            }
            let statusCode = response.statusCode
            guard (200..<300).contains(statusCode) else {
                completion(.failure(.httpError(code: statusCode, data: data)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}

public class CallMock: CallInput {
    public var response: Result<Data?, ConnectionError>
    
    public init(response: Result<Data?, ConnectionError>) {
        self.response = response
    }
    
    public init(success data: Data?) {
        self.response = .success(data)
    }
    
    public init(failure error: ConnectionError) {
        self.response = .failure(error)
    }
    
    public func get(url: URL, completion: @escaping (Result<Data?, ConnectionError>) -> Void) {
        completion(response)
    }
}
