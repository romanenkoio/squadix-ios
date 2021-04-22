//
//  WeaterPopup.swift
//  Squadix
//
//  Created by Illia Romanenko on 20.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class WeaterPopup: BaseViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var skyStatusLabel: UILabel!
    
    var weather: DailyWeather?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let weather = weather else { return }
        setupWith(weather)
        
    }
    
    func setupWith(_ weather: DailyWeather)  {
        guard let minTemp = weather.temp.minTemp, let maxTemp = weather.temp.maxTemp, let windSpeed = weather.windSpeed, let cloud = weather.cloud, let description = weather.weather.first?.weatherDescription else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        timeLabel.text = "Температура: \(Int(minTemp))-\(Int(maxTemp)) °C"
        windSpeedLabel.text = "Скорость ветра: \(windSpeed) м/с"
        cloudLabel.text = "Облачность: \(cloud)%"
        skyStatusLabel.text = "Погода: \(description)"
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
