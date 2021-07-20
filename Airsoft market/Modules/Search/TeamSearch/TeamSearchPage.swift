//
//  TeamSearchPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 7.07.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya

class TeamSearchPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    var refreshControl = UIRefreshControl()
    var teamData: [Team] = []
    var totalTeamPages = 0
    var teamRequest: Cancellable?
    var querry: String? {
        didSet {
            page = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(ProfileSearchCell.self)
        tableView.setupDelegateData(self)
        tableView.addSubview(refreshControl)
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        loadTeams()
    }
    
    @objc func refresh() {
        page = 0
        loadTeams(page: page, querry: querry)
        refreshControl.endRefreshing()
    }
    
    func loadTeams(page: Int? = nil, querry: String? = nil) {
        if teamRequest != nil {
            teamRequest?.cancel()
            teamRequest = nil
        }
        
        if page == 0 {
            teamData = []
            tableView.reloadData()
//            spinner.stopAnimating()
        }
        
//        spinner.startAnimating()
        teamRequest = networkManager.getAllTeams(page: page, querry: querry, completion: { [weak self] teams in
            guard let sSelf = self else { return }
            if KeychainManager.isAdmin {
                sSelf.title = "Команд: \(teams.totalElements )"
            }
            sSelf.totalTeamPages = teams.totalPages
            
            if teams.content.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in teams.content {
                    sSelf.teamData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.teamData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .none)
                sSelf.tableView.endUpdates()
                sSelf.teamRequest = nil
                sSelf.page += 1
            } else {
                sSelf.teamRequest = nil
                print(" [NETWORK] Загружены все пользователи")
            }
         
        }) {
            print("error")
        }
    }
}

extension TeamSearchPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = teamData[indexPath.row]
        networkManager.getTeamById(teamID: team.id, completion: { [weak self] team in
            let vc = TeamPage.loadFromNib()
            vc.team = team
            self?.pushController(vc)
        })
    }
}

extension TeamSearchPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSearchCell.self), for: indexPath)
        
        if let profileCell = cell as? ProfileSearchCell {
            let item = teamData[indexPath.row]
            profileCell.setupCell(team: item)

            return profileCell
        }
        return cell
    }
}
