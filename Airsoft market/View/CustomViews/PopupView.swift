//
//  PopupView.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class PopupView: UIView {
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private var titleLabel: UILabel?
    private var subtitleLabel: UILabel?
    private var stackView = UIStackView()
    
    private var isShowen = false
    private var title: String?
    private var subtitle: String?
    private var image: UIImage?
    
    
    // Value less than 0 requires manual dismissing
    var presentationTime = TimeInterval(2)
    var eventOnDismissed: ((PopupView) -> ())?

    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        self.init()
        self.title = title
        self.subtitle = subtitle
        self.image = image
        
        configureViews()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        configureViews()
    }
    
    
    private func configureViews() {
        addSubview(backgroundView)
        
        stackView.axis = .vertical
        stackView.spacing = 8
        backgroundView.backgroundColor = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1).withAlphaComponent(0.2)
        backgroundView.contentView.backgroundColor = .clear
        backgroundView.contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillProportionally
        
        imageView.image = (image ?? UIImage(named: "confirm"))?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.darkGray
        
        if title != nil {
            titleLabel = UILabel()
            titleLabel?.text = title
            titleLabel?.textColor = UIColor.darkGray
            titleLabel?.textAlignment = .center
            titleLabel?.numberOfLines = 0
            stackView.addArrangedSubview(titleLabel!)
        }
        if subtitle != nil {
            subtitleLabel = UILabel()
            subtitleLabel?.text = subtitle
            subtitleLabel?.textColor = UIColor.darkGray
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.numberOfLines = 0
            stackView.addArrangedSubview(subtitleLabel!)
        }
        pinViews()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let superview = superview {
            frame = superview.bounds
        }
        backgroundView.layer.cornerRadius = 15
        backgroundView.clipsToBounds = true
    }
    
    private func pinViews() {
        backgroundView.constraints.forEach { backgroundView.removeConstraint($0) }
        imageView.constraints.forEach { imageView.removeConstraint($0) }
        titleLabel?.constraints.forEach { titleLabel?.removeConstraint($0) }
        subtitleLabel?.constraints.forEach { subtitleLabel?.removeConstraint($0) }
        stackView.constraints.forEach { stackView.removeConstraint($0) }
        
        var width = CGFloat(150)
        var height = CGFloat(150)
        if titleLabel != nil || subtitleLabel != nil {
            titleLabel?.sizeToFit()
            subtitleLabel?.sizeToFit()
            
            width += 50
            height += 30 + (titleLabel?.bounds.height ?? 0) + (subtitleLabel?.bounds.height ?? 0)
        }
        
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        backgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width - 30).isActive = true
        backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let yInset = (height - height / 2) / 2
        stackView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 15).isActive = true
        stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: yInset - 15).isActive = true
        stackView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -15).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.widthAnchor.constraint(equalToConstant: height / 2).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: height / 2).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel?.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        titleLabel?.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel?.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        subtitleLabel?.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        subtitleLabel?.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        layoutIfNeeded()
    }
    
    
    // MARK: - Presentation
    
    func show(_ animated: Bool = true, duration: TimeInterval? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            print("Can't show PopupView. Key window of application is nil")
            return
        }
        guard isShowen == false else {
            print("Show will be ignored. The PopupView already presented")
            return
        }
        
        if animated {
            backgroundView.alpha = 0
            backgroundView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            UIView.setAnimationCurve(.easeOut)
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.alpha = 1
                self.backgroundView.transform = .identity
            }) 
        } else {
            backgroundView.alpha = 1
            backgroundView.transform = .identity
        }
        
        if let duration = duration {
            presentationTime = duration
        }
        
        window.addSubview(self)
        startDismissTimer()
        isShowen = true
    }
    
    func dismiss(_ animated: Bool = true) {
        isShowen = false
        backgroundView.alpha = 1
        backgroundView.transform = .identity
        if animated {
            UIView.setAnimationCurve(.easeOut)
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.alpha = 0
                self.backgroundView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }) { completed in
                guard completed == true else  { return }
                self.removeFromSuperview()
                self.eventOnDismissed?(self)
            }
        } else {
            removeFromSuperview()
            eventOnDismissed?(self)
        }
    }
    
    private func startDismissTimer() {
        guard presentationTime > 0 else {
            print("PopupView requires manul dismissing")
            return
        }
        
        let timer = Timer(timeInterval: presentationTime, repeats: false) { timer in
            timer.invalidate()
            self.dismiss()
        }
        
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
}

