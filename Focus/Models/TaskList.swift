import Foundation

final class TaskList: ObservableObject {

    @Published var tasks: [Task]
    @Published var tags: [Tag]
    @Published var projects: [Project]
    @Published var currentTaskId: Int?
    @Published private(set) var editing: Bool = false
    @Published var dropTargetIndex: Int? = nil

    private let repo: TaskSpaceRepository

    public var currentTask: Task? {
        get {
            guard let id = currentTaskId else {
                return nil
            }
            return find(by: id, in: tasks)
        }
    }

    public var tasksRoot: Task {
        get {
            Task(id: -1, title: "", children: tasks)
        }
    }

    public var space: TaskSpace {
        get {
            TaskSpace(tasks: tasks, projects: projects, tags: tags)
        }
    }

    init(repo: TaskSpaceRepository) {
        self.repo = repo

        let space = TaskSpace(from: repo.Load())
        self.tasks = space.tasks
        self.tags = space.tags
        self.projects = space.projects
        self.currentTaskId = tasks.count > 0 ? tasks[0].id : nil
        print("Loaded \(self.tasks)")
    }

    public func next() {
        guard let current = self.currentTask else {
            return
        }
        if current.children.count > 0 {
            currentTaskId = current.children[0].id
        } else {
            if let parent = findParent(current, in: tasks) {
                var p: Task? = parent
                var c = current
                while true {
                    guard let pp = p else {
                        let rootIndex = tasks.firstIndex(of: c)!
                        if rootIndex + 1 < tasks.count {
                            currentTaskId = tasks[rootIndex + 1].id
                        }
                        break
                    }
                    let index = pp.children.firstIndex(of: c)!
                    if pp.children.count > index + 1 {
                        currentTaskId = pp.children[index + 1].id
                        break
                    }
                    c = pp
                    p = findParent(c, in: tasks)!
                }
            } else {
                let index = tasks.firstIndex(of: current)!
                if index < tasks.count - 1 {
                    currentTaskId = tasks[index + 1].id
                }
            }
        }
    }

    public func prev() {
        guard let current = self.currentTask else {
            return
        }
        if let parent = findParent(current, in: tasks) {
            let index = parent.children.firstIndex(of: current)!
            if index > 0 {
                var lastChild = parent.children[index - 1]
                while let deeperChild = lastChild.children.last {
                    lastChild = deeperChild
                }

                currentTaskId = lastChild.id
            }
        } else {
            let index = tasks.firstIndex(of: current)!
            if index > 0 {
                var lastChild = tasks[index - 1]
                while let deeperChild = lastChild.children.last {
                    lastChild = deeperChild
                }

                currentTaskId = lastChild.id
            }
        }
    }

    public func taskIndex(for id: Int) -> Int? {
        return tasks.firstIndex { $0.id == id }
    }

    public func isDropTarget(_ task: Task) -> Bool {
        return dropTargetIndex != nil && dropTargetIndex == 1 + tasks.firstIndex(of: task)!
    }

    public func insertTask() {
        let id: Int = 1 + (tasks.map({ $0.id }).max() ?? 0)
        let newTask = Task(id: id, title: "")
        currentTaskId = id
        editing = true

        guard let current = currentTask else {
            tasks.append(newTask)
            return
        }
//        if let parent = findParent(current, in: tasks) {
//            parent.children.insert(newTask, at: parent.children.firstIndex(of: current)! + 1)
//        } else {
//            tasks.insert(newTask, at: 1 + tasks.firstIndex(of: current)!)
//        }
    }

    public func removeTask() {
        editing = false
//        guard let current = currentTask else {
//            return
//        }
//        let root = tasksRoot
//        let parent = current.parent(in: root)!
//
//        let index = parent.children.firstIndex(of: current)!
//        if index > 0 {
//            currentTaskId = parent.children[index - 1].id
//        } else {
//            currentTaskId = parent.id
//        }
//        parent.children.remove(at: index)
//
//        if parent == root {
//            tasks = root.children
//        }
    }

    public func toggleEditing() {
        editing.toggle()
        if (!editing) {
            repo.Save(space: self.space.dto)
        }
    }

    public func edit(task: Task) {
        let index = taskIndex(for: task.id)!
        if currentTaskId != index {
            currentTaskId = index
        }
        if !editing {
            toggleEditing()
        }
    }

    func findParent (_ task: Task, in tasks: [Task]) -> Task?  {
        if tasks.count == 0 {
            return nil
        }
        for t in tasks {
            if t.children.contains(task) {
                return t
            } else {
                if let p = findParent(task, in: t.children) {
                    return p
                }
            }
        }

        return nil
    }

    func find(by id: Int, in tasks: [Task]) -> Task? {
        if tasks.count == 0 {
            return nil
        }
        for task in tasks {
            if task.id == id {
                return task
            }
            if let found = find(by: id, in: task.children) {
                return found
            }
        }

        return nil
    }

    func unindent() {
//        let task = self.currentTask!
//        if let parent = findParent(task, in: tasks) {
//            let indexInParent = parent.children.firstIndex(of: task)!
//            parent.children.remove(at: indexInParent)
//            if let grandParent = findParent(parent, in: tasks) {
//                grandParent.children.insert(task, at: 1 + grandParent.children.firstIndex(of: parent)!)
//            } else {
//                tasks.insert(task, at: 1 + tasks.firstIndex(of: parent)!)
//            }
//
//            let newChildren = parent.children[indexInParent...]
//            task.children += newChildren
//        }
    }

    func indent() {
//        let task = self.currentTask!
//        if let parent = findParent(task, in: tasks) {
//            let index = parent.children.firstIndex(of: task)!
//            if index == 0 {
//                return
//            }
//            let newParent = parent.children[index - 1]
//            parent.children.remove(at: index)
//            newParent.children.append(task)
//        } else {
//            let index = tasks.firstIndex(of: task)!
//            if index == 0 {
//                return
//            }
//            let newParent = tasks[index - 1]
//            tasks.remove(at: index)
//            newParent.children.append(task)
//        }
    }
}

