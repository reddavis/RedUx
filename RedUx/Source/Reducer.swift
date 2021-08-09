import Foundation


public struct Reducer<State, Event, Environment>
{
    /// An empty reducer. Useful for SwiftUI's previews.
    /// - Returns: A reducer.
    public static func empty() -> Reducer<State, Event, Environment>
    {
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
