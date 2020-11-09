//
//  FilterPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

protocol UpdateWithFiltersDelegate: class {
    func updateWithFilters()
}

class FilterPage: BaseViewController {
    var categoryFilters = RealmService.readFilters()
    weak var delegate: UpdateWithFiltersDelegate?
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильтры"
        tableView.setupDelegateData(self)
        tableView.registerCell(CategoryCheckboxCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = false
        let savedFilters = RealmService.readFilters()
        if savedFilters.count != 0 {
            categoryFilters = savedFilters
        }
    }
    
    @IBAction func saveFiltersAction(_ sender: Any) {
        RealmService.writeFilters(categoryFilters)
        saveButton.isEnabled = false
        delegate?.updateWithFilters()
        PopupView(title: "Фильтры установлены!", subtitle: nil, image: nil).show()
    }
}


extension FilterPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
        categoryFilters[indexPath.row].status = !categoryFilters[indexPath.row].status
        } else if indexPath.section == 0 {
            var newFilters: [Filter] = []
            newFilters = categoryFilters.map({Filter(category: $0.category, status: true)})
            categoryFilters = newFilters
        }
        
        tableView.reloadData()
        saveButton.isEnabled = categoryFilters != RealmService.readFilters()
        if categoryFilters.filter({ $0.status == true }).count == 0 {
            saveButton.isEnabled = false
        }
    }
}

extension FilterPage: UITableViewDataSource {
     func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return categoryFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryCheckboxCell.self), for: indexPath)
   
            if let filterCell = cell as? CategoryCheckboxCell {
                if indexPath.section == 0 {
                    filterCell.filterDescriptionLabel.text = "Включить все"
                    filterCell.checkBoxImage.image = categoryFilters.filter({$0.status == true}).count == categoryFilters.count ? UIImage(named: "checkBox_fill") : UIImage(named: "checkBox")
                    filterCell.selectionStyle = categoryFilters.filter({$0.status == true}).count == categoryFilters.count ? .none : .default
                } else {
                    filterCell.setupWith(categoryFilters[indexPath.row])
                }
                return filterCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 40
        }
    }
}
