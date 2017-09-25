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
        
        // start making WebViews
        webViewManager.prepare(home: URL(string: "http://localhost:32912")!)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        // TODO make sure Node is stopped gracefully.
    }


}

