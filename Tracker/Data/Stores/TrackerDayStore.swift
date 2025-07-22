import UIKit
import CoreData

final class DaysStore {
    // MARK: Properties
    
    private let context: NSManagedObjectContext
    private let dataManager = DataManager.shared
    
    // MARK: Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        createDaysIfNeeded()
    }
    
    convenience init() {
        let context = DataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: Methods
    
    private func save() {
        dataManager.saveContext()
    }
    
    private func createDays() {
        let days = R.Mocks.weekdays
        days.forEach { day in
            let dayCoreData = DayCoreData(context: context)
            dayCoreData.day = Day.shortName(by: day.rawValue)
            
            save()
        }
    }
    
    
    private func createDaysIfNeeded() {
        let daysRequest = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        
        guard let days = try? context.fetch(daysRequest) else {
            createDays()
            return
        }
        
        if days.isEmpty {
            createDays()
        }
        
        updateDays()
    }
    
    func fetchDay(with rawValue: String) -> DayCoreData? {
        let request = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(DayCoreData.day), rawValue)
        
        guard let days = try? context.fetch(request) else {
            return nil
        }
        
        return days.first
    }
    
    private func deleteDays() {
        let request = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        
        guard let days = try? context.fetch(request) else {
            return
        }
        
        days.forEach {
            context.delete($0)
        }
    }
    
    private func updateDays() {
        let request = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        
        guard let days = try? context.fetch(request) else {
            return
        }
        
        for i in 0..<7 {
            days[i].day = R.Mocks.shortDays[i]
        }
        
        save()
    }
}
