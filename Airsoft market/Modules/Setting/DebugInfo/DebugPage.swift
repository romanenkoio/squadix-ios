//
//  DebugPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/12/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

enum DebugSetting: String, CaseIterable {
    case accessToken
    case pushToken
    case profileID
    case osVersion
    case device
    
    static func getPoints() -> [DebugSetting] {
        return DebugSetting.allCases
    }
}

class DebugPage: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let menu = DebugSetting.getPoints()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(DebugCell.self)
        tableView.setupDelegateData(self)
    }
}

extension DebugPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DebugCell.self), for: indexPath)
        guard let debugCell = cell as? DebugCell else { return cell }
        
        let type = menu[indexPath.row]
        
        switch type {
        case .accessToken:
            debugCell.titileLabel.text = type.rawValue
            debugCell.infoLabel.text = KeychainManager.accessToken != nil ? KeychainManager.accessToken : "Нет данных"
            debugCell.action = {
                guard let token = KeychainManager.accessToken else { return }
                UIPasteboard.general.string = token
                PopupView(title: "Скопировано", subtitle: nil, image: UIImage(named: "confirm")).show()
            }
            return debugCell
        case .profileID:
            if let profileID = KeychainManager.profileID {
                debugCell.infoLabel.text = "\(profileID)"
                debugCell.action = {
                    UIPasteboard.general.string = "\(profileID)"
                    PopupView(title: "Скопировано", subtitle: nil, image: UIImage(named: "confirm")).show()
                }
            } else {
                debugCell.infoLabel.text = "Нет данных"
            }
            debugCell.titileLabel.text = type.rawValue
            return debugCell
        case .osVersion:
            debugCell.titileLabel.text = type.rawValue
            debugCell.infoLabel.text = UIDevice.current.systemVersion
            debugCell.action = {
                UIPasteboard.general.string = UIDevice.current.systemVersion
                PopupView(title: "Скопировано", subtitle: nil, image: UIImage(named: "confirm")).show()
            }
            return debugCell
        case .device:
            debugCell.titileLabel.text = type.rawValue
            debugCell.infoLabel.text = UIDevice.current.type.rawValue
            debugCell.action = {
                UIPasteboard.general.string = UIDevice.current.type.rawValue
                PopupView(title: "Скопировано", subtitle: nil, image: UIImage(named: "confirm")).show()
            }
            return debugCell
        case .pushToken:
            debugCell.titileLabel.text = type.rawValue
            debugCell.infoLabel.text = KeychainManager.pushToken != nil ? KeychainManager.pushToken : "Нет данных"
            debugCell.action = {
                UIPasteboard.general.string = KeychainManager.pushToken != nil ? KeychainManager.pushToken : "Нет данных"
                PopupView(title: "Скопировано", subtitle: nil, image: UIImage(named: "confirm")).show()
            }
            return debugCell
        }
    }
}

extension DebugPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
