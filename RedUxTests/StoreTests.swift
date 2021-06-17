import XCTest
@testable import RedUx


final class StoreTests: XCTestCase
{
    // Private
    private var store: Store<TestState, TestEvent, TestEnvironment>!
    
    // MARK: Setup
    
    override func setUpWithError() throws
    {
        self.store = .init(
            initialState: .init(),
            reducer: reducer,
            environment: .init()
        )
    }

    // MARK: Tests
    
    func testSendingEventWithNoEffect() async
    {
        XCTAssertNil(self.store.state.value)
        await self.store.send(.setValue("a"))
        XCTAssertEqual(self.store.state.value, "a")
        XCTAssertEqual(self.store.state.eventsReceived, [.setValue("a")])
    }
    
    func testSendingEventWithEffect() async
    {
        XCTAssertNil(self.store.state.value)
        await self.store.send(.setValueByEffect("a"))

        XCTAssertEqual(self.store.state.value, "a")
        XCTAssertEqual(self.store.state.eventsReceived, [.setValueByEffect("a"), .setValue("a")])
    }

    func testBinding()
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
        return .init {
            .setValue(value)
        }
    case .scopedEvent(let scopedEvent):
        switch scopedEvent
        {
        case .setScopedValue(let value):
            state.value = value
            return .none
        case .setScopedValueByEffect(let value):
            return .init {
                .setValue(value)
            }
        }
    }
}



// MARK: Test event

fileprivate enum TestEvent: Equatable
{
    case setValue(String)
    case setValueByEffect(String)
    case scopedEvent(ScopedEvent)
}

// MARK: Scoped event

fileprivate enum ScopedEvent: Equatable
{
    case setScopedValue(String)
    case setScopedValueByEffect(String)
}



// MARK: Test state

fileprivate struct TestState
{
    var value: String? = nil
    var eventsReceived: [TestEvent] = []
}



// MARK: Environment

fileprivate struct TestEnvironment { }
