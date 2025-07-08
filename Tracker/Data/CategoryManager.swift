import CoreData

final class CategoryStoreManager: NSObject {
    // MARK: Properties
    
    weak var delegate: NewCategoryStoreManagerDelegate?
    
    private let categoryStore: TrackerCategoryStore
    private let context = DataManager.shared.persistentContainer.viewContext
    private var insertedIndex: IndexPath?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: Init
    
    init(categoryStore: TrackerCategoryStore, delegate: NewCategoryStoreManagerDelegate) {
        self.categoryStore = categoryStore
        self.delegate = delegate
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.startUpdate()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndex = insertedIndex else {
            print("insertedIndex is nil")
            return
        }
        delegate?.removeStubAndShowCategories(indexPath: insertedIndex)
        self.insertedIndex = nil
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let category = fetchedResultsController.object(at: indexPath)
        guard let title = category.title,
              let trackersCoreData = category.trackers?.allObjects as? [TrackerCoreData]
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
