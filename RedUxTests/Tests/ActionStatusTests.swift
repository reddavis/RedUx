import XCTest
@testable import RedUx

class ActionStatusTests: XCTestCase {
    func testIsIdle() {
        XCTAssertTrue(ActionStatus<TestError>.idle.isIdle)
        
        XCTAssertFalse(ActionStatus<TestError>.loading.isIdle)
        XCTAssertFalse(ActionStatus<TestError>.complete.isIdle)
        XCTAssertFalse(ActionStatus<TestError>.failed(.init()).isIdle)
    }
    
    func testIsLoading() {
        XCTAssertTrue(ActionStatus<TestError>.loading.isLoading)
        
        XCTAssertFalse(ActionStatus<TestError>.idle.isLoading)
        XCTAssertFalse(ActionStatus<TestError>.complete.isLoading)
        XCTAssertFalse(ActionStatus<TestError>.failed(.init()).isLoading)
    }
    
    func testIsComplete() {
        XCTAssertTrue(ActionStatus<TestError>.complete.isComplete)
        
        XCTAssertFalse(ActionStatus<TestError>.idle.isComplete)
        XCTAssertFalse(ActionStatus<TestError>.loading.isComplete)
        XCTAssertFalse(ActionStatus<TestError>.failed(.init()).isComplete)
    }
    
    func testIsFailed() {
        XCTAssertTrue(ActionStatus<TestError>.failed(.init()).isFailed)
        
        XCTAssertFalse(ActionStatus<TestError>.idle.isFailed)
        XCTAssertFalse(ActionStatus<TestError>.loading.isFailed)
        XCTAssertFalse(ActionStatus<TestError>.complete.isFailed)
    }
    
    func testErrorAccessor() {
        let error = TestError()
        XCTAssertEqual(ActionStatus.failed(error).error, error)
        
        XCTAssertNil(ActionStatus<TestError>.idle.error)
        XCTAssertNil(ActionStatus<TestError>.loading.error)
        XCTAssertNil(ActionStatus<TestError>.complete.error)
    }
}

// MARK: Error

fileprivate struct TestError: Error, Equatable {}
