import UIKit

enum Day: Int {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    
    static func getDayFromNumber(number: Int) -> Day {
        let days = [Day.sunday, Day.monday, Day.tuesday, Day.wednesday, Day.thursday, Day.friday, Day.saturday]
        
        return days[number - 1]
    }
    
    static func shortName(by number: Int) -> String {
        let shortDays = R.Mocks.shortDays
        guard number <= 7 && number >= 1 else {
            return shortDays.last ?? ""
        }
        
        return shortDays[number - 1]
    }
    
    init?(shortName: String) {
        let rawValue = Int(R.Mocks.shortDays.firstIndex(of: shortName) ?? -1) + 1
        self.init(rawValue: rawValue)
    }
}
