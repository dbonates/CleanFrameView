//
//  CleanFrameView.swift
//  CleanFrameView
//
//  Created by Dmitry Nikolaev on 21.03.15.
//  Copyright (c) 2015 Dmitry Nikolaev. All rights reserved.
//


import AppKit


open class CleanFrameView : NSView {
    
    var northWestSouthEastCursor: NSCursor!
    var northeastsouthwestCursor: NSCursor!
    var eastWestCursor: NSCursor!
    var northSouthCursor: NSCursor!

    open var resizable = true {
        didSet {
            window?.invalidateCursorRects(for: self)
        }
    }
    
    open var cornerRadius: CGFloat = 5 {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    open var shadowBlurRadius: CGFloat = 15 {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    open var shadowColor: NSColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.085) {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    open var backgroundColor: NSColor = NSColor.white {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    open var strokeColor: NSColor = NSColor(calibratedRed: 220/255, green: 220/255, blue: 220/255, alpha: 1) {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    open var strokeLineWidth: CGFloat = 0.5 {
        didSet {
            self.cacheImage = nil
            self.needsDisplay = true
        }
    }
    
    let resizeInsetCornerWidth = CGFloat(10.0)
    let resizeInsetSideWidth = CGFloat(2.0)
    
    var cacheImageSize = NSSize()
    var cacheImage: NSImage?
    
    open override var alignmentRectInsets: EdgeInsets {
        return EdgeInsets(top: self.shadowBlurRadius, left: self.shadowBlurRadius, bottom: self.shadowBlurRadius, right: self.shadowBlurRadius)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        
        if (!NSEqualSizes(self.cacheImageSize, self.bounds.size) || self.cacheImage == nil) {
            self.cacheImageSize = self.bounds.size
            self.cacheImage = NSImage(size: self.bounds.size)
            self.cacheImage!.lockFocus()

            var rect = self.bounds.insetBy(dx: self.shadowBlurRadius, dy: self.shadowBlurRadius)
            
            NSGraphicsContext.saveGraphicsState()
            
            let shadow = NSShadow()
            shadow.shadowColor = self.shadowColor
            shadow.shadowBlurRadius = self.shadowBlurRadius
            shadow.set()
            
            let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: self.cornerRadius, yRadius: self.cornerRadius)
            self.backgroundColor.setFill()
            backgroundPath.fill()
            
            NSGraphicsContext.restoreGraphicsState()
            
            rect.origin.x += 0.5
            rect.origin.y += 0.5
            let borderPath = NSBezierPath(roundedRect: rect, xRadius: self.cornerRadius, yRadius: self.cornerRadius)
            //        let borderPath = NSBezierPath(rect: rect)
            borderPath.lineWidth = self.strokeLineWidth
            
            self.strokeColor.setStroke()
            borderPath.stroke()
            
            // NSColor.redColor().setFill()
            // NSRectFill(self.resizeRect())

            self.cacheImage!.unlockFocus()
            // println("set cache");
        } else {
            // println("load cache");
        }
        
        self.cacheImage!.draw(at: NSPoint(), from: NSRect(), operation:  .copy, fraction: 1)

        
    }

    // MARK:  Cursor
    
    override open func resetCursorRects() {
        
        if resizable {
            let directionHelper = self.buildDirectionHelper()

            self.addCursorRect(directionHelper.rectForDirection(.north), cursor: northSouthCursor)
            self.addCursorRect(directionHelper.rectForDirection(.northEast), cursor: northeastsouthwestCursor)
            self.addCursorRect(directionHelper.rectForDirection(.east), cursor: eastWestCursor)
            self.addCursorRect(directionHelper.rectForDirection(.southEast), cursor: northWestSouthEastCursor)
            self.addCursorRect(directionHelper.rectForDirection(.south), cursor: northSouthCursor)
            self.addCursorRect(directionHelper.rectForDirection(.southWest), cursor: northeastsouthwestCursor)
            self.addCursorRect(directionHelper.rectForDirection(.west), cursor: eastWestCursor)
            self.addCursorRect(directionHelper.rectForDirection(.northWest), cursor: northWestSouthEastCursor)
        }
    }
    
    fileprivate func buildDirectionHelper() -> CardinalDirectionHelper {
        let rect = self.bounds.insetBy(dx: self.shadowBlurRadius, dy: self.shadowBlurRadius)
        let directionHelper = CardinalDirectionHelper(rect: rect, cornerInset: resizeInsetCornerWidth, sideInset: resizeInsetSideWidth)
        return directionHelper
    }
    
    override open func mouseDown(with theEvent: NSEvent) {
        
        if !resizable {
            return
        }
        
        let pointInView = self.convert(theEvent.locationInWindow, from: nil)
        var resize = false
        let window = self.window! as NSWindow
        
        let directionHelper = self.buildDirectionHelper()
        let direction = directionHelper.directionForPoint(pointInView)
        
        if direction != nil {
            resize = true
            window.isMovableByWindowBackground = false
            NotificationCenter.default.post(name: NSNotification.Name.NSWindowWillStartLiveResize, object: self.window!)
        }
        
        let originalMouseLocationRect = window.convertToScreen(NSRect(origin: theEvent.locationInWindow, size: CGSize()))
        var originalMouseLocation = originalMouseLocationRect.origin
        var windowFrame = window.frame
        var delta = NSPoint()
        
        while true {
            
            let newEvent = window.nextEvent(matching: [NSEventMask.leftMouseDragged, NSEventMask.leftMouseUp])
            
            if newEvent!.type == .leftMouseUp {
                NotificationCenter.default.post(name: NSNotification.Name.NSWindowDidEndLiveResize, object: self.window!)
                break
            }
            
            let newMouseLocationRect = window.convertToScreen(NSRect(origin: newEvent!.locationInWindow, size: CGSize()))
            let newMouseLocation = newMouseLocationRect.origin
            delta.x += newMouseLocation.x - originalMouseLocation.x
            delta.y += newMouseLocation.y - originalMouseLocation.y
            
            // println("delta: \(delta)")
            
            //var newFrame = originalFrame
            
            let treshold = 0
            //            println("x/y: \(absdeltax) \(absdeltay)")
            
            if resize && (fabs(delta.y) >= CGFloat(treshold) || fabs(delta.x) >= CGFloat(treshold)) {
                
                // resize
                
                switch direction! {
                case .north:
                    delta.y = (windowFrame.size.height + delta.y > self.window!.minSize.height ? delta.y : self.window!.minSize.height - windowFrame.size.height)
                    
                    windowFrame.size.height += delta.y
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .northEast:
                    delta.x = (windowFrame.size.width + delta.x > self.window!.minSize.width ? delta.x : self.window!.minSize.width - windowFrame.size.width)
                    delta.y = (windowFrame.size.height + delta.y > self.window!.minSize.height ? delta.y : self.window!.minSize.height - windowFrame.size.height)
                    
                    windowFrame.size.height += delta.y
                    windowFrame.size.width += delta.x
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .east:
                    delta.x = (windowFrame.size.width + delta.x > self.window!.minSize.width ? delta.x : self.window!.minSize.width - windowFrame.size.width)
                    
                    windowFrame.size.width += delta.x
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .southEast:
                    delta.x = (windowFrame.size.width + delta.x > self.window!.minSize.width ? delta.x : self.window!.minSize.width - windowFrame.size.width)
                    delta.y = (windowFrame.size.height - delta.y > self.window!.minSize.height ? delta.y : windowFrame.size.height - self.window!.minSize.height)
                    
                    windowFrame.size.width += delta.x
                    windowFrame.size.height -= delta.y
                    windowFrame.origin.y += delta.y
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .south:
                    delta.y = (windowFrame.size.height - delta.y > self.window!.minSize.height ? delta.y : windowFrame.size.height - self.window!.minSize.height)
                    
                    windowFrame.size.height -= delta.y
                    windowFrame.origin.y += delta.y
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .southWest:
                    delta.x = (windowFrame.size.width - delta.x > self.window!.minSize.width ? delta.x : windowFrame.size.width - self.window!.minSize.width)
                    delta.y = (windowFrame.size.height - delta.y > self.window!.minSize.height ? delta.y : windowFrame.size.height - self.window!.minSize.height)
                    
                    windowFrame.origin.x += delta.x
                    windowFrame.size.width -= delta.x
                    windowFrame.size.height -= delta.y
                    windowFrame.origin.y += delta.y
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .west:
                    delta.x = (windowFrame.size.width - delta.x > self.window!.minSize.width ? delta.x : windowFrame.size.width - self.window!.minSize.width)
                    
                    windowFrame.origin.x += delta.x
                    windowFrame.size.width -= delta.x
                    window.setFrame(windowFrame, display: true, animate: false)
                    
                case .northWest:
                    delta.x = (windowFrame.size.width - delta.x > self.window!.minSize.width ? delta.x : windowFrame.size.width - self.window!.minSize.width)
                    delta.y = (windowFrame.size.height + delta.y > self.window!.minSize.height ? delta.y : self.window!.minSize.height - windowFrame.size.height)
                    
                    windowFrame.origin.x += delta.x
                    windowFrame.size.width -= delta.x
                    windowFrame.size.height += delta.y
                    window.setFrame(windowFrame, display: true, animate: false)
                }
                
                delta.x = 0
                delta.y = 0
                
            }
            
            if (!resize) {
                windowFrame.origin.x += delta.x
                windowFrame.origin.y += delta.y
                window.setFrame(windowFrame, display: true, animate: false)
                delta.x = 0
                delta.y = 0
            }
            
            originalMouseLocation = newMouseLocation
        }
        
    }
    
    fileprivate func initialize() {
        // \
        let northWestSouthEastPath = NSString(format: "%@/Contents/Frameworks/CleanFrameView.framework/Resources/resizenorthwestsoutheast.pdf", Bundle.main.bundlePath)
        let northWestSouthEastImage = NSImage(contentsOfFile: northWestSouthEastPath as String)!
        self.northWestSouthEastCursor = NSCursor(image: northWestSouthEastImage, hotSpot: NSPoint(x: northWestSouthEastImage.size.width/2, y:northWestSouthEastImage.size.height/2))
        
        // /
        let northeastsouthwestPath = NSString(format: "%@/Contents/Frameworks/CleanFrameView.framework/Resources/resizenortheastsouthwest.pdf", Bundle.main.bundlePath)
        let northeastsouthwestImage = NSImage(contentsOfFile: northeastsouthwestPath as String)!
        self.northeastsouthwestCursor = NSCursor(image: northeastsouthwestImage, hotSpot: NSPoint(x: northeastsouthwestImage.size.width/2, y:northeastsouthwestImage.size.height/2))
        
        // -
        let eastWestPath = NSString(format: "%@/Contents/Frameworks/CleanFrameView.framework/Resources/resizeeastwest.pdf", Bundle.main.bundlePath)
        let eastWestImage = NSImage(contentsOfFile: eastWestPath as String)!
        self.eastWestCursor = NSCursor(image: eastWestImage, hotSpot: NSPoint(x: eastWestImage.size.width/2, y:eastWestImage.size.height/2))
        
        // |
        let northSouthPath = NSString(format: "%@/Contents/Frameworks/CleanFrameView.framework/Resources/resizenorthsouth.pdf", Bundle.main.bundlePath)
        let northSouthImage = NSImage(contentsOfFile: northSouthPath as String)!
        self.northSouthCursor = NSCursor(image: northSouthImage, hotSpot: NSPoint(x: northSouthImage.size.width/2, y:northSouthImage.size.height/2))
    }
    
}


enum CardinalDirection {
    case north, northEast, east, southEast, south, southWest, west, northWest
    static let AllValues = [north, northEast, east, southEast, south, southWest, west, northWest]
}


class CardinalDirectionHelper {
    
    let rect: NSRect
    let cornerInset: CGFloat
    let sideInset: CGFloat
    
    init(rect: NSRect, cornerInset: CGFloat, sideInset: CGFloat) {
        self.rect = rect
        self.cornerInset = cornerInset
        self.sideInset = sideInset
    }
    
    func directionForPoint(_ point: NSPoint) -> CardinalDirection? {
        
        for direction in CardinalDirection.AllValues {
            if (NSPointInRect(point, rectForDirection(direction))) {
                return direction
            }
        }
        
        return nil
    }
    
    func rectForDirection(_ direction: CardinalDirection) -> NSRect {
        let southTopCorner = rect.origin.y + cornerInset
        let southBottom = rect.origin.y
        
        let northTop = NSMaxY(rect)
        let northBottomCorner = northTop - cornerInset
        let northBottomSide = northTop - sideInset
        
        let westLeft = rect.origin.x
        let westRightCorner = westLeft + cornerInset
        
        let eastRight = NSMaxX(rect)
        let eastLeftCorner = eastRight - cornerInset
        let eastLeftSide = eastRight - sideInset
        
        let northRect = NSRect(x: westRightCorner, y: northBottomSide, width: eastLeftCorner - westRightCorner, height: sideInset)
        let northEastRect = NSRect(x: eastLeftCorner, y: northBottomCorner, width: cornerInset, height: cornerInset)
        let eastRect = NSRect(x: eastLeftSide, y: southTopCorner, width: sideInset, height: northBottomCorner - southTopCorner)
        let southEastRect = NSRect(x: eastLeftCorner, y: southBottom, width: cornerInset, height: cornerInset)
        
        let southRect = NSRect(x: westRightCorner, y: southBottom, width: eastLeftCorner - westRightCorner, height: sideInset)
        let southWestRect = NSRect(x: westLeft, y: southBottom, width: cornerInset, height: cornerInset)
        let westRect = NSRect(x: westLeft, y: southTopCorner, width: sideInset, height: northBottomCorner - southTopCorner)
        let northWestRect = NSRect(x: westLeft, y: northBottomCorner, width: cornerInset, height: cornerInset)
        
        switch direction {
        case .north: return northRect
        case .northEast: return northEastRect
        case .east: return eastRect
        case .southEast: return southEastRect
        case .south: return southRect
        case .southWest: return southWestRect
        case .west: return westRect
        case .northWest: return northWestRect
        }
        
    }
    
}

