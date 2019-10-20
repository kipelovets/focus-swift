import Foundation

final class Task: Hashable, Identifiable, ObservableObject {
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: Int
    var title: String
    var notes: String = ""
    var createdAt: Date
    var dueAt: Date? = nil
    var done: Bool = false
    var project: Project? = nil
    var tagPositions: [TaskTagPosition] = []
    var children: [Task] = [] 
    var parent: Task? = nil
    var position = 0

    var dto: TaskDto {
        get {
            TaskDto(id: id, title: title, notes: notes, createdAt: createdAt, dueAt: dueAt, done: done, projectId: project?.id, tagPositions: tagPositions.map {$0.dto}, parentTaskId: parent?.id, position: position)
        }
    }

    init(id: Int, title: String, children: [Task] = []) {
        self.id = id
        self.title = title
        self.children = children
        self.createdAt = Date()
        self.children.forEach {$0.parent = self}
    }

    init(from task: TaskDto) {
        self.id = task.id
        self.title = task.title
        self.notes = task.notes
        self.createdAt = task.createdAt
        self.dueAt = task.dueAt
        self.done = task.done
    }

    public func add(child task: Task) {
        children.append(task)
        task.parent = self
    }
}

final class Project: Equatable, Identifiable {
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

    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
}

final class Tag: Equatable, Identifiable {
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

    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
}

final class TaskTagPosition {
    var tag: Tag
    var position: Int

    var dto: TaskTagPositionDto {
        get {
            TaskTagPositionDto(tagId: tag.id, position: position)
        }
    }

    init(with tag: Tag, position: Int) {
        self.tag = tag
        self.position = position
    }
}

final class TaskSpace {
    var tasks: [Task]
    var projects: [Project]
    var tags: [Tag]

    var dto: TaskSpaceDto {
        get {
            return TaskSpaceDto(
                tasks: tasks.map { $0.dto },
                projects: projects.map {$0.dto},
                tags: tags.map {$0.dto}
            )
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

        self.tasks = space.tasks.map { Task(from: $0) }
        for task in self.tasks {
            let t = space.tasks.first(where: { $0.id == task.id })!
            if t.parentTaskId != nil {
                let p = self.tasks.first(where: { $0.id == t.parentTaskId })!
                p.add(child: task)
            }
            if t.projectId != nil {
                let p = self.projects.first(where: { $0.id == t.projectId })!
                task.project = p
            }
            for tagPos in t.tagPositions {
                let tag = self.tags.first(where: { $0.id == tagPos.tagId })!
                task.tagPositions.append(TaskTagPosition(with: tag, position: tagPos.position))
            }
        }
    }
    
    var nextId: Int {
        get {
            return 1 + (tasks.map { $0.id }.max() ?? 0)
        }
    }
}

