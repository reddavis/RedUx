# RedUx

A super simple Swift implementation of the redux pattern making use of Swift 5.5's new async await API's. 

## Requirements

- iOS 15.0+
- macOS 12.0+

## Installation

### Swift Package Manager

In Xcode:

1. Click `Project`.
2. Click `Package Dependencies`.
3. Click `+`.
4. Enter package URL: `https://github.com/reddavis/Redux`.
5. Add `RedUx` to your app target.

## Documentation

Documentation can be found [here](https://determined-dubinsky-ed15d5.netlify.app/).

## Usage

### App store

```
import Asynchrone
import RedUx


typealias AppStore = RedUx.Store<AppState, AppEvent, AppEnvironment>


extension AppStore {
    static func make() -> AppStore {
        Store(
            state: .init(),
            reducer: reducer,
            environment: .init(),
            middlewares: [
                HighlyComplicatedIncrementMiddleware().eraseToAnyMiddleware()
            ]
        )
    }
    
    static func mock(
        state: AppState
    ) -> AppStore {
        Store(
            state: state,
            reducer: .empty,
            environment: .init(),
            middlewares: []
        )
    }
}



// MARK: Reducer

fileprivate let reducer: Reducer<AppState, AppEvent, AppEnvironment> = Reducer { state, event, environment in
    switch event {
    case .increment:
        state.count += 1
        return .none
    case .decrement:
        state.count -= 1
        return .none
    case .incrementWithDelayViaMiddleware:
        return .none
    case .incrementWithDelayViaEffect:
        return .effect {
            try? await Task.sleep(seconds: 2)
            return .increment
        }.eraseToAnyAsyncSequenceable()
    case .toggleIsPresentingSheet:
        state.isPresentingSheet.toggle()
        return .none
    case .details:
        return .none
    }
}
<>
detailsReducer.pull(
    state: \.details,
    event: {
        guard case AppEvent.details(let localEvent) = $0 else { return nil }
        return localEvent
    },
    appEvent: AppEvent.details,
    environment: { $0 }
)



// MARK: State

struct AppState: Equatable {
    var count = 0
    var isPresentingSheet = false
    var details: DetailsState = .init()
}



// MARK: Event

enum AppEvent {
    case increment
    case decrement
    case incrementWithDelayViaMiddleware
    case incrementWithDelayViaEffect
    case toggleIsPresentingSheet
    case details(DetailsEvent)
}



// MARK: Environment

struct AppEnvironment {
    static var mock: AppEnvironment { .init() }
}



// MARK: Middleware

struct HighlyComplicatedIncrementMiddleware: Middlewareable {
    let outputStream: AnyAsyncSequenceable<AppEvent>
    
    // Private
    private let _outputStream: PassthroughAsyncSequence<AppEvent> = .init()
    
    // MARK: Initialization
    
    init() {
        self.outputStream = self._outputStream.eraseToAnyAsyncSequenceable()
    }
    
    // MARK: Middlewareable
    
    func execute(event: AppEvent, state: () -> AppState) async {
        guard case .incrementWithDelayViaMiddleware = event else { return }
        
        try? await Task.sleep(seconds: 2)
        self._outputStream.yield(.increment)
    }
}

```

### Root screen

```swift
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
                    self.viewModel.send(.incrementWithDelayViaMiddleware)
                }
                .buttonStyle(.bordered)
            }
            
            Button("Present sheet") {
                self.viewModel.send(.toggleIsPresentingSheet)
            }
            .buttonStyle(.bordered)
        }
        .sheet(
            isPresented: self.viewModel.binding(
                value: \.isPresentingSheet,
                event: .toggleIsPresentingSheet
            ),
            onDismiss: nil,
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
```

### Tests

```swift
import XCTest
import RedUxTestUtilities
@testable import Example


class RootScreenTests: XCTestCase {
    func testStateChange() async {
        let store = RootScreen.LocalStore.make()
        
        await XCTAssertStateChange(
            store: store,
            events: [
                .increment,
                .decrement,
                .incrementWithDelay
            ],
            matches: [
                .init(),
                .init(count: 1),
                .init(count: 0),
                .init(count: 1)
            ]
        )
    }
}
```

## Other libraries

- [Papyrus](https://github.com/reddavis/Papyrus) - Papyrus aims to hit the sweet spot between saving raw API responses to the file system and a fully fledged database like Realm.
- [Asynchrone](https://github.com/reddavis/Asynchrone) - Extensions and additions to AsyncSequence, AsyncStream and AsyncThrowingStream.
- [Validate](https://github.com/reddavis/Validate) - A property wrapper that can validate the property it wraps.
- [Kyu](https://github.com/reddavis/Kyu) - A persistent queue system in Swift.
- [FloatingLabelTextFieldStyle](https://github.com/reddavis/FloatingLabelTextFieldStyle) - A floating label style for SwiftUI's TextField.
- [Panel](https://github.com/reddavis/Panel) - A panel component similar to the iOS Airpod battery panel.
