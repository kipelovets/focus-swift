//
//  Task.swift
//  Focus
//
//  Created by Georgii Korshunov on 29/09/2019.
//  Copyright © 2019 Georgii Korshunov. All rights reserved.
//

import Foundation

struct Task: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var notes: String
    var createdAt: Date
    var done: Bool
    var projectId: Int?
    var tagIds: [Int]
}

struct Project: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

struct Tag: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

final class TaskListState: ObservableObject {
    @Published var tasks: [Task]
    @Published private(set) var currentTaskIndex = 0
    @Published var editing = false
    
    public var currentTask: Task? {
        get {
            tasks[currentTaskIndex]
        }
    }
    
    init(tasks: [Task]) {
        self.tasks = tasks
    }
    
    public func next() {
        currentTaskIndex = (currentTaskIndex + 1) % tasks.count
    }
    
    public func prev() {
        currentTaskIndex = max(currentTaskIndex - 1, 0)
    }
    
    public func taskIndex(for id: Int) -> Int? {
        return tasks.firstIndex { $0.id == id }
    }
    
    public func insertTask() {
        let id: Int = 1 + (tasks.map({ $0.id }).max() ?? 0)
        let newTask = Task(id: id, title: "", notes: "", createdAt: Date(), done: false, projectId: nil, tagIds: [])
        currentTaskIndex = tasks.count == 0 ? 0 : currentTaskIndex + 1
        tasks.insert(newTask, at: currentTaskIndex)
        editing = true
    }
    
    public func removeTask() {
        tasks.remove(at: currentTaskIndex)
        editing = false
        currentTaskIndex = [currentTaskIndex, tasks.count - 1].min()!
    }
}

