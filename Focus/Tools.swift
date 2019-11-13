import Foundation

fileprivate func createDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = DateFormatter.Style.none
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter
}

extension Date {
    init(from string: String) {
        let date = createDateFormatter().date(from: string)!
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    var formatted: String {
        return createDateFormatter().string(from: self)
    }
    
    func same(as other: Date) -> Bool {
        return self.formatted == other.formatted
    }
}

func loadPreviewSpace() -> Space {
    let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    let repo = TaskSpaceRepositoryFile(filename: file!.path)
    
    return Space(repo)
}
