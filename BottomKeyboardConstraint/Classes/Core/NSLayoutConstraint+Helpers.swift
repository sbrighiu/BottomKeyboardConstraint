//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//

import Foundation

// MARK: - Gesture management
extension NSLayoutConstraint: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view as? UIControl) == nil
    }
}

extension NSLayoutConstraint {
    internal func addGesture() {
        guard let delegate = model.vcDelegate,
            delegate.keyboardShouldDismissAtTap() else { return }
        
        removeGesture()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        delegate.view.addGestureRecognizer(gesture)
        
        model.tapGesture = gesture
    }
    
    internal func removeGesture() {
        guard let tapGesture = model.tapGesture else { return }
        
        model.vcDelegate?.view.removeGestureRecognizer(tapGesture)
        model.tapGesture = nil
    }
}
