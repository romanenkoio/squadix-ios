//
//  GalleryCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 30.06.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    @IBOutlet weak var galeryImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageUrl: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(with image: String) {
        guard let url = URL(string: image) else { return }
        spinner.startAnimating()
        galeryImageView.sd_setImage(with: url) { [weak self] _, _, _, _ in
            self?.spinner.stopAnimating()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openFullScrren))
        galeryImageView.addGestureRecognizer(tap)
        
    }
    
    @objc func openFullScrren() {
        let vc = FullPicturePage.loadFromNib()
        vc.currentImage = imageUrl
        navigationController()?.pushViewController(vc, animated: true)
    }

}
