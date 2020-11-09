//
//  UIImageView.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func loadImageWith(_ url: String) {
        guard let newUrlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        self.kf.setImage(with: URL(string: newUrlStr),
        placeholder: UIImage(named: "placeholder"))
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.2) else { return nil }
        return imageData.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func loadFromURL(from imageUrl:  String, completition: @escaping (UIImage) -> Void, failure: @escaping (String) -> Void) {
        guard let url = URL(string: imageUrl) else {
            failure("[IMAGE] Create image url failure")
            return
        }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                failure("[IMAGE] Download data failure")
                return
            }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    failure("[IMAGE] Create image failure")
                    return
                }
                completition(image)
            }
        }
    }
}








