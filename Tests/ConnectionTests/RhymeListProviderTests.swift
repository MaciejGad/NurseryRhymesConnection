import XCTest

import Connection
import Models

final class RhymeListProviderTest: XCTestCase {
    var sut: RhymeListProvider!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let configuration = URLSessionConfiguration.default
           configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        sut = RhymeListProvider(session: urlSession)
    }
    
    override func tearDown() {
        sut = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testSuccess() {
        //given
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://maciejgad.github.io/NurseryRhymesJSON/data/list.json")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = listJSON.data(using: .utf8)
            return (response, data)
        }
        let expectation = self.expectation(description: "fetch")
        
        //when
        var output: List? = nil
        sut.fetchList { (result) in
            switch result {
            case .success(let list):
                output = list
            case .failure(let error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(output)
        XCTAssertEqual(output?.results.count, 4)
        let first = output?.results.first
        XCTAssertNotNil(first)
        XCTAssertEqual(first?.rhymeId, "01_the_three_children")
    }
    
    func testFailure() {
        //given
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://maciejgad.github.io/NurseryRhymesJSON/data/list.json")
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let expectation = self.expectation(description: "fetch")
        
        //when
        var error: RhymeListProviderError? = nil
        sut.fetchList { (result) in
            switch result {
            case .failure(let anError):
                error = anError
            case .success:
                XCTFail("Success shouldn't be called")
            }
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(error)
        if case let .httpError(code: code, data: data) = error {
            XCTAssertEqual(code, 500)
            XCTAssertEqual(data?.count, 0)
        } else {
            XCTFail("Error should be RhymeListProviderError.httpError")
        }
    }
    
    static var allTests = [
        ("testSuccess", testSuccess),
        ("testFailure", testFailure)
    ]
}

fileprivate let listJSON = #"{"results":[{"rhymeId":"01_the_three_children","title":"THE THREE CHILDREN","image":"https:\/\/maciejgad.github.io\/NurseryRhymesJSON\/images\/01_the_three_children.jpg"},{"rhymeId":"02_kindness_to_animals","title":"KINDNESS TO ANIMALS","image":"https:\/\/maciejgad.github.io\/NurseryRhymesJSON\/images\/02_kindness_to_animals.jpg"},{"rhymeId":"03_how_doth_the_little_busy_bee","author":"Isaac Watts","title":"HOW DOTH THE LITTLE BUSY BEE","image":"https:\/\/maciejgad.github.io\/NurseryRhymesJSON\/images\/03_how_doth_the_little_busy_bee.jpg"},{"rhymeId":"04_twinkle_twinkle","title":"TWINKLE, TWINKLE","image":"https:\/\/maciejgad.github.io\/NurseryRhymesJSON\/images\/04_twinkle_twinkle.jpg"}]}"#
