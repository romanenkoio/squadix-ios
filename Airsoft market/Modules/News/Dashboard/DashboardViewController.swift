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
    private var refreshControl = UIRefreshControl()
    
    var notifications: [DasboardNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(NotificationCell.self)
        tableView.setupDelegateData(self)
        title = "Уведомления"
        loadNotifications()
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func loadNotifications() {
        networkManager.getNotifications { [weak self] notifications in
            self?.notifications = notifications.content
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    @objc func refresh() {
        loadNotifications()
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

extension DashboardViewController: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return DashboardViewController.loadFromNib()
    }
    
    static func canHandle(_ deeplink: Deeplink) -> Bool {
        guard let url = deeplink.url, url.path.contains("/notifications") else { return false }
        return true
    }
    
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool {
        return true
    }
    
    func handle(_ deeplink: Deeplink) {
    }
}
