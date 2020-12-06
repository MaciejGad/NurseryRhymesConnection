import Foundation

public class DecodingProvider<T: Decodable> {
    private let call: CallInput
    private let jsonDecoder: JSONDecoder
    private let outputQueue: DispatchQueue
    
    public let baseURL: URL
    
    public convenience init(baseURL: URL, session: URLSession = .shared, jsonDecoder: JSONDecoder = .init(), outputQueue: DispatchQueue = .main) {
        self.init(baseURL: baseURL, call: Call(session: session), jsonDecoder: jsonDecoder, outputQueue: outputQueue)
    }
    
    public init(baseURL: URL, call: CallInput, jsonDecoder: JSONDecoder = .init(), outputQueue: DispatchQueue = .main) {
        self.call = call
        self.jsonDecoder = jsonDecoder
        self.outputQueue = outputQueue
        self.baseURL = baseURL
    }
    
    public func fetch(url: URL, completion: @escaping (Result<T, ConnectionError>) -> Void) {
        let wrappedFailure: (ConnectionError) -> Void = { [weak self] error in
            let outputQueue = self?.outputQueue ?? .main
            outputQueue.asyncIfNeeded {
                completion(.failure(error))
            }
        }
        let wrappedSuccess: (T) -> Void = { [weak self] list in
            let outputQueue = self?.outputQueue ?? .main
            outputQueue.asyncIfNeeded {
                completion(.success(list))
            }
        }
        let jsonDecoder = self.jsonDecoder
        call.get(url: url) { result in
            switch result {
            case .success(let aData):
                guard let data = aData, !data.isEmpty else {
                    wrappedFailure(.emptyResponse)
                    return
                }
                do {
                    let result = try jsonDecoder.decode(T.self, from: data)
                    wrappedSuccess(result)
                } catch {
                    wrappedFailure(.decodeError(error))
                }
            case .failure(let error):
                wrappedFailure(error)
            }
        }
    }
    
    
}

