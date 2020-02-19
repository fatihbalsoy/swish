//
//  Touch.swift
//  
//
//  Created by Fatih Balsoy on 2/18/20.
//

import Foundation

class _command_touch: Command {
    var session: ShellSession!
    
    required init(_ session: ShellSession) {
        self.session = session
    }
    
    func execute(_ args: [String]) -> Int {
        do {
//            var urls = [URL?]()
//            for a in 0...args.count-1 {
//                if a != 0 {
//                    let split = String(args.get(a)).split(separator: ".")
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
            
        }
        return 0
    }
}
