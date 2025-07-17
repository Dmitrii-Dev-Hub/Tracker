import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {

    private let dataManager = DataManager.shared
    private var content: NSManagedObjectContext
    private let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
    
    override init() {
        content = dataManager.persistentContainer.viewContext
        super.init()
    }

    func create(category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: content)
        
        categoryCoreData.title = category.title
        categoryCoreData.trackers = []
        
        save()
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        guard let categoriesCoreData = try? content.fetch(request) else {
            print("Categories core data is nil in fetchAll()")
            return []
        }
        
        let categories = categoriesCoreData.map {
            guard let title = $0.title else {
                fatalError("ERROR: Title of stored category is nil")
            }
            
            let trackersCoreData = $0.trackers?.allObjects as? [TrackerCoreData]
            let trackerStore = TrackerStore()
            let trackers = trackersCoreData?.map { trackerStore.makeTracker(from: $0) }
            
            return TrackerCategory(title: title, trackers: trackers ?? [])
        }
        
        return categories
    }

    private func save() {
        dataManager.saveContext()
    }
}
