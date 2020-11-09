//
//  CollectionView+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func registerCell(_ cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass.self), bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass.self))
    }
    
    func setupDelegateData(_ controller: UIViewController) {
        self.delegate = controller as? UICollectionViewDelegate
        self.dataSource = controller as? UICollectionViewDataSource
    }
}
