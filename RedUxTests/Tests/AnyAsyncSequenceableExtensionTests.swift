import Asynchrone
import XCTest
@testable import RedUx


final class AnyAsyncSequenceableExtensionTests: XCTestCase {
    func testEffectBuilder() async {
        let event = AppEvent.setValue("a")
        let sequence = AnyAsyncSequenceable.effect {
            event
        }
        
        let result = await sequence.collect()
        XCTAssertEqual(result, [event])
    }
    
    func testFireAndForgetBuilder() async {
        let sequence = AnyAsyncSequenceable<AppEvent>.fireAndForget { }
        
        let result = await sequence.collect()
        XCTAssert(result.isEmpty)
    }
}
