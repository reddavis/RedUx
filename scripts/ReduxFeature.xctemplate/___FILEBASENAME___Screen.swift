import RedUx
import SwiftUI

struct ___VARIABLE_productName___Screen: View, RedUxable {
    typealias LocalState = ___VARIABLE_productName___State
    typealias LocalEvent = ___VARIABLE_productName___Event
    typealias LocalEnvironment = ___VARIABLE_productName___Environment

    let store: LocalStore
    @StateObject var viewModel: LocalViewModel
    
    // MARK: Initialization
    
    init(store: LocalStore, viewModel: LocalViewModel) {
        self.store = store
        _viewModel = .init(wrappedValue: viewModel)
    }

    // MARK: Body

    var body: some View {
        List {}
        .navigationTitle("___VARIABLE_productName___")
    }
}

// MARK: Preview

#if DEBUG
struct ___VARIABLE_productName___Screen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ___VARIABLE_productName___Screen.mock(
                state: .init(),
                environment: .mock()
            )
        }
    }
}
#endif
