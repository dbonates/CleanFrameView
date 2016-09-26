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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window = CleanWindow(contentRect: NSRect(x: 500, y: 500, width: 200, height: 200))
        self.window.minSize = NSSize(width: 200, height: 200)
        let app = NSApplication.sharedApplication()
        app.activateIgnoringOtherApps(true)
        self.window.makeKeyAndOrderFront(nil)
    }

}


public class CleanWindow: NSWindow {
    
    public init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: NSBorderlessWindowMask, backing: .Buffered, defer: false)
        
        self.movableByWindowBackground = true
        self.alphaValue = 1
        self.opaque = false
        self.backgroundColor = NSColor.clearColor()
        self.hasShadow = false
        let cleanFrameView = CleanFrameView(frame: NSZeroRect)
        cleanFrameView.resizable = false
        self.contentView = cleanFrameView
        self.releasedWhenClosed = false
        
    }
    
    override public var canBecomeMainWindow: Bool {
        get {return true}
    }
    
    override public var canBecomeKeyWindow: Bool {
        get {return true}
    }
    
}
