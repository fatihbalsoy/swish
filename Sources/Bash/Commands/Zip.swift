//
//  Zip.swift
//  
//
//  Created by Fatih Balsoy on 2/22/20.
//

import Foundation
import Zip

class _command_zip: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "zip"
        usage = "usage: zip [-options] [-p password] [-b path] [-t mmddyyyy] [-n suffixes] [zipfile list] [-xi list]"
    }
    
    override func execute(_ args: [String]) -> Int {
        var outputs = [String]()
        do {
            _ = try args.get(0)
            _ = try args.get(1)
            
            if try args.get(0).hasSuffix(".zip") {
                var pwdIndex: Int = -2
                let zip = session.getFilePathURL(withFile: try args.get(0))
                
                var urls = [URL]()
                for a in 1..<args.endIndex {
                    let arg = args[a]
                    if arg == "-p" && pwdIndex == -2 {
                        pwdIndex = a
                        _ = try args.get(a + 1)
                    } else {
                        if a != pwdIndex + 1 {
                            let path = session.getFilePathURL(withFile: arg)
                            urls.append(path as URL)
                        }
                    }
                }
                
                for url in urls {
                    outputs.append("\tadding: \(url.lastPathComponent)")
                    try Zip.zipFiles(
                        paths: [url],
                        zipFilePath: zip as URL,
                        password: pwdIndex != -2 ? args[pwdIndex + 1] : nil,
                        progress: { (progress) -> () in
                            print(progress)
                    })
                }
                session.stdout.appendOutput(0, outputs, self)
                return 0
            } else {
                session.stderr.appendOutput(1, ["zip: Zip file structure invalid (\(try args.get(0)))"], self)
                return 1
            }
        } catch let error as NSError {
            if !args.indices.contains(0) || !args.indices.contains(1) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
    
}

class _command_unzip: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "unzip"
        usage = "usage: unzip [-Z] [-opts[modifiers]] file[.zip] [list] [-x xlist] [-d exdir]"
    }
    
    override func execute(_ args: [String]) -> Int {
        return 0
    }
    
}
