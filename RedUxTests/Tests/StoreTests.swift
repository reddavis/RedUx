import XCTest
@testable import RedUx


final class StoreTests: XCTestCase {
    private var store: Store<AppState, AppEvent, AppEnvironment>!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.store = .init(
            state: .init(),
            reducer: reducer,
            environment: .init(),
            middlewares: [
                TestMiddleware().eraseToAnyMiddleware(),
                ScopedMiddleware().pull(
                    inputEvent: {
                        guard case let AppEvent.subEvent(localEvent) = $0 else { return nil }
                        return localEvent
                    },
                    outputEvent: AppEvent.subEvent,
                    state: \.subState
                )
            ]
        )
    }

    // MARK: Tests
    
    func testSendingEvent() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValue("a"))
        XCTAssertEqual(self.store.state.value, "a")
        XCTAssertEqual(self.store.state.eventsReceived, [.setValue("a")])
    }
        
    func testScopedStore() {
        let scopedStore = self.store.scope(
            state: \.subState,
            event: AppEvent.subEvent,
            environment: { $0 }
        )
        
        XCTAssertNil(scopedStore.state.value)
        scopedStore.send(.setValue("a"))
        
        // Check scoped store's value changes
        XCTAssertEventuallyEqual(scopedStore.state.value, "a")
        
        // Check scoped store's received event
        XCTAssertEventuallyEqual(scopedStore.state.eventsReceived, [.setValue("a")])

        // Check parent store's value changes
        XCTAssertEventuallyEqual(self.store.state.eventsReceived, [.subEvent(.setValue("a"))])
    }
    
    // MARK: Middleware
    
    func testMiddleware() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueByEffect("a"))
        
        XCTAssertEventuallyEqual(self.store.state.value, "a")
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueByEffect("a"), .setValue("a")]
        )
    }
    
    func testScopedMiddleware() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.subEvent(.setValueByEffect("a")))
        
        XCTAssertEventuallyEqual(
            self.store.state.subState.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.subEvent(.setValueByEffect("a")), .subEvent(.setValue("a"))]
        )
    }
}
