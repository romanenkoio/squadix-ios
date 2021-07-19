//
//  SearchPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya
import HMSegmentedControl

class SearchPage: BaseViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var segment: HMSegmentedControl!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var peopleSearch: PeopleSearchPage!
    var teamSearch: TeamSearchPage!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSegmentController()
        Analytics.trackEvent("User_search_screen")
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
        
        peopleSearch = PeopleSearchPage.loadFromNib()
        teamSearch = TeamSearchPage.loadFromNib()
        
        container.addSubview(peopleSearch.view)
        self.addChild(peopleSearch)
        peopleSearch.didMove(toParent: self)
    }
    
    func setupSegmentController() {
        segment.backgroundColor = UIColor.white
        segment.sectionTitles = ["Люди", "Команды"]
        segment.selectionIndicatorColor = UIColor.mainStrikeColor
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.mainStrikeColor,
            .font: UIFont.systemFont(ofSize: 13)
        ]

        segment.selectedTitleTextAttributes = attributes
        
        attributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 13)
        ]
        segment.titleTextAttributes = attributes
        segment.selectionIndicatorLocation = .top
        segment.selectionIndicatorHeight = 2
        segment.selectedSegmentIndex = 0
        segment.borderType = .bottom
        segment.borderWidth = 0.5
        segment.borderColor = .lightGray
    }
    
    @IBAction func segmentChanged(_ sender: HMSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            teamSearch.removeFromParent()
            teamSearch.view.removeFromSuperview()
            teamSearch.willMove(toParent: nil)
            
            container.addSubview(peopleSearch.view)
            self.addChild(peopleSearch)
            peopleSearch.willMove(toParent: self)
        case 1:
            peopleSearch.removeFromParent()
            peopleSearch.view.removeFromSuperview()
            peopleSearch.willMove(toParent: nil)
            
            container.addSubview(teamSearch.view)
            self.addChild(teamSearch)
            peopleSearch.willMove(toParent: self)
        default:
            print("Иди на хуй пидарняга")
        }
    }
    
}

extension SearchPage: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if !text.isEmpty {
            switch segment.selectedSegmentIndex {
            case 0:
                peopleSearch.loadUsers(page: 0, querry: text)
            case 1:
                teamSearch.loadTeams(page: 0, querry: text)
            default:
                return
            }
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = ""
        switch segment.selectedSegmentIndex {
        case 0:
            peopleSearch.loadUsers(page: 0)
        case 1:
            teamSearch.loadTeams(page: 0)
        default:
            return
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        page = 0
    }
}

