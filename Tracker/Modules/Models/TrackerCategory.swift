import Foundation

struct TrackerCategory: Equatable, CustomStringConvertible {
    
    let title: String
    let trackers: [Tracker]
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
    
    var description: String {
        let string = """
                     
                     \ntitle: \(title),
                     trackers: \(trackers)
                     
                     ----------------------
                     """
        return string
    }
}
