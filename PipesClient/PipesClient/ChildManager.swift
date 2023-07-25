import Foundation
import Observation

@Observable class ChildManager {

    var child: Process? = nil
    var isRunning: Bool { child != nil }
    var childListenTask: Task<Void, Never>? = nil
    var counterRunning: Bool = false
    let inputPipeURL = URL(fileURLWithPath: "/tmp/pipes.input-pipe")
    let outputPipeURL = URL(fileURLWithPath: "/tmp/pipes.output-pipe")

    deinit {
        childListenTask?.cancel()
    }

    func start() {
        guard child == nil else { return print("child already running") }
        let child = Process()
        child.executableURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/pipes-server")
        child.arguments = [
            "--input-pipe-path", inputPipeURL.path,
            "--output-pipe-path", outputPipeURL.path,
        ]
        try! child.run()
        print("running child with pid: \(child.processIdentifier)")
        self.child = child
    }

    func listen() {
        guard childListenTask == nil else { return print("already listening") }

        childListenTask = Task {
            let fileHandle = try! FileHandle(forReadingFrom: outputPipeURL)
            defer { fileHandle.closeFile() }

            while !Task.isCancelled {
                if let message = fileHandle.availableData.utf8String, !message.isEmpty {
                    print(message)
                }
            }
        }
    }

    func stopListening() {
        if let childListenTask {
            childListenTask.cancel()
            self.childListenTask = nil
        }
    }

    func stop() {
        guard let child else { return print("child not running") }

        stopCounter()
        Thread.sleep(forTimeInterval: 1)

        print("terminating child with pid: \(child.processIdentifier)")
        child.interrupt()
        self.child = nil
        print("child terminated")
    }

    func sendMessage(_ message: String) {
        let fileHandle = try! FileHandle(forWritingTo: inputPipeURL)
        defer { try! fileHandle.close() }

        let secData = message.data(using: .utf8)
        if let secData = secData {
            try! fileHandle.write(contentsOf: secData)
        }
    }

    func echo(_ message: String) {
        sendMessage("echo:\(message)")
    }

    func startCounter() {
        sendMessage("startCounter:")
        listen()

        counterRunning = true
    }

    func stopCounter() {
        sendMessage("stopCounter:")
        stopListening()

        counterRunning = false
    }
}

extension Data {
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }
}
