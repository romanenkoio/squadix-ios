//
//  FullPicturePage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class FullPicturePage: BaseViewController {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var fullImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    var currentImageIndex = 0
    var images: [String] = []
    var currentImage = ""
    let screenSize = UIScreen.main.bounds
    let pageSpacing: CGFloat = 20
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideTabBar()
    }
    
    @objc func closeSwipeAction(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up, .down:
            self.dismiss(animated: true, completion: nil)
        default:
            print("Undefined")
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideTabBar() {
        guard let appDelegate = getAppDelegate(), let rootVC = appDelegate.window?.rootViewController, let tabBarVC = rootVC as? BaseTabBarViewController else { return }
        
        if tabBarVC.tabBar.isHidden {
            tabBarVC.tabBar.isHidden = false
        } else {
            tabBarVC.tabBar.isHidden = true
        }
    }
    
    func setCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width + pageSpacing, height: view.frame.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionViewFrame = CGRect(x: 0, y: 0, width: view.frame.width + pageSpacing, height: view.frame.height)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        
        view.insertSubview(collectionView, belowSubview: closeButton)
        
        collectionView.registerCell(FullPictureCell.self)
        collectionView.setupDelegateData(self)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0), at: .centeredVertically, animated: false)
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down]
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipeAction))
            swipe.direction = direction
            collectionView.addGestureRecognizer(swipe)
        }
    }
}

extension FullPicturePage: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FullPictureCell.self), for: indexPath)
        guard let fullPictureCell = cell as? FullPictureCell else {return cell}
        fullPictureCell.pictureURL = images[indexPath.row]
        return fullPictureCell
    }
}
