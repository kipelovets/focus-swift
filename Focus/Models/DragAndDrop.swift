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
    let perspective: Perspective
    
    init(taskIndexByHeight: @escaping FindTaskIndexByHeight, taskList: Perspective) {
        self.taskIndexByHeight = taskIndexByHeight
        self.perspective = taskList
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        perspective.dropTarget = perspective.tree.nth(self.dropTargetIndex(height: info.location.y))
        guard let target = perspective.dropTarget else {
            return DropProposal(operation: .move)
        }
        perspective.dropDepth = Int(((info.location.x - CGFloat(target.depth) * 30) / 30).rounded(.down))
        print("\(target.depth) -- \(perspective.dropDepth)")

        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        perspective.dropTarget = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        perspective.drop()

        return true
    }
    
    private func dropTargetIndex(height: CGFloat) -> Int {
        return taskIndexByHeight(height)
    }
}
