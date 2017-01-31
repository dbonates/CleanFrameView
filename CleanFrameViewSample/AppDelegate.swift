//
//  AppDelegate.swift
//  CleanFrameViewSample
//
//  Created by Dmitry Nikolaev on 21.03.15.
//  Copyright (c) 2015 Dmitry Nikolaev. All rights reserved.
//

import Cocoa
import CleanFrameView

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: CleanWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window = CleanWindow(contentRect: NSRect(x: 500, y: 500, width: 200, height: 200))
        self.window.minSize = NSSize(width: 200, height: 200)
        let app = NSApplication.shared()
        app.activate(ignoringOtherApps: true)
        self.window.makeKeyAndOrderFront(nil)
    }

}


open class CleanWindow: NSWindow {
    
    public init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: NSBorderlessWindowMask, backing: .buffered, defer: false)
        
        self.isMovableByWindowBackground = true
        self.alphaValue = 1
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = false
        let cleanFrameView = CleanFrameView(frame: NSZeroRect)
        cleanFrameView.resizable = false
        self.contentView = cleanFrameView
        self.isReleasedWhenClosed = false
        
    }
    
    override open var canBecomeMain: Bool {
        get {return true}
    }
    
    override open var canBecomeKey: Bool {
        get {return true}
    }
    
}
