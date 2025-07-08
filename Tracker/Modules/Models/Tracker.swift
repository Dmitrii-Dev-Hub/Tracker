import UIKit

struct Tracker {
    let id: UUID
    let name: String?
    let color: UIColor?
    let emoji: String?
    let timetable: [Day]?
    let creationDate: Date?
    
    func isEmpty(type: TypeOfEventOrHabit) -> Bool {
        let hasRequiredFields = name?.isEmpty == false && color != nil && emoji != nil
        let isHabitValid = hasRequiredFields && timetable?.isEmpty == false && type == .habit
        let isEventValid = hasRequiredFields && type == .event
        return !(isHabitValid || isEventValid)
    }
    
    init(id: UUID, name: String?, color: UIColor?, emoji: String?, timetable: [Day]?, creationDate: Date?) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.timetable = timetable
        self.creationDate = creationDate
    }
}
