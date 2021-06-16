//
//  Updatable.swift
//  Squadix
//
//  Created by Illia Romanenko on 4.02.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation

protocol Updatable: AnyObject {
    func update()
}

protocol Commentable {
    func getComment()
    func likeComment(commentID: Int)
    func deleteComment(commentID: Int)
}

protocol PaginableObject {
    var totalElements: Int {get set}
    var totalPages: Int {get set}
}
