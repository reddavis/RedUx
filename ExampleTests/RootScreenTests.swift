import XCTest
@testable import Example

class RootScreenTests: XCTestCase {
    var store: AppStore!
    
    override func setUpWithError() throws {
        self.store = .make()
    }
    
    // MARK: Test
    
    func testIncrement() async {
        await XCTAssertStateChange(
            store: self.store,
            event: .increment,
            matches: [
                .init(),
                .init(count: 1)
            ]
        )
    }
    
    func testDecrement() async {
        await XCTAssertStateChange(
            store: store,
            event: .decrement,
            matches: [
                .init(),
                .init(count: -1)
            ]
        )
    }
    
    func testIncrementWithEffect() async {
        await XCTAssertStateChange(
            store: store,
            event: .incrementWithDelayViaEffect,
            matches: [
                .init(),
                .init(count: 1)
            ]
        )
    }
}
