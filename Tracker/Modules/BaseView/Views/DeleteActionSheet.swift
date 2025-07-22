import UIKit
final class DeleteActionSheet {
    private let alert: UIAlertController
    
    init(title: String?, message: String?, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) {_ in
            handler()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""),
                                      style: .cancel) { action in
            alert.dismiss(animated: true)
        })
        
        self.alert = alert
    }
    
    func present(on viewController: UIViewController?) {
        viewController?.present(alert, animated: true)
    }
}
