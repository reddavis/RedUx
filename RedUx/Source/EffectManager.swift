import Foundation

actor EffectManager {
    var tasks: [String: Task<Void, Never>] = [:]
    
    // MARK: Task management
    
    func addTask(_ task: Task<Void, Never>, with id: String) {
        self.removeTask(id) // Cancel previous task with the same ID.
        self.tasks[id] = task
    }
    
    func removeTask(_ id: String) {
        guard let task = self.tasks[id] else { return }
        task.cancel()
        self.tasks[id] = nil
    }
}
