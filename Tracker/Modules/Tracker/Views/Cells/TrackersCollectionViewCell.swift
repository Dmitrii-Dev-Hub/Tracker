import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackersCollectionViewCell"
    weak var delegate: TrackersCellDelegate?
    
    private var isCompletedToday = false
    private(set) var trackerId: UUID?
    private var completedDays = 0
    private var date: Date?
    private(set) var isPinned = false
    
    // MARK: Properties
    
    private let backView = TrackerColorCellView()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = R.ColorYP.blackDynamic
        
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton.systemButton(with: R.ImagesYP.addIcon, target: nil, action: nil)
        button.layer.cornerRadius = 17
        button.tintColor = R.ColorYP.whiteDynamic
        
        return button
    }()
    
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    func getTrackerViewFrame() -> CGRect {
        backView.frame
    }
    
    func getColor() -> UIColor? {
        backView.getColor()
    }
    
    func getTitle() -> String? {
        backView.getTitle()
    }
    
    func getEmoji() -> String? {
        backView.getEmoji()
    }
    
    func pin() {
        backView.pin()
        isPinned = true
    }
    
    func unpin() {
        backView.unpin()
        isPinned = false
    }
    
    func configure(tracker: Tracker, isCompleted: Bool, completedDays: Int, date: Date, isPinned: Bool) {
        self.isCompletedToday = isCompleted
        self.trackerId = tracker.id
        self.date = date
        
        setTitle(text: tracker.name)
        setEmoji(emoji: tracker.emoji)
        setColor(color: tracker.color)
        
        if isCompletedToday {
            self.completedDays = completedDays - 1
            setCompletedState(with: completedDays)
        } else {
            self.completedDays = completedDays
            setUncompletedState(with: completedDays)
        }
        
        isPinned ? pin() : unpin()
    }
    
    private func setColor(color: UIColor?) {
        backView.set(color: color)
        addButton.backgroundColor = color
    }
    
    private func setEmoji(emoji: String?) {
        guard let emoji = emoji else { return }
        backView.set(emoji: String(emoji))
    }
    
    private func setTitle(text: String?) {
        backView.set(title: text)
    }
    
    private func setDays(text: String?) {
        daysLabel.text = text
    }
    
    private func setCompletedState(with count: Int) {
        addButton.layer.opacity = 0.3
        addButton.setImage(R.ImagesYP.checkmark, for: .normal)
        setDays(text: String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), count))
        isCompletedToday = true
    }
    
    private func setUncompletedState(with count: Int) {
        addButton.layer.opacity = 1
        addButton.setImage(R.ImagesYP.addIcon, for: .normal)
        setDays(
            text: String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), count)
        )
        isCompletedToday = false
    }
    
    @objc private func recordTracker() {
        guard let trackerId = trackerId, let date = date else {
            assertionFailure("tracker id is nil")
            return
        }
        if Date() > date {
            if isCompletedToday {
                delegate?.incompleteTracker(id: trackerId)
                setUncompletedState(with: completedDays)
            } else {
                delegate?.completeTracker(id: trackerId)
                setCompletedState(with: completedDays + 1)
            }
        }
    }
    
    private func configureViews() {
        [backView, daysLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        addButton.addTarget(self, action: #selector(recordTracker), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: 90),
            
            addButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 8),
            daysLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
        ])
    }
    
    
    
}
