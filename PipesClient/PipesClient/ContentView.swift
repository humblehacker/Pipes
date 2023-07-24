//
//  ContentView.swift
//  PipesClient
//
//  Created by David Whetstone on 7/24/23.
//

import Observation
import SwiftUI

struct ContentView: View {
    var childManager = ChildManager()

    var body: some View {
        VStack {
            Text("\(FileManager.default.currentDirectoryPath)")
                .textSelection(.enabled)

            Button(
                action: { childManager.start() },
                label: { Text("Start Child") }
            )

            Button(
                action: { childManager.stop() },
                label: { Text("Stop Child") }
            )

            Button(
                action: { childManager.sendMessage() },
                label: { Text("Send message") }
            ).disabled(!childManager.isRunning)
        }
        .padding()
    }
}



#Preview {
    ContentView()
}
