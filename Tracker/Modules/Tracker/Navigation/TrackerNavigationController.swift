import UIKit

final class TrackerNavigationController: UINavigationController {
    
    private let datePicker: UIDatePicker = { 
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private let searchBar: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = Resources.ColorYP.blue
        searchController.searchBar.searchTextField.clearButtonMode = .never
        return searchController
    }()
    
    weak var viewController: TrackerNavigationControllerDelegate?
    
    init(rootViewController: TrackerNavigationControllerDelegate) {
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
        let datePicker = UIDatePicker()
        
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        datePicker.tintColor = Resources.ColorYP.blue
        
        viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupAppearance() {
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = Resources.ColorYP.whiteDynamic
        navigationBar.tintColor = Resources.ColorYP.blackDynamic
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        
        viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        viewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: Resources.ImagesYP.addIcon , style: .done, target: self, action: #selector(actionAddButton))
        
        searchBar.searchResultsUpdater = viewController
        viewController?.navigationItem.searchController = searchBar
        
        viewController?.navigationItem.hidesSearchBarWhenScrolling = false
        viewController?.navigationItem.largeTitleDisplayMode = .always
        viewController?.navigationItem.title = "Трекеры"
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewController?.dateWasChanged(date: sender.date)
    }
    
    @objc private func actionAddButton() {
        viewController?.addButtonTapped()
    }
}
