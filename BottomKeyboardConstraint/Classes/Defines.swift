//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//

import Foundation

// MARK: - Constants
internal let genericKeyboardAnimationDuration: TimeInterval = 0.25

// MARK: - Log Framework errors and warnings
internal func logFrameworkError(_ string: String, line: Int = #line, file: String = #file) {
    print("[BottomKeyboardConstraint-Error {\(file):\(line)}] \(string) [Please check your bottom constraint code and, if necessary, open an issue on https://github.com/sbrighiu/BottomKeyboardConstraint.git with more details]")
}

internal func logFrameworkWarning(_ string: String, line: Int = #line, file: String = #file) {
    print("[BottomKeyboardConstraint-Warning {\(file):\(line)}] \(string)")
}

// MARK: - Device
internal var topDevicePadding: CGFloat = {
    if let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding != 0 {
        return topPadding
    }
    return 20
}()

internal var deviceHasNotch: Bool = {
    return topDevicePadding > 20.0
}()

