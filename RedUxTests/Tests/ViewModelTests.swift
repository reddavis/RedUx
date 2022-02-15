import XCTest
@testable import RedUx


final class ViewModelTests: XCTestCase {
    private var store: Store<AppState, AppEvent, AppEnvironment>!
    private var viewModel: ViewModel<AppState, AppEvent>!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.store = .init(
            state: .init(),
            reducer: reducer,
            environment: .init(),
            middlewares: [
                TestMiddleware().eraseToAnyMiddleware()
            ]
        )
        
        self.viewModel = .init(self.store)
    }

    // MARK: Tests
    
    func testStateChangesFromEventPropagateToViewModel() async {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue("a"))
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue("a")]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue("a")]
        )
    }
    
    func testStateChangesFromEventWithEffectPropagateToViewModel() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueByEffect("a"))
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueByEffect("a"), .setValue("a")]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueByEffect("a"), .setValue("a")]
        )
    }
    
    func testBindingWithValue() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = "test"

        XCTAssertEventuallyEqual(
            self.store.state.value,
            "test"
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            "test"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue("test")]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue("test")]
        )
    }
    
    func testBinding() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: .setValueToA
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValueToA event.
        binding.wrappedValue = "whatever"
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            "a"
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueToA]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueToA]
        )
    }
    
    func testBindingRemovesDuplicateSetterCalls() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: AppEvent.setValue
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValue event.
        let value = "a value"
        binding.wrappedValue = value
        binding.wrappedValue = value
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(value)]
        )
    }
}
