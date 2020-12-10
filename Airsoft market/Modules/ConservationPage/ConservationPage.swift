//
//  ConservationPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 10.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ConservationPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var messages: [Int] = [1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1]
    @IBOutlet weak var inputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(OutMessageCell.self)
        tableView.registerCell(InMessageCell.self)
        tableView.setupDelegateData(self)
        title = "Михаил Кляшев"
        inputTextView.layer.borderColor = UIColor.gray.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 15
        tableView.reloadData()
        scrollToBottom()
    }

    func scrollToBottom() {
        tableView.scrollToRow(at: IndexPath(item:messages.count - 1, section: 0), at: .bottom, animated: true)
    }


}

extension ConservationPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        switch message {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OutMessageCell.self), for: indexPath)
            guard let outCell = cell as? OutMessageCell else {
                return cell
            }
            return outCell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InMessageCell.self), for: indexPath)
            guard let inCell = cell as? InMessageCell else {
                return cell
            }
            return inCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OutMessageCell.self), for: indexPath)
            return cell
        }
    }
}
