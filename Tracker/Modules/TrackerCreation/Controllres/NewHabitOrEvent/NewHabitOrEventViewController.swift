import UIKit

final class NewHabitOrEventViewController: UIViewController,
                                           ScheduleViewControllerDelegate2,
                                           CategoriesViewControllerDelegate {
    
    var selectedDays = [Day]() {
        willSet(new) {
            tracker = Tracker(
                id: tracker.id,
                name: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                timetable: new,
                creationDate: TrackersViewController.currentDate)
        }
    }
    var selectedCategory: TrackerCategory? = nil {
        didSet {
            tracker = Tracker(
                id: tracker.id,
                name: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                timetable: tracker.timetable,
                creationDate: TrackersViewController.currentDate)
        }
    }
    
    var tracker: Tracker = Tracker(
        id: UUID(),
        name: nil,
        color: Resources.ColorYP.blue,
        emoji: "👻",
        timetable: nil,
        creationDate: TrackersViewController.currentDate
    ) {
        willSet(newValue) {
            if !newValue.isEmpty(type: typeTracker) && selectedCategory != nil {
                newCategory = TrackerCategory(title: selectedCategory!.title,
                                              trackers: (selectedCategory!.trackers) + [newValue])
                
                unlockCreateButton()
            } else {
                blockCreateButton()
            }
        }
    }
    
    weak var delegate: NewHabitOrEventViewDelegate?
    
    private var errorLabelHeightConstraint: NSLayoutConstraint?
    private var errorLabelTopConstraint: NSLayoutConstraint?
    
    private var valueSchedule: [Day] = []
    private var textWeak: String?
    
    private var newCategory: TrackerCategory? = nil
    
    private let typeTracker: TypeOfEventOrHabit
    
    private let textField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = Resources.Text.placeholderNewTracker
        textField.backgroundColor = Resources.ColorYP.backgroundDynamic
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = Resources.ColorYP.red
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = Resources.ColorYP.gray
        tableView.backgroundColor = Resources.ColorYP.backgroundDynamic
        return tableView
    }()
    
    private let cancelButton = CancelButton(title: Resources.Text.ButtonTitle.cancel)
    private let doneButton = MainButton(title: Resources.Text.ButtonTitle.create)
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    init(type: TypeOfEventOrHabit) {
        self.typeTracker = type
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchViewController()
        
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        setupViews()
        setupLayouts()
        setupTableView()
        setupButtons()
        setupAppearance()
        
        hideWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func switchViewController() {
        switch typeTracker {
        case .habit:
            title = Resources.Text.NavTitle.habitTitle
        case .event:
            title = Resources.Text.NavTitle.eventTitle
        }
    }
    
    private func showWarning() {
        warningLabel.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.errorLabelHeightConstraint?.constant = 20
            self.errorLabelTopConstraint?.constant = 8
            self.view.layoutIfNeeded()
        })
        
        
    }
    private func hideWarning() {
        UIView.animate(withDuration: 0.1, animations: {
            self.warningLabel.isHidden = true
            self.errorLabelHeightConstraint?.constant =  0
            self.errorLabelTopConstraint?.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    private func blockCreateButton() {
        doneButton.backgroundColor = Resources.ColorYP.gray
        doneButton.isEnabled = false
    }
    
    private func unlockCreateButton() {
        doneButton.backgroundColor = Resources.ColorYP.blackDynamic
        doneButton.isEnabled = true
    }
    
    @objc private func textChanged(_ textField: UITextField) {
        let maxNumber = 38
        if  textField.text?.count ?? 0 <= maxNumber {
            hideWarning()
            tracker = Tracker(
                id: tracker.id,
                name: textField.text,
                color: tracker.color,
                emoji: tracker.emoji,
                timetable: tracker.timetable,
                creationDate: TrackersViewController.currentDate)
        } else {
            showWarning()
            blockCreateButton()
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func doneButtonTapped() {
        guard let newCategory = newCategory else {
            print("Category is nil")
            return
        }
        
        let index = TrackersViewController.categories.firstIndex(of: newCategory)
        
        if let index = index {
            TrackersViewController.categories[index] = newCategory
        } else {
            TrackersViewController.categories.append(newCategory)
        }
        self.dismiss(animated: true)
        delegate?.addTracker()
    }
    
}

//MARK: - UITableViewDataSource
extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        typeTracker == .habit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TrackerOptionTableViewCell.identifier,
                for: indexPath
            ) as? TrackerOptionTableViewCell
        else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configureCategory(subtitle: selectedCategory?.title ?? "")
        }
        
        if indexPath.row == 1 {
            cell.configureSchedule(days: selectedDays)
        }
        
        if indexPath.row == 0 && typeTracker == .event
            || indexPath.row == 1 && typeTracker == .habit
        {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NewHabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if typeTracker == .habit || typeTracker == .event, indexPath.row == 0 {
            let categoriesVC = CategoriesViewController(delegate: self, selectedCategory: selectedCategory)
            navigationController?.pushViewController(categoriesVC, animated: true)
        }
        
        if typeTracker == .habit, indexPath.row == 1 {
            let scheduleVC = ScheduleViewController(delegate: self, selectedDays: Set(selectedDays))
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension NewHabitOrEventViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ formattedSchedule: [Day], chosenDays: Set<Day>) {
        valueSchedule = formattedSchedule
        tableView.reloadData()
    }
}

//MARK: - setup UI
extension NewHabitOrEventViewController {
    private func setupViews() {
        view.addView(textField)
        view.addView(warningLabel)
        view.addView(tableView)
        view.addView(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(doneButton)
    }
    
    private func setupLayouts() {
        let tableViewHeight = typeTracker == .habit ? CGFloat(150) : CGFloat(75)
        
        errorLabelHeightConstraint = warningLabel.heightAnchor.constraint(equalToConstant: 0)
        errorLabelHeightConstraint?.isActive = true
        
        errorLabelTopConstraint = warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0)
        errorLabelTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            //titleTextField
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                  constant: 16),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                   constant: -16),
            warningLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor,
                                                 constant: -24),
            
            //dataTableView
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
            //buttonsStackView
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerOptionTableViewCell.self,
                           forCellReuseIdentifier: TrackerOptionTableViewCell.identifier)
    }
    
    private func setupButtons() {
        blockCreateButton()
        doneButton.addTarget(self, action: #selector(doneButtonTapped),
                               for: .touchUpInside)
        
        cancelButton.addTarget(self,
                               action: #selector(cancelButtonTapped),
                               for: .touchUpInside)
    }
    
    private func setupAppearance() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = Resources.ColorYP.whiteDynamic
    }
}
