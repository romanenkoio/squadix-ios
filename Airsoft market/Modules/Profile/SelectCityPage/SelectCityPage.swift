//
//  SelectCityPahge.swift
//  Squadix
//
//  Created by Illia Romanenko on 14.05.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya

class SelectCityPage: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectAction: ((City) -> Void)?
    var placesRequest: Cancellable?
    var places: [City] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(CitySelectCell.self)
        setupSearchController()
        loadPlaces(with: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.isActive = true

            // skipping to the next run loop is required, otherwise the keyboard does not appear
        
        DispatchQueue.main.async { [weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по названию"
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.backgroundColor = .white
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func loadPlaces(with prefix: String) {
        spinner.startAnimating()
        placesRequest?.cancel()
        placesRequest = UtilitesManager.shared.getCity(prefix: prefix.lowercased()) { [weak self] places in
            self?.spinner.stopAnimating()
            self?.places = places
            self?.tableView.reloadData()
        } failure: { [weak self] _ in
            self?.spinner.stopAnimating()
        }
    }
}

extension SelectCityPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectAction?(places[indexPath.row])
    }
}

extension SelectCityPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CitySelectCell.self), for: indexPath)
        guard let cityCell = cell as? CitySelectCell else { return cell }
        cityCell.setupWith(city: places[indexPath.row])
        return cityCell
    }
}

extension SelectCityPage: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let prefix = searchController.searchBar.text else { return }
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {  [weak self] _ in
            self?.loadPlaces(with: prefix)
        })
    }
}
