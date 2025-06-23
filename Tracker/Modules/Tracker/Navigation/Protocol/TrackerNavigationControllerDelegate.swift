import UIKit

protocol TrackerNavigationControllerDelegate: UIViewController, UISearchResultsUpdating {
    func dateWasChanged(date: Date)
    func addButtonTapped()
}
