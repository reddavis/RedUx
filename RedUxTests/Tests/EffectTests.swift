import Asynchrone
import XCTest
@testable import RedUx

final class EffectTests: XCTestCase {
    func testInitializationWithReturningClosure() async {
        let id = "123"
        let effect = Effect(id: id) {
            AppEvent.setValueToA
        }
        
        XCTAssertEqual(effect.id, id)
        XCTAssertFalse(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertEqual(value, [.setValueToA])
    }
    
    func testInitializationWithReturnlessClosure() async {
        let id = "123"
        let values = ["1", "2", "3"]
        let effect = Effect<AppEvent>(id: id) { emit, finish in
            for value in values {
                emit(.setValue(value))
            }
            
            finish()
        }
        
        XCTAssertEqual(effect.id, id)
        XCTAssertFalse(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertEqual(
            value,
            values.map(AppEvent.setValue)
        )
    }
    
    func testInitializationWithEvent() async {
        let effect = Effect(AppEvent.setValueToA)
        
        XCTAssertFalse(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertEqual(value, [.setValueToA])
    }
    
    func testInitializationWithSequence() async {
        let id = "123"
        let effect = Effect(
            id: id,
            sequence: Just(AppEvent.setValueToA)
        )
        
        XCTAssertEqual(effect.id, id)
        XCTAssertFalse(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertEqual(value, [.setValueToA])
    }
    
    func testCancelBuilder() async {
        let id = "123"
        let effect = Effect<AppEvent>.cancel(id)
        
        XCTAssertEqual(effect.id, id)
        XCTAssertTrue(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertTrue(value.isEmpty)
    }
}
