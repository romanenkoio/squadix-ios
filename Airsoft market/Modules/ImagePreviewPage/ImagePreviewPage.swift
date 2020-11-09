//
//  ImagePreviewPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 9/3/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ImagePreviewPage: BaseViewController {
    @IBOutlet weak var imagePreview: UIImageView!
    var imageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreview.loadImageWith(imageUrl)
        view.backgroundColor = .clear
    }
}
