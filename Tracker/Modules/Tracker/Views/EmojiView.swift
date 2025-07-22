import UIKit

final class EmojiView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        
        return label
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        layer.cornerRadius = 12
        backgroundColor = R.ColorYP.whiteDynamic.withAlphaComponent(0.3)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeEmoji(emoji: String) {
        label.text = emoji
    }
    
    private func configure() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
