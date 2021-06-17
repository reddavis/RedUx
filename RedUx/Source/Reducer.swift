import Foundation


public struct Reducer<State, Event, Environment>
{
    // Static
    public static func empty() -> Reducer<State, Event, Environment>
    {
        .init { _, _, _ in .none }
    }
    
    // Public
    public typealias Reduce = (inout State, Event, Environment) -> Effect<Event>?
    
    // Private
    private let reduce: Reduce

    // MARK: Initialization
    
    public init(_ reduce: @escaping Reduce)
    {
        self.reduce = reduce
    }

    // MARK: API
    
    func execute(
        state: inout State,
        event: Event,
        environment: Environment
    ) -> Effect<Event>?
    {
        self.reduce(&state, event, environment)
    }
}
