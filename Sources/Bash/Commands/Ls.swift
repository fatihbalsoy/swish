//
//  Ls.swift
//  
//
//  Created by Fatih Balsoy on 2/20/20.
//

import Foundation

class _command_ls: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "ls"
        usage = "usage: ls [-a] [dir]"
    }
    
    override func execute(_ args: [String]) -> Int {
        struct DirectoryContent {
            var url: URL
            var argument: String
        }
        
        var outputs = [String]()
        do {
            var urls = [DirectoryContent]()

            if args.count == 0 {
                urls.append(DirectoryContent(url: session.currentPath as URL, argument: ""))
            } else {
                for a in 0...args.count-1 {
                    let name = String(try args.get(a))
                    if name != "-a" {
                        let path = session.getFilePathURL(withFile: name)
                        print("PathT2:", path)
                        urls.append(DirectoryContent(url: path as URL, argument: name))
                    }
                }
            }
            if urls.count == 0 {
                urls.append(DirectoryContent(url: session.currentPath as URL, argument: ""))
            }
            
            for url in urls {
                if urls.count > 1 {
                    outputs.append(contentsOf: ["", url.argument + ":"])
                }
                
                let fileURLs = try FileManager.default.contentsOfDirectory(at: url.url, includingPropertiesForKeys: nil)
                for fileUrl in fileURLs {
                    let name = fileUrl.pathComponents.last ?? ""
                    if !name.starts(with: ".") || args.contains("-a") {
                        outputs.append(name)
                    }
                }
            }
            session.stdout.appendOutput(0, outputs, self)
            return 0
        } catch let error as NSError {
            print(error.debugDescription)
            session.stderr.appendError(1, error, args, self)
            session.stdout.appendOutput(0, outputs, self)
            return 1
        }
    }
}
