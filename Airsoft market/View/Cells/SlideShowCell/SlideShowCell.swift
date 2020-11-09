//
//  SlideShowCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow
import YoutubePlayer_in_WKWebView

class SlideShowCell: BaseTableViewCell {
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var slideShowHeight: NSLayoutConstraint!
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var slideHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageSlideshow.addGestureRecognizer(gestureRecognizer)
    }

    @objc func didTap() {
        action?()
    }
}
