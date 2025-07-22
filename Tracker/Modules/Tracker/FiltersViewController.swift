import UIKit
final class FiltersViewController: UIViewController {
    // MARK: Properties
    
    private let filters = R.Mocks.filters
    weak var delegate: TrackersViewController?
    
    private var selectedFilter: Filters = .all {
        didSet {
            UserDefaults.standard.setValue(selectedFilter.rawValue,
                                           forKey: R.Keys.selectedFilter)
            delegate?.setFilter(filter: selectedFilter)
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: Methods
    
    private func getCheckedIndex() -> IndexPath {
        let filter = UserDefaults.standard.object(forKey: R.Keys.selectedFilter)
        guard let filterNum = filter as? Int else {
            return IndexPath(row: 0, section: 0)
        }
        return IndexPath(row: filterNum, section: 0)
    }
}

// MARK: UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        cell.backgroundColor = R.ColorYP.backgroundDynamic
        
        cell.textLabel?.text = filters[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        let selectedIndexPath = getCheckedIndex()
        if selectedIndexPath == indexPath {
            let imageView = UIImageView(image: R.ImagesYP.checkmark)
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryView == nil {
            let imageView = UIImageView(image: R.ImagesYP.checkmark)
            cell.accessoryView = imageView
            
            selectedFilter = Filters(rawValue: indexPath.row) ?? .all
            self.dismiss(animated: true)
        } else {
            cell.accessoryView = nil
        }
    }
}

// MARK: UI

extension FiltersViewController {
    private func configure() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        
        tableView.dataSource = self
        tableView.delegate = self
        
        title = R.Text.Filters.filters.value
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addView(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}
