import Foundation

public enum ConnectionError: LocalizedError {
    case malformedUrl
    case response(Error)
    case wrongResponseType
    case emptyResponse
    case httpError(code: Int, data: Data?)
    case decodeError(Error)
}
