import Asynchrone
import XCTest
@testable import RedUx

final class EffectManagerTests: XCTestCase {
    private var manager: EffectManager!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.manager = .init()
    }
    
    func testAddingTask() async {
        let task = Task {}
        let id = "1"
        let internalID = "2"
        await self.manager.addTask(task, id: id, uuid: internalID)
        
        await XCTAsyncAssertEqual(
            { 1 },
            { await self.manager.tasks.count }
        )
    }
    
    func testCancellingTask() async {
        let id = "1"
        let internalID = "2"
        let completionExpectation = self.expectation(description: "Completion called")
        
        let task = Empty(completeImmediately: false)
            .sink(
                receiveValue: {},
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error) where error is CancellationError:()
                    case .failure(let error):
                        XCTFail("Invalid failure error. CancellationError expected: \(error)")
                    case .finished:
                        XCTFail(".finished is an invalid result")
                    }
                    completionExpectation.fulfill()
                }
            )
        
        await self.manager.addTask(task, id: id, uuid: internalID)
        await self.manager.cancelTask(id)
        
        await self.waitForExpectations(timeout: 5.0, handler: nil)
        await XCTAsyncAssertEqual(
            { 0 },
            { await self.manager.tasks.count }
        )
    }
    
    func testNotifyingOfTaskCompletion() async {
        let task = Task {}
        let id = "1"
        let internalID = "2"
        await self.manager.addTask(task, id: id, uuid: internalID)
        await self.manager.taskComplete(id: id, uuid: internalID)
        
        await XCTAsyncAssertEqual(
            { 0 },
            { await self.manager.tasks.count }
        )
    }
    
    func testNotifyingOfTaskCompletionWithDifferentInternalID() async {
        let task = Task {}
        let id = "1"
        let internalID = "2"
        await self.manager.addTask(task, id: id, uuid: internalID)
        await self.manager.taskComplete(id: id, uuid: "different")
        
        await XCTAsyncAssertEqual(
            { 1 },
            { await self.manager.tasks.count }
        )
    }
}
