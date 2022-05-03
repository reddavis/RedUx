import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreen.main(
                store: AppStore.main()
            )
        }
    }
}
