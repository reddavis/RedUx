import Asynchrone

/// A middleware that performs type erasure by wrapping another middleware.
public struct AnyMiddleware<InputEvent, OutputEvent, State>: Middlewareable {
    
    /// The closure that is called when the `execute` function is called.
    public typealias OnExecute = (_ event: InputEvent, _ state: () -> State) async -> Void
    
    /// The output stream is used my the middleware to emit events
    /// to a subscriber - which would be a store.
    public let outputStream: AnyAsyncSequenceable<OutputEvent>
    
    // Private
    private let execute: OnExecute
    
    // MARK: Initialization
    
    /// Create a new AnyMiddleware instance.
    /// - Parameters:
    ///   - outputStream: The async sequence used to emit events.
    ///   - onExecute: The closure that is called when execute function is called.
    public init(outputStream: AnyAsyncSequenceable<OutputEvent>, onExecute: @escaping OnExecute) {
        self.outputStream = outputStream
        self.execute = onExecute
    }
    
    /// Create a new AnyMiddleware instance that type erases the provided middleware.
    /// - Parameters:
    ///   - middleware: The middleware to type erase.
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
    
    /// The execute function is called by the store when it receives an event.
    /// - Parameters:
    ///   - event: The event.
    ///   - state: The store's current state.
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
