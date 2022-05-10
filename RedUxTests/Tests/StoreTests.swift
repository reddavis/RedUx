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
            [.subEvent(.setValueViaEffect(value)), .subEvent(.setValue(value))]
        )
    }
    
    // MARK: Effects
    
    func testSendingEventThatTriggersAnEffect() {
        XCTAssertStateChange(
            store: self.store,
            events: [.setValueViaEffect("a")],
            matches: [
                .init(),
                .init(
                    eventsReceived: [
                        .setValueViaEffect("a")
                    ]
                ),
                .init(
                    value: "a",
                    eventsReceived: [
                        .setValueViaEffect("a"),
                        .setValue("a")
                    ]
                )
            ]
        )
    }
    
    // MARK: Middleware
    
    func testMiddleware() {
        XCTAssertStateChange(
            store: self.store,
            events: [.setValueViaMiddleware("a")],
            matches: [
                .init(),
                .init(
                    eventsReceived: [
                        .setValueViaMiddleware("a")
                    ]
                ),
                .init(
                    value: "a",
                    eventsReceived: [
                        .setValueViaMiddleware("a"),
                        .setValue("a")
                    ]
                )
            ]
        )
    }
    
    func testScopedMiddleware() {
        XCTAssertStateChange(
            store: self.store,
            events: [.subEvent(.setValueViaMiddleware("a"))],
            matches: [
                .init(),
                .init(
                    eventsReceived: [
                        .subEvent(.setValueViaMiddleware("a"))
                    ],
                    subState: .init(
                        eventsReceived: [.setValueViaMiddleware("a")]
                    )
                ),
                .init(
                    eventsReceived: [
                        .subEvent(.setValueViaMiddleware("a")),
                        .subEvent(.setValue("a"))
                    ],
                    subState: .init(
                        value: "a",
                        eventsReceived: [
                            .setValueViaMiddleware("a"),
                            .setValue("a")
                        ]
                    )
                )
            ]
        )
    }
}
