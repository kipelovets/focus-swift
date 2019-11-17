import Foundation
import Combine

func loadPreviewSpace(_ filter: PerspectiveType = .All) -> Space {
    let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    let repo = TaskSpaceRepositoryFile(filename: file!.path, readonly: true)
    
    return Space(repo, with: filter)
}

enum SafeWhile: Error {
    case TooMuchIterations
}

func safeWhile(_ expression: () -> Bool, count: Int = 1000) throws {
    for _ in 0..<count {
        if !expression() {
            return
        }
    }
    
    throw SafeWhile.TooMuchIterations
}
