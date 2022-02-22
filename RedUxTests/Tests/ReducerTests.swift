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
    
    func testPullingReducer() {
        let reducer: Reducer<AppState, AppEvent, AppEnvironment> = subReducer.pull(
            state: \.subState,
            appState: { $0.subState = $1 },
            event: {
                guard case let AppEvent.subEvent(subEvent) = $0 else { return nil }
                return subEvent
            },
            environment: { $0 }
        )
        
        // Execute
        let value = "abc"
        reducer.execute(
            state: &self.state,
            event: .subEvent(.setValue(value)),
            environment: .init()
        )
        
        XCTAssertEqual(
            self.state,
            .init(
                subState: .init(
                    value: value,
                    eventsReceived: [
                        .setValue(value)
                    ]
                )
            )
        )
    }
    
    func testPullingReducerWithWritableKey() {
        let reducer: Reducer<AppState, AppEvent, AppEnvironment> = subReducer.pull(
            state: \.subState,
            event: {
                guard case let AppEvent.subEvent(subEvent) = $0 else { return nil }
                return subEvent
            },
            environment: { $0 }
        )
        
        // Execute
        let value = "abc"
        reducer.execute(
            state: &self.state,
            event: .subEvent(.setValue(value)),
            environment: .init()
        )
        
        XCTAssertEqual(
            self.state,
            .init(
                subState: .init(
                    value: value,
                    eventsReceived: [
                        .setValue(value)
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
