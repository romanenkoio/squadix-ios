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
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tapAvatarAction: VoidBlock?
    var reportAction: VoidBlock?
    var openImageAction: VoidBlock?
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
        scrollView.isHidden = images.count == 0
        addImages()
    }

    @IBAction func likeAction(_ sender: Any) {
        action?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorAvatar.image = UIImage(named: "avatar_placeholder")
        for view in imagesStackView.subviews {
            view.removeFromSuperview()
        }
    }
    
    @IBAction func tapAvatarAction(_ sender: Any) {
        tapAvatarAction?()
    }
    
    @IBAction func reportAction(_ sender: Any) {
        reportAction?()
    }
    
    func addImages() {
        for image in images {
            let commentImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            commentImageView.loadImageWith(image)
            commentImageView.contentMode = .scaleAspectFill
            commentImageView.translatesAutoresizingMaskIntoConstraints = true
            commentImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            commentImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
            let tap = ImageTap(target: self, action: #selector(openImage))
            tap.imageUrl = image
            commentImageView.isUserInteractionEnabled = true
            commentImageView.addGestureRecognizer(tap)
            commentImageView.layer.cornerRadius = 5
            imagesStackView.addArrangedSubview(commentImageView)
        }
    }
    
    @objc func openImage(sender: ImageTap) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("The controller to presentation, to represent push in nil")
            return
        }
        let vc = FullPicturePage.loadFromNib()
        vc.url = sender.imageUrl
        appDelegate.currentViewController?.navigationController?.present(vc, animated: true)
    }
}

class ImageTap: UITapGestureRecognizer {
  var imageUrl: String = ""
}


