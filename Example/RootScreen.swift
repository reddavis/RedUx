import RedUx
import SwiftUI


enum RootScreen {
    typealias Store = AppStore
    
    static func make(
        store: Store
    ) -> some View {
        ContentView(store: store)
    }
    
    static func mock(
        state: AppState
    ) -> some View {
        ContentView(
            store: Store(
                state: state,
                reducer: .empty,
                environment: .mock
            )
        )
    }
}
