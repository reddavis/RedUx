import Asynchrone
import XCTest
@testable import RedUx

final class StoreTests: XCTestCase {
    private let manager = EffectManager()
    private var store: Store<AppState, AppEvent, AppEnvironment>!
    
    // MARK: Setup
    
    @MainActor
    override func setUpWithError() throws {
        self.store = .init(
            state: .init(),
            reducer: reducer,
            environment: .init(),
            effectManager: manager
        )
    }

    // MARK: Tests
    
    func testSendingEvent() async {
        await XCTAsyncAssertNil { await self.store.state.value }
        await self.store.send(.setValue("a"))
        await XCTAsyncAssertEqual(
            { await self.store.state.value },
            { "a" }
        )
        await XCTAsyncAssertEqual(
            { await self.store.state.eventsReceived },
            { [.setValue("a")] }
        )
    }
    
    // MARK: Scoped store
    
    func testScopedStore() async {
        let scopedStore = await self.store.scope(
            state: \.subState,
            event: AppEvent.subEvent,
            environment: { $0 }
        )
        let value = "a"
        
        await XCTAssertStateChange(
            store: scopedStore,
            event: .setValue(value),
            matches: [
                self.store.state.subState,
                .init(value: value, eventsReceived: [.setValue(value)])
            ]
        )

        // Check parent store's value changes
        await XCTAsyncAssertEqual(
            { await self.store.state.eventsReceived },
            { [.subEvent(.setValue(value))] }
        )
    }
    
    func testSendingEffectTriggeringEventToScopedStore() async {
        let scopedStore = await self.store.scope(
            state: \.subState,
            event: AppEvent.subEvent,
            environment: { $0 }
        )
        let value = "a"
        
        await XCTAsyncAssertNil { await scopedStore.state.value }
        await XCTAssertStateChange(
            store: scopedStore,
            event: .setValueViaEffect(value),
            matches: [
                .init(),
                .init(value: nil, eventsReceived: [.setValueViaEffect(value)]),
                .init(value: value, eventsReceived: [.setValueViaEffect(value), .setValue(value)])
            ]
        )
        
        // Check parent store's value changes
        await XCTAsyncAssertEqual(
            { await self.store.state.eventsReceived },
            { [.subEvent(.setValueViaEffect(value)), .subEvent(.setValue(value))] }
        )
    }
    
    // MARK: Effects
    
    func testSendingEventThatTriggersAnEffect() async {
        await XCTAssertStateChange(
            store: self.store,
            event: .setValueViaEffect("a"),
            matches: [
                .init(),
                .init(
                    eventsReceived: [
                        .setValueViaEffect("a")
                    ]
                ),
                .init(
                    value: "a",
                    eventsReceived: [
                        .setValueViaEffect("a"),
                        .setValue("a")
                    ]
                )
            ]
        )
    }
    
    func testTriggeringLongRunningEffect() async {
        await XCTAssertStateChange(
            store: self.store,
            event: .startLongRunningEffect,
            matches: [
                .init(),
                .init(
                    eventsReceived: [.startLongRunningEffect]
                ),
                .init(
                    value: "a",
                    eventsReceived: [
                        .startLongRunningEffect,
                        .setValue("a")
                    ]
                ),
                .init(
                    value: "b",
                    eventsReceived: [
                        .startLongRunningEffect,
                        .setValue("a"),
                        .setValue("b")
                    ]
                ),
                .init(
                    value: "c",
                    eventsReceived: [
                        .startLongRunningEffect,
                        .setValue("a"),
                        .setValue("b"),
                        .setValue("c")
                    ]
                )
            ]
        )
        
        await XCTAsyncAssertEventuallyEqual(
            { 0 },
            { await self.manager.tasks.count }
        )
    }
    
    func testCancellingEffect() async {
        let id = "1"
        let task = Empty(completeImmediately: false)
            .sink(
                receiveValue: {},
                receiveCompletion: { result in }
            )
        
        await self.manager.addTask(
            task,
            with: id
        )
        
        await XCTAsyncAssertEqual(
            { 1 },
            { await self.manager.tasks.count }
        )
        
        await self.store.send(.triggerCancelEffect(id))
                
        await XCTAsyncAssertEventuallyEqual(
            { 0 },
            { await self.manager.tasks.count }
        )
        
        XCTAssertTrue(task.isCancelled)
    }
}
