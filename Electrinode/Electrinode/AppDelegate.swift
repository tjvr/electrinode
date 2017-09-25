//
//  AppDelegate.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var node: Node!
    let webViewManager = WebViewManager()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // boot Node
        node = Node(entryPoint: Bundle.main.resourcePath!.appending("/main.js"))
        node.start()
        
        // TODO delay until Node is ready
        
        // start making WebViews
        webViewManager.home = URL(string: "http://localhost:32912")!
        webViewManager.prepare()
        
        // TODO can we delay finishing launching until the initial web view is ready?
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        // TODO make sure Node is stopped gracefully.
    }


}

