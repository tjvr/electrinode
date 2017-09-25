//
//  ViewController.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = NSApplication.shared.delegate as! AppDelegate
        webView = app.webViewManager.take()
        webView.navigationDelegate = self
        webView.frame = view.frame
        view.addSubview(webView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("yay!")
    }

}

