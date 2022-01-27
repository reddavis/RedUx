import XCTest
@testable import RedUx


final class ViewModelTests: XCTestCase {
    private var store: Store<State, Event, Environment>!
    private var viewModel: ViewModel<State, Event>!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.store = .init(
            state: .init(),
            reducer: reducer,
            environment: .init()
        )
        
        self.viewModel = .init(self.store)
    }

    // MARK: Tests
    
    func testStateChangesFromEventPropagateToViewModel() async {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue("a"))
        
        await XCTAssertEventuallyEqual(
            { self.viewModel.state.value },
            { "a" }
        )
        
        await XCTAssertEventuallyEqual(
            { self.viewModel.state.eventsReceived },
            { [.setValue("a")] }
        )
    }
    
    func testStateChangesFromEventWithEffectPropagateToViewModel() async {
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
    
    func testBindingWithValue() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = "test"

        await XCTAssertEventuallyEqual(
            { self.store.state.value },
            { "test" }
        )
        
        await XCTAssertEventuallyEqual(
            { self.store.state.eventsReceived },
            { [.setValue("test")] }
        )
    }
    
    func testBinding() async {
        let binding = self.viewModel.binding(
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
