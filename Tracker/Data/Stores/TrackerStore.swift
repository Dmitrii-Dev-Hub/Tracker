
import UIKit
import CoreData

final class TrackerStore {
    // MARK: Properties
    
    private let context: NSManagedObjectContext
    private let dataManager = DataManager.shared
    private let categoryStore: CategoryStore
    private let daysStore: DaysStore
    private let trackerRecordStore: TrackerRecordStore
    
    private let pinnedCategoryTitle = R.Text.ContextMenu.pinned.value
    
    // MARK: Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = CategoryStore(context: context)
        self.daysStore = DaysStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    convenience init() {
        let context = DataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: Methods
    
    private func save() {
        dataManager.saveContext()
    }
    
    func fetchTracker(by id: UUID) -> Tracker? {
        guard let trackerCoreData = fetchTrackerCoreData(by: id) else {
            return nil
        }
        let tracker = Tracker(coreDataTracker: trackerCoreData)
        
        return tracker
    }
    
    func trackersIsEmpty(in day: Day, or date: Date) -> Bool {
        let request = createTrackersFetchRequest(with: day, and: nil, date: date, completionType: .any)
        
        guard let trackers = try? context.fetch(request) else {
            return true
        }
        
        return trackers.isEmpty
    }
    
    func trackersCount(day: Day, date: Date, text: String?) -> Int {
        let request = createTrackersFetchRequest(with: day, and: text, date: date)
        
        guard let trackers = try? context.fetch(request) else { return 0 }
        
        return trackers.count
    }
    
    func fetchCategory(by trackerId: UUID) -> TrackerCategory? {
        guard let tracker = fetchTrackerCoreData(by: trackerId),
              let categoryCD = tracker.category,
              let title = categoryCD.title
        else {
            return nil
        }
        
        let trackers = categoryCD.trackers?.allObjects as? [Tracker]
        let category = TrackerCategory(title: title, trackers: trackers ?? [])
        
        return category
    }
    
    func create(tracker: Tracker, for category: TrackerCategory) {
        let trackerCoreData = TrackerCoreData(context: context)
        
        guard let category = categoryStore.fetchCategoryCoreData(by: category.title) else {
            return
        }
        
        trackerCoreData.trackerId = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = Tracker.convertColorToString(tracker.color ?? UIColor())
        trackerCoreData.emoji = String(tracker.emoji ?? "⚙️")
        trackerCoreData.creationDate = tracker.creationDate
        
        trackerCoreData.category = category
        trackerCoreData.schedule = convertToDaysCoreData(from: tracker.timetable)
        
        save()
    }
    
    func update(tracker: Tracker, category: TrackerCategory) {
        guard let trackerCoreData = fetchTrackerCoreData(by: tracker.id),
              let category = categoryStore.fetchCategoryCoreData(by: category.title)
        else {
            return
        }
        if trackerCoreData.category?.title == pinnedCategoryTitle {
            trackerCoreData.realCategoryName = category.title
        } else {
            trackerCoreData.category = category
        }
        
        
        
        trackerCoreData.name = tracker.name
        trackerCoreData.color = Tracker.convertColorToString(tracker.color ?? UIColor())
        trackerCoreData.emoji = String(tracker.emoji ?? "⚙️")
        trackerCoreData.schedule = convertToDaysCoreData(from: tracker.timetable)
        
        save()
    }
    
    func deleteTracker(by id: UUID) {
        guard let trackerCoreData = fetchTrackerCoreData(by: id) else {
            return
        }
        
        context.delete(trackerCoreData)
        
        save()
    }
    
    func pinTracker(id: UUID?) {
        guard let id else { return }
        let tracker = fetchTrackerCoreData(by: id)
        
        tracker?.realCategoryName = tracker?.category?.title
        
        if let pinnedCategory = categoryStore.fetchCategoryCoreData(by: pinnedCategoryTitle) {
            tracker?.category = pinnedCategory
        } else {
            let pinnedCategory = CategoryCoreData(context: context)
            pinnedCategory.isPinned = true
            pinnedCategory.title = pinnedCategoryTitle
            save()
            tracker?.category = pinnedCategory
        }
        
        save()
    }
    
    func unpinTracker(id: UUID?) {
        guard let id else { return }
        guard let tracker = fetchTrackerCoreData(by: id) else { return }
        
        if let realCategory = categoryStore.fetchCategoryCoreData(by: tracker.realCategoryName ?? "") {
            tracker.category = realCategory
        } else {
            let realCategory = CategoryCoreData(context: context)
            realCategory.title = tracker.realCategoryName
            save()
            tracker.category = realCategory
        }
        
        save()
    }
    
    func trackerIsPinned(id: UUID?) -> Bool? {
        guard
            let id = id,
            let tracker = fetchTrackerCoreData(by: id)
        else { return nil }
        
        return tracker.category?.title == pinnedCategoryTitle
    }
    
    func fetchRealCategory(trackerId: UUID?) -> TrackerCategory? {
        guard
            let trackerId,
            let tracker = fetchTrackerCoreData(by: trackerId),
            let realCategoryName = tracker.realCategoryName,
            let realCategory = categoryStore.fetchCategory(by: realCategoryName)
        else { return nil }
        
        return realCategory
    }
    private func convertToDaysCoreData(from daysArray: [Day]?) -> NSSet {
        let schedule = daysArray?.map {
            Day.shortName(by: $0.rawValue)
        }
        
        let daysRequest = NSFetchRequest<DayCoreData>(entityName: "DayCoreData")
        
        guard var days = try? context.fetch(daysRequest) else {
            print("Days is empty in DB")
            return NSSet()
        }
        
        days = days.filter { day in
            schedule?.contains(where: { str in
                day.day == str
            }) ?? false
        }
        
        return NSSet(array: days)
    }
    
    func fetchTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), id as CVarArg)
        
        guard let trackerCoreData = try? context.fetch(fetchRequest) as [TrackerCoreData] else {
            return nil
        }
        
        return trackerCoreData.first
    }
    
    func createTrackersFetchRequest(with day: Day, and text: String?, date: Date, completionType: CompletionType = .any) -> NSFetchRequest<TrackerCoreData> {
        guard let day = daysStore.fetchDay(with: Day.shortName(by: day.rawValue)) else {
            fatalError("Неправильно передан день в setupFetchedResultsController")
        }
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        let isPinnedSort = NSSortDescriptor(key: #keyPath(TrackerCoreData.category.isPinned),
                                            ascending: false)
        let titlesSort = NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title),
                                          ascending: true)
        
        fetchRequest.sortDescriptors = [isPinnedSort, titlesSort]
        
        let completionPredicate = getCompletionPredicate(type: completionType, date: date)
        let dayPredicate = NSPredicate(format: "ANY schedule == %@", day)
        let countDaysPredicate = NSPredicate(format: "schedule.@count == 0")
        
        let strippedTargetDate = stripTime(from: date) ?? Date()
        let datePredicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@",
            strippedTargetDate as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: strippedTargetDate)! as CVarArg
        )
        let compoundEventPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [datePredicate, countDaysPredicate]
        )
        
        if text == nil {
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [compoundEventPredicate, dayPredicate])
            let compoundPredicateWithCompletion = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, completionPredicate])
            
            fetchRequest.predicate = compoundPredicateWithCompletion
        } else {
            let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", text ?? "")
            
            let compoundFilterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, searchPredicate])
            let compoundSearchEventPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundEventPredicate, searchPredicate])
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [compoundSearchEventPredicate, compoundFilterPredicate])
            let compoundPredicateWithCompletion = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, completionPredicate])
            
            fetchRequest.predicate = compoundPredicateWithCompletion
        }
        
        return fetchRequest
    }
    
    private func getCompletionPredicate(type: CompletionType, date: Date) -> NSPredicate {
        let strippedTargetDate = stripTime(from: date) ?? Date()
        let completionPredicate: NSPredicate
        switch type {
        case .any:
            completionPredicate = NSPredicate(value: true)
        case .completed:
            completionPredicate = NSPredicate(
                format: "SUBQUERY(completedDates, $cd, $cd.date >= %@ AND $cd.date < %@).@count > 0",
                strippedTargetDate as CVarArg,
                Calendar.current.date(byAdding: .day, value: 1, to: strippedTargetDate)! as CVarArg
            )
        case .uncompleted:
            completionPredicate = NSPredicate(
                format: "SUBQUERY(completedDates, $cd, $cd.date >= %@ AND $cd.date < %@).@count == 0",
                strippedTargetDate as CVarArg,
                Calendar.current.date(byAdding: .day, value: 1, to: strippedTargetDate)! as CVarArg
            )
        }
        
        return completionPredicate
    }
    
    private func stripTime(from date: Date) -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))
    }
}

