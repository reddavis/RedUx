import XCTest
@testable import Quoin

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
    
    // MARK: Scoped store
    
    func testScopedStore() {
        let scopedStore = self.store.scope(
            state: \.subState,
            event: AppEvent.subEvent,
            environment: { $0 }
        )
        let value = "a"
        
        XCTAssertNil(scopedStore.state.value)
        scopedStore.send(.setValue(value))
        
        // Check scoped store's value changes
        XCTAssertEventuallyEqual(scopedStore.state.value, value)
        
        // Check scoped store's received event
        XCTAssertEventuallyEqual(scopedStore.state.eventsReceived, [.setValue(value)])

        // Check parent store's value changes
        XCTAssertEventuallyEqual(self.store.state.eventsReceived, [.subEvent(.setValue(value))])
    }
    
    func testSendingEffectTriggeringEventToScopedStore() {
        let scopedStore = self.store.scope(
            state: \.subState,
            event: AppEvent.subEvent,
            environment: { $0 }
        )
        let value = "a"
        
        XCTAssertNil(scopedStore.state.value)
        scopedStore.send(.setValueViaEffect(value))
        
        // Check scoped store's value changes
        XCTAssertEventuallyEqual(scopedStore.state.value, value)
        
        // Check scoped store's received event
        XCTAssertEventuallyEqual(
            scopedStore.state.eventsReceived,
            [.setValueViaEffect(value), .setValue(value)]
        )

        // Check parent store's value changes
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.subEvent(.setValueViaEffect(value)), .setValue(value)]
        )
    }
    
    // MARK: Effects
    
    func testSendingEventThatTriggersAnEffect() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect("a"))
        
        XCTAssertEventuallyEqual(
            self.store.state,
            .init(
                value: "a",
                eventsReceived: [
                    .subEvent(.setValueViaEffect("a")),
                    .subEvent(.setValue("a"))
                ]
            )
        )
    }
    
    // MARK: Middleware
    
    func testMiddleware() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaMiddleware("a"))
        
        XCTAssertEventuallyEqual(self.store.state.value, "a")
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueViaMiddleware("a"), .setValue("a")]
        )
    }
    
    func testScopedMiddleware() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.subEvent(.setValueViaMiddleware("a")))
        
        XCTAssertEventuallyEqual(
            self.store.state.subState.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.subEvent(.setValueViaMiddleware("a")), .subEvent(.setValue("a"))]
        )
    }
}
