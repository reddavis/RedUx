import Asynchrone
import Foundation


/// A reducer is responsible for taking an event and deciding how the state should be changed and
/// whether any effects should be executed.
public struct Reducer<State, Event, Environment>
{
    // Static
    
    /// An empty reducer. Useful for SwiftUI's previews.
    /// - Returns: A reducer.
    public static var empty: Reducer<State, Event, Environment> {
        .init { _, _, _ in .none }
    }
    
    // Public
    public typealias Reduce = (inout State, Event, Environment) -> AnyAsyncSequenceable<Event>?
    
    // Private
    private let reduce: Reduce

    // MARK: Initialization
    
    /// Construct a Reducer.
    /// - Parameter reduce: Reduce closure.
    public init(_ reduce: @escaping Reduce) {
        self.reduce = reduce
    }

    // MARK: API
    
    func execute(
        state: inout State,
        event: Event,
        environment: Environment
    ) -> AnyAsyncSequenceable<Event>?
    {
        self.reduce(&state, event, environment)
    }
}

// MARK: Pull

extension Reducer {
    /// Transforms or "Pulls" a local reducer into a global reducer.
    ///
    /// The main benefit of this function is that it enables the ability to breakdown
    /// a large reducer into several smaller ones.
    /// - Parameters:
    ///   - state: A key path that sets and gets the local state from the app state.
    ///   - localEvent: A function for transforming an app event into a local event.
    ///   - appEvent: A function for transforming a local event into an app event.
    ///   - environment: A function for transforming an app environment into a local environment.
    /// - Returns: A `Reducer<AppState, AppEvent, AppEnvironment>`.
    public func pull<AppState, AppEvent, AppEnvironment>(
        state: WritableKeyPath<AppState, State>,
        localEvent: @escaping (AppEvent) -> Event?,
        appEvent: @escaping (Event) -> AppEvent,
        environment: @escaping (AppEnvironment) -> Environment
    ) -> Reducer<AppState, AppEvent, AppEnvironment> {
        .init { appState, event, appEnvironment in
            guard let event = localEvent(event) else { return .none }
            let eventStream = self.reduce(
                &appState[keyPath: state],
                event,
                environment(appEnvironment)
            )
            
            return eventStream?.map { event in
                appEvent(event)
            }.eraseToAnyAsyncSequenceable()
        }
    }
}

// MARK: Combine

infix operator <>
extension Reducer {
    /// Combines two reducers of the same `State`, `Event` and `Environment` into one.
    ///
    /// The left hand reducer will be reduced first followed by the right hand reducer.
    /// - Parameters:
    ///   - lhs: The left hand reducer.
    ///   - rhs: The right hand reducer.
    /// - Returns: A new reducer
    public static func <>(
        lhs: Reducer<State, Event, Environment>,
        rhs: Reducer<State, Event, Environment>
    ) -> Reducer<State, Event, Environment> {
        .init { state, event, environment in
            let streamA = lhs.reduce(&state, event, environment)
            let streamB = rhs.reduce(&state, event, environment)
            
            if
                let streamA = streamA,
                let streamB = streamB {
                return streamA
                    .merge(with: streamB)
                    .eraseToAnyAsyncSequenceable()
            }
            
            return streamA ?? streamB ?? .none
        }
    }
}
