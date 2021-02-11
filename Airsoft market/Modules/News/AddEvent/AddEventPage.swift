//
//  AddEventPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/16/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class AddEventPage: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startPointTime: StrikeInputField!
    @IBOutlet weak var startEventDate: StrikeInputField!
    @IBOutlet weak var startPointCoordinate: StrikeInputField!
    @IBOutlet weak var eventCoordinate: StrikeInputField!
    @IBOutlet weak var titleLabel: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var startCoordButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var startDate = Date()
    var startPointDate = Date()
    
    var imagePicker = UIImagePickerController()
    var datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    var imageData: [UIImage] = []
    var selectedIndex = 0
    weak var delegate: UpdateFeedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerCell(ProductImageCell.self)
        collectionView.setupDelegateData(self)
        
        configureUI()
    }
    
    func configureUI() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        startPointTime.inputView = datePicker
        startEventDate.inputView = datePicker
        startPointTime.tag = 1000
        startEventDate.tag = 1001
        datePicker.addTarget(self, action: #selector(selectDateAction(picker:)), for: .valueChanged)
        startPointTime.addTarget(self, action: #selector(startEditTextFields(_:)), for: .editingDidBegin)
        startEventDate.addTarget(self, action: #selector(startEditTextFields(_:)), for: .editingDidBegin)
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        title = "Добавление ивента"
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        let isShowFillButton = RealmService.readNotes().count == 0 ? true : false
        startGameButton.isHidden = isShowFillButton
        startCoordButton.isHidden = isShowFillButton
    }
    
    @objc func selectDateAction(picker: UIDatePicker) {
        if picker.tag == 1000 {
            datePicker.datePickerMode = .time
            startPointDate = datePicker.date
            startPointTime.text = dateFormatter.string(from: datePicker.date)
        } else {
            startDate = datePicker.date
            datePicker.datePickerMode = .dateAndTime
            startEventDate.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    @objc func startEditTextFields(_ textField: UITextField) {
        datePicker.tag = textField.tag
        if textField.tag == 1000 {
            dateFormatter.dateFormat = "HH:mm"
            datePicker.datePickerMode = .time
        } else {
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            datePicker.datePickerMode = .dateAndTime
            datePicker.minimumDate = Date()
        }
    }
    
    @IBAction func previewEventAction(_ sender: Any) {
        buildEvent { event in
            guard let event = event else { return }
            self.spinner.stopAnimating()
            event.isPreview = true
            self.navigationController?.pushViewController(VCFabric.getEventShowPage(event: event, isPreview: true, images: self.imageData), animated: true)
        }
    }
    
    @IBAction func saveEventAction(_ sender: Any) {
        let manager = NetworkManager()
        
        buildEvent { event in
            guard let event = event else { return }
            manager.createEvent(event: event, images: self.imageData, completion: {
                self.delegate?.updateFeed(type: .event)
                self.spinner.stopAnimating()
                self.navigationController?.popViewController(animated: true)
            }) { error in
                self.spinner.stopAnimating()
                print(error as Any)
            }
        }
    }
    
    @IBAction func chooseEventCoorAction(_ sender: Any) {
        navigationController?.pushViewController(VCFabric.getBookmarkPage(type: .gameCoordinate, delegate: self), animated: true)
    }
    
    @IBAction func chooseStartCoordAction(_ sender: Any) {
        navigationController?.pushViewController(VCFabric.getBookmarkPage(type: .startCoordinate, delegate: self), animated: true)
    }
    
    private func buildEvent(completion: @escaping (Event?) -> Void) {
        spinner.startAnimating()
        guard imageData.count != 0, titleLabel.text != "", eventCoordinate.text != "", startPointCoordinate.text != "", startEventDate.text != "", startPointTime.text != "", descriptionTextView.text != "" else {
            spinner.stopAnimating()
            return
        }
        
        guard let startCoordText = startPointCoordinate.text, !startCoordText.isEmpty, Validator.shared.validate(string: startCoordText, pattern: Validator.Regexp.coordinates.rawValue), let startCoord = startCoordText.getCoordinates() else {
            showAlert(title: AlertErrors.coordinatesError.rawValue)
            self.spinner.stopAnimating()
            return
        }
        guard let сoordText = eventCoordinate.text, !сoordText.isEmpty, Validator.shared.validate(string: сoordText, pattern: Validator.Regexp.coordinates.rawValue), let coord = сoordText.getCoordinates() else {
            showAlert(title: AlertErrors.coordinatesError.rawValue)
            self.spinner.stopAnimating()
            return
        }
        
        let event = Event()
        event.description = descriptionTextView.text
        event.eventDate = startDate
        event.eventStartLatitude = startCoord.latitude
        event.eventStartLongitude = startCoord.longitude
        event.eventLatitude = coord.latitude
        event.eventLongitude = coord.longitude
        if let text = titleLabel.text {
            event.shortDescription = text
        }
        event.startTime = startDate
        event.authorID = KeychainManager.profileID
        
        let utilitesService = UtilitesManager()
    
        
        self.spinner.startAnimating()
        utilitesService.getAdress(lat: coord.latitude, long: coord.longitude, completion: { address in
            event.eventAdress = address.getAddressString()
            self.spinner.startAnimating()
            utilitesService.getAdress(lat: startCoord.latitude, long: startCoord.longitude, completion: { address in
                event.eventStartAdress = address.getAddressString()
                completion(event)
            }, failure: { error in
                self.spinner.stopAnimating()
                print(error as Any)
            })
        }) { error in
            self.spinner.stopAnimating()
            print(error as Any)
        }
    }
}

extension AddEventPage: UICollectionViewDataSource {
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

extension AddEventPage: UICollectionViewDelegate {
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

extension AddEventPage: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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

extension AddEventPage: UpdateEventDelegate {
    func updateCoordinates(coord: String, coordType: Common.CoordinatesType) {
        switch coordType {
        case .gameCoordinate:
            eventCoordinate.text = coord
        case .startCoordinate:
            startPointCoordinate.text = coord
        }
    }
}
