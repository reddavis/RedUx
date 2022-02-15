import Asynchrone
import Foundation
@testable import RedUx


// MARK: Events

enum AppEvent: Equatable {
    case setValue(String?)
    case subEvent(SubEvent)
    case setValueByEffect(String)
    case setValueToA
}


enum SubEvent: Equatable {
    case setValue(String)
    case setValueByEffect(String)
}



// MARK: State

struct AppState: Equatable {
    var value: String? = nil
    var eventsReceived: [AppEvent] = []
    var subState: SubState = .init()
}


struct SubState: Equatable {
    var value: String? = nil
    var eventsReceived: [SubEvent] = []
}



// MARK: Environment

struct AppEnvironment { }



// MARK: Reducers

let reducer =
mainReducer
<>
subReducer.pull(
    state: \.subState,
    event: { event in
        guard case let AppEvent.subEvent(subEvent) = event else { return nil }
        return subEvent
    },
    appEvent: { .subEvent($0) },
    environment: { $0 }
)

let mainReducer: Reducer<AppState, AppEvent, AppEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event {
    case .setValue(let value):
        state.value = value
    case .subEvent(let event):
        return
    case .setValueByEffect:
        // Do nothing, it's handled by the middleware
        return
    case .setValueToA:
        state.value = "a"
    }
}

let subReducer: Reducer<SubState, SubEvent, AppEnvironment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event {
    case .setValue(let value):
        state.value = value
        return
    case .setValueByEffect:
        return
    }
}



// MARK: Middlewares

struct TestMiddleware: Middlewareable {
    let outputStream: AnyAsyncSequenceable<AppEvent>
    
    // Private
    private let _outputStream: PassthroughAsyncSequence<AppEvent> = .init()
    
    // MARK: Initialization
    
    init() {
        self.outputStream = self._outputStream.eraseToAnyAsyncSequenceable()
    }
    
    // MARK: Middlewareable
    
    func execute(event: AppEvent, state: () -> AppState) async {
        guard case let .setValueByEffect(value) = event else { return }
        self._outputStream.yield(.setValue(value))
    }
}



struct ScopedMiddleware: Middlewareable {
    let outputStream: AnyAsyncSequenceable<SubEvent>
    
    // Private
    private let _outputStream: PassthroughAsyncSequence<SubEvent> = .init()
    
    // MARK: Initialization
    
    init() {
        self.outputStream = self._outputStream.eraseToAnyAsyncSequenceable()
    }
    
    // MARK: Middlewareable
    
    func execute(event: SubEvent, state: () -> SubState) async {
        guard case let .setValueByEffect(value) = event else { return }
        self._outputStream.yield(.setValue(value))
    }
}
