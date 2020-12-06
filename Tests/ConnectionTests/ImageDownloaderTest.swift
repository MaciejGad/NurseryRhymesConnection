import XCTest

import Connection
import Models


final class ImageDownloaderTest: XCTestCase {
    var sut: ImageDownloader!
    var baseURL: URL!
    var callMock: CallMock!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        baseURL = URL(string: testingDomain)!
        let data = Data(base64Encoded: imageBase64)
        callMock = CallMock(success: data)
        sut = ImageDownloader(baseURL: baseURL, call: callMock)
    }
    
    override func tearDown() {
        sut = nil
        baseURL = nil
        callMock = nil
        super.tearDown()
    }
    
    func testSuccess() {
        //given
        let file: String = "test.jpg"
        
        //when
        var output: Image? = nil
        sut.fetch(file: file) { result in
            switch result {
            case .success(let image):
                output = image
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        
        //then
        XCTAssertNotNil(output)
        #if canImport(UIKit)
        let image = output!
        XCTAssertEqual(image.size, .init(width: 10, height: 10))
        #endif
    }
    
    func testFailure() {
        //given
        let file: String = "test.jpg"
        callMock.response = .failure(.httpError(code: 503, data: nil))

        //when
        var error: ConnectionError? = nil
        sut.fetch(file: file) { result in
            switch result {
            case .failure(let anError):
                error = anError
            case .success:
                XCTFail("Success shoudn't be called")
            }
        }

        //then
        XCTAssertNotNil(error)
        if case let .httpError(code: code, data: data) = error! {
            XCTAssertEqual(code, 503)
            XCTAssertNil(data)
        } else {
            XCTFail("Error should be ConnectionError.httpError")
        }
    }
    
    static var allTests = [
        ("testSuccess", testSuccess),
        ("testFailure", testFailure)
    ]
}

fileprivate let testingDomain = "https://testing.io"

fileprivate let imageBase64 = #"/9j/4AAQSkZJRgABAQAASABIAAD/4QCMRXhpZgAATU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAAAqgAwAEAAAAAQAAAAoAAAAA/+0AOFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAAOEJJTQQlAAAAAAAQ1B2M2Y8AsgTpgAmY7PhCfv/CABEIAAoACgMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAADAgQBBQAGBwgJCgv/xADDEAABAwMCBAMEBgQHBgQIBnMBAgADEQQSIQUxEyIQBkFRMhRhcSMHgSCRQhWhUjOxJGIwFsFy0UOSNIII4VNAJWMXNfCTc6JQRLKD8SZUNmSUdMJg0oSjGHDiJ0U3ZbNVdaSVw4Xy00Z2gONHVma0CQoZGigpKjg5OkhJSldYWVpnaGlqd3h5eoaHiImKkJaXmJmaoKWmp6ipqrC1tre4ubrAxMXGx8jJytDU1dbX2Nna4OTl5ufo6erz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAECAAMEBQYHCAkKC//EAMMRAAICAQMDAwIDBQIFAgQEhwEAAhEDEBIhBCAxQRMFMCIyURRABjMjYUIVcVI0gVAkkaFDsRYHYjVT8NElYMFE4XLxF4JjNnAmRVSSJ6LSCAkKGBkaKCkqNzg5OkZHSElKVVZXWFlaZGVmZ2hpanN0dXZ3eHl6gIOEhYaHiImKkJOUlZaXmJmaoKOkpaanqKmqsLKztLW2t7i5usDCw8TFxsfIycrQ09TV1tfY2drg4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwAIBgYHBgUIBwcHCQkICgwUDQwLCwwZEhMPFB0aHx4dGhwcICQuJyAiLCMcHCg3KSwwMTQ0NB8nOT04MjwuMzQy/9sAQwEJCQkMCwwYDQ0YMiEcITIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy/9oADAMBAAIRAxEAAAEfTc/0uS//2gAIAQEAAQUCSjK55Tuh/rkn2f/aAAgBAxEBPwF//9oACAECEQE/AZP/2gAIAQEABj8CHMyQoU6cu0PyYf8A/8QAMxABAAMAAgICAgIDAQEAAAILAREAITFBUWFxgZGhscHw0RDh8SAwQFBgcICQoLDA0OD/2gAIAQEAAT8hgfFmce8Y2uuChPBNJ5ni/wD/2gAMAwEAAhEDEQAAEFP/xAAzEQEBAQADAAECBQUBAQABAQkBABEhMRBBUWEgcfCRgaGx0cHh8TBAUGBwgJCgsMDQ4P/aAAgBAxEBPxDBMzq//9oACAECEQE/EOeP1v/aAAgBAQABPxDO3DI5pykkO+IoCGadypU3bG4sfiWrVkj36v8A/9k="#
