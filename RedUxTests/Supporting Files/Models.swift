import Foundation
@testable import RedUx


// MARK: Events

enum Event: Equatable {
    case setValue(String)
    case subEvent(SubEvent)
    case setValueByEffect(String)
    case setValueToA
}


enum SubEvent: Equatable {
    case setValue(String)
}



// MARK: State

struct State: Equatable {
    var value: String? = nil
    var eventsReceived: [Event] = []
    var subState: SubState = .init()
}


struct SubState: Equatable {
    var value: String? = nil
    var eventsReceived: [SubEvent] = []
}



// MARK: Environment

struct Environment { }



// MARK: Reducers

let reducer
    =
    mainReducer
    <<<
    subReducer.pull(
        state: \.subState,
        localEvent: { event in
            guard case let Event.subEvent(subEvent) = event else { return nil }
            return subEvent
        },
        appEvent: { .subEvent($0) },
        environment: \.self
    )

let mainReducer: Reducer<State, Event, Environment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event
    {
    case .setValue(let value):
        state.value = value
        return .none
    case .subEvent(let event):
        return .none
    case .setValueByEffect(let value):
        return .just(.setValue(value))
    case .setValueToA:
        return .just(.setValue("a"))
    }
}

let subReducer: Reducer<SubState, SubEvent, Environment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event
    {
    case .setValue(let value):
        state.value = value
        return .none
    }
}
