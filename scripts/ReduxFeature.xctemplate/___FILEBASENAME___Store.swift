import RedUx

typealias ___VARIABLE_productName___Store = RedUx.Store<___VARIABLE_productName___State, ___VARIABLE_productName___Event, ___VARIABLE_productName___Environment>

extension ___VARIABLE_productName___Store {
    static func make(
        state: State = .init(),
        environment: Environment = .main()
    ) -> Self {
        .init(
            state: .init(),
            reducer: reducer,
            environment: .main(),
            middlewares: []
        )
    }

    #if DEBUG
    static func mock(
        state: State = .init(),
        environment: Environment = .mock()
    ) -> Self {
        .init(
            state: state,
            reducer: .empty,
            environment: environment,
            middlewares: []
        )
    }
    #endif
}

private let reducer: Reducer<___VARIABLE_productName___State, ___VARIABLE_productName___Event, ___VARIABLE_productName___Environment> = ___VARIABLE_productName___Reducer.main
