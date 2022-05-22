import SwiftUI
import RedUx


struct DetailsScreen: View, RedUxable {
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
            Button("Present dialog") {
                self.viewModel.send(.presentActionSheet)
            }
            .buttonStyle(.bordered)
        }
        .confirmationDialog(
            "",
            isPresented: self.viewModel.binding(
                value: \.isPresentingActionSheet,
                event: .dismissActionSheet
            ),
            actions: {
                Button("A") {
                    self.viewModel.send(.dismissActionSheet)
                }
            }
        )
    }
}



// MARK: Preview

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
