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

    let nodeArgs = ["node", Bundle.main.resourcePath!.appending("/main.js")]


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        var argc = Int32(nodeArgs.count)
        let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: nodeArgs.count)
        for (index, arg) in nodeArgs.enumerated() {
            argv[index] = UnsafeMutablePointer<Int8>(mutating: arg.cString(using: .utf8)!)
        }
        
        //node_Init(&argc, argv, argc, argv)
        
        let n = node_Start(argc, argv)
        // if control gets here then node quit
        // TODO: spawn a separate thread in which to run Node!
        
        print("result: \(n)")
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

