import XCTest

import Connection
import Models


final class SingleRhymeProviderTest: XCTestCase {
    var sut: SingleRhymeProvider!
    var baseURL: URL!
    var callMock: CallMock!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        baseURL = URL(string: testingDomain)!
        let data = rhymeJSON.data(using: .utf8)
        callMock = CallMock(success: data)
        sut = SingleRhymeProvider(baseURL: baseURL, call: callMock)
    }
    
    override func tearDown() {
        sut = nil
        baseURL = nil
        callMock = nil
        super.tearDown()
    }
    
    func testSuccess() {
        //given
        let id: Rhyme.ID = "five-little-ducks"
        
        //when
        var output: Rhyme? = nil
        sut.fetch(id: id) { result in
            switch result {
            case .success(let rhyme):
                output = rhyme
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        
        //then
        XCTAssertNotNil(output)
        XCTAssertEqual(output?.title, "Five Little Ducks Went Swimming One Day")
    }
    
    func testFailure() {
        //given
        let id: Rhyme.ID = "not-exisitng"
        callMock.response = .failure(.httpError(code: 404, data: nil))
        
        //when
        var error: ConnectionError? = nil
        sut.fetch(id: id) { result in
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
            XCTAssertEqual(code, 404)
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

fileprivate let rhymeJSON = #"{"id":"five-little-ducks","image":"https:\/\/placeducky.com\/real\/281\/276.png","text":"Five little ducks went swimming one day,\nOver the hills and far away,\nAnd Mummy Duck said “Quack, quack, quack”\nBut only four little ducks came back.","title":"Five Little Ducks Went Swimming One Day"}"#

fileprivate let testingDomain = "https://testing.io"
