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
    @State var echoText: String = ""

    var body: some View {
        VStack {
            Button(
                action: {
                    if childManager.isRunning {
                        childManager.stop()
                    } else {
                        childManager.start()
                    }
                },
                label: { Text(childManager.isRunning ? "Stop Child" : "Start Child") }
            )

            HStack {
                TextField("message", text: $echoText)

                Button(
                    action: { childManager.echo(echoText) },
                    label: { Text("Echo") }
                ).disabled(!childManager.isRunning || echoText.isEmpty)
            }
            .frame(maxWidth: 200)

                Button(
                    action: {
                        if childManager.counterRunning {
                            childManager.stopCounter()
                        } else {
                            childManager.startCounter()
                        }
                    },
                    label: {
                        if childManager.counterRunning {
                            Text("Stop counter")
                        } else {
                            Text("Start counter")
                        }
                    }
                )
                .disabled(!childManager.isRunning)
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
