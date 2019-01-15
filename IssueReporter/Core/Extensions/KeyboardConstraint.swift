// The MIT License (MIT)
//
// Copyright (c) 2015 James Tang (j@jamztang.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

internal class KeyboardLayoutConstraint: NSLayoutConstraint {

    private var offset: CGFloat = 0
    private var keyboardVisibleHeight: CGFloat = 0

    public override func awakeFromNib() {
        super.awakeFromNib()

        offset = constant

        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notification

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height
            }

            updateConstant()

            guard
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }

            UIView.animate(
                withDuration: TimeInterval(duration.doubleValue),
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curve.uintValue),
                animations: {
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        updateConstant()

        if let userInfo = notification.userInfo {

            guard
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }

            UIView.animate(
                withDuration: TimeInterval(duration.doubleValue),
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curve.uintValue),
                animations: {
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
                    return
            }, completion: nil)
        }
    }

    func updateConstant() {
        constant = offset + keyboardVisibleHeight
    }
}

