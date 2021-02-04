//
//  AddProductPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class AddProductPage: BaseViewController {
    @IBOutlet weak var productTextField: StrikeInputField!
    @IBOutlet weak var categoryTextField: StrikeInputField!
    @IBOutlet weak var priceTextField: StrikeInputField!
    @IBOutlet weak var postSwitcher: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var regionTextField: StrikeInputField!
    @IBOutlet weak var postButton: OliveButton!
    var profile: Profile?
   
    var categoryPicker = UIPickerView()
    var imagePicker = UIImagePickerController()
    var imageData: [UIImage] = []
    var selectedIndex = 0
    var categories: [String] = []
    weak var delegate: Updatable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        collectionView.registerCell(ProductImageCell.self)
        collectionView.setupDelegateData(self)
        priceTextField.delegate = self
        
        networkManager.getCurrentUser { (profile, error, _) in
            guard let profile = profile else {
                print(error ?? "error")
                return
            }
            
            self.profile = profile
            var reg = ""
            
            if let region = profile.country {
                reg = region
            }
            
            if let city = profile.city {
                reg += ", \(city)"
            }
            self.regionTextField.text = reg
        }
        
        categoryTextField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryTextField.enableLongPressActions = false
    }
    
    @IBAction func showPreviewAction(_ sender: Any) {
        guard imageData.count != 0 else { return }
        let product = MarketProduct()
        product.authorID = KeychainManager.profileID
        product.description = descriptionTextView.text
        product.isPreview = true
        product.postAvalible = postSwitcher.isOn
        product.createdAt = Date().dateToHumanString()
        product.postID = 1
        product.authorID = KeychainManager.profileID
        product.authorAvatarURL = profile?.profilePictureUrl
        product.authorName = profile?.profileName
        product.productCategory = categoryTextField.text
        product.productName = productTextField.text
        product.price = Int(priceTextField.text!)
        product.productRegion = regionTextField.text
        product.images = imageData
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let navigationBarHeight =  self.navigationController?.navigationBar.frame.size.height
        textViewHeight.constant = textViewHeight.constant - tabBarHeight! - navigationBarHeight!
        
        navigationController?.pushViewController(VCFabric.getProductPage(product: product), animated: true)
    }

    @IBAction func postAction(_ sender: Any) {
        postButton.isEnabled = false
        guard imageData.count != 0, !productTextField.text!.isEmpty, !categoryTextField.text!.isEmpty, !priceTextField.text!.isEmpty, !descriptionTextView.text.isEmpty else  {
            postButton.isEnabled = true
            return
        }
        spinner.startAnimating()
        
        let product = MarketProduct()
        
        guard let prodPrice = Int((priceTextField?.text)!) else {
            spinner.stopAnimating()
            return
        }
        
        product.productCategory = categoryTextField.text
        product.description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        product.productName = productTextField.text
        product.price = prodPrice
        product.productRegion = regionTextField.text
        product.postAvalible = postSwitcher.isOn
      
        networkManager.createProduct(product: product, images: imageData, completion: { [weak self] in
            PopupView(title: "Объявление на модерации", subtitle: nil, image: UIImage(named: "confirm")).show()
            self?.spinner.stopAnimating()
            self?.navigationController?.popViewController(animated: true)
            self?.delegate?.update()
        }) { [weak self] error in
            PopupView(title: "Ошибка. Попробуйте позже", subtitle: nil, image: UIImage(named: "cancel")).show()
            self?.postButton.isEnabled = true
            self?.spinner.stopAnimating()
            print(error ?? "Error")
        }
    }
}

extension AddProductPage: UICollectionViewDataSource {
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

extension AddProductPage: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        var buttonTitile = imageData.indices.contains(indexPath.row) ? "Сделать новое фото" : "Сделать фото"
        alert.addAction(UIAlertAction(title: buttonTitile, style: .default) { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self?.imagePicker.sourceType = .camera
                self?.selectedIndex = indexPath.row
                self?.present(self!.imagePicker, animated: true, completion: nil)
            }
        })
        
        buttonTitile = imageData.indices.contains(indexPath.row) ? "Заменить фото из галереи" : "Выбрать из галереи"
        alert.addAction(UIAlertAction(title: buttonTitile, style: .default) { [weak self]  _ in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                self?.imagePicker.sourceType = .savedPhotosAlbum
                self?.selectedIndex = indexPath.row
                self?.present(self!.imagePicker, animated: true, completion: nil)
            }
        })
        
        if imageData.indices.contains(indexPath.row) {
            alert.addAction(UIAlertAction(title: "Удалить фото", style: .default) { [weak self] _ in
                self?.imageData.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
        
        })
        
        present(alert, animated: true)
    }
}


extension AddProductPage: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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

extension AddProductPage: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
}

extension AddProductPage: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          categoryTextField.text = categories[row]
      }
}


