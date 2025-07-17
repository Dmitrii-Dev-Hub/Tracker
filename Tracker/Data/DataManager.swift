import Foundation
import CoreData

final class DataManager {
    static let shared = DataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "CoreData")
              
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                assertionFailure("Error loading Persistent Stores: \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
