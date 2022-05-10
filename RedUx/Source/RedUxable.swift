import SwiftUI

/// A protocol to help guide structuring a SwiftUI view to use RedUx.
///
/// The use of this protocol isn't required in order to use RedUx. It can be used as a
/// guide on how to setup RedUx.
///
/// An example of this may look like:
///
/// ```swift
/// import RedUx
/// import SwiftUI
///
///
/// struct RootScreen: View, RedUxable {
///     typealias LocalState = AppState
///     typealias LocalEvent = AppEvent
///     typealias LocalEnvironment = AppEnvironment
///
///     let store: LocalStore
///     @StateObject var viewModel: LocalViewModel
///
///     // MARK: Initialization
///
///     init(store: LocalStore, viewModel: LocalViewModel) {
///         self.store = store
///         self._viewModel = .init(wrappedValue: viewModel)
///     }
///
///     // MARK: Body
///
///     var body: some View {
///         VStack(alignment: .center) {
///             Text(verbatim: .init(self.viewModel.count))
///                 .font(.largeTitle)
///
///             HStack {
///                 Button("Decrement") {
///                     self.viewModel.send(.decrement)
///                 }
///                 .buttonStyle(.bordered)
///
///                 Button("Increment") {
///                     self.viewModel.send(.increment)
///                 }
///                 .buttonStyle(.bordered)
///
///                 Button("Delayed increment") {
///                     self.viewModel.send(.incrementWithDelay)
///                 }
///                 .buttonStyle(.bordered)
///             }
///         }
///     }
/// }
///
///
///
/// // MARK: Preview
///
/// struct RootScreen_Previews: PreviewProvider {
///     static var previews: some View {
///         RootScreen.mock(
///             state: .init(
///                 count: 0
///             ),
///             environment: .mock
///         )
///     }
/// }
/// ```
public protocol RedUxable {
    
    /// The local state type.
    associatedtype LocalState: Equatable
    
    /// The local event type.
    associatedtype LocalEvent
    
    /// The local state type.
    associatedtype LocalEnvironment
    
    /// The local store.
    typealias LocalStore = Store<LocalState, LocalEvent, LocalEnvironment>
    
    /// The local view model
    typealias LocalViewModel = ViewModel<LocalState, LocalEvent, LocalEnvironment>
    
    /// Create a "live" RedUxable view with a store and view model.
    /// - Parameters:
    ///     - store: The store.
    /// - Returns: A view.
    static func make(store: LocalStore) -> Self
    
    
    /// Create a "mock" RedUxable view.
    /// - Parameters:
    ///     - state: The state.
    ///     - environment: The environment.
    /// - Returns: A view.
    static func mock(
        state: LocalState,
        environment: LocalEnvironment
    ) -> Self
    
    /// The store
    var store: LocalStore { get }
    
    /// The view model
    var viewModel: LocalViewModel { get }
    
    /// Initialize a new RedUxable view.
    init(store: LocalStore, viewModel: LocalViewModel)
}

// MAKR: Default implementation

extension RedUxable {
    /// Create a "live" RedUxable view with a store.
    /// - Parameter store: The store
    /// - Returns: A view.
    public static func make(store: LocalStore) -> Self {
        .init(store: store, viewModel: .init(store))
    }
    
    /// Create a "mock" RedUxable view.
    ///
    /// This function will create a store that uses the state and environment object passed
    /// and an `empty` reducer.
    /// - Parameters:
    ///   - state: The state.
    ///   - environment: The environment. Generally, this would be a mocked environment.
    /// - Returns: A view.
    public static func mock(
        state: LocalState,
        environment: LocalEnvironment
    ) -> Self {
        let store = LocalStore(
            state: state,
            reducer: .empty,
            environment: environment,
            middlewares: []
        )
        
        return .init(
            store: store,
            viewModel: .init(store)
        )
    }
}
