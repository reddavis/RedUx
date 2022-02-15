import Asynchrone


public struct AnyMiddleware<InputEvent, OutputEvent, State>: Middlewareable {
    public typealias OnExecute = (_ event: InputEvent, _ state: () -> State) async -> Void
    public let outputStream: AnyAsyncSequenceable<OutputEvent>
    
    // Private
    private let execute: OnExecute
    
    // MARK: Initialization
    
    public init(outputStream: AnyAsyncSequenceable<OutputEvent>, onExecute: @escaping OnExecute) {
        self.outputStream = outputStream
        self.execute = onExecute
    }
    
    public init<T>(_ middleware: T)
    where
    T: Middlewareable,
    T.InputEvent == InputEvent,
    T.OutputEvent == OutputEvent,
    T.State == State {
        self.execute = middleware.execute
        self.outputStream = middleware.outputStream
    }
    
    // MARK: Middlewareable
    
    public func execute(event: InputEvent, state: () -> State) async {
        await self.execute(event, state)
    }
}



// MARK: Erasure

extension Middlewareable {
    
    /// Type erase a middle.
    /// - Returns: A `AnyMiddleware<InputEvent, OutputEvent, State>` instance.
    public func eraseToAnyMiddleware() -> AnyMiddleware<InputEvent, OutputEvent, State> {
        .init(self)
    }
}
