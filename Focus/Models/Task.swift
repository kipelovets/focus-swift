import Foundation

final class Task: Hashable, Identifiable, ObservableObject {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: Int
    @Published var title: String
    @Published var notes: String = ""
    var createdAt: Date
    @Published var dueAt: Date? = nil
    @Published var done: Bool = false
    @Published var project: Project? = nil
    @Published var tags: [Tag] = []
    @Published var children: [Task] = []

    var dto: TaskDto {
        get {
            TaskDto(id: id, title: title, createdAt: createdAt, dueAt: dueAt, done: done, projectId: project?.id, tagIds: tags.map {$0.id})
        }
    }
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
        self.createdAt = Date()
    }
    
    init(from task: TaskDto) {
        self.id = task.id
        self.title = task.title
        self.notes = task.notes
        self.createdAt = task.createdAt
        self.dueAt = task.dueAt
        self.done = task.done
    }
}

final class Project: Identifiable {
    var id: Int
    var title: String

    var dto: ProjectDto {
        get {
            ProjectDto(id: id, title: title)
        }
    }

    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    init(from project: ProjectDto) {
        self.id = project.id
        self.title = project.title
    }
}

final class Tag: Identifiable {
    var id: Int
    var title: String

    var dto: TagDto {
        get {
            TagDto(id: id, title: title)
        }
    }
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    init(from tag: TagDto) {
        self.id = tag.id
        self.title = tag.title
    }
}

final class TaskSpace {
    var tasks: [Task]
    var projects: [Project]
    var tags: [Tag]
    
    var dto: TaskSpaceDto {
        get {
            var taskDtos: [TaskDto] = tasks.map { $0.dto }

            var parentTasks = tasks
            while parentTasks.count > 0 {
                var newParentTasks: [Task] = []
                parentTasks.forEach { parentTask in
                    parentTask.children.forEach { task in
                        taskDtos.append(task.dto)
                        if task.children.count > 0 {
                            newParentTasks.append(task)
                        }
                    }
                }
                parentTasks = newParentTasks
            }

            return TaskSpaceDto(tasks: taskDtos, projects: projects.map {$0.dto}, tags: tags.map {$0.dto})
        }
    }

    init(tasks: [Task], projects: [Project], tags: [Tag]) {
        self.tasks = tasks
        self.projects = projects
        self.tags = tags
    }
    
    init(from space: TaskSpaceDto) {
        self.tags = space.tags.map { Tag(from: $0) }
        self.projects = space.projects.map { Project(from: $0) }
        
        self.tasks = []
        let allTasks = space.tasks.map { Task(from: $0) }
        for task in allTasks {
            let t = space.tasks.first(where: { $0.id == task.id })!
            if t.parentTaskId != nil {
                let p = allTasks.first(where: { $0.id == t.parentTaskId })!
                p.children.append(task)
            } else {
                self.tasks.append(task)
            }
            if t.projectId != nil {
                let p = self.projects.first(where: { $0.id == t.projectId })!
                task.project = p
            }
        }
    }
}

