//
//  BaseViewController.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 9/10/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    let networkManager = NetworkManager()
    let generator = UINotificationFeedbackGenerator()
            
    var profileID: Int?
    var page = 0
    var isLoadinInProgress = false
    
    var shouldBackSwipe: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackSwipe()
        page = 0
    }
    
    func configureBackSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        self.view.addGestureRecognizer(swipe)
        swipe.direction = .right
    }
    
    @objc func swipeAction(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .right, shouldBackSwipe {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(title: String, handler: VoidBlock? = nil) {
        let alert = UIAlertController(title: "Ошибка", message: title, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { _ in
            handler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDestructiveAlert(handler: VoidBlock? = nil) {
        let alert = UIAlertController(title: "", message: "Вы уверены?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Нет", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: UIAlertAction.Style.destructive, handler: { _ in
            handler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPopup(isError: Bool = false, title: String) {
        PopupView(title: "", subtitle: title, image: isError ? UIImage(named: "cancel") : UIImage(named: "confirm")).show()
    }
}

extension BaseViewController {
    enum AlertErrors: String {
        case coordinatesError = "Подходящий формат координат: 55.316078, 27.953750"
    }
}
