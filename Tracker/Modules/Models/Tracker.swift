import UIKit

enum TrackerType {
    case habit, event
}

struct Tracker: CustomStringConvertible {
    let id: UUID
    let name: String?
    let color: UIColor?
    let emoji: String?
    let timetable: [Day]?
    let creationDate: Date?
    
    func isEmpty(type: TrackerType) -> Bool {
        if self.name != nil && !(self.name == "") && self.color != nil &&
            self.emoji != nil && self.timetable != nil &&
            !(self.timetable?.isEmpty ?? true) && type == .habit {
            
            return false
        } else if self.name != nil && !(self.name == "") &&
                    self.color != nil && self.emoji != nil && type == .event {
            
            return false
        }
        
        return true
    }
    
    init(id: UUID, name: String?, color: UIColor?, emoji: String?, timetable: [Day]?, creationDate: Date?) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.timetable = timetable
        self.creationDate = creationDate
    }
    
    init(coreDataTracker: TrackerCoreData) {
        guard let id = coreDataTracker.trackerId,
              let name = coreDataTracker.name,
              let emoji = coreDataTracker.emoji,
              let creationDate = coreDataTracker.creationDate
        else {
            fatalError("Some property is nil in Tracker")
        }
        
        let color = Tracker.convertStringToColor(coreDataTracker.color)
        let days = coreDataTracker.schedule?.allObjects as? [DayCoreData]

        let schedule = days?.map {
            Day(shortName: $0.day ?? "") ?? .monday
        }
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.timetable = schedule
        self.creationDate = creationDate
    }
    
    var description: String {
        let string = """
                     \n\nid: \(id),
                     name: \(name ?? ""),
                     color: \(String(describing: color)),
                     emoji: \(String(describing: emoji)),
                     timetable: \(String(describing: timetable)),
                     date: \(String(describing: creationDate))
                     \n
                     """
        return string
    }
    
    static func convertStringToColor(_ string: String?) -> UIColor {
          guard let string = string,
                string.hasPrefix("#"),
                string.count == 7
          else {
              return .white
          }
          let hex = String(string.dropFirst())
          var rgbValue: UInt64 = 0
          Scanner(string: hex).scanHexInt64(&rgbValue)
          
          let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
          let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
          let b = CGFloat(rgbValue & 0x0000FF) / 255.0
          return UIColor(red: r, green: g, blue: b, alpha: 1)
      }
      
    static func convertColorToString(_ color: UIColor) -> String {
          var red: CGFloat = 0
          var green: CGFloat = 0
          var blue: CGFloat = 0
          var alpha: CGFloat = 0
          color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
          
          let r = Int(red * 255)
          let g = Int(green * 255)
          let b = Int(blue * 255)
          return String(format: "#%02X%02X%02X", r, g, b)
      }
}
