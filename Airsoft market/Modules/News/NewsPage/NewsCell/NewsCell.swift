//
//  swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya
import ActiveLabel

class NewsCell: BaseTableViewCell {
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var headerTitleLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var promoImage: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var videoIndicator: UIImageView!
    @IBOutlet weak var likeImage: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var imageCountView: UIView!
    @IBOutlet weak var imageCountLabel: UILabel!
    @IBOutlet weak var comentCountLabel: UILabel!
    @IBOutlet weak var acpectConstraint: NSLayoutConstraint!
    
    private let networkManager = NetworkManager()
    
    var currentPost: Post?
    var currentEvent: Event?
    var videoPicUrl = ""
    var likeAction: Cancellable? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorAvatar.makeRound()
    }
    
    func setLikeState(post: Post) {
        currentPost?.likesCount = post.likesCount
        currentPost?.isLiked = post.isLiked
        if let post = currentPost {
            setupNews(with: post)
        }
    }
    
    func setLikeState(event: Event) {
        currentEvent?.likesCount = event.likesCount
        currentEvent?.isLiked = event.isLiked
        if let event = currentEvent {
            setupEvent(with: event)
        }
    }
    
    func setupNews(with post: Post) {
        currentPost = post
        if let pic = post.authorAvatarURL {
            authorAvatar.loadImageWith(pic)
        } else {
            authorAvatar.image = UIImage(named: "avatar_placeholder")
        }
        comentCountLabel.text = "\(post.commentsCount)"
        headerTitleLabel.text = post.contentType == .image ? post.description : post.shortDescription
        likeCount.text = "\(post.likesCount)"
        likeImage.setImage(UIImage(named: post.isLiked ? "like_fill" : "like"), for: .normal)
        action = { [weak self] in
            if self?.likeAction != nil {
                print("LikaAction canceled")
                return
            }
            Analytics.trackEvent(post.isLiked ? "Post_liked" : "Post_unliked")
            self?.likeAction = self?.networkManager.toggleLike(postID: post.id, type: .feed, completion: { post in
                self?.generator.notificationOccurred(.success)
                self?.setLikeState(post: post)
                self?.likeAction = nil
            })
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let postDate = post.postDate,  let date = formatter.date(from: postDate) {
            createDate.text =  date.dateToHumanString()
        } else {
            createDate.text = ""
        }
        
        dateLabel.isHidden = true
        
        if let videoURL = post.videoUrl {
            videoPicUrl = "https://img.youtube.com/vi/\(videoURL)/hqdefault.jpg"
        }
        
        if post.contentType == .image, post.imageUrls.count == 0 {
            promoImage.isHidden = true
        } else {
            promoImage.isHidden = false
            promoImage.loadImageWith(post.contentType != .video ? post.imageUrls![0] : videoPicUrl)
        }
        
        imageCountView.isHidden = post.contentType == .video || post.imageUrls.count <= 1
        imageCountLabel.text = "\(post.imageUrls.count)+"
        videoIndicator.isHidden = post.contentType != .video
        authorName.text = post.authorName
    }
    
    func setupEvent(with event: Event) {
        currentEvent = event
        if let pic = event.authorAvatarURL {
            authorAvatar.loadImageWith(pic)
        } else {
            authorAvatar.image = UIImage(named: "avatar_placeholder")
        }
        comentCountLabel.text = "\(event.commentsCount)"
        headerTitleLabel.text = event.shortDescription
        dateLabel.text = event.eventDate.dateToHumanString()
        authorName.text = event.authorName
        createDate.text = event.eventDate == nil ? "" : event.createdAt.dateToHumanString()
        dateLabel.isHidden = false
        videoIndicator.isHidden = true
        promoImage.loadImageWith(event.imageUrls[0])
        likeCount.text = "\(event.likesCount)"
        likeImage.setImage(UIImage(named: event.isLiked ? "like_fill" : "like"), for: .normal)
        action = { [weak self] in
            if self?.likeAction != nil {
                print("LikeAction canceled")
                return
            }
            Analytics.trackEvent(event.isLiked ? "Post_liked" : "Post_unliked")
            self?.likeAction = self?.networkManager.toggleLike(postID: event.id, type: .event, completion: { event in
                let updatedEvent = Event()
                updatedEvent.likesCount = event.likesCount
                updatedEvent.isLiked = event.isLiked
                self?.generator.notificationOccurred(.success)
                self?.setLikeState(event: updatedEvent)
                self?.likeAction = nil
            })
        }
    }
    
    @IBAction func likeAction(_ sender: UIButton) {
        print("Like")
        action?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeCount.text = "0"
        likeImage.setImage(UIImage(named: "like"), for: .normal)
        authorAvatar.image = UIImage(named: "avatar_placeholder")
        promoImage.isHidden = false
        imageCountView.isHidden = true
        comentCountLabel.text = "0"
    }
}
