import Asynchrone
import XCTest
@testable import RedUx

final class EffectTests: XCTestCase {
    func testInitializationWithClosure() async {
        let id = "123"
        let effect = Effect(id: id) {
            AppEvent.setValueToA
        }
        
        XCTAssertEqual(effect.id, id)
        XCTAssertFalse(effect.isCancellation)
        
        let value = await effect.collect()
        XCTAssertEqual(value, [.setValueToA])
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
