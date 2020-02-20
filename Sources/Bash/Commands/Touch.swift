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
            _ = try args.get(1)
            
//            var urls = [URL?]()
//            for a in 0...args.count-1 {
//                if a != 0 {
//                    let split = String(try args.get(a)).split(separator: ".")
//                    let filename = String(split.dropLast().joined(separator: "."))
//
//                    let dir = getPathWith(dir: filename)
//                    let DirPath = dir.appendingPathComponent(filename)?.appendingPathExtension(String(split.last ?? ""))
//
//                    urls.append(DirPath)
//                }
//            }
//            do {
//                for url in urls {
//                    let fileExists = FileManager.default.fileExists(atPath: url!.path)
//                    if !fileExists {
//                        try Data("".utf8).write(to: url!)
//                    }
//                }
//            } catch let error as NSError {
//                addErrorToHistory(error, arguments: args)
//            }
        } catch {
            if !args.indices.contains(1) {
                session.stderr.appendOutput(1, usage)
                return 1
            }
        }
        return 0
    }
}
