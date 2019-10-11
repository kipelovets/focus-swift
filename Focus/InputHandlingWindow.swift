import Foundation
import Cocoa
import SwiftUI

class InputHandlingWindow: NSWindow {
    private let inputHandler: InputHandler
    
    public init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, inputHandler: InputHandler)
    {
        self.inputHandler = inputHandler
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }
    
    override func keyDown(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
            inputHandler.keyDown(with: keyCode)
        } else {
            print("Unknown key \(event.keyCode)")
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}
