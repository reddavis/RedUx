import Foundation


public extension AsyncStream
{
    /// Construct a AsyncStream buffering given an Element type.
    ///
    /// - Parameter elementType: The type the AsyncStream will produce.
    /// - Parameter maxBufferedElements: The maximum number of elements to
    ///   hold in the buffer past any checks for continuations being resumed.
    /// - Parameter build: The work associated with yielding values to the
    ///   AsyncStream.
    ///
    /// The maximum number of pending elements limited by dropping the oldest
    /// value when a new value comes in if the buffer would excede the limit
    /// placed upon it. By default this limit is unlimited.
    ///
    /// The build closure passes in a Continuation which can be used in
    /// concurrent contexts. It is thread safe to send and finish; all calls are
    /// to the continuation are serialized, however calling this from multiple
    /// concurrent contexts could result in out of order delivery.
    init(
        _ elementType: Element.Type = Element.self,
        bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded,
        _ build: @escaping (AsyncStream<Element>.Continuation) async -> Void
    )
    {
        self = AsyncStream(
            elementType,
            bufferingPolicy: limit,
            { continuation in
                Task {
                    await build(continuation)
                }
            }
        )
    }
}

// MARK: Just

public extension AsyncStream
{
    /// Initialize a single value yielding stream.
    /// - Parameter value: The value to yield.
    /// - Returns: An `AsyncStream`.
    static func just(_ value: Element) -> Self
    {
        .init {
            $0.finish(with: value)
        }
    }
}



// MARK: AsyncStream.Continuation

public extension AsyncStream.Continuation
{
    /// Yield the provided value and then finish the stream.
    /// - Parameter value: The value to yield to the stream.
    func finish(with value: Element)
    {
        self.yield(value)
        self.finish()
    }
}