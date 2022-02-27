import Asynchrone


extension AnyAsyncSequenceable {
    
    // MARK: Builders
    
    /// Create a simple effect that emits a single event.
    /// - Parameter closure: An async closure that returns an event.
    /// - Returns: A type erased async sequence.
    public static func effect(_ closure: @escaping () async -> Element) -> Self {
        AsyncStream {
            let event = await closure()
            $0.finish(with: event)
        }.eraseToAnyAsyncSequenceable()
    }
    
    /// Creates a fire and forget async sequence. This sequence will not emit any events
    /// and will finish as soon as the provided closure has been executed.
    /// - Parameter closure: An async closure.
    /// - Returns: A type erased async sequence.
    public static func fireAndForget(_ closure: @escaping () async -> Void) -> Self {
        AsyncStream {
            await closure()
            $0.finish()
        }.eraseToAnyAsyncSequenceable()
    }
}
