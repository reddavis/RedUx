import XCTest
@testable import RedUx


@MainActor
final class StoreTests: XCTestCase
{
    // Private
    private var store: Store<State, Event, Environment>!
    
    // MARK: Setup
    
    @MainActor
    override func setUpWithError() throws
    {
        self.store = .init(
            state: .init(),
            reducer: reducer,
            environment: .init()
        )
    }

    // MARK: Tests
    
    func testSendingEventWithNoEffect() async
    {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValue("a"))
        XCTAssertEqual(self.store.state.value, "a")
        XCTAssertEqual(self.store.state.eventsReceived, [.setValue("a")])
    }
    
    func testSendingEventWithEffect() async
    {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueByEffect("a"))
        
        await XCTAssertEventuallyEqual(
            { self.store.state.value },
            { "a" }
        )
        
        await XCTAssertEventuallyEqual(
            { self.store.state.eventsReceived },
            { [.setValueByEffect("a"), .setValue("a")] }
        )
    }
    
    func testBindingWithValue() async
    {
        let binding = self.store.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = "a"

        await XCTAssertEventuallyEqual(
            { self.store.state.value },
            { "a" }
        )
        
        await XCTAssertEventuallyEqual(
            { self.store.state.eventsReceived },
            { [.setValue("a")] }
        )
    }
    
    func testBinding() async
    {
        let binding = self.store.binding(
            value: \.value,
            event: .setValueToA
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = "whatever"
        
        await XCTAssertEventuallyEqual(
            { self.store.state.value },
            { "a" }
        )
        
        await XCTAssertEventuallyEqual(
            { self.store.state.eventsReceived },
            { [.setValueToA, .setValue("a")] }
        )
    }
    
    func testScopedStore() async
    {
        let scopedStore = self.store.scope(
            state: \.subState,
            event: Event.subEvent,
            environment: { $0 }
        )
        
        scopedStore.send(.setValue("a"))
        
        // Check scoped store's value changes
        await XCTAssertEventuallyEqual(
            { scopedStore.state.value },
            { "a" }
        )
        
        // Check scoped store's received event
        await XCTAssertEventuallyEqual(
            { scopedStore.state.eventsReceived },
            { [.setValue("a")] }
        )
        
        // Check parent store's value changes
        await XCTAssertEventuallyEqual(
            { self.store.state.eventsReceived },
            { [.subEvent(.setValue("a"))] }
        )
    }
}
