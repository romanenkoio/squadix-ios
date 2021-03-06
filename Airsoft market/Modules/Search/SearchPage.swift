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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
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
        setup()
        Analytics.trackEvent("User_search_screen")
        page = 0
        guard !isTeamSearch else {
            navigationItem.searchController = nil
            return
        }
        loadUsers(page: page)
    }
    
    func setup() {
        title = "Поиск"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
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
    
    @objc func refresh() {
        guard !isTeamSearch else {
            return
        }
        refreshControl.endRefreshing()
        page = 0
        loadUsers(page: page, querry: querry)
    }
}

extension SearchPage: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if !text.isEmpty {
            querry = text
            loadUsers(page: page, querry: text)
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = ""
        loadUsers(page: 0)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        page = 0
    }
}

extension SearchPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectUser == nil {
            navigationController?.pushViewController(VCFabric.getProfilePage(for: usersData[indexPath.row].id), animated: true)
        } else {
            selectUser?(usersData[indexPath.row])
            navigationController?.popViewController(animated: true)
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

extension SearchPage: UITableViewDataSource {
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
