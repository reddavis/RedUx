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
    
    func testEventsAreForwardedToStore() async {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue(self.value))
        
        await XCTAssertEventuallyEqual(
            self.store.state,
            .init(
                value: self.value,
                eventsReceived: [.setValue(self.value)]
            )
        )
    }
    
    func testStateChangesFromEventPropagateToViewModel() async {
        XCTAssertNil(self.viewModel.state.value)
        self.viewModel.send(.setValue(self.value))
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state,
            .init(
                value: self.value,
                eventsReceived: [.setValue(self.value)]
            )
        )
    }
    
    func testStateChangesFromEventViaMiddlewarePropagateToViewModel() async {
        XCTAssertNil(self.store.state.value)
        self.viewModel.send(.setValueViaMiddleware(self.value))
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state,
            .init(
                value: self.value,
                eventsReceived: [.setValueViaMiddleware(self.value), .setValue(self.value)]
            )
        )
    }
    
    func testStateChangesFromEventViaEffectPropagateToViewModel() async {
        XCTAssertNil(self.store.state.value)
        self.store.send(.setValueViaEffect(self.value))
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state,
            .init(
                value: self.value,
                eventsReceived: [.setValueViaEffect(self.value), .setValue(self.value)]
            )
        )
    }
    
    // MARK: Bindings
    
    func testBindingWithValue() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: AppEvent.setValue
        )

        XCTAssertNil(self.store.state.value)
        binding.wrappedValue = self.value
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state,
            .init(
                value: self.value,
                eventsReceived: [.setValue(self.value)]
            )
        )
    }
    
    func testBindingRemovesDuplicateSetterCalls() async {
        let binding = self.viewModel.binding(
            value: \.value,
            event: AppEvent.setValue
        )
        XCTAssertNil(self.store.state.value)
        
        // trigger the .setValue event twice.
        binding.wrappedValue = self.value
        binding.wrappedValue = self.value
        
        await XCTAssertEventuallyEqual(
            self.viewModel.state,
            .init(
                value: self.value,
                eventsReceived: [.setValue(self.value)]
            )
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
