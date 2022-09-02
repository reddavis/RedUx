import Asynchrone
import RedUx

typealias AppStore = Store<AppState, AppEvent, AppEnvironment>

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
    case .incrementWithDelayViaEffect:
        return Effect(.increment)
            .delay(for: 2)
            .eraseToEffect()
    case .presentSheet:
        state.isPresentingSheet = true
        return .none
    case .dismissSheet:
        state.isPresentingSheet = false
        return .none
    case .details:
        return .none
    case .setText(let text):
        state.text = text
        return .none
    case .setTextFieldText(let text):
        state.textFieldText = text
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
    var text = ""
    var textFieldText = ""
}

// MARK: Event

enum AppEvent {
    case increment
    case decrement
    case incrementWithDelayViaEffect
    case presentSheet
    case dismissSheet
    case details(DetailsEvent)
    case setText(String)
    case setTextFieldText(String)
}

// MARK: Environment

struct AppEnvironment {
    static var mock: AppEnvironment { .init() }
}
