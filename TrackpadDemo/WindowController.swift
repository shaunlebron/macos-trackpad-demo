//  References:
//  [1] https://stackoverflow.com/questions/29779937/is-there-a-lost-focus-window-event-in-objective-c
//  [2] https://github.com/kaunteya/FloatCoin/blob/fd8ff099f22657695c4a4aca012bf06a72ad84aa/FloatCoin/WindowController.swift
//  [3] https://github.com/chockenberry/Notchmeister/blob/9e9308f0803a4e0faf27790c02081689545a989d/Notchmeister/Notchmeister/PortalEffect.swift#L162-L171

import Cocoa

// Move mouse cursor to inside the window so that touch events are captured.[3]
func captureMouse(window: NSWindow) {
    let view = window.contentView
    let screen = window.screen

    let viewPoint = NSPoint(x: view!.frame.midX, y:view!.frame.midY)
    let windowPoint = view!.convert(viewPoint, to: nil)
    let screenPoint = window.convertPoint(toScreen: windowPoint)
    let globalPoint = CGPoint(
        x: screen!.frame.origin.x + screenPoint.x,
        y: screen!.frame.origin.y + screen!.frame.height - screenPoint.y
    )

    CGWarpMouseCursorPosition(globalPoint)
}

// TODO: see how JWM removes the title bar and traffic light while keeping the window border

class WindowController: NSWindowController, NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        print("focus")
        captureMouse(window: super.window!)
    }
    func windowDidResignKey(_ notification: Notification) {
        print("blur")
        // TODO: restore mouse position?
    }
}

