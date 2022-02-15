import Asynchrone
import RedUx
import XCTest


/// Assert that a store's state changes match expectation after sending
/// a collection of events.
/// - Parameters:
///   - store: The store to test state changes against.
///   - events: The events to send to the store.
///   - statesToMatch: An array of state changes expected. These will be asserted
///     equal against the store's state changes.
///   - timeout: Time to wait for store state changes. Defaults to `5`
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
public func XCTAssertStateChange<State: Equatable, Event, Environment>(
    store: Store<State, Event, Environment>,
    events: [Event],
    matches statesToMatch: [State],
    timeout: TimeInterval = 5.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    // Add initial state
    var states: [State] = [store.state]
    store.stateSequence
        .removeDuplicates()
        .sink { states.append($0) }
    
    for event in events {
        store.send(event)
    }
    
    XCTAssertEventuallyEqualStates(
        { states },
        { statesToMatch },
        timeout: timeout,
        file: file,
        line: line
    )
}



// MARK: XCTAssertEventuallyEqualStates

private func XCTAssertEventuallyEqualStates<State: Equatable>(
    _ expressionA: @escaping () async -> [State],
    _ expressionB: @escaping () async -> [State],
    timeout: TimeInterval = 5.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let timeoutDate = Date(timeIntervalSinceNow: timeout)
    
    while true {
        let resultA = await expressionA()
        let resultB = await expressionB()
        
        switch resultA == resultB {
        // All good!
        case true:
            return
        // False and timed out.
        case false where Date.now.compare(timeoutDate) == .orderedDescending:
            let error = XCTAssertStatesEventuallyEqualError(
                stateChanges: resultA,
                stateChangesExpected: resultB
            )
            
            XCTFail(
                error.message,
                file: file,
                line: line
            )
            return
        // False but still within timeout limit.
        case false:()
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
}
