import Foundation

/// `ValueStatus` is a helpful enum which can be used to describe the state of a
/// long running action that involves a value such as; fetching data from an API.
///
/// An example of what this could look like being used.
/// ```swift
/// struct AppState: Equatable {
///     var blogPosts: ValueStatus<[BlogPost], APIError> = .idle
/// }
/// ```
public enum ValueStatus<Value, ErrorType>: Equatable
where Value: Equatable, ErrorType: Error & Equatable {
    /// Status is in an idle state and hasn't yet started.
    case idle
    
    /// Status is in a loading state.
    ///
    /// The loading status can provide access to previously loaded
    /// value. This can be used to display the previously loaded value
    /// along with a loading indicator.
    case loading(Value?)
    
    /// Status is complete.
    case complete(Value)
    
    /// Status has failed.
    ///
    /// The failed status can provide access to previously loaded
    /// value. This can be used to display the previously loaded value
    /// along with a error message.
    case failed(ErrorType, Value?)
    
    // MARK: Helpers
    
    /// Indicates whether ValueStatus is in an idle state.
    public var isIdle: Bool {
        guard case .idle = self else { return false }
        return true
    }
    
    /// Indicates whether ValueStatus is in a loading state.
    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
    
    /// Indicates whether ValueStatus is in a complete state.
    public var isComplete: Bool {
        guard case .complete = self else { return false }
        return true
    }
    
    /// Indicates whether ValueStatus is in a failed state.
    public var isFailed: Bool {
        guard case .failed = self else { return false }
        return true
    }
    
    /// Convenience accessor to the error if the status is in a failed state.
    public var error: ErrorType? {
        guard case .failed(let error, _) = self else { return nil }
        return error
    }
    
    /// Convenience accessor to the value if the status is in a complete state.
    public var value: Value? {
        guard case let .complete(value) = self else { return nil }
        return value
    }
    
    /// Convenience accessor to the latest value of the status.
    ///
    /// This slightly differs from `value` because the value could be coming
    /// from `loading` or `failed`, depending on the current status.
    ///
    /// Example:
    /// - `.idle`
    ///     - `latestValue` => nil
    ///     - `value` => nil
    /// - `.loading(nil)`
    ///     - `latestValue` => nil
    ///     - `value` => nil
    /// - `.complete("value")`
    ///     - `latestValue` => "value"
    ///     - `value` => "value"
    /// - `.loading("value")`
    ///     - `latestValue` => "value"
    ///     - `value` => nil
    public var latestValue: Value? {
        switch self {
        case .complete(let value):
            return value
        case .loading(let value), .failed(_, let value):
            return value
        default:
            return nil
        }
    }
}

extension ValueStatus: Sendable where Value: Sendable {}
