import Foundation
import Models

public protocol BookListForRhymeProviderInput {
    func fetch(id: Rhyme.ID, completion: @escaping (Result<BookListForRhyme, ConnectionError>) -> Void)
}

public final class BookListForRhymeProvider: DecodingProvider<BookListForRhyme>, BookListForRhymeProviderInput {
    
    public func fetch(id: Rhyme.ID, completion: @escaping (Result<BookListForRhyme, ConnectionError>) -> Void) {
        guard let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(.malformedUrl))
            return
        }
        let filename = "books/\(encodedId).json"
        guard let url = URL(string: filename, relativeTo: baseURL) else {
            assertionFailure("Can't load url")
            completion(.failure(.malformedUrl))
            return
        }
        fetch(url: url, completion: completion)
    }
}
