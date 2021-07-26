//
//  TeamAvatarCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow
import Photos

class TeamAvatarCell: BaseTableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var changeAvatarButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var team: Team?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imagePicker.delegate = self
    }
    
    @IBAction func addTeamAvatarButtonDidTap(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            if (newStatus == PHAuthorizationStatus.authorized) {
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                    DispatchQueue.main.async {
                        self.imagePicker.sourceType = .savedPhotosAlbum
                        self.topMostController()?.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            } else if (status == PHAuthorizationStatus.denied) {
                DispatchQueue.main.async {
                    if let top = self.topMostController() as? BaseViewController {
                        top.showPermissionAlert(for: .galery)
                    }
                }
            }
        })
    }
    
    func setupCell(team: Team) {
        teamNameLabel.text = team.name
        
        if !team.teamAvatar.isEmpty {
            avatarImage.loadImageWith(team.teamAvatar)
        } else {
            avatarImage.image = UIImage(named: "team_placeholder")
        }
        
        avatarImage.makeRound()
        guard let country = team.country, let city = team.city else { return }
        regionLabel.text = "\(country), \(city)"
    }
    
    
}

extension TeamAvatarCell: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let team = team else { return }
            avatarImage.image = pickedImage
            team.avatarToUpload = pickedImage
            networkManager.editTeam(team: team) { [weak self] team in
                self?.networkManager.getTeamById(teamID: team.id) { team in
                    self?.avatarImage.sd_setImage(with: URL(string: team.teamAvatar), completed: nil)
                }
            }
        }
        topMostController()?.dismiss(animated: true, completion: nil)
    }
}
