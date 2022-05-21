@testable import RedUx
import Asynchrone
import XCTest

/// Assert an async closure thorws an error.
/// - Parameters:
///   - closure: The closure.
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAsyncAssertThrowsError<T>(
    _ closure: () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await closure()
        XCTFail(
            "Failed to throw error",
            file: file,
            line: line
        )
    }
    catch { }
}

/// Assert an async closure does not throw.
/// - Parameters:
///   - closure: The closure.
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAsyncAssertNoThrow<T>(
    _ closure: () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await closure()
    }
    catch {
        XCTFail(
            "Unexpexted error thrown \(error)",
            file: file,
            line: line
        )
    }
}

/// Assert an async closure returns nil.
/// - Parameters:
///   - closure: The closure.
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAsyncAssertNil<T>(
    _ closure: () async -> T?,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let value = await closure()
    XCTAssertNil(
        value,
        file: file,
        line: line
    )
}

/// Assert two async closures return equal values.
/// - Parameters:
///   - expressionA: Expression A.
///   - expressionB: Expression B.
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAsyncAssertEqual<T: Equatable>(
    _ expressionA: @escaping () async -> T,
    _ expressionB: @escaping () async -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let valueA = await expressionA()
    let valueB = await expressionB()

    XCTAssertEqual(
        valueA,
        valueB,
        file: file,
        line: line
    )
}

// MARK: await XCTAssertEventuallyEqualError

struct XCTAssertEventuallyEqualError: Error {
    let message: String

    var localizedDescription: String {
        self.message
    }

    // MARK: Initialization

    init<T: Equatable>(resultA: T?, resultB: T?) {
        var resultADescription = "(null)"
        if let resultA = resultA {
            resultADescription = String(describing: resultA)
        }

        var resultBDescription = "(null)"
        if let resultB = resultB {
            resultBDescription = String(describing: resultB)
        }

        self.message = """

---------------------------
Failed To Assert Equality
---------------------------

# Result A
\(resultADescription)


# Result B
\(resultBDescription)

---------------------------
"""
    }
}

// MARK: XCTAssertStatesEventuallyEqualError

struct XCTAssertStatesEventuallyEqualError: Error {
    let message: String

    var localizedDescription: String {
        message
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

// MARK: XCTestCase

/// Assert that a store's state changes match expectation after sending
/// a collection of events.
/// - Parameters:
///   - store: The store to test state changes against.
///   - event: The event to send to the store.
///   - statesToMatch: An array of state changes expected. These will be asserted
///     equal against the store's state changes.
///   - timeout: Time to wait for store state changes. Defaults to `5`
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAssertStateChange<State: Equatable, Event, Environment>(
    store: Store<State, Event, Environment>,
    event: Event,
    matches statesToMatch: [State],
    timeout: TimeInterval = 5.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let timeoutDate = Date(timeIntervalSinceNow: timeout)
    var states: [State] = []
    
    // We use the semaphore in order to guarantee the sink task has started.
    // This is to ensure we collect all events.
    let semaphore = DispatchSemaphore(value: 0)
    Just(store.state)
        .eraseToAnyAsyncSequenceable()
        .chain(with: store.stateSequence)
        .removeDuplicates()
        .sink {
            states.append($0)
            semaphore.signal()
        }
    
    Task.detached(priority: .low) {
        semaphore.wait()
        store.send(event)
    }
        
    while true {
        switch states == statesToMatch {
        // All good!
        case true:
            return
        // False and timed out.
        case false where Date.now.compare(timeoutDate) == .orderedDescending:
            let error = XCTAssertStatesEventuallyEqualError(
                stateChanges: states,
                stateChangesExpected: statesToMatch
            )

            XCTFail(
                error.message,
                file: file,
                line: line
            )
            return
        // False but still within timeout limit.
        case false:
            try? await Task.sleep(nanoseconds: 50000000)
        }
    }
}

/// Assert two expressions are eventually equal.
/// - Parameters:
///   - expressionA: Expression A
///   - expressionB: Expression B
///   - timeout: Time to wait for store state changes. Defaults to `5`
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAssertEventuallyEqual<T: Equatable>(
    _ expressionA: @escaping @autoclosure () -> T?,
    _ expressionB: @escaping @autoclosure () -> T?,
    timeout: TimeInterval = 5.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let timeoutDate = Date(timeIntervalSinceNow: timeout)
    
    while true {
        let resultA = expressionA()
        let resultB = expressionB()
        
        switch resultA == resultB {
        // All good!
        case true:
            return
        // False and timed out.
        case false where Date.now.compare(timeoutDate) == .orderedDescending:
            let error = XCTAssertEventuallyEqualError(
                resultA: resultA,
                resultB: resultB
            )

            XCTFail(
                error.message,
                file: file,
                line: line
            )
            return
        // False but still within timeout limit.
        case false:
            try? await Task.sleep(nanoseconds: 50000000)
        }
    }
}

/// Assert two async expressions are eventually equal.
/// - Parameters:
///   - expressionA: Expression A
///   - expressionB: Expression B
///   - timeout: Time to wait for store state changes. Defaults to `5`
///   - file: The file where this assertion is being called. Defaults to `#filePath`.
///   - line: The line in the file where this assertion is being called. Defaults to `#line`.
func XCTAsyncAssertEventuallyEqual<T: Equatable>(
    _ expressionA: @escaping () async -> T?,
    _ expressionB: @escaping () async -> T?,
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
            let error = XCTAssertEventuallyEqualError(
                resultA: resultA,
                resultB: resultB
            )

            XCTFail(
                error.message,
                file: file,
                line: line
            )
            return
        // False but still within timeout limit.
        case false:
            try? await Task.sleep(nanoseconds: 50000000)
        }
    }
}
