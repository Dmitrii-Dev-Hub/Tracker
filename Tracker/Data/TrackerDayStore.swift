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
            dayCoreData.day = day.rawValue
            
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
    }
    
    func fetchDay(with rawValue: String) -> DayCoreData? {
        let request = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(DayCoreData.day), rawValue)
        
        guard let days = try? context.fetch(request) else {
            return nil
        }
        
        return days.first
    }
}
