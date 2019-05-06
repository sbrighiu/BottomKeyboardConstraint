//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardHandlerDelegate: class {
    var bottomConstraint: NSLayoutConstraint? { get set }
    var keyboardHandler: KeyboardHandler? { get set }
    var view: UIView! { get set }
    
    func keyboardWillShow()
    func keyboardWillHide()
    func keyboardWillAutomaticallyDismiss()
    func keyboardDidShow()
    func keyboardDidHide()
    func keyboardDidUpdateSize(height: CGFloat)
}

extension KeyboardHandlerDelegate {
    func keyboardWillShow() { }
    func keyboardWillHide() { }
    func keyboardWillAutomaticallyDismiss() { }
    func keyboardDidShow() { }
    func keyboardDidHide() { }
    func keyboardDidUpdateSize(height: CGFloat) { }
}

enum KeyboardHandlerBottomMargin {
    case tabBar
    case custom(CGFloat)
    
    fileprivate var height: CGFloat {
        switch self {
        case .tabBar: return 49
        case .custom(let height): return height
        }
    }
}

private let genericAnimationDuration: TimeInterval = 0.5

class KeyboardHandler: NSObject {
    
    // MARK: - Variables
    var shouldDismissAtTap = true
    var customBottomMargin: KeyboardHandlerBottomMargin = .custom(0)
    
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate var frame: CGRect = .zero
    
    fileprivate weak var _delegate: KeyboardHandlerDelegate? // Keeping a weak reference needs an optional variable
    fileprivate var delegate: KeyboardHandlerDelegate { return _delegate! }
    
    fileprivate var alreadyCalledDidActions: Bool = false
    
    fileprivate var didAddCustomHeight = false
    
    // MARK: -
    init(withVC vc: UIViewController & KeyboardHandlerDelegate) {
        super.init()
        
        self._delegate = vc
        
        registerToNotifications()
    }
    
    // MARK: - Explicit update method
    fileprivate func updateVC(_ delta: CGFloat,
                              duration: Double,
                              animationOptions: UIView.AnimationOptions = [],
                              show: Bool = false) {
        guard delta != .zero else { dismissInBG(); return }
        
        var extraHeight = delta
        if customBottomMargin.height != 0, !didAddCustomHeight {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, bottomPadding != 0 {
                extraHeight -= bottomPadding
            }
            extraHeight -= customBottomMargin.height
            didAddCustomHeight = true
        }
        
        var finalHeight = (delegate.bottomConstraint?.constant ?? 0) + extraHeight
        delegate.bottomConstraint?.constant = finalHeight
        
        if !show {
            finalHeight = 0
            delegate.bottomConstraint?.constant = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.delegate.view.layoutIfNeeded()
        }, completion: nil)
        
        if delta < 100, delta > -100 {
            delegate.keyboardDidUpdateSize(height: finalHeight)
            return
        }
        
        show ? delegate.keyboardWillShow() : delegate.keyboardWillHide()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Dismissal
extension KeyboardHandler {
    func dismissInBG() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.dismiss()
            }
        }
    }
    
    @objc func dismiss() {
        if tapGesture != nil || !shouldDismissAtTap {
            alreadyCalledDidActions = false
            
            if shouldDismissAtTap == true {
                self.delegate.view.endEditing(false)
            }
            
            delegate.bottomConstraint?.constant = 0
            self.frame = CGRect.zero
            self.updateVC(.zero,
                          duration: genericAnimationDuration,
                          animationOptions: [.layoutSubviews,
                                             .beginFromCurrentState,
                                             .allowUserInteraction])
            
            self.removeGesture()
            self.delegate.keyboardWillAutomaticallyDismiss()
        }
    }
}

// MARK: - Keyboard management methods
private extension KeyboardHandler {
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard let _ = delegate.bottomConstraint else { return }
        
        addGesture()
        
        let oldFrame = self.frame
        let (frame, options, duration) = notification.getFrameOptionsAndDuration(with: delegate.view)
        if let value = frame {
            self.frame = value
        }
        
        if oldFrame.size.height != self.frame.size.height {
            updateVC(self.frame.size.height - oldFrame.size.height,
                     duration: duration,
                     animationOptions: options,
                     show: true)
        }
    }
    
    @objc func keyboardDidShow(_ notification: Foundation.Notification) {
        guard let _ = delegate.bottomConstraint else { return }
        
        if !alreadyCalledDidActions {
            self.delegate.keyboardDidShow()
            alreadyCalledDidActions = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        guard let _ = delegate.bottomConstraint else { return }
        
        removeGesture()
        
        let (options, duration) = notification.getOptionsAndDuration()
        if self.frame.size.height > 0.0 {
            self.updateVC(-self.frame.size.height,
                          duration: duration,
                          animationOptions: options)
        }
        self.frame = .zero
    }
    
    @objc func keyboardDidHide(_ notification: Foundation.Notification) {
        guard let _ = delegate.bottomConstraint else { return }
        
        didAddCustomHeight = false
        self.delegate.keyboardDidHide()
    }
}

// MARK: - Notifications
private extension KeyboardHandler {
    func registerToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardHandler.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardHandler.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHandler.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHandler.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
}

// MARK: - Gesture management
extension KeyboardHandler: UIGestureRecognizerDelegate {
    fileprivate func addGesture() {
        guard shouldDismissAtTap else { return }
        
        removeGesture()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(KeyboardHandler.dismiss))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        delegate.view.addGestureRecognizer(gesture)
        
        tapGesture = gesture
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view as? UIControl) == nil
    }
    
    fileprivate func removeGesture() {
        guard shouldDismissAtTap, tapGesture != nil, (delegate.view.gestureRecognizers?.count ?? 0) > 0 else { return }
        
        delegate.view.removeGestureRecognizer(tapGesture!)
        tapGesture = nil
    }
}

// MARK: - Convenience
private extension Foundation.Notification {
    func getFrameOptionsAndDuration(with superView: UIView?) -> (CGRect?, UIView.AnimationOptions, TimeInterval) {
        let (options, duration) = getOptionsAndDuration()
        var frame: CGRect?
        
        guard let userInfo = self.userInfo else { return (frame, options, duration) }
        
        if let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let value = superView?.convert(rect, from: nil) {
            frame = value
        }
        
        return (frame, options, duration)
    }
    
    func getOptionsAndDuration() -> (UIView.AnimationOptions, TimeInterval) {
        var options: UIView.AnimationOptions = []
        var duration: TimeInterval = 0
        
        guard let userInfo = self.userInfo else { return (options, duration) }
        
        if let value = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as AnyObject) as? UInt {
            options = UIView.AnimationOptions(rawValue: value)
        }
        if let value = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            duration = value
        }
        
        return (options, duration)
    }
}
