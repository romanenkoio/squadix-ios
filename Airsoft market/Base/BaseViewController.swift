//
//  BaseViewController.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 9/10/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum Permissions: String {
    case camera = "к камере"
    case galery = "к галерее"
}

class BaseViewController: UIViewController {
    let networkManager = NetworkManager()
    let generator = UINotificationFeedbackGenerator()
            
    var profileID: Int?
    var page = 0
    var isLoadinInProgress = false
    var reportScroll: VoidBlock?
    var commetnForScroll: Int = 0
    
    var shouldBackSwipe: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackSwipe()
        page = 0
    }
    
    func pushController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func popController() {
        navigationController?.popViewController(animated: true)
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
    
    func showAlert(maintText: String = "Ошибка", title: String, handler: VoidBlock? = nil, buttonTitle: String = "Ok") {
        let alert = UIAlertController(title: maintText, message: title, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: { _ in
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
        getFeedback(type: .warning)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(for permissions: Permissions) {
        let alert = UIAlertController(title: "Ошибка разрешений", message: "Приложению необходим доступ \(permissions.rawValue)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Перейти в настройки", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        present(alert, animated: true)
    }
    
    func showPopup(isError: Bool = false, title: String) {
        PopupView(title: "", subtitle: title, image: isError ? UIImage(named: "cancel") : UIImage(named: "confirm")).show()
    }
    
    func getFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

extension BaseViewController {
    enum AlertErrors: String {
        case coordinatesError = "Подходящий формат координат: 55.316078, 27.953750"
    }
}

extension BaseViewController {
    func trackEvent(_ event: String, params: [String : Any]? = nil) {
        Analytics.trackEvent(event, params: params)
    }
    
    func trackScreenView(_ value: String? = nil) {
        Analytics.trackEvent(value ?? String(describing: self))
    }
}

internal class Analytics {
    static func trackEvent(_ event: String, params: [String : Any]? = nil) {
        let eventStringReplaced = event.replacingOccurrences(of: "-", with: "_")
        FirebaseAnalytics.Analytics.logEvent(eventStringReplaced, parameters: params)
    }
}

extension BaseViewController {
    func getVersion() -> String? {
        
        return nil
    }
    
    func getBuildVersion() -> Int? {
        guard let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let build = Int(buildString) else { return nil }
        return build
    }
}
