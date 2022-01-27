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
    
    await _XCTAssertEventuallyEqualStates(
        { states },
        { statesToMatch },
        timeout: timeout,
        file: file,
        line: line
    )
}



// MARK: _XCTAssertEventuallyEqualStates

private func _XCTAssertEventuallyEqualStates<State: Equatable>(
    _ expressionOne: @escaping () async -> [State],
    _ expressionTwo: @escaping () async -> [State],
    timeout: TimeInterval = 5.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let handle = Task { () -> Result<Void, _XCTError> in
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        var resultOne: [State] = []
        var resultTwo: [State] = []
        
        repeat {
            resultOne = await expressionOne()
            resultTwo = await expressionTwo()
            
            if resultOne == resultTwo {
                return .success(Void())
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
        } while Date().compare(timeoutDate) == .orderedAscending
        
        let error = _XCTError(
            stateChanges: resultOne,
            stateChangesExpected: resultTwo
        )
        return .failure(error)
    }
    
    let result = await handle.value
    switch result {
    case .success:
        return
    case .failure(let error):
        XCTFail(
            error.message,
            file: file,
            line: line
        )
    }
}



// MARK: XCTError

private struct _XCTError: Error {
    let message: String
    
    var localizedDescription: String {
        self.message
    }
    
    // MARK: Initialization
    
    init(_ message: String) {
        self.message = message
    }
    
    init<State: Equatable>(stateChanges: [State], stateChangesExpected: [State]) {
        self.init(
"""

---------------------------
Failed To Assert Equality
---------------------------

# State Changes
\(
    stateChanges.enumerated().map {
        "\($0)) \(String(describing: $1))"
    }.joined(separator: "\n")
)


# States Changes Expected
\(
    stateChangesExpected.enumerated().map {
        "\($0)) \(String(describing: $1))"
    }.joined(separator: "\n")
)

---------------------------
"""
        )
    }
}
