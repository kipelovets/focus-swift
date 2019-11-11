import Foundation

class TaskTree {
    let filter: PerspectiveType
    let root: TaskTreeNode
    
    private var originalTasks: [Task]

    init(from space: SpaceModel, with filter: PerspectiveType) {
        let tasks = space.tasks.filter({ filter.accepts(task: $0) }).sorted(by: { $0.position < $1.position })
        let root = TaskTreeNode(rootFor: tasks, with: filter)
        
        self.root = root
        self.filter = filter
        self.originalTasks = root.flattenChildren.map { $0.model! }
    }

    func nth(_ n: Int) -> TaskTreeNode? {
        var counter = -1
        var node: TaskTreeNode? = root
        while counter < n, node != nil {
            node = node?.succeeding
            counter += 1
        }

        return node
    }
    
    func commit(to space: SpaceModel) {
        let currentTasks = self.root.flattenChildren.map { $0.model! }
        
        for task in currentTasks {
            if !originalTasks.contains(task) {
                space.tasks.append(task)
            }
        }
        
        switch filter {
        case .Inbox, .Project(_):
            root.reindexChildren()
        default:
            var pos = 0
            var node = root.succeeding
            while node != nil {
                switch filter {
                case .Due(_):
                    node?.model?.duePosition = pos
                case .Tag(let tag):
                    node?.model?.position(at: pos, in: tag)
                default:
                    break
                }
                pos += 1
                node = node?.succeeding
            }
        }
        
        for task in originalTasks {
            if !currentTasks.contains(task) {
                space.tasks.remove(at: space.tasks.firstIndex(of: task)!)
            }
        }
        originalTasks = root.flattenChildren.map { $0.model! }
    }
    
    func find(by id: Int) -> TaskTreeNode? {
        var tasks = root.children
        while tasks.count > 0 {
            var newTasks: [TaskTreeNode] = []
            for task in tasks {
                if task.id == id {
                    return task
                }
                newTasks += task.children
            }
            tasks = newTasks
        }
        
        return nil
    }
}

