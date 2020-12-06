import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RhymeListProviderTest.allTests),
    ]
}
#endif
