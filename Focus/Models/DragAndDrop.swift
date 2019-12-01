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
            print("Error decoding drag data: \(error)")
            throw error
        }
    }
}

final class ProjectDragData: NSObject, Codable, NSItemProviderReading, NSItemProviderWriting {
    var project: ProjectDto

    init(project: ProjectDto) {
        self.project = project
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
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ProjectDragData {
        let decoder = JSONDecoder()
        do {
            let myJSON = try decoder.decode(ProjectDragData.self, from: data)
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
    
    init(taskIndexByHeight: @escaping FindTaskIndexByHeight, perspective: Perspective) {
        self.taskIndexByHeight = taskIndexByHeight
        self.perspective = perspective
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
        let targetDepth = target.depth
        var dropDepth = max(0, Int(((info.location.x - CGFloat(targetDepth) * 30) / 30).rounded(.down)))
        if dropDepth > targetDepth + 1 {
            dropDepth = targetDepth + 1
        }
        perspective.dropDepth = dropDepth

        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        perspective.dropTarget = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let p = info.itemProviders(for: ProjectDragData.idTypes).first!
        guard p.canLoadObject(ofClass: TaskDragData.self) else {
            return false
        }
        // TODO: support dropping projects
        commandBus.handle(.Drop)

        return true
    }
    
    private func dropTargetIndex(height: CGFloat) -> Int {
        return taskIndexByHeight(height)
    }
}

extension DropInfo {
    func accepts(type: NSItemProviderReading.Type) -> Bool {
        guard self.hasItemsConforming(to: ProjectDragData.idTypes) else {
            return false
        }
        let p = itemProviders(for: ProjectDragData.idTypes).first!
        guard p.canLoadObject(ofClass: type.self) else {
            return false
        }
        var processed = false
        let semaphore = DispatchSemaphore(value: 0)
        p.loadDataRepresentation(forTypeIdentifier: kUTTypeData as String) { (data, error) in
            defer { semaphore.signal() }
            
            guard error == nil else {
                print("Error loading drop data \(error!)")
                return
            }
            guard data != nil else {
                print("Failed loading drop data")
                return
            }
            do {
                let project = try type.object(withItemProviderData: data!, typeIdentifier: kUTTypeData as String)
                print("Loaded project drop data: \(project)")
                
                
                processed = true
            } catch {
                print("Error loading project drop data: \(error)")
                return
            }
        }
        _ = semaphore.wait(timeout: .distantFuture)
        
        return processed
    }
}
