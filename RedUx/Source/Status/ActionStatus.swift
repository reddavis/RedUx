import Foundation

/// `ActionStatus` is a helpful enum which can be used to describe the state of a
/// long running action such as; submitting a form, manipulating data, running migrations,
/// executing API requests etc.
///
/// An example of what this could look like being used.
/// ```swift
/// struct AppState: Equatable {
///     var migrationStatus: ActionStatus<MigrationError> = .idle
/// }
/// ```
public enum ActionStatus<ErrorType>: Equatable where ErrorType: Error & Equatable {
    /// Action is in an idle state and hasn't yet started.
    case idle
    
    /// Action is in a loading state.
    case loading
    
    /// Action has been successfully completed.
    case complete
    
    /// Action has failed.
    case failed(ErrorType)
    
    // MARK: Helpers
    
    /// Indicates whether ActionStatus is in an idle state.
    public var isIdle: Bool {
        guard case .idle = self else { return false }
        return true
    }
    
    /// Indicates whether ActionStatus is in a loading state.
    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    /// Indicates whether ActionStatus is in a complete state.
    public var isComplete: Bool {
        guard case .complete = self else { return false }
        return true
    }
    
    /// Indicates whether ActionStatus is in a failed state.
    public var isFailed: Bool {
        guard case .failed = self else { return false }
        return true
    }
    
    /// Convenience accessor to the error if the status is in a failed state.
    public var error: ErrorType? {
        guard case .failed(let error) = self else { return nil }
        return error
    }
}
