//
//  FullPicturePage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class FullPicturePage: UIViewController {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var fullImage: UIImageView!
    
    var currentImageIndex = 0
    var images: [String] = []
    var currenImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullImage.loadImageWith(currenImage)
        let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right, .up, .down]
        fullImage.isUserInteractionEnabled = true
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
            swipe.direction = direction
            fullImage.addGestureRecognizer(swipe)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @objc func swipeAction(sender: UISwipeGestureRecognizer) {
        guard let index = images.firstIndex(of: currenImage) else { return }
        
        switch sender.direction {
        case .left:
            guard index + 1 <= images.count - 1 else { return }
            fullImage.loadImageWith(images[index + 1])
            currenImage = images[index + 1]
        case .right:
            guard index - 1 >= 0 else { return }
            fullImage.loadImageWith(images[index - 1])
            currenImage = images[index - 1]
        case .up, .down:
            self.dismiss(animated: true, completion: nil)
        default:
            print("Undefined")
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}





