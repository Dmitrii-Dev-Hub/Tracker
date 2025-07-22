import UIKit

final class NewHabitOrEventViewController: UIViewController,
                                           ScheduleViewControllerDelegate2, CategoriesViewControllerDelegate {
    
    private var colorTrackers = R.ColorYP.Tracker.trackers
    private var manager: TrackerStoreManager?
    
    var days: String {
        let trackerRecordStore = TrackerRecordStore()
        let count = trackerRecordStore.fetchCount(by: tracker.id)
        
        return String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), count)
    }
    
    private let typeTracker: TrackerType
    private var isEdit: Bool = false
    
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
        color: nil,
        emoji: nil,
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
    
    private let scrollView: UIScrollView = UIScrollView()
    private let scrollContainer: UIView = UIView()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = R.ColorYP.blackDynamic
        
        return label
    }()
    
    private let textField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = R.Text.placeholderNewTracker
        textField.backgroundColor = R.ColorYP.backgroundDynamic
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.ColorYP.red
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.separatorColor = R.ColorYP.gray
        tableView.backgroundColor = R.ColorYP.backgroundDynamic
        return tableView
    }()
    
    private var emojiAndColorsCollectionView: EmojiAndColorsCollectionView = {
        let params = GeometricParams(cellCount: 6, topInset: 24,
                                     leftInset: 18, bottomInset: 40,
                                     rightInset: 18, cellSpacing: 5)
        let collection = EmojiAndColorsCollectionView(params: params)
        return collection
    }()
    
    private let cancelButton = CancelButton(title: R.Text.ButtonTitle.cancel.value)
    private let doneButton = MainButton(title: R.Text.ButtonTitle.create.value)
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    init(type: TrackerType) {
        self.typeTracker = type
        self.manager = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    private(set) var oldSelectedColor: UIColor? = nil
    private(set) var oldSelectedEmoji: String? = nil
    
    init(
        trackerStore: TrackerStore,
        categoryStore: CategoryStore,
        tracker: Tracker,
        category: TrackerCategory,
        isEdit: Bool = false
    ) {
        self.manager = TrackerStoreManager(trackerStore: trackerStore, categoryStore: categoryStore)
        let isEvent = (tracker.timetable == nil || tracker.timetable == [])
        
        self.tracker = tracker
        self.typeTracker = isEvent ? .event : .habit
        self.selectedCategory = category
        self.selectedDays = tracker.timetable ?? [Day]()
        self.isEdit = isEdit
        self.oldSelectedColor = tracker.color
        self.oldSelectedEmoji = tracker.emoji
        super.init(nibName: nil, bundle: nil)
        let params = GeometricParams(cellCount: 6, topInset: 24,
                                     leftInset: 18, bottomInset: 40,
                                     rightInset: 18, cellSpacing: 5)
        emojiAndColorsCollectionView = EmojiAndColorsCollectionView(params: params, oldSelectedColor: oldSelectedColor, oldSelectedEmoji: oldSelectedEmoji)
        textField.text = tracker.name
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchViewController()
        
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        emojiAndColorsCollectionView.delegateController = self
        
        
        setupTableView()
        setupButtons()
        setupAppearance()
        setupViews()
        setupLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func switchViewController() {
        if isEdit {
            title = "Редактирование привычки"
        } else {
            switch typeTracker {
            case .habit:
                title = R.Text.NavTitle.habit.value
            case .event:
                title = R.Text.NavTitle.event.value
            }
        }
    }
    
    private func showWarning() {
        UIView.animate(withDuration: 0.1, animations: {
            self.warningLabel.isHidden = false
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
        doneButton.backgroundColor = R.ColorYP.gray
        doneButton.isEnabled = false
    }
    
    private func unlockCreateButton() {
        doneButton.backgroundColor = R.ColorYP.blackDynamic
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

        self.dismiss(animated: true)
        delegate?.addTracker(tracker: tracker, category: newCategory)
    }
    
    @objc private func buttonSaveTapped() {
        self.dismiss(animated: true)
        guard let selectedCategory else { return }
        manager?.update(tracker: tracker, category: selectedCategory)
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
            let categoriesVC = CategoriesViewController(selectedCategory: selectedCategory, delegate: self)
            
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

//MARK: - ScheduleViewControllerDelegate
extension NewHabitOrEventViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ formattedSchedule: [Day], chosenDays: Set<Day>) {
        valueSchedule = formattedSchedule
        tableView.reloadData()
    }
}

//MARK: - EmojiAndColorsCollectionViewDelegate
extension NewHabitOrEventViewController: EmojiAndColorsCollectionViewDelegate {
    func changeSelectedColor(new color: UIColor) {
        tracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: color,
            emoji: tracker.emoji,
            timetable: tracker.timetable,
            creationDate: TrackersViewController.currentDate)
    }
    
    func changeSelectedEmoji(new emoji: String?) {
        tracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: emoji,
            timetable: tracker.timetable,
            creationDate: TrackersViewController.currentDate)
    }
}


//MARK: - setup UI
extension NewHabitOrEventViewController {
    private func getCollectionHeight() -> CGFloat {
         let availableWidth = view.frame.width - emojiAndColorsCollectionView.params.paddingWidth
         let cellHeight =  availableWidth / CGFloat(emojiAndColorsCollectionView.params.cellCount)
         
         let num = 38 + 48 + 80 + cellHeight * 6
         let collectionSize = CGFloat(num)
         
         return collectionSize
     }
    
    private func setupViews() {
        view.addView(scrollView)
        scrollView.addView(scrollContainer)
        
        if isEdit {
            scrollView.addView(daysLabel)
        }
        
        scrollContainer.addView(textField)
        scrollContainer.addView(warningLabel)
        scrollContainer.addView(tableView)
        scrollContainer.addView(emojiAndColorsCollectionView)
        scrollContainer.addView(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(doneButton)
    }
    
    private func setupLayouts() {
        let tableViewHeight = typeTracker == .habit ? CGFloat(150) : CGFloat(75)
        
        errorLabelHeightConstraint = warningLabel.heightAnchor.constraint(equalToConstant: 0)
        errorLabelHeightConstraint?.isActive = true
        
        errorLabelTopConstraint = warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0)
        errorLabelTopConstraint?.isActive = true
        
        if isEdit {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
                
                scrollContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                scrollContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                scrollContainer.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
                scrollContainer.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
                //datelabel
                
                daysLabel.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: 16),
                daysLabel.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: -16),
                daysLabel.topAnchor.constraint(equalTo: scrollContainer.topAnchor, constant: 24),
                
                //titleTextField
                textField.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                   constant: 16),
                textField.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                    constant: -16),
                textField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor,
                                               constant: 24),
                textField.heightAnchor.constraint(equalToConstant: 75),
                
    //            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
    //            warningLabel.heightAnchor.constraint(equalToConstant: 50),
                warningLabel.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                      constant: 16),
                warningLabel.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                       constant: -16),
                warningLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor,
                                                     constant: -24),
                
                //dataTableView
                tableView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                   constant: 16),
                tableView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                    constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
                
                emojiAndColorsCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                emojiAndColorsCollectionView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: 0),
                emojiAndColorsCollectionView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: 0),
                emojiAndColorsCollectionView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
                emojiAndColorsCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
                
                //buttonsStackView
                buttonsStackView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                          constant: 20),
                buttonsStackView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                           constant: -20),
                buttonsStackView.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor,
                                                         constant: -16),
                buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
                
                scrollContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                scrollContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                scrollContainer.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
                scrollContainer.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
                
                //titleTextField
                textField.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                   constant: 16),
                textField.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                    constant: -16),
                textField.topAnchor.constraint(equalTo: scrollContainer.topAnchor,
                                               constant: 24),
                textField.heightAnchor.constraint(equalToConstant: 75),
                
    //            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
    //            warningLabel.heightAnchor.constraint(equalToConstant: 50),
                warningLabel.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                      constant: 16),
                warningLabel.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                       constant: -16),
                warningLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor,
                                                     constant: -24),
                
                //dataTableView
                tableView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                   constant: 16),
                tableView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                    constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
                
                emojiAndColorsCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                emojiAndColorsCollectionView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: 0),
                emojiAndColorsCollectionView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: 0),
                emojiAndColorsCollectionView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
                emojiAndColorsCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
                
                //buttonsStackView
                buttonsStackView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor,
                                                          constant: 20),
                buttonsStackView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor,
                                                           constant: -20),
                buttonsStackView.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor,
                                                         constant: -16),
                buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            ])
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerOptionTableViewCell.self,
                           forCellReuseIdentifier: TrackerOptionTableViewCell.identifier)
    }
    
    private func setupButtons() {
        
        if isEdit {
            doneButton.addTarget(self, action: #selector(buttonSaveTapped),
                                 for: .touchUpInside)
            doneButton.titleLabel?.text = "Сохранить"
        } else {
            blockCreateButton()
            doneButton.addTarget(self, action: #selector(doneButtonTapped),
                                 for: .touchUpInside)
        }
        
        cancelButton.addTarget(self,
                               action: #selector(cancelButtonTapped),
                               for: .touchUpInside)
    }
    
    private func setupAppearance() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = R.ColorYP.whiteDynamic
        
        daysLabel.text = days
    }
}
