import Foundation

struct TaskDto: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var notes: String = ""
    var createdAt: Date
    var dueAt: Date? = nil
    var done: Bool = false
    var projectId: Int? = nil
    var tagPositions: [TaskTagPositionDto] = []
    var parentTaskId: Int? = nil
    var position: Int = 0
    var duePosition: Int = 0
    
    func position(in tagId: Int) -> Int? {
        for p in tagPositions {
            if p.tagId == tagId {
                return p.position
            }
        }
        
        return nil
    }
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

struct TaskTagPositionDto: Hashable, Codable {
    var tagId: Int
    var position: Int
}
