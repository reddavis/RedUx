import Asynchrone
import RedUx


typealias AppStore = RedUx.Store<AppState, AppEvent, AppEnvironment>


extension AppStore {
    static func make() -> AppStore {
        Store(
            state: .init(),
            reducer: reducer,
            environment: .init(),
            middlewares: [
                HighlyComplicatedIncrementMiddleware().eraseToAnyMiddleware()
            ]
        )
    }
    
    static func mock(
        state: AppState
    ) -> AppStore {
        Store(
            state: state,
            reducer: .empty,
            environment: .init(),
            middlewares: []
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
    case .incrementWithDelayViaMiddleware:
        return .none
    case .incrementWithDelayViaEffect:
        return .effect {
            try? await Task.sleep(seconds: 2)
            return .increment
        }.eraseToAnyAsyncSequenceable()
    case .toggleIsPresentingSheet:
        state.isPresentingSheet.toggle()
        return .none
    case .details:
        return .none
    }
}
<>
detailsReducer.pull(
    state: \.details,
    event: {
        guard case AppEvent.details(let localEvent) = $0 else { return nil }
        return localEvent
    },
    appEvent: AppEvent.details,
    environment: { $0 }
)



// MARK: State

struct AppState: Equatable {
    var count = 0
    var isPresentingSheet = false
    var details: DetailsState = .init()
}



// MARK: Event

enum AppEvent {
    case increment
    case decrement
    case incrementWithDelayViaMiddleware
    case incrementWithDelayViaEffect
    case toggleIsPresentingSheet
    case details(DetailsEvent)
}



// MARK: Environment

struct AppEnvironment {
    static var mock: AppEnvironment { .init() }
}



// MARK: Middleware

struct HighlyComplicatedIncrementMiddleware: Middlewareable {
    let outputStream: AnyAsyncSequenceable<AppEvent>
    
    // Private
    private let _outputStream: PassthroughAsyncSequence<AppEvent> = .init()
    
    // MARK: Initialization
    
    init() {
        self.outputStream = self._outputStream.eraseToAnyAsyncSequenceable()
    }
    
    // MARK: Middlewareable
    
    func execute(event: AppEvent, state: () -> AppState) async {
        guard case .incrementWithDelayViaMiddleware = event else { return }
        
        try? await Task.sleep(seconds: 2)
        self._outputStream.yield(.increment)
    }
}
