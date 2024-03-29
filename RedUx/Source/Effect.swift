import Asynchrone
import Foundation

public struct Effect<Event>: Sendable where Event: Sendable {
    /// The ID of the effect.
    let id: String
    
    /// The unique ID of the effect.
    let uuid: String = UUID().uuidString
    
    /// Indicate whether this effect is a cancellation effect.
    let isCancellation: Bool
    
    // Private
    private let sequence: AnyAsyncSequenceable<Event>
    
    // MARK: Initialization
    
    /// Initialize an effect that will emit a single event.
    ///
    /// - Parameters:
    ///   - id: The ID of the efect. Default value: `UUID().uuidString`.
    ///   - closure: The effect's function.
    public init(
        id: String = UUID().uuidString,
        closure: @escaping () async -> Event?
    ) {
        self.id = id
        self.isCancellation = false
        self.sequence = AsyncStream {
            guard let event = await closure() else {
                $0.finish()
                return
            }
            
            $0.finish(with: event)
        }
        .eraseToAnyAsyncSequenceable()
    }
    
    /// Initialize an effect that can emit unlimited events.
    ///
    /// Use this initializer if your effect can emit multiple events. For example:
    ///     - Location monitor.
    ///     - Streaming values (e.g. websockets)
    ///     - Audio player position monitoring.
    ///
    /// - Parameters:
    ///   - id: The ID of the efect. Default value: `UUID().uuidString`.
    ///   - closure: The effect's function. The closure provides you with
    ///   two closures. The first one, `emit`, should be used to emit events.
    ///   The second `finish`, should be called when/if the effect finishes.
    public init(
        id: String = UUID().uuidString,
        closure: @Sendable @escaping (_ continuation: AsyncStream<Event>.Continuation) async -> Void
    ) {
        self.id = id
        self.isCancellation = false
        self.sequence = AsyncStream { continuation in
            let task = Task {
                await closure(continuation)
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
            
            await task.value
        }
        .eraseToAnyAsyncSequenceable()
    }
    
    /// Initialize an effect that emits a single event.
    ///
    /// - Parameter event: The event to emit.
    public init(_ event: Event) {
        self.id = UUID().uuidString
        self.isCancellation = false
        self.sequence = Just(event)
            .eraseToAnyAsyncSequenceable()
    }
    
    init<T>(
        id: String = UUID().uuidString,
        sequence: T,
        isCancellation: Bool = false
    ) where T: AsyncSequence, T: Sendable, T.Element == Element {
        self.id = id
        self.sequence = sequence.eraseToAnyAsyncSequenceable()
        self.isCancellation = isCancellation
    }
}

// MARK: AsyncSequence

extension Effect: AsyncSequence {
    public typealias Element = Event
    
    public func makeAsyncIterator() -> AnyAsyncSequenceable<Event>.AsyncIterator {
        self.sequence.makeAsyncIterator()
    }
}

// MARK: Builders

extension Effect {
    /// Creates a fire and forget effect. This effect will not emit any events
    /// and will finish as soon as the provided closure has been executed.
    ///
    /// - Parameter closure: An async closure.
    /// - Returns: An effect.
    public static func fireAndForget(_ closure: @escaping () async -> Void) -> Self {
        .init {
            await closure()
            return nil
        }
    }
    
    /// Create a cancel effect that can be used to cancel a long running effect.
    ///
    /// - Parameter id: The ID of the effect to cancel.
    /// - Returns: An effect.
    public static func cancel(_ id: String) -> Self {
        .init(
            id: id,
            sequence: Empty(),
            isCancellation: true
        )
    }
}

// MARK: AsyncSequence

extension AsyncSequence {
    /// Type erase any async sequence into an effect.
    ///
    /// - Parameters:
    ///   - id: The ID of the efect. Default value: `UUID().uuidString`.
    /// - Returns: An effect.
    public func eraseToEffect(id: String = UUID().uuidString) -> Effect<Element> where Self: Sendable, Element: Sendable {
        .init(id: id, sequence: self)
    }
}
