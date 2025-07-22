import UIKit

final class StatisticViewController: UIViewController {
    // MARK: Properties
    
    private let stub = NoContentView(text: "Анализировать пока нечего",
                                     image: R.ImagesYP.dizzy)
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(StatisticTableViewCell.self,
                           forCellReuseIdentifier: StatisticTableViewCell.reuseIdentifier)
        tableView.backgroundColor = R.ColorYP.whiteDynamic
        
        return tableView
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if getCount() == 0 {
            tableView.removeFromSuperview()
            setupStub()
            return
        }
        
        if !tableView.isDescendant(of: view) {
            removeStub()
            setupTable()
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: Methods
    
    private func getCount() -> Int {
        if let count = UserDefaults.standard.object(forKey: R.Keys.completedTrackers) as? Int {
            return count
        } else {
            return 0
        }
    }
}

// MARK: UITableViewDataSource

extension StatisticViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticTableViewCell.reuseIdentifier,
            for: indexPath) as? StatisticTableViewCell
        else {
            return UITableViewCell()
        }
        
        cell.setTitle(text: "Трекеров завершено")
        cell.setCount(count: getCount())
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
        return .leastNonzeroMagnitude
    }
}

// MARK: UI

extension StatisticViewController {
    private func configureUI() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        title = NSLocalizedString("statistic", comment: "")
        
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: Resources.Colors.foreground]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        [stub, tableView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let _ = UserDefaults.standard.object(forKey: R.Keys.completedTrackers) as? Int {
            setupTable()
        } else {
            setupStub()
        }
    }
    
    private func removeStub() {
        if stub.isDescendant(of: view) {
            stub.removeFromSuperview()
        }
    }
    
    private func setupStub() {
        view.addSubview(stub)
        
        NSLayoutConstraint.activate([
            stub.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stub.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 24),
        ])
    }
}
