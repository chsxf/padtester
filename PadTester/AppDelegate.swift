//
//  AppDelegate.swift
//  PadTester
//
//  Created by Christophe on 22/11/2020.
//

import Cocoa
import GameController

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        GCController.startWirelessControllerDiscovery()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

