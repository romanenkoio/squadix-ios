//
//  ImageSlideShow+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ImageSlideshow
import UIKit

extension ImageSlideshow {
    func setupImagesWithUrls(_ urls: [String]) {
        var slides: [KingfisherSource] = []
        for item in urls {
            slides.append(KingfisherSource(urlString: item)!)
        }
        self.setImageInputs(slides)
    }
    
    func setupImagesWithImages(_ images: [UIImage]) {
         var slides: [ImageSource] = []
         for item in images {
             slides.append(ImageSource(image: item))
         }
         self.setImageInputs(slides)
     }
    
    func setupView() {
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.mainStrikeColor
        pageIndicator.pageIndicatorTintColor = UIColor.black
        self.zoomEnabled = true
        self.contentScaleMode = .scaleAspectFill
        self.pageIndicator = pageIndicator
        self.activityIndicator = DefaultActivityIndicator()
        self.circular = false
    }
}
