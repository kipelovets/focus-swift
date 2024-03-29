import Foundation
import Cocoa
import SwiftUI

class InputHandlingWindow: NSWindow {
    private let inputHandler: CommandBus
    
    public init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, inputHandler: CommandBus)
    {
        self.inputHandler = inputHandler
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }
    
    override func keyDown(with event: NSEvent) {
        if let keyCode = Command(withEvent: event) {
            inputHandler.handle(keyCode)
        } else {
            print("Unknown key \(event)")
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}
