import UIKit

final class MainButton: BaseButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        configureButton()
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        backgroundColor = R.ColorYP.blackDynamic
        setTitleColor(R.ColorYP.whiteDynamic, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

