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
        let outputQueue = self.outputQueue
        let failure: (ConnectionError) -> Void = { error in
            outputQueue.asyncIfNeeded {
                completion(.failure(error))
            }
        }
        let success: (T) -> Void = { item in
            outputQueue.asyncIfNeeded {
                completion(.success(item))
            }
        }
        let jsonDecoder = self.jsonDecoder
        call.get(url: url) { result in
            switch result {
            case .success(let aData):
                guard let data = aData, !data.isEmpty else {
                    failure(.emptyResponse)
                    return
                }
                do {
                    let result = try jsonDecoder.decode(T.self, from: data)
                    success(result)
                } catch {
                    failure(.decodeError(error))
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
}
