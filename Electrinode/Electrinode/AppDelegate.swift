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
        webViewManager.home = URL(string: "https://localhost:32912")!
        webViewManager.prepare()
        
        // TODO delay until Node has started its HTTP server
        
        // avoid Flash of unrendered DOM:
        // delay launching until the initial web view has loaded
        // dirty hack to wait for execution
        while !webViewManager.isReady {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
        }
        // TODO consider doing this for every new window?
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        // TODO make sure Node is stopped gracefully.
    }


}

