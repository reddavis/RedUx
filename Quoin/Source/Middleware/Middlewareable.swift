import Asynchrone

/// Middleware provides a way to build more complicated application logic that doesn't belong inside
/// the reducer.
///
/// A middleware will receive all events that are sent to a store along with the store's
/// current state. The middleware can then emit events to the store via it's `outputStream`.
///
/// A middleware might be used for location monitoring, making requests to an API, downloading data or
/// observing application state.
public protocol Middlewareable {
    /// The input event.
    associatedtype InputEvent
    
    /// The output event.
    associatedtype OutputEvent
    
    /// The state.
    associatedtype State

    /// The output stream is used my the middleware to emit events
    /// to a subscriber - which would be a store.
    var outputStream: AnyAsyncSequenceable<OutputEvent> { get }
    
    /// The execute function is called by the store when it receives an event.
    /// - Parameters:
    ///   - event: The event.
    ///   - state: The store's current state.
    func execute(event: InputEvent, state: () -> State) async
}

// MARK: Pull

extension Middlewareable {
    /// Transforms or "Pulls" a scoped middleware into a global middleware.
    ///
    /// Similar to reducers, it may make sense to scope a middleware. For example,
    /// if the middleware's only function is to monitor and update application state
    /// it may make sense to scope it to only being able to send a subset of events and
    /// only have access to a scoped state.
    ///
    /// - Parameters:
    ///   - inputEvent: A function for transforming an app event into a scoped event.
    ///   - oututEvent: A function for transforming a scoped event into an app event.
    ///   - state: A function for transforming an app state into a scoped state.
    /// - Returns: A `AnyMiddleware<AppInputEvent, AppOutputEvent, AppState>`.
    public func pull<AppInputEvent, AppOutputEvent, AppState>(
        inputEvent: @escaping (AppInputEvent) -> InputEvent?,
        outputEvent: @escaping (OutputEvent) -> AppOutputEvent,
        state: @escaping (AppState) -> State
    ) -> AnyMiddleware<AppInputEvent, AppOutputEvent, AppState> {
        AnyMiddleware(
            outputStream: self.outputStream.map(outputEvent).eraseToAnyAsyncSequenceable(),
            onExecute: { appEvent, appState in
                guard let event = inputEvent(appEvent) else { return }
                
                await self.execute(
                    event: event,
                    state: { state(appState()) }
                )
            }
        )
    }
}
