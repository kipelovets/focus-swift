func dumpTree(node: TaskNode, _ offset: Int = 0) {
    let prefix = String(repeating: "\t", count: offset)
    let parent: String
    if node.parent != nil {
        parent = String(node.parent!.id)
    } else {
        parent = "nil"
    }
    print(prefix + "\(node.title) = \(node.id), parent \(parent)")
    print(prefix + "children [" + node.children.map({"\($0.id)"}).joined(separator: ", ") + "]")
    for child in node.children {
        dumpTree(node: child, offset + 1)
    }
}
