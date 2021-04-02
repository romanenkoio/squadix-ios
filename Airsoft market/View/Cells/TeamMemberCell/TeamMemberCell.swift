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
    var people: [Profile] = []
    var temp: [Profile] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(PeopleCollectionCell.self)
        var profile = Profile()
        profile.profileName = "Мишаня Задудон"
        profile.id = 1
        
        var profile2 = Profile()
        profile2.profileName = "Илья Романенко"
        profile2.id = 2
        temp.append(profile)
        temp.append(profile2)
        temp.append(profile)
        temp.append(profile2)
        temp.append(profile)
        temp.append(profile2)
        temp.append(profile)
        temp.append(profile2)
    }
}

extension TeamMemberCell: UICollectionViewDelegate {
    
}

extension TeamMemberCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return temp.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PeopleCollectionCell.self), for: indexPath)
        guard let profileCell = cell as? PeopleCollectionCell else {
            return cell
        }
        
        profileCell.setupCell(people: temp[indexPath.row])
        return profileCell
    }
    
}
