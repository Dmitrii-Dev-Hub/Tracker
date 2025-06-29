import UIKit

struct Tracker {
    let id: UUID
    let name: String?
    let color: UIColor?
    let emoji: Character?
    let timetable: [Day]?
    let creationDate: Date?
    
    func isEmpty(type: TypeOfEventOrHabit) -> Bool {
        let hasRequiredFields = name?.isEmpty == false && color != nil && emoji != nil
        let isHabitValid = hasRequiredFields && timetable?.isEmpty == false && type == .habit
        let isEventValid = hasRequiredFields && type == .event
        return !(isHabitValid || isEventValid)
    }
}
