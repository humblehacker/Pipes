import ArgumentParser
import Dispatch
import Foundation

@main
struct PipesServer: AsyncParsableCommand {
    @Option(help: "path to input pipe")
    var pipePath: String


    mutating func run() async throws {
        print("listening on \(pipePath)")

        let url = URL(fileURLWithPath: pipePath)
        await listen(pipeURL: url)
    }

    func listen(pipeURL: URL) async {
        do {
            try FileManager.default.removeItem(at: pipeURL)
        } catch let error {
            print("error deleting", error)
        }

        mkfifo(pipeURL.path, 0o777)
        let fileHandle = FileHandle(forReadingAtPath: pipeURL.path)
        
        while true {
            if let data = fileHandle?.availableData {
                if let readedData = String(data: data, encoding: .utf8), readedData != "" {
                    print(readedData)
                }
            }
        }
    }
}
