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
    @IBOutlet weak var inputTextView: UITextView!
    
    var profile: Profile?
    
    var messages: [Int] = [1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(OutMessageCell.self)
        tableView.registerCell(InMessageCell.self)
        tableView.setupDelegateData(self)
        inputTextView.layer.borderColor = UIColor.gray.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 15
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        addProfileButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }

    func scrollToBottom() {
        tableView.scrollToRow(at: IndexPath(item:messages.count - 1, section: 0), at: .bottom, animated: true)
    }

    func addProfileButton() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let customView = UIView(frame: frame)
        let imageView = UIImageView()
        if let url = profile?.profilePictureUrl {
            imageView.loadImageWith(url)
        } else {
            imageView.image = UIImage(named: "avatar_placeholder")
        }
        
        if let profileName = profile?.profileName {
            title = profileName
        } else {
            title = "Неизвестный пользователь"
        }
        
        imageView.frame = frame
        imageView.layer.cornerRadius = imageView.frame.height * 0.5
        imageView.layer.masksToBounds = true
        customView.addSubview(imageView)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: customView)]
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
            outCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return outCell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InMessageCell.self), for: indexPath)
            guard let inCell = cell as? InMessageCell else {
                return cell
            }
            inCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return inCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OutMessageCell.self), for: indexPath)
            return cell
        }
    }
}
