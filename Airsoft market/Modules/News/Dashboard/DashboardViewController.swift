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
            self?.notifications = notifications.content
            self?.tableView.reloadData()
        }
    }
}

extension DashboardViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let manager = NetworkManager()
//
//        let accept = UIContextualAction(style: .normal, title: "Опубликовать") { (action, sourceView, completionHandler) in
//            let item = self.marketData[indexPath.row]
//            manager.updateProductStatus(productID: item.postID, status: ProductStatus.active, completion: { [weak self] _ in
//                self?.marketData.remove(at: indexPath.row)
//                self?.tableView.reloadData()
//            }) { error in
//                print(error)
//            }
//        }
//        accept.backgroundColor = .systemGreen
//
//        let decline = UIContextualAction(style: .destructive, title: "Отклонить") { (action, sourceView, completionHandler) in
//            let item = self.marketData[indexPath.row]
//
//
//            let alert = UIAlertController(title: "", message: "Причина отклонения", preferredStyle: .alert)
//
//            alert.addTextField { (textField) in
//                textField.placeholder = "Причина:"
//            }
//
//            alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
//
//            alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
//                guard let reason = alert?.textFields![0].text, !reason.isEmpty else {
//                    return
//                }
//
//                manager.updateProductStatus(productID: item.postID, status: ProductStatus.deleted, reason: reason, completion: { [weak self] _ in
//                    self?.marketData.remove(at: indexPath.row)
//                    self?.tableView.reloadData()
//                }) { error in
//                    print(error)
//                }
//
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//        }
//
//        let swipeAction = UISwipeActionsConfiguration(actions: [decline, accept])
//        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//        return swipeAction
//    }
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

