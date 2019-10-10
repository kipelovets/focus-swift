//
//  TaskRow.swift
//  Focus
//
//  Created by Georgii Korshunov on 29/09/2019.
//  Copyright © 2019 Georgii Korshunov. All rights reserved.
//

import SwiftUI

class CustomNSTextField: NSTextField {
    override func keyUp(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
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
            print("Y: text '\(text)'")
            text = textField.stringValue
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            textField?.resignFirstResponder()
            firstResponder?.resignFirstResponder()
            if let keyCode = KeyCode(withCommand: commandSelector) {
                if let t = textField?.stringValue {
                    text = t
                }
                print("X: \(keyCode) $text '\(text)' _text '\(_text)' string value '\(textField?.stringValue)'")
                inputHandler.keyDown(with: keyCode)
                
                return true
            }
            print("\(commandSelector)")
            return false
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            print("begin editing")
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            if let t = textField?.stringValue {
                text = t
            }
            print("end editing")
        }

        func controlTextDidChange(_ obj: Notification) {
            print("change")
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
            print("FOCUS")
        }
    }
}

struct TaskRow: View {
    @EnvironmentObject var taskData: TaskListState
    var taskId: Int
    var highlighted = false
    var editing = false
    
    var taskIndex: Int? {
        taskData.taskIndex(for: taskId)
    }
    
    var body: some View {
        HStack {
            Color(highlighted ? .gray : .darkGray).frame(width: 8, height: 30)
            Spacer().frame(width: 16, height: 20)
            HStack {
                
                Button(action: {
                    if let i = self.taskIndex {
                        self.taskData.tasks[i].done.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                            .overlay(
                                Circle().foregroundColor(Color(white:0.2))
                                    .frame(width: 16, height: 16)
                        )
                        if taskIndex != nil && taskData.tasks[taskIndex ?? 0].done {
                            Text("✔").foregroundColor(.yellow)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if taskIndex != nil {
                    if editing {
                        CustomTextField(text: $taskData.tasks[taskIndex ?? 0].title, isFirstResponder: true)
                    } else {
                        Text(taskData.tasks[taskIndex ?? 0].title)
                    }
                }
                
            }.padding(5)
        }.border(Color(.gray), width: highlighted ? 2 : 0)
            .background(Color(white: 0.2))
    }
    
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskRow(taskId:1, highlighted: true)
            TaskRow(taskId:2)
            TaskRow(taskId:3, editing: true)
        }
    }
}
