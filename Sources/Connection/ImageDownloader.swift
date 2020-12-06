import Foundation

#if canImport(UIKit)
import UIKit
public typealias Image = UIImage
#else
public struct Image {
    let data: Data
    public init?(data: Data) {
        if data.isEmpty {
            return nil
        }
        self.data = data
    }
}
#endif

public protocol ImageDownloaderInput {
    func fetch(url: URL, completion: @escaping (Result<Image, ConnectionError>) -> Void)
    func fetch(file: String, completion: @escaping (Result<Image, ConnectionError>) -> Void)
}

public final class ImageDownloader: ImageDownloaderInput {
    private let call: CallInput
    private let outputQueue: DispatchQueue
    
    public let baseURL: URL
    
    public convenience init(baseURL: URL, session: URLSession = .shared, outputQueue: DispatchQueue = .main) {
        self.init(baseURL: baseURL, call: Call(session: session), outputQueue: outputQueue)
    }
    
    public init(baseURL: URL, call: CallInput, outputQueue: DispatchQueue = .main) {
        self.call = call
        self.outputQueue = outputQueue
        self.baseURL = baseURL
    }
    
    public func fetch(file: String, completion: @escaping (Result<Image, ConnectionError>) -> Void) {
        guard let filename = file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
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
    
    public func fetch(url: URL, completion: @escaping (Result<Image, ConnectionError>) -> Void) {
        let outputQueue = self.outputQueue
        let failure: (ConnectionError) -> Void = { error in
            outputQueue.asyncIfNeeded {
                completion(.failure(error))
            }
        }
        let success: (Image) -> Void = { image in
            outputQueue.asyncIfNeeded {
                completion(.success(image))
            }
        }
        call.get(url: url) { result in
            switch result {
            case .success(let aData):
                guard let data = aData, !data.isEmpty else {
                    failure(.emptyResponse)
                    return
                }
                guard let image = Image(data: data) else {
                    failure(.decodeError(NotAnImageError()))
                    return
                }
                success(image)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    struct NotAnImageError: LocalizedError {}
}
