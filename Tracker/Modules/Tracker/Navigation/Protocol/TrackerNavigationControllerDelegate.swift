import UIKit

protocol TrackersNavigationControllerDelegate: UIViewController, UISearchResultsUpdating {
    func dateWasChanged(date: Date)
    func addButtonTapped()
}
