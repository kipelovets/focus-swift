import Cocoa
import SwiftUI

fileprivate let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
fileprivate let repo = TaskSpaceRepository(filename: documentsPath + "/Main.focus")
fileprivate var taskListState = TaskListState(repo: repo)
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
