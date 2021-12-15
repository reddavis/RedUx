import XCTest
@testable import RedUx


final class AsyncStreamTests: XCTestCase
{
    func testMerge() async
    {
        let streamA = AsyncStream<Int> { continuation in
            continuation.yield(0)
            await Task.sleep(100000)
            continuation.yield(2)
            continuation.finish()
        }
        
        let streamB = AsyncStream<Int> { continuation in
            await Task.sleep(100000)
            continuation.yield(1)
            await Task.sleep(100000)
            continuation.yield(3)
            continuation.yield(4)
            continuation.finish()
        }
        
        let merged = streamA.merge(with: streamB)
        var values: [Int] = []
        for await value in merged
        {
            values.append(value)
        }
        
        XCTAssertEqual(values, [0, 1, 2, 3, 4])
    }
}
