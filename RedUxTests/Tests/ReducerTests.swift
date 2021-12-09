import XCTest
@testable import RedUx


final class ReducerTests: XCTestCase
{
    private var state: State!
    
    // MARK: Setup
    
    override func setUpWithError() throws
    {
        self.state = .init()
    }
    
    // MARK: Tests
    
    func testEventOnMainReducer()
    {
        _ = reducer.execute(
            state: &self.state,
            event: .setValue("abc"),
            environment: .init()
        )
        
        XCTAssertEqual(
            self.state,
            .init(
                value: "abc",
                eventsReceived: [.setValue("abc")]
            )
        )
    }
    
    func testEventOnSubReducer()
    {
        _ = reducer.execute(
            state: &self.state,
            event: .subEvent(.setValue("abc")),
            environment: .init()
        )
        
        XCTAssertEqual(
            self.state,
            .init(
                eventsReceived: [
                    .subEvent(.setValue("abc"))
                ],
                subState: .init(
                    value: "abc",
                    eventsReceived: [
                        .setValue("abc")
                    ]
                )
            )
        )
    }
}

 

// MARK: Events

fileprivate enum Event: Equatable
{
    case setValue(String)
    case subEvent(SubEvent)
}

fileprivate enum SubEvent: Equatable
{
    case setValue(String)
}


// MARK: State

fileprivate struct State: Equatable
{
    var value: String? = nil
    var eventsReceived: [Event] = []
    var subState: SubState = .init()
}

fileprivate struct SubState: Equatable
{
    var value: String? = nil
    var eventsReceived: [SubEvent] = []
}


// MARK: Environment

fileprivate struct Environment { }


// MARK: Reducers

fileprivate let reducer = mainReducer
    >>>
    subReducer.pull(
        state: \.subState,
        localEvent: { event in
            guard case let Event.subEvent(subEvent) = event else { return nil }
            return subEvent
        },
        appEvent: { .subEvent($0) },
        environment: \.self
    )



fileprivate let mainReducer: Reducer<State, Event, Environment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event
    {
    case .setValue(let value):
        state.value = value
        return .none
    case .subEvent(let event):
        return .none
    }
}

fileprivate let subReducer: Reducer<SubState, SubEvent, Environment> = .init { state, event, environment in
    state.eventsReceived.append(event)
    
    switch event
    {
    case .setValue(let value):
        state.value = value
        return .none
    }
}
