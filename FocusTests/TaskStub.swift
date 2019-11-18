import Foundation
@testable import Focus

extension TaskNodeTree {
    var nodeStubs: [N] {
        get {
            buildNodeStubs(from: root.children.map { $0.model! })
        }
    }
}

extension TaskNode {
    var treeNodeStubs: [N] {
        get {
            var root = self
            while !root.isRoot {
                root = root.parent!
            }
            
            return buildNodeStubs(from: root.children.map { $0.model! })
        }
    }
}

class N: Equatable, CustomDebugStringConvertible {
    static func == (lhs: N, rhs: N) -> Bool {
        lhs.id == rhs.id && lhs.children == rhs.children
    }
    
    var debugDescription: String {
        var desc = "\(id)"
        if children.count > 0 {
            desc += " \(children)"
        }
        return desc
    }
    
    let id: Int
    let children: [N]
    init(_ id: Int, _ children: [N] = []) {
        self.id = id
        self.children = children
    }
}

fileprivate func buildTasksTree(from stubs: [N]) -> [Task] {
    stubs.map { Task(id: $0.id, title: "task \($0.id)", children: buildTasksTree(from: $0.children)) }
}

func buildTasks(from nodeStubs: [N]) -> [Task] {
    let tree = buildTasksTree(from: nodeStubs)
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

func buildNodeStubs(from tasks: [Task]) -> [N] {
    tasks.map { N($0.id, buildNodeStubs(from: $0.children)) }
}

func dumpNodes(_ stubs: [N], offset: Int = 0) {
    if offset == 0 {
        print("------- tree dump")
    }
    stubs.forEach {
        print(String(repeating: "\t", count: offset) + "task \($0.id)")
        dumpNodes($0.children, offset: offset + 1)
    }
}
