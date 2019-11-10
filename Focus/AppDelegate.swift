import Cocoa
import SwiftUI

fileprivate let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
fileprivate let repo = TaskSpaceRepositoryFile(filename: documentsPath + "/Main.focus")
fileprivate let space = Space(repo)
fileprivate let commandRecorder = CommandRecorder(perspective: space.perspective!)
var inputHandler = InputHandler(perspective: space.perspective!, recorder: commandRecorder)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {    
    var window: InputHandlingWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = SpaceView(space: space).environmentObject(space)
        
        // Create the window and set the content view. 
        window = InputHandlingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false, inputHandler: inputHandler)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onNotification(_:)),
            name: nil,
            object: nil)
    }
    
    @objc func onNotification(_ sender: NSNotification) {
        if sender.name == NSNotification.Name("NSMenuWillSendActionNotification") {
            if let x = sender.userInfo?["MenuItem"] as? NSMenuItem {
                if x.title == "Quit Focus" {
                    space.save()
                }
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        space.save()
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        space.save()
        return .terminateNow
    }
}
