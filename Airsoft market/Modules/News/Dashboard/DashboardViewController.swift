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
    
    var notifications: [Notifications] = [Notifications(), Notifications(), Notifications()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(NotificationCell.self)
        tableView.setupDelegateData(self)
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
        notificationCell.setupView(notification: Notifications())
        return notificationCell
    }
}


class Notifications {
    var message: String!
    var pictureUrl: String?
    var profileId: Int?
    var time: String!
    var postUrl: String?
    var type: NotificationType!
    
    init() {
        message = "Пользователь Михаил Кляшев поставил лайк вашему посту \"Лучшие гей-клубы города\""
        time = Date().dateToHumanString()
        type = .like
    }
    
    enum NotificationType {
        case like
        case aprooved
        case decline
        case systemNews
    }
}

