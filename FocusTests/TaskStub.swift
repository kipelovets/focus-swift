import Foundation
@testable import Focus

class T: Equatable {
    static func == (lhs: T, rhs: T) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let children: [T]
    init(_ id: Int, _ children: [T]) {
        self.id = id
        self.children = children
    }
}

fileprivate func buildTasksTree(from stubs: [T]) -> [Task] {
    stubs.map { Task(id: $0.id, title: "task \($0.id)", children: buildTasksTree(from: $0.children)) }
}

func buildTasks(from stubs: [T]) -> [Task] {
    let tree = buildTasksTree(from: stubs)
    var tasks = tree
    var parents = tree
    while parents.count > 0 {
        var newParents: [Task] = []
        for t in parents {
            newParents += t.children
        }
        tasks += newParents
        parents = newParents
    }
    
    return tasks
}

func buildStubs(from tasks: [Task]) -> [T] {
    tasks.map { T($0.id, buildStubs(from: $0.children)) }
}

func dump(_ stubs: [T], offset: Int = 0) {
    stubs.forEach {
        print(String(repeating: "\t", count: offset) + "task \($0.id)")
        dump($0.children, offset: offset + 1)
    }
}
