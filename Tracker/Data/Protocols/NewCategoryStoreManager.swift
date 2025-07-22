import Foundation

protocol NewCategoryStoreManagerDelegate: AnyObject {
    func insert(_ category: TrackerCategory, at indexPath: IndexPath)
}
