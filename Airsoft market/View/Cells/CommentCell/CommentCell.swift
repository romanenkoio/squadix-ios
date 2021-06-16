//
//  CommentCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 12.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentCell: BaseTableViewCell {
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var commentTextLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tapAvatarAction: VoidBlock?
    var reportAction: VoidBlock?
    var images: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(comment: Comment) {
        if let avatar = comment.authorAvatarURL {
            authorAvatar.loadImageWith(avatar)
        } else {
            authorAvatar.image = UIImage(named: "avatar_placeholder")
        }
        images = comment.images
        authorName.text = comment.authorName
        likeCountLabel.text = "\(comment.likeCount)"
        likeCountLabel.isHidden = comment.likeCount == 0
        commentTextLabel.text = comment.text
        timeLabel.text = comment.createdAt?.dateToHumanString()
        likeButton.setImage(UIImage(named: comment.isLiked ? "like_fill" : "like"), for: .normal)
        commentTextLabel.numberOfLines = 0
        commentTextLabel.enabledTypes = [.url]
        commentTextLabel.customize { label in
            label.handleURLTap { url in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        commentTextLabel.isHidden = comment.text.isEmpty
        collectionView.isHidden = true
        collectionView.dataSource = self
        collectionView.registerCell(ProductImageCell.self)
    }

    @IBAction func likeAction(_ sender: Any) {
        action?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorAvatar.image = UIImage(named: "avatar_placeholder")
    }
    
    @IBAction func tapAvatarAction(_ sender: Any) {
        tapAvatarAction?()
    }
    
    @IBAction func reportAction(_ sender: Any) {
        reportAction?()
    }
}


extension CommentCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.isHidden = images.count == 0
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath)
        if let imageCell = cell as? ProductImageCell {
            imageCell.setupImage(with: images[indexPath.row])
            return imageCell
        }
        return cell
    }
}

extension CommentCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
