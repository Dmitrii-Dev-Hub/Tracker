import UIKit

final class CancelButton: BaseButton {
    init(title: String) {
        super.init(frame: .zero)
        
        configureButton()
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        backgroundColor = R.ColorYP.whiteDynamic
        setTitleColor(R.ColorYP.red, for: .normal)
        layer.borderWidth = 1
        layer.borderColor = R.ColorYP.red.cgColor
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}
