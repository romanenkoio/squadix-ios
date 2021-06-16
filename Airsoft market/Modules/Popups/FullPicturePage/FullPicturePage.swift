//
//  FullPicturePage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class FullPicturePage: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var mainView: UIView!
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.loadImageWith(url)
        imageView.contentMode = .scaleAspectFit
        let tap = UIGestureRecognizer(target: self, action: #selector(didTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func didTap() {
        self.dismiss(animated: true)
    }
}

