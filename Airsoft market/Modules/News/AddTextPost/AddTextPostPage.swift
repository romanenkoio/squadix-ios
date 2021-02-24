//
//  AddTextPostPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/30/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class AddTextPostPage: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainTextField: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var previewButton: WhiteButton!
    @IBOutlet weak var postButton: OliveButton!
    
    weak var updatableDelegate: UpdateFeedDelegate?
    var imagePicker = UIImagePickerController()
    var imageData: [UIImage] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextField.layer.borderWidth = 1
        mainTextField.layer.cornerRadius = 5
        collectionView.registerCell(ProductImageCell.self)
        collectionView.setupDelegateData(self)
    }
    
    @IBAction func previewAction(_ sender: Any) {
        guard let ppostPreview = buildPost(isPreview: true) else { return  }
        navigationController?.pushViewController(VCFabric.getNewsShowPage(post: ppostPreview), animated: true)
    }
    
    @IBAction func postAction(_ sender: Any) {
        guard let post = buildPost() else { return }
        spinner.startAnimating()
        let manager = NetworkManager()
        manager.postVideo(post: post, completion: { [weak self] in
            self?.updatableDelegate?.updateFeed(type: .feed)
            Analytics.trackEvent("Post_added")
            self?.getFeedback(type: .success)
            self?.navigationController?.popViewController(animated: true)
            self?.spinner.stopAnimating()
            }, failure: { [weak self] error in
                self?.spinner.stopAnimating()
        })
    }
    
    func buildPost(isPreview: Bool = false) -> Post? {
        let post = Post()
        if mainTextField.text.isEmpty && imageData.count == 0 {
            return nil
        }
        guard  let id = KeychainManager.profileID else { return nil }
        post.description = mainTextField.text
        post.contentType = .image
        post.imageUrls = []
        post.isPreview = isPreview
        post.id = id
        if post.isPreview {
            post.previewImages = imageData
        } else {
            if imageData.count != 0 {
                for image in imageData {
                    if let codedImage = image.toBase64() {
                        post.imageUrls.append(codedImage)
                    }
                }
            }
        }
       
        return post
    }
}

extension AddTextPostPage: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath)
        if let imageCell = cell as? ProductImageCell {
            if indexPath.row < imageData.count {
                if imageData[indexPath.row].imageAsset != nil {
                    imageCell.productImageView.image = imageData[indexPath.row]
                }
            } else {
                imageCell.productImageView.image = UIImage(named: "placeholder")
            }
            return imageCell
        }
        return cell
    }
}

extension AddTextPostPage: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        var buttonTitile = imageData.indices.contains(indexPath.row) ? "Сделать новое фото" : "Сделать фото"
        alert.addAction(UIAlertAction(title: buttonTitile, style: .default) { [weak self] _ in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                if  accessGranted {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        DispatchQueue.main.async {
                            self?.imagePicker.sourceType = .camera
                            self?.selectedIndex = indexPath.row
                            self?.present(self!.imagePicker, animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionAlert(for: .camera)
                    }
                }
            })
        })
        
        buttonTitile = imageData.indices.contains(indexPath.row) ? "Заменить фото из галереи" : "Выбрать из галереи"
        alert.addAction(UIAlertAction(title: buttonTitile, style: .default) { [weak self]  _ in
            let status = PHPhotoLibrary.authorizationStatus()
            
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                        DispatchQueue.main.async {
                            self?.imagePicker.sourceType = .savedPhotosAlbum
                            self?.selectedIndex = indexPath.row
                            self?.present(self!.imagePicker, animated: true, completion: nil)
                        }
                    }
                } else if (status == PHAuthorizationStatus.denied) {
                    DispatchQueue.main.async {
                        self?.showPermissionAlert(for: .galery)
                    }
                }
            })
        })
        
        if imageData.indices.contains(indexPath.row) {
            alert.addAction(UIAlertAction(title: "Удалить фото", style: .destructive) { [weak self] _ in
                self?.imageData.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
        
        })
        
        present(alert, animated: true)
    }
}

extension AddTextPostPage: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if selectedIndex < imageData.count {
                if imageData[selectedIndex].imageAsset != nil {
                    imageData[selectedIndex] = pickedImage
                } else {
                    imageData.append(pickedImage)
                }
            } else {
                imageData.append(pickedImage)
            }
            collectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
}
