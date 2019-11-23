import Foundation

final class SpaceModel {
    var tasks: [Task]
    var projects: [Project]
    var tags: [Tag]

    var dto: TaskSpaceDto {
        TaskSpaceDto(
            tasks: tasks.map { $0.dto },
            projects: projects.map {$0.dto},
            tags: tags.map {$0.dto}
        )
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
        1 + (tasks.map { $0.id }.max() ?? 0)
    }
    
    func findDue(date: Date?) -> [Task] {
        guard date != nil else {
            return []
        }
        
        let dom: Int = date!.dayOfMonth
        let filter = PerspectiveType.Due(.CurrentMonthDay(dom))
        
        return self.tasks.filter({ filter.accepts(task: $0) })
    }
}

