import UIKit

final class TrackerNavigationController: UINavigationController {
    
    private let datePicker = UIDatePicker()
    
    private let searchBar: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = R.Text.MainScreen.search.value
        searchController.searchBar.setValue(R.Text.ButtonTitle.cancel.value, forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = R.ColorYP.blue
        searchController.searchBar.searchTextField.clearButtonMode = .never
        return searchController
    }()
    
    weak var viewController: TrackersNavigationControllerDelegate?
    
    init(rootViewController: TrackersNavigationControllerDelegate) {
        super.init(rootViewController: rootViewController)
        viewController = rootViewController
        setupAppearance()
        actionAddButton()
        setDatePicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDatePicker() {
        datePicker.locale = Locale.current
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        datePicker.tintColor = R.ColorYP.blue
        
        datePicker.backgroundColor = R.ColorYP.datePickerBackground
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        
        datePicker.overrideUserInterfaceStyle = .light
        
        viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    func setDate(date: Date) {
        datePicker.setDate(date, animated: true)
    }
    
    private func setupAppearance() {
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = R.ColorYP.whiteDynamic
        navigationBar.tintColor = R.ColorYP.blackDynamic
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        
        viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        viewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.ImagesYP.addIcon , style: .done, target: self, action: #selector(actionAddButton))
        
        searchBar.searchResultsUpdater = viewController
        viewController?.navigationItem.searchController = searchBar
        
        viewController?.navigationItem.hidesSearchBarWhenScrolling = false
        viewController?.navigationItem.largeTitleDisplayMode = .always
        viewController?.navigationItem.title = R.Text.MainScreen.trackers.value
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewController?.dateWasChanged(date: sender.date)
    }
    
    @objc private func actionAddButton() {
        viewController?.addButtonTapped()
    }
}
