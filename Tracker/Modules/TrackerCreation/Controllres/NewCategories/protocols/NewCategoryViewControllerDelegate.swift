import Foundation

protocol NewCategoryViewControllerDelegate: NSObject {
    var categories: [TrackerCategory] { get set }
    func removeStubAndShowCategories()
}
