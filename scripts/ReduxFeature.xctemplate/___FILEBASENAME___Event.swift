enum ___VARIABLE_productName___Event {
    case idle
    
    case navigation(NavigationEvent<___VARIABLE_productName___Route>)
}

// Delete this if the screen has no parent. Or delete this comment if it has one.
// If you keep it, please rename `from(ParentName: Foo` to `from(parentName: Foo`
extension LegalEvent {
    static func from(___VARIABLE_parentName___: ___VARIABLE_parentName___Event) -> Self? {
        guard case let ___VARIABLE_parentName___Event.legal(localEvent) = ___VARIABLE_parentName___Event else { return nil }
        return localEvent
    }
}
