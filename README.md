# macOS Trackpad Demo

_Show raw touch points from macOS trackpad, using Storyboard and Swift._

https://user-images.githubusercontent.com/116838/236108497-ed2543de-623c-4200-8dbb-54a3ba901f61.mp4

## Building

Open `TrackpadDemo.xcodeproj/` in Xcode and from the menu click Project > Run.

(I’m using Xcode 14.2)

## Motivation

I’m very new to macOS development, so please send pull requests and issues if
you want to improve what I’ve done.

I’m building an app that requires raw touch points, and I had a lot of trouble
figuring out how to do that. I primarily used GitHub’s code search and
stackoverflow to find usage examples of Apple’s API functions that were
mentioned in these old docs here:

https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/HandlingTouchEvents/HandlingTouchEvents.html

## Touch events

To monitor touch points, we need an `NSView` which can listen to the following events:

* `touchesBegan`
* `touchesMoved`
* `touchesEnded`
* `touchesCancelled`

The constructor has to set some flags:

* `allowedTouchTypes = [.indirect]`: allows us to receive the events
* `wantsRestingTouches = true`: don’t trigger cancel events for resting touches, since we want raw data

Some special things I handle with the events:

* Sometimes we aren’t notified when touches go stale, so there’s some ceremony I wrote to remove them.
* Touch identifiers are long numbers, so I associate it with a smaller number, using an index which counts up from zero, and resets when all touch points disappear.

## Cursor requirements

To ensure all touch events are captured, we have to do various things to the cursor:

* Move the cursor inside the window.
* Keep the cursor from moving.
* Hide the cursor. (just a UX detail)

To do this, we make some view-level API calls in the `NSView` constructor:

* `CGAssociateMouseAndMouseCursorPosition(0)`: lock mouse cursor position
* `CGDisplayHideCursor(CGMainDisplayID())`: hide mouse cursor

Then we move the cursor inside the window with the `NSWindowController` focus events.

* `windowDidBecomeKey`: called when window gains focus
* `windowDidResignKey`: called when window loses focus
* `CGWarpMouseCursorPosition(globalPoint)`: set cursor position
