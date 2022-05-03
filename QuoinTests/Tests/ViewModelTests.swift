import XCTest
@testable import Quoin

final class ViewModelTests: XCTestCase {
    private var store: Store<AppState, AppEvent, AppEnvironment>!
    private var viewModel: ViewModel<AppState, AppEvent>!
    private let value = "a"
    
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
    
    func testStateChangesFromEventPropagateToViewModel() {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue(self.value))
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testStateChangesFromEventViaMiddlewarePropagateToViewModel() {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect(self.value))
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueViaMiddleware(self.value), .setValue(self.value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueViaMiddleware(self.value), .setValue(self.value)]
        )
    }
    
    func testStateChangesFromEventViaEffectPropagateToViewModel() {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect(self.value))
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
    }
    
    // MARK: Bindings
    
    func testBindingWithValue() {
        let binding = self.viewModel.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = self.value

        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testBindingEmitsEventOnWrappedValueChange() {
        let binding = self.viewModel.binding(
            value: \.value,
            event: .setValueToA
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValueToA event.
        binding.wrappedValue = "whatever"
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
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
    
    func testBindingRemovesDuplicateSetterCalls() {
        let binding = self.viewModel.binding(
            value: \.value,
            event: AppEvent.setValue
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValue event.
        binding.wrappedValue = self.value
        
        XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )
        
        XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testReadonlyBindingReceivesValueChange() {
        let binding = self.viewModel.binding(
            value: \.value
        )
        
        XCTAssertNil(binding.wrappedValue)
        self.viewModel.send(.setValue(self.value))
        XCTAssertEventuallyEqual(
            binding.wrappedValue,
            self.value
        )
    }
    
    func testReadonlyBindingDoesNotEmitsEventOnWrappedValueChange() {
        let binding = self.viewModel.binding(
            value: \.value
        )
        binding.wrappedValue = "whatever"
        
        XCTAssertNil(binding.wrappedValue)
        XCTAssertNil(self.store.state.value)
        XCTAssertNil(self.viewModel.state.value)
    }
}
