//
//  CommentView.swift
//  Squadix
//
//  Created by Illia Romanenko on 25.05.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import GrowingTextView
import Photos

protocol CommentViewDelegate: AnyObject {
    func sendComment(commentText: String)
    func attachFile()
}

final class CommentView: UIView {
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: CommentViewDelegate?
    var imageData: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
     
     private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: CommentView.self), owner: self, options: nil)
        growingTextView.delegate = self
        growingTextView.layer.borderWidth = 1
        growingTextView.layer.cornerRadius = 5
        growingTextView.layer.borderColor = UIColor.lightGray.cgColor
        sendCommentButton.isEnabled = false
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.isHidden = true
        stackView.isHidden = true
     }
    
    @IBAction func sendCommentAction(_ sender: Any) {
        guard let text = growingTextView.text else { return }
        delegate?.sendComment(commentText: text)
        growingTextView.text = ""
    }
    
    @IBAction func attachFileAction(_ sender: Any) {
        if imageData.count < 10 {
            delegate?.attachFile()
        }
    }
    
    func updateAttachments(image: UIImage) {
        
    }
}

extension CommentView: GrowingTextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
        sendCommentButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
