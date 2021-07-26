//
//  PeopleSearchPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 7.07.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya

class PeopleSearchPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    var usersData: [Profile] = []
    var totalUserPages = 0
    var userRequest: Cancellable?
    var querry: String? {
        didSet {
            page = 0
        }
    }
    var isTeamSearch = false
    var selectUser: UserBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(ProfileSearchCell.self)
        tableView.setupDelegateData(self)
      
        tableView.addSubview(refreshControl)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        page = 0
        guard !isTeamSearch else {
            navigationItem.searchController = nil
            return
        }
        loadUsers(page: page)
    }

    @objc func refresh() {
        guard !isTeamSearch else {
            return
        }
        refreshControl.endRefreshing()
        page = 0
        loadUsers(page: page, querry: querry)
    }
    
    func loadUsers(page: Int? = nil, querry: String? = nil) {
        if userRequest != nil {
            userRequest?.cancel()
            userRequest = nil
        }
        
        if page == 0 {
            usersData = []
            tableView.reloadData()
            spinner.stopAnimating()
        }
        
        spinner.startAnimating()
        userRequest = networkManager.getAllUsers(page: page, querry: querry, completion: { [weak self] users in
            guard let sSelf = self else { return }
            if KeychainManager.isAdmin {
                sSelf.title = "Пользователей: \(users.totalElements ?? 0)"
            }
            sSelf.spinner.stopAnimating()
            sSelf.totalUserPages = users.totalPages
            
            if users.content.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in users.content {
                    sSelf.usersData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.usersData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .none)
                sSelf.tableView.endUpdates()
                sSelf.userRequest = nil
                sSelf.page += 1
            } else {
                sSelf.userRequest = nil
                print(" [NETWORK] Загружены все пользователи")
            }
            sSelf.spinner.stopAnimating()
        }) { error in
            print(error)
            self.spinner.stopAnimating()
        }
    }
}



extension PeopleSearchPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectUser == nil {
            navigationController?.pushViewController(VCFabric.getProfilePage(for: usersData[indexPath.row].id), animated: true)
        } else {
           let user = usersData[indexPath.row]
            guard user.teamName == "" else {
                showPopup(isError: true, title: "Пользователь уже состоит в комнаде.")
                return }
            guard let name = user.profileName else { return }
            let alert = UIAlertController(title: "", message: "Вы действительно хотите добавить \(name)", preferredStyle: .alert)
            
            let accept = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
                self?.selectUser?(user)
                self?.navigationController?.popViewController(animated: true)
            }
           
            let decline = UIAlertAction(title: "Отмена", style: .destructive)
        
            alert.addAction(decline)
            alert.addAction(accept)
            present(alert, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 300)) {
            guard !isTeamSearch else {
                return
            }
            loadUsers(page: page)
        }
    }
}

extension PeopleSearchPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSearchCell.self), for: indexPath)
        
        if let profileCell = cell as? ProfileSearchCell {
            let item = usersData[indexPath.row]
            profileCell.setupCell(profile: item)

            return profileCell
        }
        return cell
    }
}
