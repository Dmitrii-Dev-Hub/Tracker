import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackersCollectionViewCell"
    
    weak var delegate: TrackersCellDelegate?
    
    private var isCompletedToday = false
    private var trackerId: UUID?
    private var completedDays = 0
    private var date: Date?
    
    // MARK: Properties
    
    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = R.ColorYP.whiteDynamic
        
        return label
    }()
    
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
    
    private let emojiView = EmojiView()
    
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    func configure(tracker: Tracker, isCompleted: Bool, completedDays: Int, date: Date) {
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
    }
    
    private func setColor(color: UIColor?) {
        backView.backgroundColor = color
        addButton.backgroundColor = color
    }
    
    private func setEmoji(emoji: String?) {
        guard let emoji = emoji else { return }
        emojiView.changeEmoji(emoji: String(emoji))
    }
    
    private func setTitle(text: String?) {
        titleLabel.text = text
    }
    
    private func setDays(text: String?) {
        daysLabel.text = text
    }
    
    private func setCompletedState(with count: Int) {
        addButton.layer.opacity = 0.3
        addButton.setImage(R.ImagesYP.checkmark, for: .normal)
        setDays(text: getDayText(number: count))
        isCompletedToday = true
    }
    
    private func setUncompletedState(with count: Int) {
        addButton.layer.opacity = 1
        addButton.setImage(R.ImagesYP.addIcon, for: .normal)
        setDays(text: getDayText(number: count))
        isCompletedToday = false
    }
    
    private func getDayText(number: Int) -> String {
        let last = number % 10
        var text: String
        switch last {
        case 0, 5, 6, 7, 8, 9:
            text = "дней"
        case 1:
            text = "день"
        case 2, 3, 4:
            text = "дня"
        default:
            text = "день"
        }
        text = "\(number) " + text
        
        return text
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
        [backView, titleLabel, daysLabel, addButton, emojiView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addButton.addTarget(self, action: #selector(recordTracker), for: .touchUpInside)
        
        backView.addSubview(titleLabel)
        backView.addSubview(emojiView)
        contentView.addSubview(backView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(addButton)
        
        
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: 8),
            
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
