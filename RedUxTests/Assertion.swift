import XCTest


public func XCTAsyncAssertThrowsError<T>(
    _ closure: () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async
{
    do
    {
        _ = try await closure()
        XCTFail(message())
    }
    catch { }
}


public func XCTAsyncAssertNil<T>(
    _ closure: () async -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async
{
    let value = await closure()
    XCTAssertNil(
        value,
        message(),
        file: file,
        line: line
    )
}


public func XCTAsyncAssertEqual<T: Equatable>(
    _ expression1: @escaping () async -> T,
    _ expression2: @escaping () async -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async
{
    let valueA = await expression1()
    let valueB = await expression2()

    XCTAssertEqual(
        valueA,
        valueB,
        message(),
        file: file,
        line: line
    )
}


public func XCTAssertEventuallyEqual<T: Equatable>(
    _ expression1: @escaping () async throws -> T,
    _ expression2: @escaping () async throws -> T,
    _ message: @autoclosure () -> String = "",
    timeout: TimeInterval = 10.0,
    file: StaticString = #filePath,
    line: UInt = #line
) async
{
    let handle = Task { () -> Bool in
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        repeat
        {
            let result1 = try? await expression1()
            let result2 = try? await expression2()
            
            if result1 == result2
            {
                return true
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
        } while Date().compare(timeoutDate) == .orderedAscending
        
        return false
    }
    
    let success = await handle.value
    if success { return }
    
    XCTFail(message(), file: file, line: line)
}
