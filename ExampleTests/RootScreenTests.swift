import XCTest
@testable import Example

class RootScreenTests: XCTestCase {
    func testStateChange() async {
        let store = RootScreen.LocalStore.make()
        
        await XCTAssertStateChange(
            store: store,
            events: [
                .increment,
                .decrement,
                .incrementWithDelayViaEffect
            ],
            matches: [
                .init(),
                .init(count: 1),
                .init(count: 0),
                .init(count: 1)
            ]
        )
    }
}
