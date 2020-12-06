import Foundation

#if canImport(UIKit)
import UIKit
typealias Image = UIImage
#else
struct Image {
    let data: Data
    init?(data: Data) {
        if data.isEmpty {
            return nil
        }
        self.data = data
    }
}
#endif

protocol ImageDownloaderInput {
    func fetch(url: URL, completion: @escaping (Result<Image, ConnectionError>) -> Void)
}

final class ImageDownloader: ImageDownloaderInput {
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
    
    func fetch(url: URL, completion: @escaping (Result<Image, ConnectionError>) -> Void) {
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
