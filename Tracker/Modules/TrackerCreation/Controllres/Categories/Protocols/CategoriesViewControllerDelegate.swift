import Foundation

protocol CategoriesViewControllerDelegate: NSObject {
    var selectedCategory: TrackerCategory? { get set }
}

