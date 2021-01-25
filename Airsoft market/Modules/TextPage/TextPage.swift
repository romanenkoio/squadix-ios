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
}


class TextPage: BaseViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}
