//
//  WebView.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation
import WebKit

class WebViewManager {
    var home: URL!
    let hiddenWindow: NSWindow
    
    var backgroundQueue = DispatchQueue(label: "webviews")
    private var pending = [WKWebView]()
    
    static let defaultSize = CGSize(width: 1136, height: 640)
    
    init() {
        hiddenWindow = NSWindow(contentRect: CGRect(origin: CGPoint(x: -1000, y: -1000), size: WebViewManager.defaultSize),
                                styleMask: [.titled, .closable], backing: .nonretained, defer: false)
    }

    func prepare() {
        let webView = create()
        backgroundQueue.sync {
            self.pending.append(webView)
        }
    }
    
    func take() -> WKWebView {
        var webView: WKWebView!
        backgroundQueue.sync {
            assert(self.pending.count > 0, "must call prepare() once before take()")
            webView = self.pending.remove(at: 0)
        }
        self.prepare()
        return webView
    }
    
    private func create() -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // enable "Inspect Element" if defaults is set
        if UserDefaults.standard.bool(forKey: "canInspectElement") == true {
            config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        }
        
        // create WebView
        let frame = CGRect(origin: CGPoint.zero, size: WebViewManager.defaultSize)
        // TODO pick better default size -- we don't want to force a re-layout
        let webView = WKWebView(frame: frame, configuration: config)
        
        // make it fill the thing
        webView.autoresizingMask = [.width, .height]
        
        // load homepage Node gave us
        webView.load(URLRequest(url: self.home))
    
        // add to hidden window, so it actually loads
        hiddenWindow.contentView?.addSubview(webView)
        webView.lockFocus()
        
        // call handler once HTML loads
        // webView.navigationDelegate = self

        return webView
    }
    
    // nb. Requests will silently fail if App Transport Security settings are not set
    // to allow `localhost`.
}
