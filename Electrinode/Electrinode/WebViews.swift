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
    
    var pendingRequests = Set<WebViewRequest>() // so they don't get dealloc'd
    var readyViews = [WKWebView]()
    
    static let defaultSize = CGSize(width: 1136, height: 640)
    
    init() {
        hiddenWindow = NSWindow(contentRect: CGRect(origin: CGPoint(x: -1000, y: -1000), size: WebViewManager.defaultSize),
                                styleMask: [.titled, .closable], backing: .nonretained, defer: false)
    }

    func prepare(home: URL) {
        self.home = home
        DispatchQueue.main.async {
            self.createView { w in }
        }
    }
    
    func create() -> WKWebView {
        // block until a WebView is ready
        let semaphore = DispatchSemaphore(value: 0)
        var result: WKWebView!
        
        self.createView { request in
            self.pendingRequests.remove(request) // "free"
            
            result = request.webView
            semaphore.signal()
        }
        //semaphore.wait()
        return self.pendingRequests.first!.webView
        
        //return result
    }
    
    private func createView(callback: @escaping (WebViewRequest) -> ()) {
        let wrapper = WebViewRequest(home: self.home, callback: callback)
        
        // make sure to retain our new WKWebView--ARC hates us
        self.pendingRequests.insert(wrapper)
        
        // add to hidden window, so it actually loads
        hiddenWindow.contentView?.addSubview(wrapper.webView)
        // TODO why this?
        wrapper.webView.lockFocus()
    }
}

class WebViewRequest: NSObject, WKNavigationDelegate {
    let webView: WKWebView
    let callback: (WebViewRequest) -> ()
    
    init(home: URL, callback: @escaping (WebViewRequest) -> ()) {
        let config = WKWebViewConfiguration()
        
        // enable "Inspect Element" if defaults is set
        if UserDefaults.standard.bool(forKey: "canInspectElement") == true {
            config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        }
        
        // create WebView
        let frame = CGRect(origin: CGPoint.zero, size: WebViewManager.defaultSize)
        // TODO pick better default size -- we don't want to force a re-layout
        webView = WKWebView(frame: frame, configuration: config)
        
        // make it fill the thing
        webView.autoresizingMask = [.width, .height]
        
        // load homepage Node gave us
        print(home)
        webView.load(URLRequest(url: home)) //URL(string: "http://tjvr.org")!))
        
        // call handler once HTML loads
        self.callback = callback
        super.init()
        webView.navigationDelegate = self
    }
    
    // nb. Requests will silently fail if App Transport Security settings are not set
    // to allow `localhost`.
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.callback(self)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
}
