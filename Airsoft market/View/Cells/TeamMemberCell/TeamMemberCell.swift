//
//  TeamMemberCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class TeamMemberCell: BaseTableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var people: [TeamMember] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(PeopleCollectionCell.self)
    }
}

extension TeamMemberCell: UICollectionViewDelegate {
    
}

extension TeamMemberCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PeopleCollectionCell.self), for: indexPath)
        guard let profileCell = cell as? PeopleCollectionCell else {
            return cell
        }
        
        profileCell.setupCell(people: people[indexPath.row])
        return profileCell
    }
}
