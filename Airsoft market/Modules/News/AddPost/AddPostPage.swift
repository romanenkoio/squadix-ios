//
//  AddPostPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/20/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class AddPostPage: BaseViewController {

    @IBOutlet weak var linkTextField: StrikeInputField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var headerTextField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var previewButton: WhiteButton!
    @IBOutlet weak var postButton: OliveButton!
    
    var isEdit = false
    var post: Post? {
        didSet {
            isEdit = true
        }
    }
    weak var delegate: UpdateFeedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
        configureUI()
    }
    
    func configureUI() {
        title = "Новый пост"
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        previewButton.isEnabled = false
        postButton.isEnabled = false
        
        if isEdit {
            guard let videoUrl = post?.videoUrl, let postDescritption = post?.description, let postTitile = post?.shortDescription else { return }
            title = "Редактирование"
            linkTextField.text = "https://www.youtube.com/watch?v=\(videoUrl)"
            previewImageView.loadImageWith("https://img.youtube.com/vi/\(videoUrl)/hqdefault.jpg")
            descriptionTextView.text = postDescritption
            headerTextField.text = postTitile
            previewButton.isEnabled = true
            postButton.isEnabled = false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let videoID = text.matches(for: Validator.Regexp.youtube.rawValue), videoID != "" else {
            headerTextField.text = ""
            descriptionTextView.text = ""
            previewImageView.image = UIImage(named: "placeholder")
            previewButton.isEnabled = false
            postButton.isEnabled = false
            return
        }
        
        spinner.startAnimating()
        let manager = NetworkManager()
        manager.getYoutubeInfo(id: videoID, completion: { [weak self] info in
            self?.headerTextField.text = info?.items[0].snippet.title
            self?.descriptionTextView.text = info?.items[0].snippet.snippetDescription
            let videoPicUrl = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
            self?.previewImageView.loadImageWith(videoPicUrl)
            self?.spinner.stopAnimating()
            self?.previewButton.isEnabled = true
            self?.postButton.isEnabled = true
        }, failure: { [weak self] _ in
            print("Get youtube info error")
            self?.spinner.stopAnimating()
        })
    }
    
    @IBAction func pasteFromPasteBoard(_ sender: Any) {
        guard let paste = UIPasteboard.general.string else { return }
        linkTextField.text = paste
        textFieldDidChange(linkTextField)
    }
    
    @IBAction func previewAction(_ sender: Any) {
        guard let post = buildPost() else { return }
        navigationController?.pushViewController(VCFabric.getNewsShowPage(post: post), animated: true)
    }
    
    @IBAction func postAction(_ sender: Any) {
        guard let post = buildPost() else { return }
        postButton.isEnabled = false
        spinner.startAnimating()
        
        let manager = NetworkManager()
        if isEdit {
            manager.editPost(post: post, { [weak self] in
                self?.spinner.stopAnimating()
                PopupView(title: "Опубликовано!", image:  UIImage(named: "confirm")).show()
                self?.isEditing = false
                self?.delegate?.updateFeed(type: .feed)
                self?.navigationController?.popToRootViewController(animated: true)
                self?.spinner.stopAnimating()
            }) {  [weak self] _ in
                self?.postButton.isEnabled = true
                PopupView(title: "Не удалось обновить пост", image:  UIImage(named: "cancel")).show()
                self?.spinner.stopAnimating()
            }
        } else {
            manager.postVideo(post: post, completion: { [weak self] in
                self?.spinner.stopAnimating()
                PopupView(title: "Опубликовано!", image:  UIImage(named: "confirm")).show()
                self?.isEditing = false
                self?.delegate?.updateFeed(type: .feed)
                self?.navigationController?.popViewController(animated: true)
            }) { [weak self] _ in
                self?.postButton.isEnabled = true
                self?.spinner.stopAnimating()
                PopupView(title: "Не удалось опубликовтаь пост", image:  UIImage(named: "cancel")).show()
            }
        }
    }
    
    func buildPost() -> Post? {
        let newPost = Post()
        guard let id = KeychainManager.profileID, let title = headerTextField.text, let description = descriptionTextView.text, let link = linkTextField.text else { return nil }
        
        guard let parsedLink = link.matches(for: Validator.Regexp.youtube.rawValue) else { return nil}
        if isEdit {
            guard let post = post else { return nil }
            newPost.id = post.id
        }
        newPost.videoUrl = parsedLink
        newPost.authorID = id
        newPost.contentType = .video
        newPost.description = description
        newPost.shortDescription = title
        
        return newPost
    }
}

