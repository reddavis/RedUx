import Foundation


extension Store
{
    public func projection<ProjectedState, ProjectedEvent, ProjectedEnvironment>(
        state: (_ state: ProjectedState) -> State,
        event: (_ event: ProjectedEvent) -> Event,
        environment: (_ environment: ProjectedEvent) -> Environment
    ) -> Store<State, Event, Environment>
    {
        .init(
            state: <#T##State#>, reducer: <#T##Reducer<State, Event, Environment>#>, environment: <#T##Environment#>)
    }
}
