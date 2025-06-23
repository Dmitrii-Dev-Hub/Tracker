import UIKit

extension UITabBar {
    func addTopBorder(color: UIColor?, thickness: CGFloat) {
        let subview = UIView()
        subview.backgroundColor = color
        self.addView(subview)
        
        NSLayoutConstraint.activate([
            subview.leftAnchor.constraint(equalTo: leftAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
            subview.heightAnchor.constraint(equalToConstant: thickness),
            subview.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
