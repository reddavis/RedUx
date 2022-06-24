import Foundation

actor EffectManager {
    var tasks: [String: TaskWrapper] = [:]
    
    // MARK: Task management
    
    func addTask(_ task: Task<Void, Never>, id: String, uuid: String) {
        self.cancelTask(id) // Cancel previous task with the same ID.
        self.tasks[id] = .init(id: uuid, task: task)
        
        print("TASKS SIZE: \(self.tasks.count)")
    }
    
    func cancelTask(_ id: String) {
        guard let wrapper = self.tasks[id] else { return }
        wrapper.task.cancel()
        self.tasks.removeValue(forKey: id)
    }
    
    func taskComplete(id: String, uuid: String) {
        guard let wrapper = self.tasks[id],
              wrapper.id == uuid else { return }
        self.tasks.removeValue(forKey: id)
    }
}

// MARK: Task wrapper

struct TaskWrapper {
    let id: String
    let task: Task<Void, Never>
}
