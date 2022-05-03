import Quoin

struct DetailsState: Equatable {
    var isPresentingActionSheet: Bool = false
}

// MARK: Reducer

let detailsReducer: Reducer<DetailsState, DetailsEvent, AppEnvironment> = Reducer { state, event, environment in
    switch event {
    case .toggleActionSheet:
        state.isPresentingActionSheet.toggle()
        return .none
    }
}

// MARK: Event

enum DetailsEvent {
    case toggleActionSheet
}
