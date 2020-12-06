import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RhymeListProviderTest.allTests),
        testCase(BookListForRhymeProviderTest.allTests),
        testCase(SingleRhymeProviderTest.allTests),
    ]
}
#endif
