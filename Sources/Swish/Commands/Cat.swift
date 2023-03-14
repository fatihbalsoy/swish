//
//  Cat.swift
//  
//
//  Created by Fatih Balsoy on 1/25/21.
//

import Foundation

class _command_cat: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "cat"
        usage = "usage: cat [-benstuv] [file ...]"
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            _ = try args.get(0)

            var output = [String]()
            var exit = 0
            for a in args {
                let url: URL = session.getFilePathURL(withFile: a).filePathURL!
                var isDir: ObjCBool = false
                let _ = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
                if !isDir.boolValue {
                    print("File", url.path)
                    output.append(try String(contentsOf: url as URL, encoding: .utf8))
                } else {
                    print("Folder")
                    let folder = url.lastPathComponent
                    output.append("cat: \(folder): Is a directory.")
                    exit = 1
                }
            }
            if exit == 0 {
                session.stdout.appendOutput(exit, output, self)
            } else {
                session.stderr.appendOutput(exit, output, self)
            }
            return exit
        } catch let error as NSError {
            if !args.indices.contains(0) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}
