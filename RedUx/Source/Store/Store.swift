import Asynchrone
import Combine
import Foundation
import SwiftUI


/// A Store is the core of the application. It is used to manage state and handle events sent to it.
///
/// Generally an application will have one store and then use the scope function to create sub stores for
/// different components of the app.
@dynamicMemberLookup
public final class Store<State, Event, Environment>: ObservableObject {
    
    /// The state of the store.
    @Published private(set) public var state: State
    
    /// The environment.
    public let environment: Environment
    
    // Private
    private let reducer: (inout State, Event) -> AnyAsyncSequenceable<Event>?
    private var parentStatePropagationCancellable: AnyCancellable?
    
    // MARK: Initialization
    
    /// Construct a Store with state, reducer and environment.
    /// - Parameters:
    ///   - state: An initial state.
    ///   - reducer: A reducer.
    ///   - environment: An environment.
    public convenience init(
        state: State,
        reducer: Reducer<State, Event, Environment>,
        environment: Environment
    ) {
        self.init(
            state: state,
            reducer: { reducer.execute(state: &$0, event: $1, environment: environment) },
            environment: environment
        )
    }
    
    private init(
        state: State,
        reducer: @escaping (inout State, Event) -> AnyAsyncSequenceable<Event>?,
        environment: Environment
    ) {
        self.state = state
        self.reducer = reducer
        self.environment = environment
    }
    
    // MARK: State
    
    public subscript<U>(dynamicMember keyPath: KeyPath<State, U>) -> U {
        self.state[keyPath: keyPath]
    }
    
    // MARK: Events
    
    /// Send an event through the store's reducer.
    /// - Parameter event: The event.
    @MainActor
    public func send(_ event: Event) {
        guard let stream = self.reducer(&self.state, event) else { return }
        
        Task.detached {
            for await event in stream {
                await self.send(event)
            }
        }
    }
}

// MARK: Scope

extension Store
{
    /// Create a sub store from the current store.
    ///
    /// The scoped store derives it's state and environment from the parent store.
    /// Events that are sent to this store are converted a parent store event, using the `fromScopedEvent` parameter
    /// and then passed to the parent store. Changes to the parent state are then reflected back to the scoped store.
    /// - Parameters:
    ///   - state: An initial state.
    ///   - event: A reducer.
    ///   - environment: An environment.
    /// - Returns: A `Store` instance.
    public func scope<ScopedState, ScopedEvent, ScopedEnvironment>(
        state toScopedState: @escaping (_ state: State) -> ScopedState,
        event fromScopedEvent: @escaping (_ event: ScopedEvent) -> Event,
        environment toScopedEnvironment: (_ environment: Environment) -> ScopedEnvironment
    ) -> Store<ScopedState, ScopedEvent, ScopedEnvironment> {
        let scopedStore = Store<ScopedState, ScopedEvent, ScopedEnvironment>(
            state: toScopedState(self.state),
            reducer: .init { state, event, environment in
                Task.detached {
                    await MainActor.run {
                        self.send(fromScopedEvent(event))
                    }
                }

                return .none
            },
            environment: toScopedEnvironment(self.environment)
        )
        
        // Propagate changes to state to scoped store.
        scopedStore.parentStatePropagationCancellable = self.$state
            .dropFirst()
            .sink { [weak scopedStore] state in
                scopedStore?.state = toScopedState(state)
            }
        
        return scopedStore
    }
}
