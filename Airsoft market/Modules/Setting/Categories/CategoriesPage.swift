//
//  CategoriesPageViewController.swift
//  Squadix
//
//  Created by Illia Romanenko on 12.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class CategoriesPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(SimpleTextCell.self)
        loadCategories()
        title = "Категории"
    }
    
    func loadCategories() {
        networkManager.getCategories { categories in
            self.categories = categories.sorted(by: {$0 < $1})
        }
    }
}

extension CategoriesPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
        guard let categoryCell = cell as? SimpleTextCell else {
            return cell
        }
        
        categoryCell.simpleTextLabel.text = categories[indexPath.row]
        return categoryCell
    }
}

extension CategoriesPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let manager = NetworkManager()
        
        let remove = UIContextualAction(style: .destructive, title: "Удалить") { (action, sourceView, completionHandler) in
            let item = self.categories[indexPath.row]
        }
        remove.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Изменить") { (action, sourceView, completionHandler) in
            let item = self.categories[indexPath.row]
            
            let alert = UIAlertController(title: "", message: "Изменить категорию", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Новое название:"
            }
            
            alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
                guard let newName = alert?.textFields![0].text, !newName.isEmpty else {
                    return
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        edit.backgroundColor = .systemGreen
        let swipeAction = UISwipeActionsConfiguration(actions: [remove, edit])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
}
