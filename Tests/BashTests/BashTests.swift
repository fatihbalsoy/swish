import XCTest
@testable import Bash

let _kUUID: String = UUID().uuidString
class BashInit: XCTestCase {
    var bash: Bash!
    
    let root = "XCTestRoot"
    let hostname = "XCTest"
    let user = "user"
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        
        let developer = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
        
        /// /Users/`USERNAME`/Developer/Applications/BashSwift/XCTestRoot
        let rootURL = developer.appendingPathComponent("BashSwift/\(root)") as NSURL?
        
        Shell(root: rootURL).session(user: user, hostname: hostname, uuid: _kUUID) { (exists, session) in
            print(_kUUID)
            
            print("stdin:")
            for input in session.stdin {
                print("– \(input.stream)")
            }
            print("")
            print("")
            print("stdout:")
            for input in session.stdout {
                print("– \(input.stream)")
            }
            print("")
            print("")
            print("stderr:")
            for input in session.stderr {
                print("– \(input.stream)")
            }
            print("")
            print("")
            
            self.bash = Bash(session: session)
        }
        
        print("sessions:",Shell.sessions)
        self.bash.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
        }
        
//        bash.execute("rm -rf tmp home") { (exit) in }
//        bash.execute("ls") { (exit) in
//            let contains = self.bash.session.stdout.contains { (stream) -> Bool in
//                return stream.stream == "home" || stream.stream == "tmp"
//            }
//            XCTAssertFalse(contains)
//        }
    }
}

final class BashTests: BashInit {
    
    // MARK: - Indexing
    func testFindFunction() {        
        /// Command exists
        if let _ = bash.find(command: "touch") {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        
        /// Command exists and had no problems
        bash.execute("echo hi") { (exit) in
            XCTAssertEqual(0, exit)
        }
        
        /// Command does not exist
        bash.execute("nonexistent") { (exit) in
            XCTAssertEqual(127, exit)
        }
        
        /// Empty arguments
        bash.execute("    ") { (exit) in
            XCTAssertEqual(0, exit)
        }
    }
    
    func testCommandIndexing() {
        if let index = bash.findAllCommands() {
            print("\nIndexing commands:")
            for command in index {
                let className = String(describing: command.self).replacingOccurrences(of: "Bash._command_", with: "")
                if command.name == className {
                    let usage = command.usage.split(separator: " ").dropFirst().joined(separator: " ")
                    print("   🟢  \(command.name) \(usage)")
                    XCTAssert(true)
                } else {
                    let message = "\(className) : not equal to '\(command.name)'"
                    print("   🔴  \(message)")
                    XCTAssert(false, message)
                }
            }
        } else {
            XCTAssert(false)
        }
        print("\n")
    }
    
    // MARK: - Standard Streams
    func testStandardOutput() {
        bash.execute("echo hello world i am a computer") { (exit) in
            let stdout = self.bash.session.stdout
            XCTAssertEqual(stdout.last?.stream.first, "hello world i am a computer")
            XCTAssertEqual(stdout.last?.exitCode, exit) // 0
        }
    }
    
    func testStandardInput() {
        bash.execute("echo hello world this is another test!") { (exit) in
            let stdin = self.bash.session.stdin
            XCTAssertEqual(stdin.last?.stream.first, "echo hello world this is another test!")
            XCTAssertEqual(stdin.last?.exitCode, exit) // 0
        }
    }
    
    func testStandardError() {
        /// Command does not exist
        bash.execute("nonexistent") { (exit) in
            let stderr = self.bash.session.stderr
            XCTAssertEqual(stderr.last?.exitCode, exit) // 127
        }
        
        /// Unexpectedly crashed
//        bash.execute("") { (exit) in
//            let stderr = self.bash.session.stderr
//            XCTAssertEqual(stderr.last?.exitCode, exit) // 128
//        }
    }
    
    // MARK: - Command Protocol
    func testCommandUsage() {
        bash.execute("touch") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: touch") ?? false)
        }
    }
    
    func testCommandProtocol() {
        if let index = bash.findAllCommands() {
            for command in index {
                XCTAssertNotEqual(command.name, "")
                XCTAssertNotEqual(command.usage, "")
            }
        }
    }
    
    // MARK: - Prompt
    func testPrompt() {
        let prompt = bash.session.prompt
        XCTAssertNotEqual(prompt, bash.session.storage.get()["PS1"])
        XCTAssertEqual(prompt, "\(hostname):~ \(user)$ ")
        
        if (hostname != "hostname" && user != "user") {
            XCTAssertNotEqual(prompt, "hostname:~ user$")
        }
    }
    
    // MARK: - Syncronization
    func testSyncronization() {
        bash.session.storage.set(_kUUID, for: "SYNC")
        Shell().session(uuid: _kUUID) { (exists, session) in
            XCTAssertEqual(session.storage.get()["SYNC"], self.bash.session.storage.get()["SYNC"])
        }
    }
    
    // MARK: - Variables
    func testRandomVariable() {
        let rand1 = bash.session.storage.get()["RANDOM"]
        let rand2 = bash.session.storage.get()["RANDOM"]
        
        XCTAssertNotEqual(rand1, rand2)
    }
    func testSetGetVariables() {
        let set = "Testing"
        bash.session.storage.set(set, for: "XCTEST")
        
        let get = bash.session.storage.get()["XCTEST"]
        XCTAssertEqual(set, get)
    }
    func testRemoveVariables() {
        bash.session.storage.removeValue(forKey: "XCTEST")
        let get = bash.session.storage.get()["XCTEST"]
        XCTAssertEqual(get, nil)
    }
    func testRemoveAllVariables() {
        let storage = bash.session.storage.get()
        bash.session.storage.removeAll()
        XCTAssertLessThan(bash.session.storage.get().count, storage.count)
        
        bash.session.storage.set(from: storage)
        XCTAssertEqual(bash.session.storage.get().count, storage.count)
    }
    func testAppendListOfVariables() {
        let custom = [
            "XCTEST_APPEND": "Test1",
            "XCTEST_OBJECT": "Test2"
        ]
        bash.session.storage.set(from: custom)
        let get = bash.session.storage.get()
        
        XCTAssertEqual(get["XCTEST_APPEND"], "Test1")
        XCTAssertEqual(get["XCTEST_OBJECT"], "Test2")
    }

//    static var allTests = [
//        ("testFindFunction", testFindFunction),
//    ]
}
