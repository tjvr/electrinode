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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        node = Node(entryPoint: Bundle.main.resourcePath!.appending("/main.js"))
        node.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

