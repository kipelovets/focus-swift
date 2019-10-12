import Foundation

final class TaskList: ObservableObject {

    @Published var tasks: [Task]
    @Published var tags: [Tag]
    @Published var projects: [Project]
    @Published var currentTaskIndex = 0
    @Published private(set) var editing: Bool = false
    @Published var dropTargetIndex: Int? = nil

    private let repo: TaskSpaceRepository

    public var currentTask: Task? {
        get {
            tasks[currentTaskIndex]
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
    }

    public func next() {
        currentTaskIndex = min(currentTaskIndex + 1, tasks.count - 1)
    }

    public func prev() {
        currentTaskIndex = max(currentTaskIndex - 1, 0)
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
        currentTaskIndex = tasks.count == 0 ? 0 : currentTaskIndex + 1
        tasks.insert(newTask, at: currentTaskIndex)
        editing = true
    }

    public func removeTask() {
        tasks.remove(at: currentTaskIndex)
        editing = false
        currentTaskIndex = [currentTaskIndex, tasks.count - 1].min()!
    }

    public func toggleEditing() {
        editing.toggle()
        if (!editing) {
            repo.Save(space: self.space.dto)
        }
    }

    public func edit(task: Task) {
        let index = taskIndex(for: task.id)!
        if currentTaskIndex != index {
            currentTaskIndex = index
        }
        if !editing {
            toggleEditing()
        }
    }
}

