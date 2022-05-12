import XCTest
@testable import RedUx

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
    
    func testStateChangesFromEventPropagateToViewModel() async {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue(self.value))
        
        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )

        await XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testStateChangesFromEventViaMiddlewarePropagateToViewModel() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect(self.value))
        
        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
    }
    
    func testStateChangesFromEventViaEffectPropagateToViewModel() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect(self.value))
        
        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValueViaEffect(self.value), .setValue(self.value)]
        )
    }
    
    // MARK: Bindings
    
    func testBindingWithValue() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: { .setValue($0 ?? "") }
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = self.value

        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testBindingEmitsEventOnWrappedValueChange() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: .setValueToA
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValueToA event.
        binding.wrappedValue = "whatever"
        
        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValueToA]
        )

        await XCTAssertEventuallyEqual(
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
        binding.wrappedValue = self.value
        
        await XCTAssertEventuallyEqual(
            self.store.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.value,
            self.value
        )
        
        await XCTAssertEventuallyEqual(
            self.store.state.eventsReceived,
            [.setValue(self.value)]
        )
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state.eventsReceived,
            [.setValue(self.value)]
        )
    }
    
    func testReadonlyBindingReceivesValueChange() async {
        let binding = self.viewModel.binding(
            value: \.value
        )
        
        XCTAssertNil(binding.wrappedValue)
        self.viewModel.send(.setValue(self.value))
        await XCTAssertEventuallyEqual(
            binding.wrappedValue,
            self.value
        )
    }
    
    func testReadonlyBindingDoesNotEmitsEventOnWrappedValueChange() async {
        let binding = self.viewModel.binding(
            value: \.value
        )
        binding.wrappedValue = "whatever"
        
        XCTAssertNil(binding.wrappedValue)
        XCTAssertNil(self.store.state.value)
        XCTAssertNil(self.viewModel.state.value)
    }
}
