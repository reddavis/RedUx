import Asynchrone
import Foundation

public struct Effect<Event> {
    public typealias Closure = () async -> Event?
    let id: String
    let isCancellation: Bool
    
    // Private
    private let sequence: AnyAsyncSequenceable<Event>
    
    // MARK: Initialization
    
    public init(
        id: String = UUID().uuidString,
        closure: @escaping Closure
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
    ) where T: AsyncSequence, T.Element == Element {
        self.id = id
        self.sequence = sequence.eraseToAnyAsyncSequenceable()
        self.isCancellation = isCancellation
    }
}

// MARK: AsyncSequence

extension Effect: AsyncSequence {
    public typealias Element = Event
    public func makeAsyncIterator() -> AnyAsyncSequenceable<Element> {
        self.sequence.makeAsyncIterator()
    }
}

// MARK: Builders

extension Effect {
    /// Creates a fire and forget effect. This effect will not emit any events
    /// and will finish as soon as the provided closure has been executed.
    /// - Parameter closure: An async closure.
    /// - Returns: A type erased async sequence.
    public static func fireAndForget(_ closure: @escaping () async -> Void) -> Self {
        .init {
            await closure()
            return nil
        }
    }
    
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
    public func eraseToEffect() -> Effect<Self.Element> {
        .init(sequence: self)
    }
}
