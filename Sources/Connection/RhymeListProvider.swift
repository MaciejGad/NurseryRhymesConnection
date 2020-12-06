import Foundation
import Models

public protocol RhymeListProviderInput {
    func fetchList(completion: @escaping (Result<List, ConnectionError>) -> Void)
}

public final class RhymeListProvider: DecodingProvider<List>, RhymeListProviderInput {
    
    
    private lazy var endpoint = URL(string: "list.json", relativeTo: baseURL)
    
    public func fetchList(completion: @escaping (Result<List, ConnectionError>) -> Void) {
        guard let url = endpoint else {
            assertionFailure("Can't load url")
            completion(.failure(.malformedUrl))
            return
        }
        fetch(url: url, completion: completion)
    }
    
}
