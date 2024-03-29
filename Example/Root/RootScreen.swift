import SwiftUI
import RedUx


struct RootScreen: View, RedUxable {
    typealias LocalState = AppState
    typealias LocalEvent = AppEvent
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
            TextEditor(
                text: self.viewModel.binding(
                    value: \.text,
                    event: AppEvent.setText
                )
            )
            .frame(height: 200)
            
            TextField(
                "Text field",
                text: self.viewModel.binding(
                    value: \.textFieldText,
                    event: AppEvent.setTextFieldText
                )
            )
            
            Text(verbatim: .init(self.viewModel.count))
                .font(.largeTitle)
            
            HStack {
                Button("Decrement") {
                    self.viewModel.send(.decrement)
                }
                .buttonStyle(.bordered)
                
                Button("Increment") {
                    self.viewModel.send(.increment)
                }
                .buttonStyle(.bordered)
                
                Button("Delayed increment") {
                    self.viewModel.send(.incrementWithDelayViaEffect)
                }
                .buttonStyle(.bordered)
            }
            
            Button("Present sheet") {
                self.viewModel.send(.presentSheet)
            }
            .buttonStyle(.bordered)
        }
        .sheet(
            isPresented: self.viewModel.binding(
                value: \.isPresentingSheet
            ),
            onDismiss: { self.viewModel.send(.dismissSheet) },
            content: {
                DetailsScreen.make(
                    store: self.store.scope(
                        state: \.details,
                        event: AppEvent.details,
                        environment: { $0 }
                    )
                )
            }
        )
    }
}



// MARK: Preview

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen.mock(
            state: .init(
                count: 0
            ),
            environment: .mock
        )
    }
}
