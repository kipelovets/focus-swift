import Foundation
import SwiftUI

final class TaskDragData: NSObject, Codable, NSItemProviderReading, NSItemProviderWriting {
    var task: TaskDto

    init(task: TaskDto) {
        self.task = task
    }
    
    public static let idTypes = [(kUTTypeData) as String]
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return idTypes
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            print("Error encoding drag data: \(error)")
            completionHandler(nil, error)
        }
        
        return progress
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return idTypes
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> TaskDragData {
        let decoder = JSONDecoder()
        do {
            let myJSON = try decoder.decode(TaskDragData.self, from: data)
            return myJSON
        } catch {
            fatalError("Error decoding drag data: \(error)")
        }
    }
}

typealias FindTaskIndexByHeight = (_ height: CGFloat) -> Int

class TaskDragDelegate: DropDelegate {
    let taskIndexByHeight: FindTaskIndexByHeight
    let taskList: TaskList
    
    init(taskIndexByHeight: @escaping FindTaskIndexByHeight, taskList: TaskList) {
        self.taskIndexByHeight = taskIndexByHeight
        self.taskList = taskList
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        taskList.dropTargetIndex = self.dropTargetIndex(height: info.location.y)

        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        taskList.dropTargetIndex = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        var index = self.dropTargetIndex(height: info.location.y)
        if index > taskList.currentTaskIndex {
            index -= 1
        }
        if taskList.currentTaskIndex != index {
            taskList.tasks.insert(taskList.tasks.remove(at:taskList.currentTaskIndex), at: index)
        }
        taskList.dropTargetIndex = nil
        
        return true
    }
    
    private func dropTargetIndex(height: CGFloat) -> Int {
        return min(taskIndexByHeight(height), taskList.tasks.count)
    }
}
