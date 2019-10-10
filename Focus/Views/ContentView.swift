//
//  ContentView.swift
//  Focus
//
//  Created by Georgii Korshunov on 28/09/2019.
//  Copyright © 2019 Georgii Korshunov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var taskList: TaskListState
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(taskList.tasks) { task in
                TaskRow(taskId: task.id, highlighted: task == self.taskList.currentTask, editing: task == self.taskList.currentTask && self.taskList.editing)
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TaskListState(tasks: taskData))
    }
}
