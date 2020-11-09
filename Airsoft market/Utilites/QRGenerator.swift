//
//  QRGenerator.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 10/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

class QRGenerator {
    static let shared = QRGenerator()
    
    func generate(with text: String) -> UIImage? {
        let data = text.data(using: String.Encoding.utf8)

          if let filter = CIFilter(name: "CIQRCodeGenerator") {
              filter.setValue(data, forKey: "inputMessage")
              let transform = CGAffineTransform(scaleX: 5, y: 5)

              if let output = filter.outputImage?.transformed(by: transform) {
                  return UIImage(ciImage: output)
              }
          }

          return nil
    }
}
