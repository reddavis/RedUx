import RedUx
import SwiftUI


enum RootScreen
{
    typealias Store = RedUx.Store<State, Event, Environment>
    
    @MainActor
    static func make() -> some View
    {
        ContentView(
            store: Store(
                state: .init(),
                reducer: self.reducer,
                environment: .init()
            )
        )
    }
    
    @MainActor
    static func mock(
        state: State
    ) -> some View
    {
        ContentView(
            store: Store(
                state: state,
                reducer: .empty(),
                environment: .init()
            )
        )
    }
}



// MARK: Reducer

extension RootScreen
{
    static let reducer: Reducer<State, Event, Environment> = Reducer { state, event, environment in
        switch event
        {
        case .increment:
            state.count += 1
            return .none
        case .decrement:
            state.count -= 1
            return .none
        case .incrementWithDelay:
            return .init { continuation in
                // Really taxing shiz
                await Task.sleep(2 * 1_000_000_000)
                continuation.yield(.increment)
                continuation.finish()
            }
        }
    }
}



// MARK: State

extension RootScreen
{
    struct State: Equatable
    {
        var count = 0
    }
}



// MARK: Event

extension RootScreen
{
    enum Event
    {
        case increment
        case decrement
        case incrementWithDelay
    }
}



// MARK: Environment

extension RootScreen
{
    struct Environment { }
}
