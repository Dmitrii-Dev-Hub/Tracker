import Foundation

protocol TrackerStoreManagerDelegate: AnyObject {
    func addTracker(at indexPath: IndexPath)
    func updateTracker(at indexPath: IndexPath)
    func deleteTracker(at indexPath: IndexPath)
    func forceReload()
}
