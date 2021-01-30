//
//  TextPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 25.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import WebKit

enum TextType {
    case rules
    case license
    case confidence
    case unknown
}


class TextPage: BaseViewController {
    @IBOutlet weak var webView: WKWebView!
    var type: TextType? = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url: URL?
        
        switch type {
        case .confidence:
            url = Bundle.main.url(forResource: "Confidential", withExtension:"html")
            title = "Политика конфиденциальности"
        case .license:
            url = Bundle.main.url(forResource: "TermsOfUse", withExtension:"html")
            title = "Пользовательское соглашение"
        case .rules:
            url = Bundle.main.url(forResource: "Rules", withExtension:"html")
            title = "Правила размещения объявлений"
        default:
            navigationController?.popViewController(animated: true)
        }
        
        guard let fileUrl = url else {
            navigationController?.popViewController(animated: true)
            return
        }
        webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl)
        let request = URLRequest(url: fileUrl)
        webView.load(request)
        
    }
}
