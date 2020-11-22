//
//  SearchPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class SearchPage: BaseViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    
    let manager = NetworkManager()
    var usersData: [Profile] = []
    var searchData: [Profile] = []
    var isSearchInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        title = "Поиск"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск... "
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.backgroundColor = .white
        }
        
        tableView.registerCell(ProfileSearchCell.self)
        tableView.setupDelegateData(self)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        loadUsers()
    }
    
    func loadUsers(searchInProgress: Bool = false) {
        manager.getAllUsers(completion: { users in
            self.usersData = users.sorted(by: { $0.profileName < $1.profileName }).filter({$0.id != KeychainManager.profileID})
            self.tableView.reloadData()
        }) { error in
            print(error)
        }
    }
    
    @objc func refresh() {
        refreshControl.endRefreshing()
        isSearchInProgress = false
        loadUsers()
        searchController.searchBar.text = ""
    }
}

extension SearchPage: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchData.removeAll()
            isSearchInProgress = true
            for item in usersData {
                if item.profileName.lowercased().contains(find: searchText.lowercased()) {
                    searchData.append(item)
                }
            }
            tableView.reloadData()
        } else if let text = searchController.searchBar.text, text.isEmpty {
            isSearchInProgress = false
            loadUsers()
        }
    }
}

extension SearchPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearchInProgress {
            navigationController?.pushViewController(VCFabric.getProfilePage(for: searchData[indexPath.row].id), animated: true)
        } else {
            navigationController?.pushViewController(VCFabric.getProfilePage(for: usersData[indexPath.row].id), animated: true)
        }
    }
}

extension SearchPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchInProgress ? searchData.count : usersData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSearchCell.self), for: indexPath)
        
        if let profileCell = cell as? ProfileSearchCell {
            let item = isSearchInProgress ? searchData[indexPath.row] : usersData[indexPath.row]
            if let pic = item.profilePictureUrl {
                 profileCell.profileAvatar.loadImageWith(pic)
            } else {
                profileCell.profileAvatar.image = UIImage(named: "avatar_placeholder")
            }
            profileCell.adminLabel.isHidden = !item.roles.contains(.admin)
            profileCell.adminLabel.text = item.roles.contains(.admin) ? Common.Roles.admin.displayRoleName : ""
            profileCell.profileNameLabel.text = item.profileName
            var reg = ""
            
            if let region = item.country {
                reg = region
            }
            
            if let city = item.city {
                reg += ", \(city)"
            }
            
            profileCell.profileRegionLabel.text = reg
            return profileCell
        }
        return cell
    }
}
