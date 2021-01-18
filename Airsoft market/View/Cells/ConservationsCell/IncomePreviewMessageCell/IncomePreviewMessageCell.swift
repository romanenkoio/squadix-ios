//
//  IncomePreviewMessageCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 18.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import ActiveLabel
import ImageSlideshow

class IncomePreviewMessageCell: BaseTableViewCell {
    @IBOutlet weak var previewNameLabel: UILabel!
    @IBOutlet weak var messageLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slider: ImageSlideshow!
    
    
    var url: URL?
    
    let service = NetworkManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 15
        dateLabel.text = Date().dateToHumanString()
        slider.roundedTopCornerImage()
        
        messageLabel.handleURLTap { url in
            let type = Deeplink.DeeplinkType.checkLinkType(url: url)
            
            switch type {
            case .event, .post, .product:
                Deeplink.Handler.shared.handle(deeplink: Deeplink(url: url))
            case .unknow:
                UIApplication.shared.open(url)
            }
        }
        
        slider.setupView()
    }
    
    func getPreview() {
        guard let url = url, let postID = url.path.matches(for: "[0-9]+").first, let id = Int(postID) else { return }
        let type = Deeplink.DeeplinkType.checkLinkType(url: url)
        
        switch type {
        case .event:
            service.getEventByID(postID: id) { [weak self] event in
                self?.slider.setupImagesWithUrls(event.imageUrls)
                if let description = event.shortDescription {
                    self?.previewNameLabel.text = "\(description)"
                }
            }
        case .post:
            service.getPostByID(postID: id) { [weak self] post in
                switch post.contentType {
                case .image:
                    self?.slider.setupImagesWithUrls(post.imageUrls)
                case .video:
                    if let videoURL = post.videoUrl {
                        self?.slider.setupImagesWithUrls(["https://img.youtube.com/vi/\(videoURL)/hqdefault.jpg"])
                    }
                case .none:
                    print("None")
                }
                self?.previewNameLabel.text = "\(post.shortDescription)"
            }
        case .product:
            service.getProductByID(postID: id) { [weak self] product in
                self?.slider.setupImagesWithUrls(product.picturesUrl)
                self?.previewNameLabel.text = "\(product.description ?? "")"
            }
        case .unknow:
            print("Пися")
        }
    }
}
