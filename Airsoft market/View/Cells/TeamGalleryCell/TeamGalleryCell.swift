//
//  TeamGalleryCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 30.06.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import Photos

class TeamGalleryCell: BaseTableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var teamID: Int?
    var images: [TeamImage] = []
    var canAddPhoto = false
    var imagePicker = UIImagePickerController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.registerCell(GalleryCell.self)
        collectionView.registerCell(ProductImageCell.self)
        collectionView.delegate = self
    }

}

extension TeamGalleryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if canAddPhoto, indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath)
            
            guard let imageCell = cell as? ProductImageCell  else { return cell }
            imageCell.productImageView.image = UIImage(named: "plus_photo")
            return imageCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GalleryCell.self), for: indexPath)
        guard let imageCell = cell as? GalleryCell else { return cell }
        imageCell.setupCell(with: images[canAddPhoto ? indexPath.row - 1 : indexPath.row].url)
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canAddPhoto ?  images.count + 1 : images.count
    }
}

extension TeamGalleryCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0, canAddPhoto {
            openPicker()
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("The controller to presentation, to represent push in nil")
                return
            }
            
            let vc = FullPicturePage.loadFromNib()
            vc.images = images.map {$0.url}
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            let index = canAddPhoto ? indexPath.item - 1 : indexPath.item
            vc.currentImage = images[index].url
            vc.currentImageIndex = index
            appDelegate.currentViewController?.navigationController?.present(vc, animated: true)
        }
    }
    
}

extension TeamGalleryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
}

extension TeamGalleryCell {
    func openPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                if  accessGranted {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        DispatchQueue.main.async {
                            self?.imagePicker.sourceType = .camera
                            self?.topMostController()?.present(self!.imagePicker, animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let top = self?.topMostController() as? BaseViewController {
                            top.showPermissionAlert(for: .camera)
                        }
                        
                    }
                }
            })
        })
        
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self]  _ in
            let status = PHPhotoLibrary.authorizationStatus()
            
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                        DispatchQueue.main.async {
                            self?.imagePicker.sourceType = .savedPhotosAlbum
                            self?.topMostController()?.present(self!.imagePicker, animated: true, completion: nil)
                        }
                    }
                } else if (status == PHAuthorizationStatus.denied) {
                    DispatchQueue.main.async {
                        if let top = self?.topMostController() as? BaseViewController {
                            top.showPermissionAlert(for: .galery)
                        }
                    }
                }
            })
        })
        
        
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            
        })
        
        topMostController()?.present(alert, animated: true)
    }
    
}

extension TeamGalleryCell: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let id = teamID else { return }
            networkManager.uploadPhotoToTeam(teamID: id, image: pickedImage) { [weak self] in
                self?.collectionView.reloadData()
            }
        }
        topMostController()?.dismiss(animated: true, completion: nil)
    }
}
