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
