//
//  Touch.swift
//  
//
//  Created by Fatih Balsoy on 2/18/20.
//

import Foundation

class _command_touch: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "touch"
        usage = "touch [-A [-][[hh]mm]SS] [-acfhm] [-r file] [-t [[CC]YY]MMDDhhmm[.SS]] file ..."
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            _ = try args.get(0)
            
            var urls = [URL?]()
            for a in 0...args.count-1 {
                let split = String(try args.get(a)).split(separator: ".")
                let filename = String(split.dropLast().joined(separator: "."))

                let dir = session.getFilePathURL(withFile: filename)
                let DirPath = dir.appendingPathExtension(String(split.last ?? ""))

                urls.append(DirPath)
            }

            for url in urls {
                let fileExists = FileManager.default.fileExists(atPath: url!.path)
                if !fileExists {
                    try Data("".utf8).write(to: url!)
                }
            }
            return 0
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
