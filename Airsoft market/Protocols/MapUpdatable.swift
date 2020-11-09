//
//  MapUpdatable.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/9/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

protocol UpdateEventDelegate: class {
    func updateCoordinates(coord: String, coordType: CoordinatesType)
}
