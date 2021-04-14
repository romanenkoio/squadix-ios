//
//  StrikeInputField.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//
import UIKit

class StrikeInputField: UITextField {
    open var lineView: UIView!
    open var titleLabel: UILabel!
    open var lineHeight: CGFloat = 1.0
    open var disabledColor: UIColor = UIColor.lightGray
    open var selectedLineColor: UIColor = UIColor.mainStrikeColor
    open var lineColor: UIColor = UIColor.mainStrikeColor
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 12)
    open var placeholderFont = UIFont.systemFont(ofSize: 16)
    open var lineViewActiveColor: UIColor = UIColor.mainStrikeColor
    open var titleColor: UIColor = UIColor.mainStrikeColor
    open var enableLongPressActions = true
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        init_FlowerInputField()
    }

    /**
     Intialzies the control by deserializing it
     - parameter coder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_FlowerInputField()
    }

    fileprivate final func init_FlowerInputField() {
        borderStyle = .none
        createTitleLabel()
        createLineView()
        updateColors()
        addEditingChangedObserver()
        font = UIFont.systemFont(ofSize: 16)
    }

    fileprivate func createTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = titleFont
        titleLabel.alpha = 0.0
        titleLabel.textColor = titleColor

        addSubview(titleLabel)
        self.titleLabel = titleLabel
    }

    fileprivate func createLineView() {
        if lineView == nil {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            configureDefaultLineHeight()
        }
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(lineView)
    }
    
    func validateTextField(lenghtCondition: Int) -> Bool {
        guard let text = self.text else { return false }
        if text.isEmpty || text.count <  lenghtCondition {
            return false
        }
        return true
    }

    fileprivate func configureDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        lineHeight = 4.0 * onePixel
    }

    func updateColors() {
        updateLineColor()
        placeholderColor = UIColor.black.withAlphaComponent(0.6)
    }

    // MARK: - View updates

    fileprivate func updateControl(_ animated: Bool = false) {
        updateColors()
        updateLineView()
        updateTitleLabel(animated)
    }

    fileprivate func updateLineView() {
        if let lineView = lineView {
            lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected)
        }
        updateLineColor()
    }

    fileprivate func updateTitleLabel(_ animated: Bool = false) {
        if let titleText = placeholder {
            let text = titleText
            let attributedString = NSMutableAttributedString(string: text)
            let color = titleColor
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                          value: color,
                                          range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: 0.4,
                                          range: NSRange(location: 0, length: text.count))
            if isRequired {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                              value: UIColor.red,
                                              range: NSRange(location: attributedString.length - 1, length: 1))
            }
            titleLabel.attributedText = attributedString
        }
        titleLabel.font = titleFont

        updateTitleVisibility(animated)
    }

    fileprivate var _highlighted: Bool = false

    /**
     A Boolean value that determines whether the receiver is highlighted.
     When changing this value, highlighting will be done with animation
     */
    override open var isHighlighted: Bool {
        get {
            return _highlighted
        }
        set {
            _highlighted = newValue
//            updateTitleColor()
            updateLineView()
        }
    }

    fileprivate func updateLineColor() {
        if !isEnabled {
            lineView.backgroundColor = disabledColor
        } else {
            if editingOrSelected {
                lineView.backgroundColor = selectedLineColor
            } else {
                guard let curText = text,
                    curText.count > 0 else {
                        self.lineView.backgroundColor = UIColor.black.withAlphaComponent(0.54)
                        return
                }
                lineView.backgroundColor = lineViewActiveColor
            }
        }
    }

    open var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }

    open func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        return CGRect(x: 0, y: bounds.size.height - lineHeight, width: bounds.size.width, height: lineHeight)
    }

    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateControl(true)
        return result
    }

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateControl(true)
        return result
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return enableLongPressActions
    }

    fileprivate func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = titleLabelRectForBounds(bounds, editing: isTitleVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alpha
            self.titleLabel.frame = frame
        }
        if animated {
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            let duration = isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }

    fileprivate var _titleVisible: Bool = false
    open func isTitleVisible() -> Bool {
        return hasText || _titleVisible
    }

    open func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        if editing {
            return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight())
        }
        return CGRect(x: 0, y: titleHeight(), width: bounds.size.width, height: titleHeight())
    }

    open func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
            let font = titleLabel.font {
            return font.lineHeight
        }
        return 15.0
    }

    /// The value of the title appearing duration
    @objc dynamic open var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    @objc dynamic open var titleFadeOutDuration: TimeInterval = 0.3

    /// OBSERVER
    fileprivate func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(StrikeInputField.editingChanged), for: .editingChanged)
    }

    @objc open func editingChanged() {
        updateControl(true)
        updateTitleLabel(true)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = titleLabelRectForBounds(bounds, editing: isTitleVisible() || false)
        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected || false)
    }

    override open var text: String? {
        didSet {
            updateControl(false)
            checkMaxLength(textField: self)
        }
    }

    // CUSTOM redraw
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let titleHeight = self.titleHeight()

        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - lineHeight
        )
        return rect
    }

    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight()
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - lineHeight
        )
        return rect
    }

    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(
            x: 0,
            y: titleHeight(),
            width: bounds.size.width,
            height: bounds.size.height - titleHeight() - lineHeight
        )
        return rect
    }

    open var placeholderColor: UIColor = UIColor.black.withAlphaComponent(0.6) {
        didSet {
            updatePlaceholder()
        }
    }

    open var isRequired: Bool = false {
        didSet {
            updatePlaceholder()
        }
    }

    func addStarIfNeeded(_ text: inout NSMutableAttributedString) {
        if  isRequired {
            if text.mutableString.contains("*") == false {
                text.mutableString.append(" *")
            }
            text.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor.red,
                              range: NSRange(location: text.length - 1, length: 1))
        }
    }

    fileprivate func updatePlaceholder() {
        guard let placeholder = placeholder else {
            return
        }
        let font = placeholderFont
        let color = isEnabled ? placeholderColor : disabledColor
        var attrText = NSMutableAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font
            ]
        )
        addStarIfNeeded(&attrText)
        attributedPlaceholder = attrText
    }
}

private var kAssociationKeyMaxLength: Int = 0

extension StrikeInputField {
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }

    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }

        let selection = selectedTextRange
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        selectedTextRange = selection
    }
}
