//
//  Cp.swift
//  
//
//  Created by Fatih Balsoy on 1/14/21.
//

import Foundation

// FIXME: Issues
// - Copying into folders needs -R and -n
// - Cant move a list of files at once
class _command_cp: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "cp"
        usage = "usage: cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file target_file" // source_file ... target_directory
    }
    
    override func execute(_ args: [String]) -> Int {
        var source = ""
        var destination = ""
        
        func sendError(_ err: String, a: [String] = args) -> Int {
            let errorData = [
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                    "Error", value: err, comment: "")
            ]
            let error = NSError(domain: "com.bitsllc.error", code: 400, userInfo: errorData)
            session.stderr.appendError(1, error, a, self)
            return 1
        }
        
        do {
            var arguments = args
            
            let copyFolders = arguments.contains("-R")
            let overwrite = !arguments.contains("-n")
            
            arguments.removeAll { (s) -> Bool in
                let params = ["-R", "-n"]
                return params.contains(s)
            }
            
            source = String(try arguments.get(0))
            destination = String(try arguments.get(1))
            
            let sourcePath = session.getFilePathURL(withFile: source)
            let destinationPath = session.getFilePathURL(withFile: destination)
            
            let fileManager = FileManager.default
            var isSrcDir : ObjCBool = false
            
            if fileManager.fileExists(atPath: sourcePath.path ?? "", isDirectory:&isSrcDir) {
                if isSrcDir.boolValue && !copyFolders {
                    return sendError("\(source) is a directory (not copied).", a: [""])
                }
            } else {
                return sendError("No such file or directory", a: [source])
            }
            
            var isDstDir : ObjCBool = false
            if fileManager.fileExists(atPath: destinationPath.path ?? "", isDirectory:&isDstDir) {
                if isDstDir.boolValue && !isSrcDir.boolValue {
                    // FIXME: Needs -R and -n
                    let sourceFile = sourcePath.lastPathComponent ?? ""
                    let input = args.joined(separator: " ") + "/" + sourceFile
                    Bash(session: session).execute("cp \(input)", hidden: true) { (exit) in }
                    return 0
                }
                if overwrite {
                    try fileManager.removeItem(atPath: destinationPath.path ?? "")
                } else {
                    return sendError("File already exists.", a: [destination])
                }
            }
            try fileManager.copyItem(atPath: sourcePath.path ?? "", toPath: destinationPath.path ?? "")
            
            return 0
        } catch let error as NSError {
            let errorTxt = error.localizedFailureReason ?? error.localizedDescription
            if !args.indices.contains(1) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            if errorTxt == "The file doesn’t exist." {
                return sendError("No such file or directory", a: [destination])
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}
