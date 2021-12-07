import Foundation
import SwiftUI


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
    @MainActor
    public func send(_ event: Event)
    {
        guard let stream = self.reducer(&self.state, event) else { return }
        
        Task.detached {
            for await event in stream
            {
                await self.send(event)
            }
        }
    }
}
