import SwiftUI


extension Store
{
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: @escaping (ScopedState) -> Event
    ) -> Binding<ScopedState>
    {
        Binding(
            get: { value(self.state) },
            set: { scopedState, transaction in
                guard transaction.animation == nil else
                {
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
    
    public func binding<ScopedState>(
        value: @escaping (State) -> ScopedState,
        event: Event
    ) -> Binding<ScopedState>
    {
        self.binding(
            value: value,
            event: { _ in event }
        )
    }
}
