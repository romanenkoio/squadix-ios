//
//  CitySelectCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 14.05.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class CitySelectCell: BaseTableViewCell {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupWith(city: City) {
        guard let cityName = city.name, let region = city.region else { return }
        cityLabel.text = cityName
        regionLabel.text = region
    }
}
