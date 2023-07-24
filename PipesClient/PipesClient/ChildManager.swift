import Foundation
import Observation

@Observable class ChildManager {

    var child: Process? = nil
    var isRunning: Bool { child != nil }

    func start() {
        guard child == nil else { return print("child already running") }
        let child = Process()
        child.executableURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/pipes-server")
        child.arguments = ["--pipe-path", "/tmp/pipes.input-pipe"]
        try! child.run()
        print("running child with pid: \(child.processIdentifier)")
        self.child = child
    }

    func stop() {
        guard let child else { return print("child not running") }
        print("terminating child with pid: \(child.processIdentifier)")
        child.terminate()
        self.child = nil
        print("child terminated")
    }

    func sendMessage() {
        let handler = FileHandle(forWritingAtPath: "/tmp/pipes.input-pipe")
        let secData = "foobar".data(using: .utf8)
        if let secData = secData {
            try! handler?.write(contentsOf: secData)
        }

        handler?.closeFile()
    }
}
