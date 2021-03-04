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
        placeholder: UIImage(named: "placeholder"),
        options: [.scaleFactor(UIScreen.main.scale)])
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let resizedImage = self.resizeImage(), let imageData = resizedImage.jpegData(compressionQuality: CGFloat(0.9))
            else { return nil }
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
    
    func resizeImage(targetSize: CGSize = CGSize(width: 700, height: 700)) -> UIImage? {
       let size = self.size

       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height

   
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }

       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       self.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
   }
}








