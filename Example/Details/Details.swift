import RedUx

struct DetailsState: Equatable {
    var isPresentingActionSheet: Bool = false
}

// MARK: Reducer

let detailsReducer: Reducer<DetailsState, DetailsEvent, AppEnvironment> = Reducer { state, event, environment in
    switch event {
    case .presentActionSheet:
        state.isPresentingActionSheet = true
        return .none
    case .dismissActionSheet:
        state.isPresentingActionSheet = false
        return .none
    }
}



// MARK: Event

enum DetailsEvent {
    case presentActionSheet
    case dismissActionSheet
}
