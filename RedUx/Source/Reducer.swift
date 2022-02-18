import Asynchrone
import Foundation


/// A reducer is responsible for taking an event and deciding how the state should be changed and
/// whether any effects should be executed.
public struct Reducer<State, Event, Environment> {
    
    // Static
    
    /// An empty reducer. Useful for SwiftUI's previews.
    /// - Returns: A reducer.
    public static var empty: Reducer<State, Event, Environment> {
        .init { _, _, _ in }
    }
    
    // Public
    public typealias Reduce = (inout State, Event, Environment) -> Void
    
    // Private
    private let reduce: Reduce

    // MARK: Initialization
    
    /// Construct a Reducer.
    /// - Parameter reduce: Reduce closure.
    public init(_ reduce: @escaping Reduce) {
        self.reduce = reduce
    }

    // MARK: Event execution
    
    func execute(
        state: inout State,
        event: Event,
        environment: Environment
    ) {
        self.reduce(&state, event, environment)
    }
    
    // MARK: Optional
    
    /// Transform the current reducer into one that accepts an optional state.
    ///
    /// The reducer will only be ran when state is non-nil.
    public var optional: Reducer<State?, Event, Environment> {
        .init { state, event, environment in
            guard state != nil else { return }
            self.reduce(&state!, event, environment)
        }
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
        event: @escaping (AppEvent) -> Event?,
        appEvent: @escaping (Event) -> AppEvent,
        environment: @escaping (AppEnvironment) -> Environment
    ) -> Reducer<AppState, AppEvent, AppEnvironment> {
        .init { appState, appEvent, appEnvironment in
            guard let event = event(appEvent) else { return }
            self.reduce(
                &appState[keyPath: state],
                event,
                environment(appEnvironment)
            )
        }
    }
}

// MARK: Combine

precedencegroup CombineReducerOperatorPrecedence {
    associativity: left
}
infix operator <>: CombineReducerOperatorPrecedence

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
            lhs.reduce(&state, event, environment)
            rhs.reduce(&state, event, environment)
        }
    }
}
