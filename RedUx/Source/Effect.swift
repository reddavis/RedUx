import Foundation


public struct Effect<Output>
{
    let closure: () async -> Output
    
    // MARK: Initialization
    
    public init(_ closure: @escaping () async -> Output)
    {
        self.closure = closure
    }
}
