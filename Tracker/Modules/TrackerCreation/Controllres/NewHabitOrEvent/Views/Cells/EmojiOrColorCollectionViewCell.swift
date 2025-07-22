import UIKit

final class EmojiOrColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiOrColorCollectionViewCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    func configure(with color: UIColor) {
        let viewFrame = CGRect(x: 0, y: 0, width: frame.width - 12, height: frame.height - 12)
        colorView.frame = viewFrame
        colorView.backgroundColor = color
        layer.cornerRadius = 12
        
        addColorView()
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = String(emoji)
        layer.cornerRadius = frame.width / 3.25
        
        addEmojiLabel()
    }
    
    private func addColorView() {
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.heightAnchor.constraint(equalToConstant: frame.height - 12),
            colorView.widthAnchor.constraint(equalToConstant: frame.width - 12),
        ])
    }
    
    private func addEmojiLabel() {
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
