//
//  MapUpdatable.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/9/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

protocol UpdateEventDelegate: AnyObject {
    func updateCoordinates(coord: String, coordType: Common.CoordinatesType)
}
