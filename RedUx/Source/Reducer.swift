import Foundation


public struct Reducer<State, Event, Environment>
{
    /// An empty reducer. Useful for SwiftUI's previews.
    /// - Returns: A reducer.
    public static var empty: Reducer<State, Event, Environment> {
        .init { _, _, _ in .none }
    }
    
    // Public
    public typealias Reduce = (inout State, Event, Environment) -> AsyncStream<Event>?
    
    // Private
    private let reduce: Reduce

    // MARK: Initialization
    
    /// Construct a Reducer.
    /// - Parameter reduce: Reduce closure.
    public init(_ reduce: @escaping Reduce)
    {
        self.reduce = reduce
    }

    // MARK: API
    
    func execute(
        state: inout State,
        event: Event,
        environment: Environment
    ) -> AsyncStream<Event>?
    {
        self.reduce(&state, event, environment)
    }
}

// MARK: Pull

extension Reducer
{
    public func pull<AppState, AppEvent, AppEnvironment>(
        state: WritableKeyPath<AppState, State>,
        localEvent: @escaping (AppEvent) -> Event?,
        appEvent: @escaping (Event) -> AppEvent,
        environment: KeyPath<AppEnvironment, Environment>
    ) -> Reducer<AppState, AppEvent, AppEnvironment>
    {
        .init { appState, event, appEnvironment in
            guard let event = localEvent(event) else { return .none }
            let eventStream = self.reduce(
                &appState[keyPath: state],
                event,
                appEnvironment[keyPath: environment]
            )
            
            return eventStream?.map { event in
                appEvent(event)
            }
        }
    }
}

// MARK: Combine

infix operator >>>
extension Reducer
{
    public static func >>>(
        lhs: Reducer<State, Event, Environment>,
        rhs: Reducer<State, Event, Environment>
    ) -> Reducer<State, Event, Environment>
    {
        .init { state, event, environment in
            let streamA = lhs.reduce(&state, event, environment)
            let streamB = rhs.reduce(&state, event, environment)
            
            if let streamA = streamA,
               let streamB = streamB
            {
                return streamA.merge(with: streamB)
            }
            
            return streamA ?? streamB ?? .none
        }
    }
}
