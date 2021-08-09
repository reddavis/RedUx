import Foundation
import SwiftUI


@MainActor
@dynamicMemberLookup
public final class Store<State, Event, Environment>: ObservableObject
{
    /// The state of the store.
    @Published private(set) public var state: State
    
    /// The environment.
    public let environment: Environment
    
    // Private
    private let reducer: (inout State, Event) -> AsyncStream<Event>?
    
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
    )
    {
        self.init(
            state: state,
            reducer: { reducer.execute(state: &$0, event: $1, environment: environment) },
            environment: environment
        )
    }
    
    private init(
        state: State,
        reducer: @escaping (inout State, Event) -> AsyncStream<Event>?,
        environment: Environment
    )
    {
        self.state = state
        self.reducer = reducer
        self.environment = environment
    }
    
    // MARK: State
    
    public subscript<U>(dynamicMember keyPath: KeyPath<State, U>) -> U
    {
        self.state[keyPath: keyPath]
    }
    
    // MARK: Events
    
    /// Send an event through the store's reducer.
    /// - Parameter event: The event.
    public func send(_ event: Event)
    {
        guard let stream = self.reducer(&self.state, event) else { return }
        
        Task {
            for await event in stream
            {
                self.send(event)
            }
        }
    }
}


// MARK: Binding

extension Store
{
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: @escaping (ScopedState) -> Event
    ) -> Binding<ScopedState>
    {
        Binding(
            get: { value(self.state) },
            set: { scopedState, transaction in
                guard transaction.animation == nil else
                {
                    _ = SwiftUI.withTransaction(transaction) {
                        self.send(event(scopedState))
                    }
                    return
                }
                
                self.send(event(scopedState))
            }
        )
    }
    
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: Event
    ) -> Binding<ScopedState>
    {
        self.binding(
            value: value,
            event: { _ in event }
        )
    }
}
