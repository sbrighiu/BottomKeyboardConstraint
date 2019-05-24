# BottomKeyboardConstraint

[![CI Status](https://img.shields.io/travis/sbrighiu/BottomKeyboardConstraint.svg?style=flat)](https://travis-ci.org/sbrighiu/BottomKeyboardConstraint)
[![Version](https://img.shields.io/cocoapods/v/BottomKeyboardConstraint.svg?style=flat)](https://cocoapods.org/pods/BottomKeyboardConstraint)
[![License](https://img.shields.io/cocoapods/l/BottomKeyboardConstraint.svg?style=flat)](https://cocoapods.org/pods/BottomKeyboardConstraint)
[![Platform](https://img.shields.io/cocoapods/p/BottomKeyboardConstraint.svg?style=flat)](https://cocoapods.org/pods/BottomKeyboardConstraint)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

BottomKeyboardConstraint is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BottomKeyboardConstraint'
```

## Description
BottomKeyboardConstraint is a library that makes it easy and transparent to deal with keyboard events, animations and dismissal.

It is always recommended pairing the view controllers using a keyboard with an UIScrollView. This library uses the bottom keyboard set by you to maintain the distance set from the bottom to the UI element selected.

Just set the bottomKeyboardConstraint to connect the bottom layout guide / top superview bottom and the bottom most element defined, and the library will do the rest.

The whole library is set up as an extension of NSLayoutConstraint and uses a simple `registerAsBottomKeyboardConstraint(in: <KeyboardDelegate object>)` to activate.

The KeyboardDelegate is defined as:
```
public protocol KeyboardDelegate {
    var bottomKeyboardConstraint: NSLayoutConstraint? { get set }

    var view: UIView! { get set }

    // Optional methods 
    func keyboardUpdated(withState state: KeyboardState)
    func keyboardShouldDismissAtTap() -> Bool // Default implementation returns true
}
```

Optionally, you can define `keyboardUpdated(withState state: KeyboardState)` method and listen for the following keyboard events:
```
public enum KeyboardState {
    case willUpdateHeight(from: CGFloat, to: CGFloat)
    case didShow
    case didSwitch
    case willHide
    case didHide
}
```

## Usage

```
//.. Import the library
import BottomKeyboardConstraint

//.. Make UIViewController or any other object a delegate for the keyboard
class ViewController: UIViewController, KeyboardDelegate {

//.. Declare a bottomKeyboardConstraint variable either as a @IBOutlet or create it in code and return it
@IBOutlet weak var bottomKeyboardConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //.. Setup the bottomKeyboardConstraint as the keyboard constraint to have it update as the keyboard shows/updates/hides.
        bottomKeyboardConstraint?.registerAsBottomKeyboardConstraint(in: self)
}

//.. Optionally you can also subscribe to the keyboard events
func keyboardUpdated(withState state: KeyboardState) {
    print(state)
}

//.. Optionally you can disable the tap to dismiss functionality when the keyboard is visible
func keyboardShouldDismissAtTap() -> Bool {
    return false
}
```

## Author

Stefan Brighiu, sbrighiu@gmail.com

## License

BottomKeyboardConstraint is available under the MIT license. See the LICENSE file for more info.
