//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//

import UIKit

public enum KeyboardState {
    case willUpdateHeight(from: CGFloat, to: CGFloat)
    case didShow
    case didSwitch
    case willHide
    case didHide
}

public protocol KeyboardDelegate {
    var bottomKeyboardConstraint: NSLayoutConstraint? { get set }
    
    var view: UIView! { get set }
    
    func keyboardUpdated(withState state: KeyboardState)
    func keyboardShouldDismissAtTap() -> Bool
}

public extension KeyboardDelegate {
    func keyboardUpdated(withState state: KeyboardState) { /* Default implementation */ }
    func keyboardShouldDismissAtTap() -> Bool { return true }
}

typealias BottomConstraintVCDelegate = UIViewController & KeyboardDelegate

extension NSLayoutConstraint {
    
    public func registerAsBottomKeyboardConstraint(in vc: UIViewController & KeyboardDelegate) {
        resetModel()
        
        model.vcDelegate = vc
        model.defaultBottomMargin = self.constant
        
        // Update model information
        if vc.view.bottomAnchor == self.firstAnchor ||
            vc.view.bottomAnchor == self.secondAnchor {
            model.takesSafeAreaIntoAccount = false
        }

        if self.firstItem is UIScrollView ||
            self.secondItem is UIScrollView {
            model.referenceViewIsAScrollView = true
        }
        
        // Observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
}

// MARK: - Keyboard management methods
extension NSLayoutConstraint {
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard vcVisible,
            let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let newHeight = frame.size.height
        
        let tabBarMargin = model.vcDelegate?.navigationController?.tabBarController?.tabBar.frame.size.height
            ?? model.vcDelegate?.tabBarController?.tabBar.frame.size.height
        let bottomMargin = tabBarMargin
            ?? UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            ?? 0
        var finalHeight: CGFloat = newHeight + model.defaultBottomMargin
        if tabBarMargin != nil {
            finalHeight = newHeight + model.defaultBottomMargin - bottomMargin
        } else {
            if bottomMargin != 0 {
                if model.takesSafeAreaIntoAccount {
                    finalHeight = newHeight + model.defaultBottomMargin - bottomMargin
                }
            }
        }
        
        model.vcDelegate?.keyboardUpdated(withState: .willUpdateHeight(from: self.constant, to: newHeight))
        
        self.constant = finalHeight
        UIView.animate(withDuration: 0,
                       delay: 0,
                       options: [.layoutSubviews, .curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {
                        self.containerView?.layoutIfNeeded()
        }, completion: nil)
        
        model.didHideWasCalled = false
    }
    
    @objc func keyboardDidShow(_ notification: Foundation.Notification) {
        guard vcVisible else { return }
        
        if !model.didShowWasCalled {
            addGesture()
            model.vcDelegate?.keyboardUpdated(withState: .didShow)
            model.didShowWasCalled = true
        } else {
            model.vcDelegate?.keyboardUpdated(withState: .didSwitch)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        guard vcVisible else { return }
        
        removeGesture()
        
        self.constant = model.defaultBottomMargin
        
        UIView.animate(withDuration: 0,
                       delay: 0,
                       options: [.layoutSubviews, .curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {
                        self.containerView?.layoutIfNeeded()
        }, completion: nil)
        
        model.vcDelegate?.keyboardUpdated(withState: .willHide)
        
        model.didShowWasCalled = false
    }
    
    @objc func keyboardDidHide(_ notification: Foundation.Notification) {
        guard vcVisible else { return }
        
        model.vcDelegate?.keyboardUpdated(withState: .didHide)
    }
}

extension NSLayoutConstraint {
    func dismissInBG() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.dismiss()
            }
        }
    }
    
    @objc func dismiss() {
        if !model.didHideWasCalled {
            model.didHideWasCalled = true
            
            containerView?.endEditing(false)
        }
    }
}

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

extension NSLayoutConstraint: Identifiable {
    internal var model: KeyboardHandler {
        let model = models[uniqueIdentifier] ?? KeyboardHandler()
        models[uniqueIdentifier] = model
        return model
    }
    
    internal func resetModel() {
        models[uniqueIdentifier] = nil
    }
    
    internal var containerView: UIView? {
        return model.vcDelegate?.view
    }
    
    internal var vcVisible: Bool {
        return model.vcDelegate?.viewIfLoaded?.window != nil
    }
}

// MARK: - Keyboard Handler Model
private var models = [Int: KeyboardHandler]()

internal class KeyboardHandler {
    weak var vcDelegate: BottomConstraintVCDelegate?
    weak var tapGesture: UITapGestureRecognizer?
    
    var defaultBottomMargin: CGFloat = 0
    
    var didHideWasCalled: Bool = false
    var didShowWasCalled = false
    
    var takesSafeAreaIntoAccount = true
    var referenceViewIsAScrollView = false
}
