//
//  NewsShowPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow
import Moya
import GrowingTextView

protocol LikeDelegate: class {
    func updateLike(inPost: Post?)
    func updateLike(inEvent: Event?)
}

enum NewsMenuPoint {
    case images
    case authorInfo
    case decription
    case source
    case like
    case comments

    
    static func getMenuForPost(post: Post) -> [[NewsMenuPoint]]  {
        var sectionWithImage: [NewsMenuPoint] = []
        let sectionWithoutImage : [NewsMenuPoint] = [ .authorInfo, .decription]
        let likeSection: [NewsMenuPoint] = [.like]
        let commentSection: [NewsMenuPoint] = [.comments]
        
        switch post.contentType {
        case .image:
            if post.imageUrls.count == 0 && post.previewImages.count == 0 {
                  return [sectionWithoutImage, likeSection]
            }
            sectionWithImage =  [ .authorInfo, .decription, .images]
            if post.isPreview {
                return [sectionWithImage]
            }
            return [sectionWithImage, likeSection, commentSection]
        case .video:
            sectionWithImage =  [ .authorInfo, .images, .decription]
            return [sectionWithImage, likeSection, commentSection]
        case .none:
            return []
        }
    }
}

class NewsShowPage: BaseViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    weak var delegate: UpdateFeedDelegate?
    weak var likeDelegate: LikeDelegate?
    var offset: CGPoint = CGPoint(x: 0, y: 0)
        
    var likeAction: Cancellable? = nil
    var menu: [[NewsMenuPoint]] = []
    
    var comments: [Comment] = [Comment(isTest: true), Comment(isTest: true), Comment(isTest: true), Comment(isTest: true), Comment(isTest: true)]
    var post: Post? {
          didSet {
              guard let post = post else { return }
              let menuInfo = NewsMenuPoint.getMenuForPost(post: post)
              menu = menuInfo
          }
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        tableView.registerCell(SimpleTextCell.self)
        tableView.registerCell(SlideShowCell.self)
        tableView.registerCell(AuthorCell.self)
        tableView.registerCell(LikeCell.self)
        tableView.registerCell(CommentCell.self)
        tableView.setupDelegateData(self)
        if let post = post, !post.isPreview {
            navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: moreButton)],
                                                   animated: true)
        }
        Analytics.trackEvent("Post_view_screen")
        
        growingTextView.layer.borderWidth = 1
        growingTextView.layer.borderColor = UIColor.lightGray.cgColor
        growingTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let id = post?.authorID else { return }
        if KeychainManager.isAdmin {
            moreButton.isHidden = false
        } else {
            moreButton.isHidden = KeychainManager.profileID != id
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Удалить пост", style: .destructive) { [weak self] _ in
            self?.showDestructiveAlert(handler: {
                self?.spinner.startAnimating()
                let service = NetworkManager()
                guard let post = self?.post else { return }
                service.deletePost(id: post.id, completion: {
                    self?.spinner.stopAnimating()
                    self?.delegate?.deleteFromFeed(id: post.id, type: .feed)
                    self?.navigationController?.popViewController(animated: true)
                }) { error in
                    self?.spinner.stopAnimating()
                    print("Error: \(error ?? "unknown")")
                }
            })
        })
        
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
        present(alert, animated: true)
    }
}

