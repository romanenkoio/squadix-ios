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
    func sendComment(commentText: String, images: [UIImage])
    func attachFile()
}

final class CommentView: UIView {
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    weak var delegate: CommentViewDelegate?
    
    var postId = 0
    var postType: NewsType?
    
    var imageData: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
            checkSendAvalible()
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
//        stackView.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(ProductImageCell.self)
     }
    
    @IBAction func sendCommentAction(_ sender: Any) {
        guard let text = growingTextView.text else { return }
        spinner.startAnimating()
        delegate?.sendComment(commentText: text, images: imageData)
        sendCommentButton.isHidden = true
    }
    
    @IBAction func attachFileAction(_ sender: Any) {
        if imageData.count < 10 {
            delegate?.attachFile()
        }
    }
    
    func commentWilSend() {
        spinner.stopAnimating()
        growingTextView.text = ""
        sendCommentButton.isHidden = false
        imageData = []
    }
    
    func commentFailSend() {
        sendCommentButton.isHidden = true
        spinner.stopAnimating()
    }
    
    func checkSendAvalible()  {
        sendCommentButton.isEnabled = !growingTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || imageData.count > 0
    }
}

extension CommentView: GrowingTextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
        checkSendAvalible()
    }
}

extension CommentView: UICollectionViewDelegate {
    
}

extension CommentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.isHidden = imageData.count == 0
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath)
        if let imageCell = cell as? ProductImageCell {
            imageCell.productImageView.image = imageData[indexPath.row]
            return imageCell
        }
        return cell
    }
}

extension CommentView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
