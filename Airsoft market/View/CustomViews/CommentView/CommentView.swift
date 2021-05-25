//
//  CommentView.swift
//  Squadix
//
//  Created by Illia Romanenko on 25.05.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import GrowingTextView

protocol CommentViewDelegate: AnyObject {
    func sendComment(commentText: String)
}

class CommentView: UIView {
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: CommentViewDelegate?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
     
     func commonInit() {
        Bundle.main.loadNibNamed(String(describing: CommentView.self), owner: self, options: nil)
        growingTextView.delegate = self
        growingTextView.layer.borderWidth = 1
        growingTextView.layer.borderColor = UIColor.lightGray.cgColor
        sendCommentButton.isEnabled = false
     }
    
    @IBAction func sendCommentAction(_ sender: Any) {
        guard let text = growingTextView.text else { return }
        delegate?.sendComment(commentText: text)
    }
}

extension CommentView: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendCommentButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
