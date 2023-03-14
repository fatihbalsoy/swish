//
//  Cd.swift
//  
//
//  Created by Fatih Balsoy on 2/21/20.
//

import Foundation

class _command_cd: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "cd"
        usage = "usage: cd [-L|-P] [dir]"
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            let dir = String(try args.get(0))
            var exit = 0
            
            func forward(directory: String) {
                let path = session.getFilePathURL(withFile: directory)
                var errorData = [String : String]()
                
                let fileManager = FileManager.default
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: path.path ?? "", isDirectory:&isDir) {
                    if isDir.boolValue {
                        session.currentPath = path
                    } else {
                        errorData = [
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                                "Not found", value: "Not a directory.", comment: "")
                        ]
                    }
                } else {
                    errorData = [
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                            "Not found", value: "No such file or directory.", comment: "")
                    ]
                }
                if (errorData != [:]) {
                    let error = NSError(domain: "com.bitsllc.error", code: 404, userInfo: errorData)
                    session.stderr.appendError(1, error, args, self)
                    exit = 1
                }
            }
            if dir.starts(with: "..") {
                let split = dir.split(separator: "/")
                for dir in split {
                    if dir == ".." {
                        session.currentPath = session.currentPath.deletingLastPathComponent! as NSURL
                    } else {
                        forward(directory: String(dir))
                    }
                }
            } else if dir == "~" {
                session.currentPath = session.homePath
            } else {
                forward(directory: dir)
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
