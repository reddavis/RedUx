import XCTest
import RedUxTestUtilities
@testable import Example


class RootScreenTests: XCTestCase {
    @MainActor
    func testStateChange() async {
        let store = RootScreen.Store.make()
        
        await XCTAssertStateChange(
            store: store,
            events: [
                .increment,
                .decrement,
                .incrementWithDelay
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
