import Foundation
import CoreData

final class TrackerRecordStore: NSObject {

    private let dataManager = DataManager.shared
    private var content: NSManagedObjectContext
    
    override init() {
        content = dataManager.persistentContainer.viewContext
        super.init()
    }

    func fetchAll() -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        guard let trackersCoreData = try? content.fetch(request) as [TrackerRecordCoreData] else {
            return []
        }
        
        let trackers = trackersCoreData.map {
            TrackerRecord($0)
        }
        
        return trackers
    }
    
    func fetchCount(by id: UUID) -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as CVarArg)
        
        request.predicate = idPredicate
        
        guard let count = try? content.count(for: request) else {
            return 0
        }
        
        return count
    }
    
    func fetch(by id: UUID, and date: Date) -> TrackerRecord? {
        guard let trackerCoreData = fetchTrackerRecord(by: id, and: date) else {
            return nil
        }
        
        return TrackerRecord(trackerCoreData)
    }
    
    func add(trackerRecord: TrackerRecord) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: content)
        
        trackerRecordCoreData.trackerId = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        
        save()
    }
    
    func delete(id: UUID, date: Date) {
        guard let trackerCoreData = fetchTrackerRecord(by: id, and: date) else {
            return
        }
        
        content.delete(trackerCoreData)
        
        save()
    }
    
    private func fetchTrackerRecord(by id: UUID, and date: Date) -> TrackerRecordCoreData? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as CVarArg)
        let strippedTargetDate = stripTime(from: date) ?? Date()
        
        
        let datePredicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        strippedTargetDate as CVarArg,
                                        Calendar.current.date(
                                            byAdding: .day,
                                            value: 1,
                                            to: strippedTargetDate) as? CVarArg ?? Date() as CVarArg)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, datePredicate])
        
        request.predicate = compoundPredicate
        
        guard let trackersCoreData = try? content.fetch(request) as [TrackerRecordCoreData],
              let trackerCoreData = trackersCoreData.first
        else {
            return nil
        }
        
        return trackerCoreData
    }
    
    private func stripTime(from date: Date) -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))
    }
    
    private func save() {
        dataManager.saveContext()
    }
}
