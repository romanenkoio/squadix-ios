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
    
    var notifications: [DasboardNotification] = [DasboardNotification(type: .aprooved), DasboardNotification(type: .decline), DasboardNotification(type: .like), DasboardNotification(type: .system)]
    
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
        notificationCell.setupView(notification: notifications[indexPath.row])
        return notificationCell
    }
}


class DasboardNotification {
    var message: String!
    var profileId: Int?
    var time: String!
    var url: String?
    var type: NotificationType!
    
    init(type: NotificationType) {
        switch type {
        case .aprooved:
            message = "Ваше объявление \"Электро глок\" опубликовано"
        case .decline:
            message = "Ваше объявление \"Страйкбольные гранаты\" отклонено."
        case .like:
            message = "Пользователь Михаил Кляшев поставил лайк вашему посту \"Лучшие гей-клубы города\""
        case .system:
            message = "Узнайте всё про последние обновления!"
        }
        
        time = Date().dateToHumanString()
        self.type = type
        profileId = 1
    }
    
    enum NotificationType {
        case like
        case aprooved
        case decline
        case system
    }
}