extension NewsShowPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewsShowPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menu[section].contains(.comments) {
            return comments.count
        }
        return menu[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SlideShowCell.self), for: indexPath)
        
        var type = NewsMenuPoint.decription
        if menu[indexPath.section].contains(.comments) {
            type = .comments
        } else {
            type = menu[indexPath.section][indexPath.row]
        }
        
        guard let post = post else { return cell }
        
        switch type {
        case .images:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SlideShowCell.self), for: indexPath)
            if let imageCell = cell as? SlideShowCell {
                switch post.contentType {
                case .image:
                    imageCell.imageSlideshow.setupView()
                    if post.isPreview {
                        imageCell.imageSlideshow.setupImagesWithImages(post.previewImages)
                    } else {
                        imageCell.imageSlideshow.setupImagesWithUrls(post.imageUrls!)
                    }
                    
                    imageCell.imageSlideshow.isHidden = false
                    imageCell.playerView.isHidden = true
                    imageCell.action = {
                        imageCell.imageSlideshow.presentFullScreenController(from: self)
                    }
                case .video:
                    imageCell.playerView.load(withVideoId: post.videoUrl!)
                    imageCell.imageSlideshow.isHidden = true
                    imageCell.playerView.isHidden = false
                case .none:
                    break
                }
              
                return imageCell
            }
        case .authorInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AuthorCell.self), for: indexPath)
            if let profileCell = cell as? AuthorCell {
                if !post.isPreview {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    if let postDate = post.postDate, let date = formatter.date(from: postDate) {
                        profileCell.postDateLabel.text = date.dateToHumanString()
                    }
                    profileCell.action = { [weak self] in
                        self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: post.authorID), animated: true)
                    }
                    if let pic = post.authorAvatarURL {
                        profileCell.profileAvatarImage.loadImageWith(pic)
                    }
                    profileCell.authorName.text = post.authorName
                } else {
                    guard let profileId = KeychainManager.profileID else { return cell }
                    networkManager.getUserById(id: profileId) { (profile, error) in
                        guard let profile = profile else { return }
                        profileCell.authorName.text = profile.profileName
                        profileCell.postDateLabel.text = Date().dateToHumanString()
                        if let pic = profile.profilePictureUrl {
                            profileCell.profileAvatarImage.loadImageWith(pic)
                        }
                    }
                }
            
                return profileCell
            }
        case .decription:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.selectionStyle = .none
                profileCell.simpleTextLabel.text = post.description
                return profileCell
            }
        case .source:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = true
                profileCell.simpleTextLabel.text = post.source
                return profileCell
            }
        case .comments:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentCell.self), for: indexPath)
            if let commentCell = cell as? CommentCell {
                commentCell.isUserInteractionEnabled = true
                commentCell.setupCell(comment: comments[indexPath.row])
                commentCell.action = { [weak self] in
                    guard let comment = self?.comments[indexPath.row] else { return }
                    comment.isLiked = !comment.isLiked
                    
                    comment.likeCount = comment.isLiked ? comment.likeCount + 1 : comment.likeCount - 1
                    self?.comments[indexPath.row] = comment
                    let indexPath = IndexPath(item: indexPath.row, section: indexPath.section)
                    tableView.reloadRows(at: [indexPath], with: .none)
//                   лайкнуть пост
                }
                
                commentCell.tapAvatarAction = { [weak self] in
                    guard let comment = self?.comments[indexPath.row] else { return }
                    self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: comment.userID), animated: true)
                }
                
                commentCell.reportAction = { [weak self] in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Пожаловаться", style: .destructive, handler: { _ in
                        self?.showDestructiveAlert(handler: {
                            //                           отправить репорт
                        })
                    }))
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
                    
                    self?.present(alert, animated: true)
                }
                return commentCell
            }
        case .like:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LikeCell.self), for: indexPath)
            if let profileCell = cell as? LikeCell {
                profileCell.likeImage.setImage(UIImage(named: post.isLiked ? "like_fill" : "like"), for: .normal)
                profileCell.likeCount.text = "\(post.likesCount)"
                profileCell.action = { [weak self] in
                    if self?.likeAction != nil {
                        print("LikeAction canceled")
                        return
                    }
                    Analytics.trackEvent(post.isLiked ? "Post_liked" : "Post_unliked")
                    self?.likeAction = self?.networkManager.toggleLike(postID: post.id, type: .feed, completion: { post in
                        self?.post?.likesCount = post.likesCount
                        self?.post?.isLiked = post.isLiked
                        self?.generator.notificationOccurred(.success)
                        self?.tableView.reloadData()
                        self?.likeDelegate?.updateLike(inPost: self?.post)
                        self?.likeAction = nil
                    })
                }
                profileCell.selectionStyle = .none
                return profileCell
            }
        }
        return cell
    }
}

extension NewsShowPage: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
    
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
}

