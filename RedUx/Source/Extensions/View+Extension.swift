import SwiftUI


public extension View {
    /// Synchronize a `Binding` and a `FocusState.Binding`'s value.
    /// [🙌 Pointfree](https://twitter.com/pointfreeco/status/1423340276098031619/photo/1)
    /// - Returns: A view.
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
