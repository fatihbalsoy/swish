//
//  Mkdir.swift
//  
//
//  Created by Fatih Balsoy on 2/20/20.
//

import Foundation

class _command_mkdir: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "mkdir"
        usage = "mkdir [-pv] [-m mode] directory ..."
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            _ = try args.get(0)
            
            var urls = [URL?]()
            for a in 0...args.count-1 {
                let path = String(try args.get(a))
                
                let dir  = session.getFilePathURL(withFile: path)
                print("dirx:",dir)
                print("pathx:",path)
                
                urls.append(dir as URL)
            }
            
            for url in urls {
                try FileManager.default.createDirectory(atPath: url!.path, withIntermediateDirectories: true, attributes: nil)
            }
            return 0
        } catch let error as NSError {
            print(error.debugDescription)
            if !args.indices.contains(0) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}
