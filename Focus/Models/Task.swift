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
    var duePosition = 0

    var dto: TaskDto {
        get {
            TaskDto(
                    id: id,
                    title: title,
                    notes: notes,
                    createdAt: createdAt,
                    dueAt: dueAt,
                    done: done,
                    projectId: project?.id,
                    tagPositions: tagPositions.map {$0.dto},
                    parentTaskId: parent?.id,
                    position: position,
                    duePosition: duePosition
            )
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
        self.duePosition = task.duePosition
        self.position = task.position
    }

    public func add(child task: Task) {
        children.append(task)
        task.parent = self
    }

    func position(at: Int, in tag: Tag) {
        for tagPos in self.tagPositions {
            if tagPos.tag == tag {
                tagPos.position = at
                return
            }
        }
        tagPositions.append(TaskTagPosition(with: tag, position: at))
    }
}

final class Project: Equatable, Identifiable, ObservableObject {
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

