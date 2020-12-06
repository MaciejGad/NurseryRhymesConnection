import XCTest

import Connection
import Models


final class BookListForRhymeProviderTest: XCTestCase {
    var sut: BookListForRhymeProvider!
    var baseURL: URL!
    var callMock: CallMock!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        baseURL = URL(string: testingDomain)!
        let data = bookListJSON.data(using: .utf8)
        callMock = CallMock(success: data)
        sut = BookListForRhymeProvider(baseURL: baseURL, call: callMock)
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
        var output: BookListForRhyme? = nil
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
        XCTAssertEqual(output?.rhymeId, id)
        XCTAssertEqual(output?.books.count, 1)
        let book = output?.books.first
        XCTAssertNotNil(book)
        XCTAssertEqual(book?.title, "Five Little Ducks Went Out One Day!")
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

fileprivate let bookListJSON = #"{"books":[{"author":"Margaret Bateson-Hill","coverImage":"https:\/\/images-na.ssl-images-amazon.com\/images\/I\/61i7xJAXwDL._SX258_BO1,204,203,200_.jpg","id":"five-little-ducks-books","title":"Five Little Ducks Went Out One Day!","urls":["https:\/\/www.amazon.com\/Five-Little-Ducks-Went-Out\/dp\/1857143957"]}],"rhymeId":"five-little-ducks"}"#

fileprivate let testingDomain = "https://testing.io"
