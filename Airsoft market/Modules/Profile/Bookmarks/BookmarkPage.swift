//
//  BookmarkPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/8/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class BookmarkPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bookmarkButton: UIButton!
    var bookmarkData: [Bookmark] = []
    weak var delegate: UpdateEventDelegate?
    var type: CoordinatesType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(BookmarkCell.self)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: bookmarkButton)],
                                              animated: true)
        
        bookmarkData = RealmService.readNotes().map({Bookmark(note: $0.note, coordinate: $0.coordinate)})
    }
    
    @IBAction func addBookmarkAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: "Заполните данные", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Название точки"
        }
        
        alert.addTextField { (textFieldPass) in
            textFieldPass.placeholder = "53.956899, 27.626396"
        }
        
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
            guard let note = alert?.textFields![0].text, !note.isEmpty, let coordinate = alert?.textFields![1].text, Validator.shared.validate(string: coordinate, pattern: Regexp.coordinates.rawValue)  else { return }
            RealmService.writeBookmark(bookmark: Bookmark(note: note, coordinate: coordinate))
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension BookmarkPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkCell.self), for: indexPath)
        guard let bookmarkCell = cell as? BookmarkCell else { return cell }
        bookmarkCell.coordinateLabel.text = bookmarkData[indexPath.row].coordinate
        bookmarkCell.noteLabel.text = bookmarkData[indexPath.row].note
        return cell
    }
    
    
}

extension BookmarkPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sType = type else { return }
        if type != nil {
            delegate?.updateCoordinates(coord: bookmarkData[indexPath.row].coordinate, coordType: sType)
            navigationController?.popViewController(animated: true)
        }
    }
}


