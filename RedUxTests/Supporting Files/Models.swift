import Asynchrone
import Foundation
@testable import RedUx


// MARK: Events

enum AppEvent: Equatable {
    case setValue(String?)
    case setValueViaEffect(String)
    case setValueToA
    case subEvent(SubEvent)
    
    case triggerCancelEffect(String)
    
    case startLongRunningEffect
}


enum SubEvent: Equatable {
    case setValue(String)
    case setValueViaEffect(String)
}



// MARK: State

struct AppState: Equatable {
    var value: String? = nil
    var eventsReceived: [AppEvent] = []
    
    var subState: SubState = .init()
    var optionalState: SubState? = nil
}


struct SubState: Equatable {
    var value: String? = nil
    var eventsReceived: [SubEvent] = []
}


struct OptionalState: Equatable {
    var value: String? = nil
    var eventsReceived: [SubEvent] = []
}



// MARK: Environment

struct AppEnvironment { }



// MARK: Reducers

let reducer =
appReducer
<>
subReducer.pull(
    state: \.subState,
    event: {
        guard case let AppEvent.subEvent(subEvent) = $0 else { return nil }
        return subEvent
    },
    appEvent: AppEvent.subEvent,
    environment: { $0 }
)
<>
optionalReducer.optional.pull(
    state: \.optionalState,
    event: {
        guard case let AppEvent.subEvent(subEvent) = $0 else { return nil }
        return subEvent
    },
    appEvent: AppEvent.subEvent,
    environment: { $0 }
)

let appReducer: Reducer<AppState, AppEvent, AppEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event {
    case .setValue(let value):
        state.value = value
        return .none
    case .subEvent(let event):
        return .none
    case .setValueToA:
        state.value = "a"
        return .none
    case .setValueViaEffect(let value):
        return Effect(.setValue(value))
    case .triggerCancelEffect(let id):
        return .cancel(id)
    case .startLongRunningEffect:
        return Effect { continuation in
            for value in ["a", "b", "c"] {
                continuation.yield(.setValue(value))
            }
            continuation.finish()
        }
    }
}

let subReducer: Reducer<SubState, SubEvent, AppEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event {
    case .setValue(let value):
        state.value = value
        return .none
    case .setValueViaEffect(let value):
        return Effect(.setValue(value))
    }
}

let optionalReducer: Reducer<SubState, SubEvent, AppEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)

    switch event {
    case .setValue(let value):
        state.value = value
        return .none
    case .setValueViaEffect(let value):
        return Effect(.setValue(value))
    }
}
