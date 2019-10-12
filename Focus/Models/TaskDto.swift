import Foundation

struct TaskDto: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var notes: String = ""
    var createdAt: Date
    var dueAt: Date? = nil
    var done: Bool = false
    var projectId: Int? = nil
    var tagIds: [Int] = []
    var parentTaskId: Int? = nil
}

struct ProjectDto: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
}

struct TagDto: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
}

struct TaskSpaceDto: Codable {
    var tasks: [TaskDto]
    var projects: [ProjectDto]
    var tags: [TagDto]
}
