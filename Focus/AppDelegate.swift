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

var taskListState = TaskListState(tasks: taskData)
var inputHandler = InputHandler(taskList: taskListState)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: InputHandlingWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(taskListState)

        // Create the window and set the content view. 
        window = InputHandlingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false, inputHandler: inputHandler)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
