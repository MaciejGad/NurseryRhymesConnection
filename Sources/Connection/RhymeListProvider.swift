import Foundation
import Models

public protocol RhymeListProviderInput {
    func fetchList(completion: @escaping (Result<List, RhymeListProviderError>) -> Void)
}

public enum RhymeListProviderError: LocalizedError {
    case malformedUrl
    case response(Error)
    case wrongResponseType
    case emptyResponse
    case httpError(code: Int, data: Data?)
    case decodeError(Error)
}

public class RhymeListProvider: RhymeListProviderInput {
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let outputQueue: DispatchQueue
    
    public init(session: URLSession = .shared, jsonDecoder: JSONDecoder = .init(), outputQueue: DispatchQueue = .main) {
        self.session = session
        self.jsonDecoder = jsonDecoder
        self.outputQueue = outputQueue
    }
    
    private func endpoint() -> URL? {
        URL(string: "https://maciejgad.github.io/NurseryRhymesJSON/data/list.json")
    }
    
    public func fetchList(completion: @escaping (Result<List, RhymeListProviderError>) -> Void) {
        let wrappedFailure: (RhymeListProviderError) -> Void = { [weak self] error in
            let outputQueue = self?.outputQueue ?? .main
            outputQueue.async {
                completion(.failure(error))
            }
        }
        let wrappedSuccess: (List) -> Void = { [weak self] list in
            let outputQueue = self?.outputQueue ?? .main
            outputQueue.async {
                completion(.success(list))
            }
        }
        guard let url = endpoint() else {
            assertionFailure("Can't load url")
            wrappedFailure(.malformedUrl)
            return
        }
        let jsonDecoder = self.jsonDecoder
        let task = session.dataTask(with: url) { (aData, aResponse, anError) in
            if let error = anError {
                wrappedFailure(.response(error))
                return
            }
            guard let response = aResponse as? HTTPURLResponse else {
                assertionFailure("Bad response type")
                wrappedFailure(.wrongResponseType)
                return
            }
            let statusCode = response.statusCode
            guard (200..<300).contains(statusCode) else {
                wrappedFailure(.httpError(code: statusCode, data: aData))
                return
            }
            guard let data = aData else {
                wrappedFailure(.emptyResponse)
                return
            }
            do {
                let result = try jsonDecoder.decode(List.self, from: data)
                wrappedSuccess(result)
            } catch {
                wrappedFailure(.decodeError(error))
            }
        }
        task.resume()
    }
    
    
}
