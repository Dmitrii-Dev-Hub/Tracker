import Foundation

protocol NewTrackerViewControllerDelegate: NSObject {
    func addTracker(tracker: Tracker, category: TrackerCategory)
}
