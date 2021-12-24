import RedUx


typealias AppStore = RedUx.Store<AppState, AppEvent, AppEnvironment>


extension AppStore {
    static func make() -> AppStore {
        Store(
            state: .init(),
            reducer: reducer,
            environment: .init()
        )
    }
    
    static func mock(
        state: AppState
    ) -> AppStore {
        Store(
            state: state,
            reducer: .empty,
            environment: .init()
        )
    }
}



// MARK: Reducer

fileprivate let reducer: Reducer<AppState, AppEvent, AppEnvironment> = Reducer { state, event, environment in
    switch event {
    case .increment:
        state.count += 1
        return .none
    case .decrement:
        state.count -= 1
        return .none
    case .incrementWithDelay:
        return AsyncStream { continuation in
            // Really taxing shiz
            await Task.sleep(2 * 1_000_000_000)
            continuation.yield(.increment)
            continuation.finish()
        }.eraseToAnyAsyncSequenceable()
    }
}



// MARK: State

struct AppState: Equatable {
    var count = 0
}



// MARK: Event

enum AppEvent {
    case increment
    case decrement
    case incrementWithDelay
}



// MARK: Environment

struct AppEnvironment {
    static var mock: AppEnvironment { .init() }
}
