import Cocoa

class View: NSView {
    var i = 10.0

    var touchIds: [Int:Int]  = [:] // touch hash -> simple number
    var touches: [Int:NSTouch] = [:]
    var touchCount = 0

    func removeTouch(phase: NSTouch.Phase, touchHash: Int, touchId: Int) {
        touches[touchId] = nil
        touchIds[touchHash] = nil
        if touchIds.count == 0 {
            touchCount = 0
        }
    }
    func onTouch(event: NSEvent, phase: NSTouch.Phase) {
        // cancel absent touches
        for (touchHash, touchId) in touchIds {
            var present = false
            for activeTouch in event.allTouches() {
                if touchHash == activeTouch.identity.hash {
                    present = true
                    break
                }
            }
            if !present {
                removeTouch(phase: NSTouch.Phase.cancelled, touchHash: touchHash, touchId: touchId)
            }
        }
        
        for touch in event.touches(matching: phase, in: nil) {
            // get or create new touch id
            let touchHash = touch.identity.hash
            var touchId = touchIds[touchHash]
            if touchId == nil {
                touchId = touchCount
                touchIds[touchHash] = touchId
                touchCount += 1
            }
            
            if phase == NSTouch.Phase.cancelled || phase == NSTouch.Phase.ended {
                removeTouch(phase: phase, touchHash: touchHash, touchId: touchId!)
            } else {
                touches[touchId!] = touch
            }
        }
        self.needsDisplay = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        allowedTouchTypes = [.indirect]
        wantsRestingTouches = true
        CGAssociateMouseAndMouseCursorPosition(0)
        CGDisplayHideCursor(CGMainDisplayID())
    }
    override func touchesBegan(with event: NSEvent) {
        onTouch(event: event, phase: NSTouch.Phase.began)
    }
    override func touchesMoved(with event: NSEvent) {
        onTouch(event: event, phase: NSTouch.Phase.moved)
    }
    override func touchesEnded(with event: NSEvent) {
        onTouch(event: event, phase: NSTouch.Phase.ended)
    }
    override func touchesCancelled(with event: NSEvent) {
        onTouch(event: event, phase: NSTouch.Phase.cancelled)
    }
    func drawDebugTouches() {
        let w = self.frame.width
        let h = self.frame.height
        let ctx = NSGraphicsContext.current?.cgContext;

        // from: https://github.com/alexey-savchenko/WaveformGenerator/blob/314c6aec32638d8b67ed3ab404320aff66b9ef0c/WaveformGenerator/WaveformGenerator.swift
        ctx!.setTextDrawingMode(.fill)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18.0),
            .foregroundColor: NSColor.black
        ]

        for (touchId, touch) in touches {
            let x = touch.normalizedPosition.x * w
            let y = touch.normalizedPosition.y * h
            ctx!.beginPath()
            ctx!.addArc(center: CGPoint(x: x, y: y), radius: 40, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            ctx!.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.15)
            ctx!.fillPath()
            let msgAttrStr = NSAttributedString(string: String(touchId), attributes: textAttributes)
            let msgLine = CTLineCreateWithAttributedString(msgAttrStr)
            let msgRect = CTLineGetImageBounds(msgLine, ctx!)
            ctx!.textPosition = CGPoint(x: x-msgRect.width/2, y: y-msgRect.height/2)
            CTLineDraw(msgLine, ctx!)
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.drawDebugTouches()
    }
}
