//
//  Uname.swift
//  
//
//  Created by Fatih Balsoy on 1/25/21.
//

import Foundation

// FIXME: Maybe ask for config when initializing shell to get accurate info
class _command_uname: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "uname"
        usage = "usage: uname [-amnprsv]"
    }
    
    var version: String{
        get {
            var clientVersion: String?
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                clientVersion = version
            }
            return clientVersion!
        }
    }

    var build: String{
        get {
            var buildNumber: String?
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                buildNumber = build
            }
            return buildNumber!
        }
    }

    var versionAndBuild: String {
        get {
            return "\(version).\(build)"
        }
    }

    var kernel: String {
        get { return "Darwin" }
    }

    var info: String {
        get {
            return "\(kernel) \(deviceName) \(versionAndBuild) \(kernel) Kernel \(versionAndBuild): \(release); \(architecture)"
        }
    }

    var architecture: String {
        get {
            #if arch(i386)
            let arch = "i386"
            #elseif arch(arm)
            let arch = "arm"
            #elseif arch(arm64)
            let arch = "arm64"
            #elseif arch(x86_64)
            let arch = "x86_64"
            #endif
            return arch
        }
    }

    var release: String {
        get {
            return ""
        }
    }

    var deviceName: String {
        get {
            return ProcessInfo().hostName
        }
    }
    
    override func execute(_ args: [String]) -> Int {
        if args.contains("-h") || args.contains("--help")  {
            session.stderr.appendOutput(1, [usage], self)
            return 1
        } else {
            if args.joined().contains("a") {
                session.stdout.appendOutput(0, [info], self)
                return 0
            }
            typealias unameIndex = (arg: String, value: String)
            let index: [unameIndex] = [
                ("s", kernel),
                ("n", deviceName),
                ("r", versionAndBuild),
                ("v", "\(kernel) Kernel \(versionAndBuild): \(release);"),
                ("m", architecture)
                // TODO: Missing 'p'
            ]
            
            var result = [String]()
            for i in index {
                if args.joined().contains(i.arg) {
                    result.append(i.value)
                }
            }
            if result.isEmpty {
                result = [kernel]
            }
            session.stdout.appendOutput(0, [result.joined(separator: " ")], self)
        }
        return 0
    }
}
