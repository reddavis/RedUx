import SwiftUI


/// A view model wraps a store and observes state changes that can be used
/// within a view.
///
/// ```swift
/// extension RootScreen {
///     struct ContentView: View {
///         let store: Store
///         @StateObject var viewModel: ViewModel<AppState, AppEvent>
///
///         // MARK: Body
///
///         var body: some View {
///             VStack(alignment: .center) {
///                 Text(verbatim: .init(self.viewModel.count))
///                     .font(.largeTitle)
///
///                 HStack {
///                     Button("Decrement") {
///                         self.viewModel.send(.decrement)
///                     }
///                     .buttonStyle(.bordered)
///
///                     Button("Increment") {
///                         self.viewModel.send(.increment)
///                     }
///                     .buttonStyle(.bordered)
///
///                     Button("Delayed increment") {
///                         self.viewModel.send(.incrementWithDelay)
///                     }
///                     .buttonStyle(.bordered)
///                 }
///             }
///         }
///     }
/// }
/// ```
@dynamicMemberLookup
public final class ViewModel<State: Equatable, Event>: ObservableObject {
    
    /// The state of the store.
    @Published var state: State
    
    // Private
    private var stateTask: Task<Void, Never>?
    private let _send: (Event) -> Void
    
    // MARK: Initialization
    
    /// Create a new view model instance.
    /// - Parameter store: The store.
    public init<Environment>(_ store: Store<State, Event, Environment>) {
        self.state = store.state
        self._send = { store.send($0) }
        self.stateTask = Task { [weak self] in
            do {
                for try await state in store.stateSequence.removeDuplicates() {
                    guard
                        let self = self,
                        !Task.isCancelled else { break }
                    
                    await MainActor.run {
                        self.state = state
                    }
                }
            } catch { }
        }
    }
    
    deinit {
        self.stateTask?.cancel()
    }
    
    // MARK: API
    
    /// Send an event to the store.
    /// - Parameter event: The even to send.
    public func send(_ event: Event) {
        self._send(event)
    }
    
    /// Returns the resulting state value of a given key path.
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        self.state[keyPath: keyPath]
    }
}

// MARK: Binding

extension ViewModel {
    /// Creates a `Binding` that prevents direct write access to the
    /// state and instead sends an event on `set`.
    ///
    /// This makes working with SwiftUI components easier.
    ///
    /// For example:
    ///
    /// ```swift
    /// TextField(
    ///     "Email",
    ///     text: viewStore.binding(
    ///         get: \.email,
    ///         send: { .setEmail($0) }
    ///     )
    /// )
    /// ```
    /// - Parameters:
    ///   - value: A function to extract the value from the state.
    ///   - event: A function to build the event that is sent to the store.
    /// - Returns: A binding.
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: @escaping (ScopedState) -> Event
    ) -> Binding<ScopedState> {
        Binding(
            get: { value(self.state) },
            set: { scopedState, transaction in
                guard transaction.animation == nil else {
                    _ = SwiftUI.withTransaction(transaction) {
                        self.send(event(scopedState))
                    }
                    return
                }
                
                self.send(event(scopedState))
            }
        )
    }
    
    /// Creates a `Binding` that prevents direct write access to the
    /// state and instead sends an event on `set`.
    ///
    /// This makes working with SwiftUI components easier.
    ///
    /// For example:
    ///
    /// ```swift
    /// SomeView()
    ///     .alert(
    ///         "Error",
    ///         isPresented: self.store.binding(
    ///             value: { $0.loginStatus.isFailed },
    ///             event: .resetLoginState
    ///         ),
    ///         actions: { },
    ///         message: {
    ///             Text(self.store.loginStatus.failedMessage)
    ///         }
    ///     )
    /// ```
    /// - Parameters:
    ///   - value: A function to extract the value from the state.
    ///   - event: An event that is sent to the store.
    /// - Returns: A binding.
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: Event
    ) -> Binding<ScopedState> {
        self.binding(
            value: value,
            event: { _ in event }
        )
    }
}
