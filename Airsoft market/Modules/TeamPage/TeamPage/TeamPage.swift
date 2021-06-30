//
//  TeamPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

enum TeamMenu {
    case teamAvatar
    case teamMember
    case teamInfo
    
    static func getMenuPoints() -> [[TeamMenu]] {
        let avatarSection: [TeamMenu] = [.teamAvatar]
        let memberSection: [TeamMenu] = [.teamMember]
        let infoSection: [TeamMenu] = [.teamInfo]
        return [avatarSection, memberSection, infoSection]
    }
}

class TeamPage: BaseViewController {
    @IBOutlet var addMemberButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var menuPoints: [[TeamMenu]] = TeamMenu.getMenuPoints()
    var team: Team!
    var sectionDescription = ["", "Члены команды", "Описание"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(TeamAvatarCell.self)
        tableView.registerCell(TeamMemberCell.self)
        tableView.registerCell(DescriptionPointCell.self)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: addMemberButton)],
                                              animated: true)
        setupOptionButton()
        
    }
    
    @IBAction func addMemberAction(_ sender: Any) {
        if team.ownerID == KeychainManager.profileID {
            let vc = SearchPage.loadFromNib()
            vc.selectUser = { [weak self] user in
                self?.networkManager.inviteToTeam(userID: user.id) {
                    print("Успешно")
                } failure: {
                    print("Не успешно")
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showDestructiveAlert(title: "Выйти из команды?", handler: {
                
            })
        }
    }
    
    func setupOptionButton() {
        addMemberButton.setImage(team.ownerID == KeychainManager.profileID ? UIImage(named: "plus") : UIImage(named: "logout"), for: .normal)
    }
}

extension TeamPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuPoints.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuPoints[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = menuPoints[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamAvatarCell.self), for: indexPath)
        guard let team = self.team else { return cell }
        
        switch type {
        case .teamAvatar:
            guard let teamAvatarCell = cell as? TeamAvatarCell else {
                return cell
            }
            teamAvatarCell.setupCell(team: team)
            return teamAvatarCell
        case .teamMember:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamMemberCell.self), for: indexPath)
            guard let teamMemberCell = cell as? TeamMemberCell else {
                return cell
            }
            teamMemberCell.people = team.people
            return teamMemberCell
        case .teamInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DescriptionPointCell.self), for: indexPath)
            guard let descriptionCell = cell as? DescriptionPointCell else {
                return cell
            }
            
            descriptionCell.teamStack.isHidden = true
            descriptionCell.descriptionLabel.text = team.description
            return descriptionCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDescription[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1, 2:
            return 40
        default:
            return 40
        }
    }
}

extension TeamPage: UITableViewDelegate {
    
}
