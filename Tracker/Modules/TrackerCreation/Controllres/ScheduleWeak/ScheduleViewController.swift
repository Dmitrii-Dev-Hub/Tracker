import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ formattedSchedule: [Day], chosenDays: Set<Day>)
}

protocol ScheduleViewControllerDelegate2: NSObject {
    var selectedDays: [Day] { get set }
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate2?
    
    private let allDays: [Day] = R.Mocks.weekdays
    private let days = R.Mocks.weekdaysStrings
    private var selectedDays: Set<Day> = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = R.ColorYP.gray
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let doneButton = MainButton(title: R.Text.ButtonTitle.done)
    
    init(delegate: ScheduleViewControllerDelegate2? = nil, selectedDays: Set<Day>) {
        self.delegate = delegate
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayouts()
        setupAppearance()
        setupNavController()
        setupTableView()
        setupButtons()
    }
    
    private func getArraySelectedDays() -> [Day] {
        var daysArray = [Day]()
        for day in allDays {
            if selectedDays.contains(day) {
                daysArray.append(day)
            }
        }
        
        return daysArray
    }
    
    private func formatSelectedDays(days: Set<Day>) -> String {
        if days.count == 7 {
            return "Каждый день"
        }
        var values = [String]()
        
        for day in days {
            values.append(day.rawValue)
        }
        let text = values.joined(separator: ", ")

        return text
    }

    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let day = allDays[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
        delegate?.selectedDays = getArraySelectedDays()
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell  = tableView.dequeueReusableCell(
                withIdentifier: ScheduleTableViewCell.identifier,
                for: indexPath
            ) as? ScheduleTableViewCell
        else {
            return UITableViewCell()
        }
        
        cell.configure(title: days[indexPath.row])
        
        cell.switchView.setOn(selectedDays.contains(allDays[indexPath.row]),
                              animated: true)
        cell.switchView.tag = indexPath.row
        cell.switchView.addTarget(self, action: #selector(switchValueChanged(_:)),
                                  for: .valueChanged)
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.clipsToBounds = true
        } else if indexPath.row == days.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.clipsToBounds = true
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK: - Setup UI
extension ScheduleViewController {
    private func setupViews() {
        view.addView(doneButton)
        view.addView(tableView)
    }
    
    private func setupLayouts() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: 25),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor,
                                                           constant: -24),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.whiteDynamic
    }
    
    private func setupNavController() {
        title = R.Text.schedule
        navigationItem.hidesBackButton = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleTableViewCell.self,
                           forCellReuseIdentifier: ScheduleTableViewCell.identifier)
    }
    
    private func setupButtons() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped),
                             for: .touchUpInside)
    }
}
