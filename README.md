# RedUx

An experiment of using Swift's async await in a Redux pattern.

## Example

### Store definition

```swift
import RedUx
import SwiftUI


enum RootScreen
{
    typealias Store = RedUx.Store<State, Event, Environment>
    
    @MainActor
    static func make() -> some View
    {
        ContentView(
            store: Store(
                state: .init(),
                reducer: self.reducer,
                environment: .init()
            )
        )
    }
    
    @MainActor
    static func mock(
        state: State
    ) -> some View
    {
        ContentView(
            store: Store(
                state: state,
                reducer: .empty(),
                environment: .init()
            )
        )
    }
}



// MARK: Reducer

extension RootScreen
{
    static let reducer: Reducer<State, Event, Environment> = Reducer { state, event, environment in
        switch event
        {
        case .increment:
            state.count += 1
            return .none
        case .decrement:
            state.count -= 1
            return .none
        case .incrementWithDelay:
            return .init { continuation in
                // Really taxing shiz
                await Task.sleep(2 * 1_000_000_000)
                continuation.yield(.increment)
                continuation.finish()
            }
        }
    }
}



// MARK: State

extension RootScreen
{
    struct State: Equatable
    {
        var count = 0
    }
}



// MARK: Event

extension RootScreen
{
    enum Event
    {
        case increment
        case decrement
        case incrementWithDelay
    }
}



// MARK: Environment

extension RootScreen
{
    struct Environment { }
}

```

### View

```swift
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
                    Button("Decrement") {
                        self.store.send(.decrement)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Increment") {
                        self.store.send(.increment)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Delayed increment") {
                        self.store.send(.incrementWithDelay)
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

```

## Requirements

- iOS 15.0+
- macOS 12.0+

## Installation

Don't

## License

Whatevs.
