import Asynchrone
import Foundation
import SwiftUI

/// A Store is the core of the application. It is used to manage state and handle events sent to it.
///
/// Generally an application will have one store and then use the scope function to create sub stores for
/// different components of the app.
public final class Store<State, Event, Environment> {    
    /// The state of the store.
    public private(set) var state: State {
        didSet {
            self._stateSequence.yield(self.state)
        }
    }
    
    /// A sequence that emits state changes.
    public let stateSequence: AnyAsyncSequenceable<State>
    
    // Private
    private let reducer: Reducer<State, Event, Environment>.Reduce
    private let environment: Environment
    private var parentStatePropagationTask: Task<Void, Error>?
    private let _stateSequence: PassthroughAsyncSequence<State> = .init()
    
    private let middlewares: [AnyMiddleware<Event, Event, State>]
    private var middlewareTasks: [Task<Void, Error>] = []
    
    private var eventBacklog: [Event] = []
    private var isProcessingEvent = false
    
    // MARK: Initialization
    
    /// Construct a Store with state, reducer and environment.
    /// - Parameters:
    ///   - state: An initial state.
    ///   - reducer: A reducer.
    ///   - environment: An environment.
    public convenience init(
        state: State,
        reducer: Reducer<State, Event, Environment>,
        environment: Environment,
        middlewares: [AnyMiddleware<Event, Event, State>]
    ) {
        self.init(
            state: state,
            reducer: { reducer.execute(state: &$0, event: $1, environment: $2) },
            environment: environment,
            middlewares: middlewares
        )
    }
    
    private init(
        state: State,
        reducer: @escaping Reducer<State, Event, Environment>.Reduce,
        environment: Environment,
        middlewares: [AnyMiddleware<Event, Event, State>]
    ) {
        self.state = state
        self.stateSequence = self._stateSequence.shared().eraseToAnyAsyncSequenceable()
        
        self.reducer = reducer
        self.environment = environment
        self.middlewares = middlewares
        
        self.subscribeToMiddlewares()
    }
    
    // MARK: Events
    
    /// Send an event through the store's reducer.
    /// - Parameter event: The event.
    public func send(_ event: Event) {
        self.eventBacklog.append(event)
        guard !self.isProcessingEvent else { return }
        
        self.isProcessingEvent = true
        var state = self.state
        
        defer {
            self.isProcessingEvent = false
            self.state = state
        }
        
        while !self.eventBacklog.isEmpty {
            let event = self.eventBacklog.removeFirst()
            let eventStream = self.reducer(&state, event, self.environment)
            self.state = state
            
            Task { [state] in
                for middleware in self.middlewares {
                    await middleware.execute(event: event, state: { state })
                }
                
                guard let eventStream = eventStream else { return }
                for await event in eventStream {
                    self.send(event)
                }
            }
        }
    }
    
    // MARK: Middleware
    
    private func subscribeToMiddlewares() {
        self.middlewareTasks
        = self.middlewares.reduce(into: [Task<Void, Error>]()) { [weak self] results, middleware in
            results.append(
                middleware.outputStream.sink { event in
                    self?.send(event)
                }
            )
        }
    }
}

// MARK: Scope

extension Store {
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
            reducer: .init { state, event, _ in
                self.send(fromScopedEvent(event))
                state = toScopedState(self.state)
                return .none
            },
            environment: toScopedEnvironment(self.environment),
            middlewares: []
        )
        
        // Propagate changes to state to scoped store.
        scopedStore.parentStatePropagationTask = Task(priority: .high) { [stateSequence, weak scopedStore] in
            scopedStore?.state = toScopedState(self.state)

            for await state in stateSequence {
                scopedStore?.state = toScopedState(state)
            }
        }

        return scopedStore
    }
}
