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
        let reducer = reducer.optional()
    }
}
