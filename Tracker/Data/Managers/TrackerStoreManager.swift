import UIKit
import CoreData


final class TrackerStoreManager: NSObject {
    // MARK: Properties
    
    weak var delegate: TrackerStoreManagerDelegate?
    
    private let trackerStore: TrackerStore
    private let categoryStore: CategoryStore
    private let daysStore: DaysStore
    
    private let context = DataManager.shared.persistentContainer.viewContext
    private var index: IndexPath? = nil
    private var actionType: TrackerCellAction? = nil
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    private var day: Day? = nil
    private var text: String? = nil
    private var date: Date? = nil
    
    private var lastCompletion: CompletionType
    
    // MARK: Init
    
    init(trackerStore: TrackerStore, categoryStore: CategoryStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.daysStore = DaysStore()
        var rawValue = UserDefaults.standard.value(forKey: R.Keys.selectedFilter) as? Int
        rawValue = rawValue == 1 ? 0 : rawValue
        lastCompletion = CompletionType(rawValue: rawValue ?? 0) ?? .any
    }
    
    // MARK: Methods
    
    func create(tracker: Tracker, category: TrackerCategory) {
        trackerStore.create(tracker: tracker, for: category)
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        categoryStore.fetchAll()
    }
    
    func pinTracker(with id: UUID?) {
        trackerStore.pinTracker(id: id)
    }
    
    func unpinTracker(with id: UUID?) {
        trackerStore.unpinTracker(id: id)
    }
    
    func isPinnedTracker(with id: UUID?) -> Bool? {
        trackerStore.trackerIsPinned(id: id)
    }
    
    func trackersIsEmpty() -> Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }
    
    func trackersIsEmpty(in day: Day, or date: Date) -> Bool {
        trackerStore.trackersIsEmpty(in: day, or: date)
    }
    
    func deleteTracker(by id: UUID) {
        trackerStore.deleteTracker(by: id)
    }
    
    func fetchTracker(by id: UUID) -> Tracker? {
        trackerStore.fetchTracker(by: id)
    }
    
    func fetchCategory(by trackerId: UUID) -> TrackerCategory? {
        trackerStore.fetchCategory(by: trackerId)
    }
    
    func fetchRealCategory(by trackerId: UUID?) -> TrackerCategory? {
        trackerStore.fetchRealCategory(trackerId: trackerId)
    }
    
    func update(tracker: Tracker, category: TrackerCategory) {
        trackerStore.update(tracker: tracker, category: category)
    }
    
    func setFilter(filter: Filters, day: Day, text: String?, date: Date) {
        switch filter {
        case .all, .today:
            setupFetchedResultsController(
                with: day,
                and: text,
                date: date,
                completionType: .any
            )
        case .completed:
            setupFetchedResultsController(
                with: day,
                and: text,
                date: date,
                completionType: .completed
            )
        case .uncompleted:
            setupFetchedResultsController(
                with: day,
                and: text,
                date: date,
                completionType: .uncompleted
            )
        }
    }

    func setupFetchedResultsController(with day: Day, and text: String?, date: Date, completionType: CompletionType) {
        lastCompletion = completionType
        fetchedResultsController = {
            let fetchRequest = trackerStore.createTrackersFetchRequest(with: day, and: text, date: date, completionType: completionType)
            
            self.day = day
            self.text = text
            self.date = date
            
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
                cacheName: nil
            )
            
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Cannot do performFetch for fetchedResultsController")
            }
            
            return fetchedResultsController
        }()
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerStoreManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                index = indexPath
                actionType = .insert
            }
        case .delete:
            if let indexPath = indexPath {
                index = indexPath
                actionType = .delete
            }
        case .update:
            if let indexPath = newIndexPath {
                index = indexPath
            }
            actionType = .update
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let index, let actionType else {
            delegate?.forceReload()
            if let day, let date {
                setupFetchedResultsController(
                    with: day,
                    and: text,
                    date: date,
                    completionType: lastCompletion
                )
            }
            return
        }
        
        switch actionType {
        case .insert:
            delegate?.addTracker(at: index)
        case .update:
            delegate?.updateTracker(at: index)
        case .delete:
            delegate?.deleteTracker(at: index)
        }
        
        self.actionType = nil
        self.index = nil
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)

        return Tracker(coreDataTracker: trackerCoreData)
    }
    
    func categoryIsEmpty(in section: Int) -> Bool {
        return fetchedResultsController.sections?[section].objects?.isEmpty ?? true
    }
    
    func categoryTitle(at section: Int) -> String {
        return fetchedResultsController.sections?[section].name ?? ""
    }
}

// MARK: TrackerCellAction

extension TrackerStoreManager {
    enum TrackerCellAction {
        case insert, delete, update
    }
}
