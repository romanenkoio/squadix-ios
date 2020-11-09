//
//  YoutobeInfo.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 9/14/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

struct YoutubeInfo: Codable {
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let snippet: Snippet
}

// MARK: - Snippet
struct Snippet: Codable {
    let title, snippetDescription: String

    enum CodingKeys: String, CodingKey {
        case title
        case snippetDescription = "description"
    }
}
