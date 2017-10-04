//
//  AppDelegate.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Cocoa

// dirty hack to wait for execution
func runLoop(until: () -> Bool) {
    // TODO make sure this doesn't block uv/node
    while !until() {
        RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NodeDelegate {
    let webViewManager = WebViewManager()
    var nodeReadyURL: String?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // boot Node
        Node.delegate = self
        Node.start(entryPoint: Bundle.main.resourcePath!.appending("/main.js"))
        
        // delay until Node has started its HTTP server
        runLoop(until: { nodeReadyURL != nil })
        
        // start making WebViews
        webViewManager.home = URL(string: nodeReadyURL!)!
        webViewManager.prepare()
        
        // avoid Flash of unrendered DOM:
        // delay launching until the initial web view has loaded
        runLoop(until: { webViewManager.isReady })
        
        // TODO consider doing this for every new window?
    }
    
    func nodeHttpStarted(url: String) {
        nodeReadyURL = url
    }
    
    func nodePing(payload: Any) {
        Node.send(payload)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        // TODO make sure Node is stopped gracefully.
    }


}

