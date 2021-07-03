//
//  NetworkMonitor.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Network
import UIKit

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    func startListner() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                print("[NETWORK] WiFi")
            } else if path.usesInterfaceType(.cellular) {
                print("[NETWORK] 3G/4G")
            } else {
                print("[NETWORK] No connection")
                DispatchQueue.main.async {
                   PopupView(title: "", subtitle: "Нет сети", image: UIImage(named: "cancel")).show()
                }
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
