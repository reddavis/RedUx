import SwiftUI


extension Store {
    /// Creates a `Binding` that prevents direct write access to the
    /// state and instead sends an event on `set`.
    ///
    /// This makes working with SwiftUI components easier.
    ///
    /// For example:
    ///
    /// ```swift
    /// TextField(
    ///     "Email",
    ///     text: viewStore.binding(
    ///         get: \.email,
    ///         send: { .setEmail($0) }
    ///     )
    /// )
    /// ```
    /// - Parameters:
    ///   - value: A function to extract the value from the state.
    ///   - event: A function to build the event that is sent to the store.
    /// - Returns: A binding.
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: @escaping (ScopedState) -> Event
    ) -> Binding<ScopedState> {
        Binding(
            get: { value(self.state) },
            set: { scopedState, transaction in
                guard transaction.animation == nil else {
                    _ = SwiftUI.withTransaction(transaction) {
                        Task.detached {
                            await MainActor.run {
                                self.send(event(scopedState))
                            }
                        }
                    }
                    return
                }
                
                Task.detached {
                    await MainActor.run {
                        self.send(event(scopedState))
                    }
                }
            }
        )
    }
    
    /// Creates a `Binding` that prevents direct write access to the
    /// state and instead sends an event on `set`.
    ///
    /// This makes working with SwiftUI components easier.
    ///
    /// For example:
    ///
    /// ```swift
    /// SomeView()
    ///     .alert(
    ///         "Error",
    ///         isPresented: self.store.binding(
    ///             value: { $0.loginStatus.isFailed },
    ///             event: .resetLoginState
    ///         ),
    ///         actions: { },
    ///         message: {
    ///             Text(self.store.loginStatus.failedMessage)
    ///         }
    ///     )
    /// ```
    /// - Parameters:
    ///   - value: A function to extract the value from the state.
    ///   - event: An event that is sent to the store.
    /// - Returns: A binding.
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: Event
    ) -> Binding<ScopedState> {
        self.binding(
            value: value,
            event: { _ in event }
        )
    }
}
