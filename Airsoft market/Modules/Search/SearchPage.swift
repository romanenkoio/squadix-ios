//
//  SearchPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya

class SearchPage: BaseViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let manager = NetworkManager()
    var usersData: [Profile] = []
    var searchData: [Profile] = []
    var isSearchInProgress = false
    var totalUserPages = 0
    var userRequest: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        Analytics.trackEvent("User_search_screen")
        page = 0
        loadUsers(page: page)
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
    }
    
    func loadUsers(searchInProgress: Bool = false, page: Int? = nil) {
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
        userRequest = manager.getAllUsers(page: page, completion: { [weak self] users in
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            sSelf.totalUserPages = users.totalPages
            
            if users.content.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in users.content {
                    sSelf.usersData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.usersData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .automatic)
                sSelf.tableView.endUpdates()
                sSelf.tableView.reloadData()
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
    
    @objc func refresh() {
        refreshControl.endRefreshing()
        isSearchInProgress = false
        page = 0
        loadUsers(page: page)
        
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
            navigationController?.pushViewController(VCFabric.getProfilePage(for: isSearchInProgress ? searchData[indexPath.row].id : usersData[indexPath.row].id), animated: true)
     
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 300)) {
            loadUsers(page: page)
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
