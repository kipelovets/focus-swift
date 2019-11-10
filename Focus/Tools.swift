import Foundation

func format(date: Date?) -> String {
    guard date != nil else {
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = DateFormatter.Style.none
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter.string(from: date!)
}
