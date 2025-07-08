import Foundation

protocol NewHabitOrEventViewDelegate: NSObject {
    func addTracker(tracker: Tracker, category: TrackerCategory)
}
