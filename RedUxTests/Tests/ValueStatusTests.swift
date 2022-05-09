import XCTest
@testable import RedUx

class ValueStatusTests: XCTestCase {
    fileprivate typealias Status = ValueStatus<String, TestError>
    
    func testIsIdle() {
        XCTAssertTrue(Status.idle.isIdle)
        
        XCTAssertFalse(Status.loading(nil).isIdle)
        XCTAssertFalse(Status.complete("").isIdle)
        XCTAssertFalse(Status.failed(.init(), nil).isIdle)
    }
    
    func testIsLoading() {
        XCTAssertTrue(Status.loading(nil).isLoading)
        
        XCTAssertFalse(Status.idle.isLoading)
        XCTAssertFalse(Status.complete("").isLoading)
        XCTAssertFalse(Status.failed(.init(), nil).isLoading)
    }
    
    func testIsComplete() {
        XCTAssertTrue(Status.complete("").isComplete)
        
        XCTAssertFalse(Status.idle.isComplete)
        XCTAssertFalse(Status.loading(nil).isComplete)
        XCTAssertFalse(Status.failed(.init(), nil).isComplete)
    }
    
    func testIsFailed() {
        XCTAssertTrue(Status.failed(.init(), nil).isFailed)
        
        XCTAssertFalse(Status.idle.isFailed)
        XCTAssertFalse(Status.loading(nil).isFailed)
        XCTAssertFalse(Status.complete("").isFailed)
    }
    
    func testErrorAccessor() {
        let error = TestError()
        XCTAssertEqual(Status.failed(error, nil).error, error)
        
        XCTAssertNil(Status.idle.error)
        XCTAssertNil(Status.loading(nil).error)
        XCTAssertNil(Status.complete("").error)
    }
}

// MARK: Error

fileprivate struct TestError: Error, Equatable {}
