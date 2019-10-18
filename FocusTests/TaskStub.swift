import Foundation
@testable import Focus

extension TaskTree {
    var stubs: [N] {
        get {
            buildStubs(from: root.children.map { $0.model! })
        }
    }
}

extension TaskTreeNode {
    var treeStubs: [N] {
        get {
            var root = self
            while root.id != -1 {
                root = root.parent!
            }
            
            return buildStubs(from: root.children.map { $0.model! })
        }
    }
}

class N: Equatable {
    static func == (lhs: N, rhs: N) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let children: [N]
    init(_ id: Int, _ children: [N]) {
        self.id = id
        self.children = children
    }
}

fileprivate func buildTasksTree(from stubs: [N]) -> [Task] {
    stubs.map { Task(id: $0.id, title: "task \($0.id)", children: buildTasksTree(from: $0.children)) }
}

func buildTasks(from stubs: [N]) -> [Task] {
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

func buildStubs(from tasks: [Task]) -> [N] {
    tasks.map { N($0.id, buildStubs(from: $0.children)) }
}

func dump(_ stubs: [N], offset: Int = 0) {
    if offset == 0 {
        print("------- tree dump")
    }
    stubs.forEach {
        print(String(repeating: "\t", count: offset) + "task \($0.id)")
        dump($0.children, offset: offset + 1)
    }
}
