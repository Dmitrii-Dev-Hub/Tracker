import CoreData

final class CategoryStoreManager: NSObject {
    // MARK: Properties
    
    weak var delegate: NewCategoryStoreManagerDelegate?
    
    private let categoryStore: TrackerCategoryStore
    private let context = DataManager.shared.persistentContainer.viewContext
    private var insertedIndex: IndexPath?
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: Init
    
    init(categoryStore: TrackerCategoryStore, delegate: NewCategoryStoreManagerDelegate) {
        self.categoryStore = categoryStore
        self.delegate = delegate
    }
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init()
        
        createFetchedController()
    }
    
    private func createFetchedController() {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        let pinnedCategoryName = NSLocalizedString("pinned", comment: "")
        fetchRequest.predicate = NSPredicate(format: "%K != %@",
                                             #keyPath(TrackerCategoryCoreData.title),
                                             pinnedCategoryName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Cannot do performFetch for fetchedResultsController")
        }
    }
    
    // MARK: Methods
    
    func create(category: TrackerCategory) {
        categoryStore.create(category: category)
    }
    
    func fetchAll() -> [TrackerCategory] {
        categoryStore.fetchAllCategories()
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension CategoryStoreManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndex = indexPath
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndex = insertedIndex else {
            return
        }
        
        if let category = object(at: insertedIndex) {
            delegate?.insert(category, at: insertedIndex)
        }
        
        self.insertedIndex = nil
    }
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let category = fetchedResultsController?.object(at: indexPath)
        guard let title = category?.title,
              let trackersCoreData = category?.trackers?.allObjects as? [TrackerCoreData]
        else {
            return nil
        }
        let trackerStore = TrackerStore()
        let trackers = trackersCoreData.map {
            trackerStore.makeTracker(from: $0)
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}
