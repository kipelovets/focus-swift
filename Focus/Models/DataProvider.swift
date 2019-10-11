import Foundation

class TaskSpaceRepository {
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    public func Load() -> TaskSpace {
        let url = NSURL(fileURLWithPath: filename)
        
        let emptySpace = TaskSpace(tasks: [], projects: [], tags: [])
        
        guard let filePath = url.path else {
            return emptySpace
        }
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            return emptySpace
        }
        
        return load(filename) ?? emptySpace
    }
    
    public func Save(space: TaskSpace) {
        save(filename, value: space)
    }
}

fileprivate func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T? {
    let data: Data
    
    do {
        data = try Data(contentsOf: URL(fileURLWithPath: filename))
    } catch {
        print("Couldn't load \(filename) from main bundle:\n\(error)")
        return nil
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
    
    return nil
}

fileprivate func save<T: Encodable>(_ filename: String, value: T) {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
    do {
        let data = try encoder.encode(value)
        try data.write(to: URL(fileURLWithPath: filename))
    } catch {
        print("Couldn't write data to \(filename):\n\(error)")
    }
}
