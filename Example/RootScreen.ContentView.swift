import SwiftUI


extension RootScreen
{
    struct ContentView: View
    {
        @StateObject var store: Store
        
        // MARK: Body
        
        var body: some View {
            VStack(alignment: .center) {
                Text(verbatim: .init(self.store.count))
                    .font(.largeTitle)
                
                HStack {
                    Button("Decrement", role: nil) {
                        await self.store.send(.decrement)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Increment", role: nil) {
                        await self.store.send(.increment)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Delayed increment", role: nil) {
                        await self.store.send(.incrementWithDelay)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}



// MARK: Preview

struct RootScreen_ContentView_Previews: PreviewProvider
{
    static var previews: some View {
        RootScreen.mock(
            state: .init(
                count: 0
            )
        )
    }
}
