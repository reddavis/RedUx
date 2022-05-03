import SwiftUI
import Quoin

struct DetailsScreen: View, Quoinable {
    typealias LocalState = DetailsState
    typealias LocalEvent = DetailsEvent
    typealias LocalEnvironment = AppEnvironment
    
    let store: LocalStore
    @StateObject var viewModel: LocalViewModel
    
    // MARK: Initialization
    
    init(store: LocalStore, viewModel: LocalViewModel) {
        self.store = store
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Button("Toggle dialog") {
                self.viewModel.send(.toggleActionSheet)
            }
            .buttonStyle(.bordered)
        }
        .confirmationDialog(
            "",
            isPresented: self.viewModel.binding(
                value: \.isPresentingActionSheet,
                event: .toggleActionSheet
            ),
            actions: {
                Button("A") { }
            }
        )
    }
}

// MARK: Preview

#if DEBUG
struct DetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailsScreen.mock(
            state: .init(
                isPresentingActionSheet: false
            ),
            environment: .mock
        )
    }
}
#endif
