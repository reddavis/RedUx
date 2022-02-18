import XCTest
@testable import RedUx


final class ReducerTests: XCTestCase {
    private var state: AppState!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.state = .init()
    }
    
    // MARK: Tests
    
    func testEventOnMainReducer() {
        reducer.execute(
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
    
    func testEventOnSubReducer() {
        reducer.execute(
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
    
    func testOptionalReducer() {
        var state: AppState? = nil
        let reducer = appReducer.optional
        let value = "abc"
        
        // State nil
        reducer.execute(
            state: &state,
            event: .setValue(value),
            environment: .init()
        )
        XCTAssertNil(state)
        
        // State not nil
        state = .init()
        reducer.execute(
            state: &state,
            event: .setValue(value),
            environment: .init()
        )
        
        XCTAssertEqual(
            state,
            .init(
                value: "abc",
                eventsReceived: [.setValue("abc")]
            )
        )
    }
}
