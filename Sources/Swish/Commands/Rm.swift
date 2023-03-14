//
//  Rm.swift
//  
//
//  Created by Fatih Balsoy on 2/20/20.
//

import Foundation

class _command_rm: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "rm"
        usage = "usage: rm [-pv] [-m mode] directory ..."
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            var isDir : ObjCBool = false
            let fileManager = FileManager.default
            
            if !args.indices.contains(0) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            
            for arg in 0...args.count-1 {
                let currentArg = try args.get(arg)
                if currentArg != "-rf" {
                    
                    let filename = String(try args.get(arg))
                    let path = session.getFilePathURL(withFile: filename)

                    if fileManager.fileExists(atPath: path.path ?? "", isDirectory:&isDir) {
                        if isDir.boolValue {
                            if args.contains("-rf") {
                                try FileManager.default.removeItem(at: path as URL)
                            } else {
                                session.stderr.appendOutput(1, ["rm: \(currentArg): is a directory"], self)
                                return 1
                            }
                        } else {
                            try FileManager.default.removeItem(at: path as URL)
                        }
                    } else {
                        session.stderr.appendOutput(1, ["rm: \(currentArg): No such file or directory"], self)
                        return 1
                    }
                    
                }
            }
            return 0
        } catch let error as NSError {
            print(error.debugDescription)
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}
