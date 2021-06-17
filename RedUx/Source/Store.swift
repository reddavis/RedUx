import Foundation
import SwiftUI


@dynamicMemberLookup
public final class Store<State, Event, Environment>: ObservableObject
{
    // Public
    @Published public var state: State
    public let environment: Environment
    
    // Private
    private let reducer: (inout State, Event) -> Effect<Event>?
    
    // MARK: Initialization
    
    public convenience init(
        initialState: State,
        reducer: Reducer<State, Event, Environment>,
        environment: Environment
    )
    {
        self.init(
            initialState: initialState,
            reducer: { reducer.execute(state: &$0, event: $1, environment: environment) },
            environment: environment
        )
    }
    
    private init(
        initialState: State,
        reducer: @escaping (inout State, Event) -> Effect<Event>?,
        environment: Environment
    )
    {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    // MARK: State
    
    public subscript<U>(dynamicMember keyPath: KeyPath<State, U>) -> U
    {
        self.state[keyPath: keyPath]
    }
}

// MARK: Events

extension Store
{
    @MainActor
    public func send(_ event: Event) async
    {
        guard let effect = self.reducer(&self.state, event) else { return }
        
        let event = await effect.closure()
        await self.send(event)
    }
    
    func sendSyncronously(_ event: Event)
    {
        guard let effect = self.reducer(&self.state, event) else { return }
        
        async {
            let event = await effect.closure()
            await self.send(event)
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
                    SwiftUI.withTransaction(transaction) {
                        self.sendSyncronously(event(scopedState))
                    }
                    return
                }
                
                self.sendSyncronously(event(scopedState))
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
