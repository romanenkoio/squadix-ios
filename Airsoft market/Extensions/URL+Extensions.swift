//
//  URL+Extensions.swift
//  Squadix
//
//  Created by Illia Romanenko on 16.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
