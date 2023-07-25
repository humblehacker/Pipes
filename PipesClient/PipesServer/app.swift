import ArgumentParser
import Dispatch
import Foundation

@main
struct PipesServer: AsyncParsableCommand {
    @Option(help: "path to input pipe")
    var inputPipePath: String

    @Option(help: "path to output pipe")
    var outputPipePath: String

    let serverImpl = PipesServerImpl()

    private enum CodingKeys: String, CodingKey {
        case inputPipePath
        case outputPipePath
    }

    func run() async throws {
        log("listening on \(inputPipePath)")
        log("outputting on \(outputPipePath)")

        do {
            try await serverImpl.run(
                inputPipeURL: URL(fileURLWithPath: inputPipePath),
                outputPipeURL: URL(fileURLWithPath: outputPipePath)
            )
        } catch let error {
            log("error running: \(error)")
        }
    }
}

func log(_ message: String, file: String = #file, line: Int = #line) {
    print("• \(message) \(file):\(line)")
}

class PipesServerImpl {
    var counterTask: Task<Void, Never>? = nil

    func run(inputPipeURL: URL, outputPipeURL: URL) async throws {
        log("run")
        let fileHandle = try! FileHandle(forReadingFrom: inputPipeURL)

        while true {
            if let message = fileHandle.availableData.utf8String, !message.isEmpty {
                let parts = message.components(separatedBy: ":")
                let (command, rest) = (parts.first, parts.dropFirst())
                switch command {
                case "echo":
                    echo(rest.first!)
                case "startCounter":
                    try startCounter(outputPipeURL: outputPipeURL)
                case "stopCounter":
                    stopCounter()
                default:
                    log("unknown command \(message)")
                }
                print(message)
            }
        }
    }

    func echo(_ message: String) {
        log("echo \(message)")
    }

    func startCounter(outputPipeURL: URL) throws {
        log("startCounter")
        guard counterTask == nil else { return log("Counter already counting") }

        counterTask = Task.detached {
            var counter = 0
            while (!Task.isCancelled) {
                counter += 1
                let output = "counter: \(counter)"
                log(output)
                let fileHandle = try! FileHandle(forWritingTo: outputPipeURL)
                try! fileHandle.write(contentsOf: output.data(using: .utf8)!)
                try! fileHandle.close()
                try? await Task.sleep(for: .seconds(1))
            }

        }
    }

    func stopCounter() {
        log("stopCounter")

        guard let counterTask else { return log("Counter not counting") }
        counterTask.cancel()
        self.counterTask = nil
        log("Counter stopped")
    }
}

extension Data {
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }
}
