import Foundation

public enum ConnectionError: LocalizedError {
    case malformedUrl
    case response(Error)
    case wrongResponseType
    case emptyResponse
    case httpError(code: Int, data: Data?)
    case decodeError(Error)
    
    var localizedDescription: String {
        switch self {
        case .malformedUrl:
            return "Malformed url"
        case .wrongResponseType:
            return "Wrong response type"
        case .emptyResponse:
            return "Empty response"
        case .httpError(code: let code, data: _):
            return "HTTP \(code)"
        case .decodeError(let error):
            return error.localizedDescription
        case .response(let error):
            return error.localizedDescription
        }
    }
}
