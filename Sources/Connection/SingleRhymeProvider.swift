import Foundation
import Models

public protocol SingleRhymeProviderInput {
    func fetch(id: Rhyme.ID, completion: @escaping (Result<Rhyme, ConnectionError>) -> Void)
}

public final class SingleRhymeProvider: DecodingProvider<Rhyme>, SingleRhymeProviderInput {
    
    public func fetch(id: Rhyme.ID, completion: @escaping (Result<Rhyme, ConnectionError>) -> Void) {
        guard let filename = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?.appending(".json") else {
            completion(.failure(.malformedUrl))
            return
        }
        guard let url = URL(string: filename, relativeTo: baseURL) else {
            assertionFailure("Can't load url")
            completion(.failure(.malformedUrl))
            return
        }
        fetch(url: url, completion: completion)
    }
}
