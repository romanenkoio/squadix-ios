//
//  WhiteButton.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class WhiteButton: UIButton {
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
            alpha = isEnabled ? 1 : 0.6
        }
    }

    var fillColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let cornerRadius = rect.size.height * Constants.cornerRadiusRatio
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: Constants.rectInset, dy: Constants.rectInset),
                                cornerRadius: cornerRadius)
        path.lineWidth = 1
        let desiredBorderColor = UIColor.mainStrikeColor
        desiredBorderColor.set()
        path.stroke()
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let size = CGSize(width: originalSize.width + 20, height: originalSize.height)
        return size
    }

    func setButtonTitle(text: String) {
        let attributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
             NSAttributedString.Key.kern: CGFloat(1.25),
             NSAttributedString.Key.foregroundColor: UIColor.mainStrikeColor.withAlphaComponent(0.8)]
        let selectedAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
             NSAttributedString.Key.kern: CGFloat(1.25),
             NSAttributedString.Key.foregroundColor:UIColor.mainStrikeColor]
        let attributedTitle = NSAttributedString(string: text,
                                                 attributes: attributes)
        let selAttrTitle = NSAttributedString(string: text,
                                              attributes: selectedAttributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
        self.setAttributedTitle(selAttrTitle, for: .highlighted)
    }
}

private extension WhiteButton {
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.lineBreakMode = .byTruncatingTail
        contentEdgeInsets = Constants.contentInsets
        guard let currentText = titleLabel?.text else {
            return
        }
        setButtonTitle(text: currentText)
    }
}
