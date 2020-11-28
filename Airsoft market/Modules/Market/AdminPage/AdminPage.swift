//
//  AdminPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class AdminPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    var marketData: [MarketProduct] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override var shouldBackSwipe: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.setupDelegateData(self)
        tableView.registerCell(MarketCell.self)
        title = "Модерация"
        loadData()
    }
    
    @objc func refresh() {
        loadData()
    }
    
    func loadData() {
        guard !isLoadinInProgress else {
            return
        }
        spinner.startAnimating()
        let manager = NetworkManager()
        
        manager.getModeratingProducts(page: page, completion: { [weak self] products in
            
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            
            if products.content.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in products.content {
                    sSelf.marketData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.marketData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .automatic)
                sSelf.tableView.endUpdates()
                sSelf.isLoadinInProgress = false
                self?.page += 1
            } else {
                sSelf.isLoadinInProgress = false
                print(" [NETWORK] Загружены все товары")
                sSelf.spinner.stopAnimating()
            }
            
            self?.refreshControl.endRefreshing()
            self?.spinner.stopAnimating()
        }) {  [weak self] error in
            print(error)
            self?.refreshControl.endRefreshing()
            self?.spinner.stopAnimating()
        }
    }
}


extension AdminPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let manager = NetworkManager()
        
        let accept = UIContextualAction(style: .normal, title: "Опубликовать") { (action, sourceView, completionHandler) in
            let item = self.marketData[indexPath.row]
            manager.updateProductStatus(productID: item.postID, status: ProductStatus.active, completion: { [weak self] _ in
                self?.marketData.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }) { error in
                print(error)
            }
        }
        accept.backgroundColor = .systemGreen
        
        let decline = UIContextualAction(style: .destructive, title: "Отклонить") { (action, sourceView, completionHandler) in
            let item = self.marketData[indexPath.row]
            manager.updateProductStatus(productID: item.postID, status: ProductStatus.deleted, completion: { [weak self] _ in
                self?.marketData.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }) { error in
                print(error)
            }
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [decline, accept])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = VCFabric.getProductPage(product: marketData[indexPath.row])
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension AdminPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MarketCell.self), for: indexPath)
        if let marketCell = cell as? MarketCell {
            marketCell.productNameLabel.text = marketData[indexPath.row].productName
            
            let reg = marketData[indexPath.row].productRegion == nil ? "Город не указан" : marketData[indexPath.row].productRegion
            marketCell.regionLabel.text = reg
            
            marketCell.productImage.loadImageWith(marketData[indexPath.row].picturesUrl[0])
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: marketData[indexPath.row].createdAt) {
                marketCell.productDateLabel.text = date.dateToHumanString()
            }
            
            if let price = marketData[indexPath.row].price {
                marketCell.productPriceLabel.text = "\(price) руб"
            }
            marketCell.selectionStyle = .none
            return marketCell
        }
        return cell
    }
}

extension AdminPage: UpdateProductFeed {
    func updateProductFeed(productID: Int) {
        if let index = marketData.firstIndex(where: { $0.postID == productID }) {
            marketData.remove(at: index)
            let indexPath = IndexPath(item: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}
