//
//  FilterPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

protocol UpdateWithFiltersDelegate: AnyObject {
    func updateWithFilters()
}

enum FiltersMenuPoint: String {
    case categories = "Категории"
    case sorting = "Сортировка"
    case switchAll = ""
    
    static func getPoints() -> [[FiltersMenuPoint]] {
        let sortingSection: [FiltersMenuPoint] = [.sorting]
        let switchAllSection: [FiltersMenuPoint] = [.switchAll]
        let filterSection: [FiltersMenuPoint] = [.categories]
        
        return [sortingSection, switchAllSection, filterSection]
    }
 }

class FilterPage: BaseViewController {
    var categoryFilters = RealmService.readFilters()
    weak var delegate: UpdateWithFiltersDelegate?
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var menu = FiltersMenuPoint.getPoints()
    var sorting = Common.Sorting.getSorting()
    var selectedSorting = Common.Sorting.standart
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильтры"
        tableView.setupDelegateData(self)
        tableView.registerCell(CategoryCheckboxCell.self)
        tableView.registerCell(RadioSelectionCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = false
        let savedFilters = RealmService.readFilters()
        if savedFilters.count != 0 {
            categoryFilters = savedFilters
        }
        selectedSorting = Common.Sorting.reverse(raw: UsersData.shared.savedSorting)
    }
    
    @IBAction func saveFiltersAction(_ sender: Any) {
        RealmService.writeFilters(categoryFilters)
        saveButton.isEnabled = false
        UsersData.shared.savedSorting = selectedSorting.rawValue
        delegate?.updateWithFilters()
        showPopup(title: "Фильтры установлены!")
    }
}


extension FilterPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            categoryFilters[indexPath.row].status = !categoryFilters[indexPath.row].status
        } else if indexPath.section == 1 {
            var newFilters: [Filter] = []
            if categoryFilters.filter({$0.status == true}).count == categoryFilters.count {
                newFilters = categoryFilters.map({Filter(category: $0.category, status: false)})
            } else {
                newFilters = categoryFilters.map({Filter(category: $0.category, status: true)})
            }
            categoryFilters = newFilters
        } else if indexPath.section == 0 {
            selectedSorting = sorting[indexPath.row]
        }
        
        tableView.reloadData()
        saveButton.isEnabled = categoryFilters != RealmService.readFilters() || UsersData.shared.savedSorting != selectedSorting.rawValue
        if categoryFilters.filter({ $0.status == true }).count == 0 {
            saveButton.isEnabled = false
        }
    }
}

extension FilterPage: UITableViewDataSource {
     func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = menu[section]
        if type.contains(.switchAll) {
            return 1
        } else if type.contains(.categories)  {
            return categoryFilters.count
        } else if type.contains(.sorting) {
            return sorting.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryCheckboxCell.self), for: indexPath)
        
        let type = menu[indexPath.section][0]
        
        switch type {
        case .categories:
            if let filterCell = cell as? CategoryCheckboxCell {
                filterCell.setupWith(categoryFilters[indexPath.row])
                return filterCell
            }
        case .switchAll:
            if let filterCell = cell as? CategoryCheckboxCell {
                filterCell.filterDescriptionLabel.text = categoryFilters.filter({$0.status == true}).count == categoryFilters.count ? "Выключить все" : "Включить все"
                filterCell.checkBoxImage.image = categoryFilters.filter({$0.status == true}).count == categoryFilters.count ? UIImage(named: "checkBox_fill") : UIImage(named: "checkBox")
                filterCell.selectionStyle = categoryFilters.filter({$0.status == true}).count == categoryFilters.count ? .none : .default
                return filterCell
            }
        case .sorting:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RadioSelectionCell.self), for: indexPath)
            if let radioCell = cell as? RadioSelectionCell {
                let sort = sorting[indexPath.row]
                radioCell.sortingNameLabel.text = sort.rawValue
                let image = UIImage(named: sort == selectedSorting ? "icon_radio_selected" : "icon_radio_blank")
                radioCell.sortingRadioButton.image = image
                return radioCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Сортировка"
        case 1:
            return "Активные категории"
        default:
            return ""
        }
    }
}
