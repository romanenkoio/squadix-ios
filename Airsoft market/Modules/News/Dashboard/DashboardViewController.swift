//
//  DashboardViewController.swift
//  Squadix
//
//  Created by Illia Romanenko on 5.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class DashboardViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var notifications: [DasboardNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(NotificationCell.self)
        tableView.setupDelegateData(self)
        title = "Уведомления"
        loadNotifications()
    }
    
    func loadNotifications() {
        networkManager.getNotifications { [weak self] notifications in
            self?.notifications = notifications
            self?.tableView.reloadData()
        }
    }
}

extension DashboardViewController: UITableViewDelegate {
    
}

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationCell.self), for: indexPath)
        guard let notificationCell = cell as? NotificationCell else {
            return cell
        }
        notificationCell.setupView(notification: notifications[indexPath.row])
        return notificationCell
    }
}

