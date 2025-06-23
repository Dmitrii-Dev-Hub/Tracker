import Foundation

struct TrackerRecord: Equatable {
    let id: UUID
    let date: Date
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        let isSameDate = Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        return lhs.id == rhs.id && isSameDate
    }
}
