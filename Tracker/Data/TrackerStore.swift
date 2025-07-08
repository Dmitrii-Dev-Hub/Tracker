import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private let dataManager = DataManager.shared
    private var context: NSManagedObjectContext
    private let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
    
    override init() {
        context = dataManager.persistentContainer.viewContext
        super.init()
    }
    
    func create(tracker: Tracker, for category: TrackerCategory) {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()

        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        
        guard let trackerCategoryCoreData = try? context.fetch(request) else {
            print("Categories core data is nil in create(tracker:)")
            return
        }
        
        let schedule = tracker.timetable?.map {
            $0.rawValue
        }
        
        let daysRequest: NSFetchRequest<DayCoreData> = DayCoreData.fetchRequest()
        
        guard var days = try? context.fetch(daysRequest) else {
            print("Days is empty in DB")
            return
        }
        
        days = days.filter { day in
            schedule?.contains(where: { str in
                day.day == str
            }) ?? false
        }
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = convertColorToString(tracker.color ?? UIColor())
        trackerCoreData.emoji = String(tracker.emoji ?? "⚙️")
        trackerCoreData.creationDate = tracker.creationDate
        
        trackerCoreData.category = trackerCategoryCoreData.first
        trackerCoreData.schedule = NSSet(array: days)
        
        save()
    }
    
    func makeTracker(from cdObject: TrackerCoreData) -> Tracker {
        guard let id = cdObject.id,
              let name = cdObject.name,
              let emoji = cdObject.emoji,
              let creationDate = cdObject.creationDate
        else {
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", timetable: [.friday], creationDate: Date())
        }
        
        let color = convertStringToColor(cdObject.color)
        let days = cdObject.schedule?.allObjects as? [DayCoreData]

        let schedule = days?.map {
            Day(rawValue: $0.day ?? "") ?? .monday
        }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            timetable: schedule,
            creationDate: creationDate
        )
    }
    
    private func save() {
        dataManager.saveContext()
    }
    
    private func convertStringToColor(_ string: String?) -> UIColor {
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
    
    private func convertColorToString(_ color: UIColor) -> String {
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
