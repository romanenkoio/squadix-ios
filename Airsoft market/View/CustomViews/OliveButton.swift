//
//  OliveButton.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class OliveButton: UIButton {
      private struct Constants {
            static let contentInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            static let cornerRadiusRatio: CGFloat = 0.68
            static let rectInset: CGFloat = 1
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }

        override var isEnabled: Bool {
            didSet {
    //            isEnabled ? showShadow() : hideShadow()
                alpha = isEnabled ? 1 : 0.6
            }
        }

    var fillColor: UIColor = UIColor.mainStrikeColor {
            didSet {
                setNeedsDisplay()
            }
        }

        override func draw(_ rect: CGRect) {
            super.draw(rect)

            let cornerRadius = rect.size.height * Constants.cornerRadiusRatio
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: Constants.rectInset, dy: Constants.rectInset),
                                    cornerRadius: cornerRadius)

            fillColor.setFill()
            path.fill()
        }

        func setButtonTitle(text: String) {
            let attributes: [NSAttributedString.Key: Any] =
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                 NSAttributedString.Key.kern: CGFloat(1.25)]
            let selectedAttributes: [NSAttributedString.Key: Any] =
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                 NSAttributedString.Key.kern: CGFloat(1.25),
                 NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
            let attributedTitle = NSAttributedString(string: text,
                                                     attributes: attributes)
            let selAttrTitle = NSAttributedString(string: text,
                                                  attributes: selectedAttributes)
            self.setAttributedTitle(attributedTitle, for: .normal)
            self.setAttributedTitle(selAttrTitle, for: .highlighted)
        }
}

private extension OliveButton {
    func showShadow() {
        layer.applySketchShadow(color: UIColor.black, alpha: 0.14, xPoint: 0, yPoint: 1, blur: 1, spread: 0)
        layer.applySketchShadow(color: UIColor.black, alpha: 0.12, xPoint: 0, yPoint: 2, blur: 1, spread: -1)
        layer.applySketchShadow(color: UIColor.black, alpha: 0.2, xPoint: 0, yPoint: 1, blur: 3, spread: 0)
    }

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.lineBreakMode = .byTruncatingTail
        contentEdgeInsets = Constants.contentInsets
        showShadow()
        guard let currentText = titleLabel?.text else {
            return
        }
        setButtonTitle(text: currentText)
    }
}
