import SwiftUI


public struct UnwrapStore<State, Event, Environment, Content: View>: View {
    // Private
    private let content: (Store<State?, Event, Environment>) -> Content
    private let store: Store<State?, Event, Environment>
    
    // MARK: Initialization
    
    public init<UnwrappedContent>(
        _ store: Store<State?, Event, Environment>,
        @ViewBuilder unwrappedContent: @escaping (Store<State, Event, Environment>) -> UnwrappedContent
    ) where Content == UnwrappedContent? {
        self.store = store
        self.content = { store in
            guard let state = store.state else { return nil }
            
            return unwrappedContent(
                store.scope(
                    state: { $0 ?? state },
                    event: { $0 },
                    environment: { $0 }
                )
            )
        }
    }
    
    // MARK: Body
    
    public var body: some View {
        self.content(self.store)
    }
}



// MARK: Preview

struct UnwrapStore_Previews: PreviewProvider {
    enum Event { }
    struct Environment { }
    
    static let nilStore: Store<String?, Event, Environment> = .init(
        state: nil,
        reducer: .empty,
        environment: .init(),
        middlewares: []
    )
    
    static let store: Store<String?, Event, Environment> = .init(
        state: "hello",
        reducer: .empty,
        environment: .init(),
        middlewares: []
    )
    
    static var previews: some View {
        VStack {
            UnwrapStore(
                self.nilStore,
                unwrappedContent: { _ in Text("Unseen") }
            )
            
            UnwrapStore(
                self.store,
                unwrappedContent: { _ in Text("Seen") }
            )
        }
    }
}
