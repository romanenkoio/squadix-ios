//
//  String+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/25/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

extension String {
    
    func base64ToImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }
        return image
    }
    
    func parseContactString() -> (method: String?, contact: String?) {
        
        guard let index = self.index(of: ":") else  { return (nil, nil)}
        var method = String(self[..<index])
        let contact = String(self[self.index(index, offsetBy: 1)...])
        if method == "Phone" {
            method = "Телефон"
        }
        return (method, contact)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }

    func getCoordinates() -> CLLocationCoordinate2D? {
        let clearString = self.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        var lat = clearString.components(separatedBy: ",")[0]
        var long = clearString.components(separatedBy: ",")[1]
        
        lat = lat.replacingOccurrences(of: ",", with: ".", options: .regularExpression)
        long = long.replacingOccurrences(of: ",", with: ".", options: .regularExpression)
        
        if let latitude =  Double(lat), let longitude = Double(long) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map { String(self[Range($0.range, in: self)!]) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}


