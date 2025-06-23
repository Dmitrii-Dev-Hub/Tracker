import UIKit

class BaseButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateTouchDown()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateTouchUpInside()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateTouchUpInside()
    }
    
    private func animateTouchDown() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.7
        })
    }
    
    private func animateTouchUpInside() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 1.0
        })
    }
}
