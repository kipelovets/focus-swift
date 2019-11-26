import SwiftUI

class CustomNSTextField: NSTextField {
    override func keyUp(with event: NSEvent) {
        if let keyCode = Command(withEvent: event) {
            print("CustomNSTextField: \(keyCode)")
        }
        super.keyUp(with: event)
    }
}

var firstResponder: NSTextField?

struct CustomTextField: NSViewRepresentable {
    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        weak var textField: CustomNSTextField? = nil
        
        var timesBecomeFirstResponder = 1
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: NSTextField) {
            print("textFieldDidChangeSelection: text '\(text)'")
            text = textField.stringValue
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            textField?.resignFirstResponder()
            firstResponder?.resignFirstResponder()
            if let keyCode = Command(withCommand: commandSelector) {
                if let t = textField?.stringValue {
                    text = t
                }
                print("CustomTextField.control: \(keyCode) $text '\(text)' _text '\(_text)' string value '\(textField?.stringValue ?? "nil")'")
                commandBus.handle(keyCode)
                
                return true
            }
            return false
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            print("CustomTextField: begin editing")
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            if let t = textField?.stringValue {
                text = t
            }
            print("CustomTextField: end editing")
        }

        func controlTextDidChange(_ obj: Notification) {
            if let t = textField?.stringValue {
                text = t
            }
        }
    }
    
    @Binding var text: String
    var isFirstResponder: Bool = false
    
    func makeNSView(context: NSViewRepresentableContext<CustomTextField>) -> NSTextField {
        let textField = CustomNSTextField(frame: .zero)
        context.coordinator.textField = textField
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        return textField
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }
    
    func updateNSView(_ uiView: NSTextField, context: NSViewRepresentableContext<CustomTextField>) {
        if uiView.stringValue != text {
            uiView.stringValue = text
        }
        
        if isFirstResponder && context.coordinator.timesBecomeFirstResponder > 0  {
            firstResponder = uiView
            context.coordinator.timesBecomeFirstResponder -= 1
            uiView.becomeFirstResponder()
        }
    }
}
