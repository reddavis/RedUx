import XCTest
@testable import RedUx


@MainActor
final class StoreTests: XCTestCase
{
    // Private
    private var store: Store<TestState, TestEvent, TestEnvironment>!
    
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
    
    func testBindingWithValue()
    {
        let binding = self.store.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = "a"
        XCTAssertEqual(self.store.state.value, "a")
        XCTAssertEqual(self.store.state.eventsReceived, [.setValue("a")])
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
}

 

// MARK: Test reducer

fileprivate let reducer: Reducer<TestState, TestEvent, TestEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event
    {
    case .setValue(let value):
        state.value = value
        return .none
    case .setValueByEffect(let value):
        return .just(.setValue(value))
    case .setValueToA:
        return .just(.setValue("a"))
    }
}



// MARK: Test event

fileprivate enum TestEvent: Equatable
{
    case setValue(String)
    case setValueByEffect(String)
    case setValueToA
}



// MARK: Test state

fileprivate struct TestState
{
    var value: String? = nil
    var eventsReceived: [TestEvent] = []
}



// MARK: Environment

fileprivate struct TestEnvironment { }
