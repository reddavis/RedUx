struct XCTAssertStatesEventuallyEqualError: Error {
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
