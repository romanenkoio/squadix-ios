//
//  SelectPickPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/10/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
//import ImageCropper

class SelectPickPage: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.makeRound()
        title = "Аватар"
        navigationItem.hidesBackButton = true  
    }
    
    @IBAction func continueAction(_ sender: Any) {
        spiner.startAnimating()

        let manager = NetworkManager()
        guard let avatar = selectedImage else {
            self.spiner.stopAnimating()
            return
        }
        manager.updloadAvatar(image: avatar, completion: {
            self.spiner.stopAnimating()
            self.navigationController?.pushViewController(VCFabric.getUserEditPage(isEdit: false), animated: true)
        }) { _ in
            self.spiner.stopAnimating()
            print("Avatar upload error")
        }
    }
    
    @IBAction func skipAction(_ sender: Any) {
        navigationController?.pushViewController(VCFabric.getUserEditPage(isEdit: false), animated: true)
    }
    
    @IBAction func selectPhotoAction(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                self?.imagePicker.sourceType = .savedPhotosAlbum
                self?.present(self!.imagePicker, animated: true, completion: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self]  _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self?.imagePicker.sourceType = .camera
                self?.present(self!.imagePicker, animated: true, completion: nil)
            }
        })
        
        if !(UIImage(named: "placeholder")?.pngData() == selectedImage?.pngData()) {
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self]  _ in
                self?.profileImage.image = UIImage(named: "placeholder")
                self?.selectedImage = nil
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        
        present(alert, animated: true)
    }
}

extension SelectPickPage: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage.image = img
            self.selectedImage = img
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
