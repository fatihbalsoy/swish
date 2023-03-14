import XCTest
@testable import Swish

let _kUUID: String = UUID().uuidString
class SwishInit: XCTestCase {
    var swish: Swish!
    
    let root = "XCTestRoot"
    let hostname = "XCTest"
    let user = "user"
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        
        let developer = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
        
        /// /Users/`USERNAME`/Library/SwiftShell/XCTestRoot
        let rootURL = developer.appendingPathComponent("SwiftShell/\(root)") as NSURL?
        
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
            
            self.swish = Swish(session: session)
        }
        
        print("sessions:",Shell.sessions)
        self.swish.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
        }
        
//        swish.execute("rm -rf tmp home") { (exit) in }
//        swish.execute("ls") { (exit) in
//            let contains = self.swish.session.stdout.contains { (stream) -> Bool in
//                return stream.stream == "home" || stream.stream == "tmp"
//            }
//            XCTAssertFalse(contains)
//        }
    }
}

final class SwishTests: SwishInit {
    
    // MARK: - Indexing
    func testFindFunction() {        
        /// Command exists
        if let _ = swish.find(command: "touch") {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        
        /// Command exists and had no problems
        swish.execute("echo hi") { (exit) in
            XCTAssertEqual(0, exit)
        }
        
        /// Command does not exist
        swish.execute("nonexistent") { (exit) in
            XCTAssertEqual(127, exit)
        }
        
        /// Empty arguments
        swish.execute("    ") { (exit) in
            XCTAssertEqual(0, exit)
        }
    }
    
    func testCommandIndexing() {
        if let index = swish.findAllCommands() {
            print("\nIndexing commands:")
            for command in index {
                let className = String(describing: command.self).replacingOccurrences(of: "Swish._command_", with: "")
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
        swish.execute("echo hello world i am a computer") { (exit) in
            let stdout = self.swish.session.stdout
            XCTAssertEqual(stdout.last?.stream.first, "hello world i am a computer")
            XCTAssertEqual(stdout.last?.exitCode, exit) // 0
        }
    }
    
    func testStandardInput() {
        swish.execute("echo hello world this is another test!") { (exit) in
            let stdin = self.swish.session.stdin
            XCTAssertEqual(stdin.last?.stream.first, "echo hello world this is another test!")
            XCTAssertEqual(stdin.last?.exitCode, exit) // 0
        }
    }
    
    func testStandardError() {
        /// Command does not exist
        swish.execute("nonexistent") { (exit) in
            let stderr = self.swish.session.stderr
            XCTAssertEqual(stderr.last?.exitCode, exit) // 127
        }
        
        /// Unexpectedly crashed
//        swish.execute("") { (exit) in
//            let stderr = self.swish.session.stderr
//            XCTAssertEqual(stderr.last?.exitCode, exit) // 128
//        }
    }
    
    // MARK: - Command Protocol
    func testCommandUsage() {
        swish.execute("touch") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: touch") ?? false)
        }
    }
    
    func testCommandProtocol() {
        if let index = swish.findAllCommands() {
            for command in index {
                XCTAssertNotEqual(command.name, "")
                XCTAssertNotEqual(command.usage, "")
            }
        }
    }
    
    // MARK: - Prompt
    func testPrompt() {
        let prompt = swish.session.prompt
        XCTAssertNotEqual(prompt, swish.session.storage.get()["PS1"])
        XCTAssertEqual(prompt, "\(hostname):~ \(user)$ ")
        
        if (hostname != "hostname" && user != "user") {
            XCTAssertNotEqual(prompt, "hostname:~ user$")
        }
    }
    
    // MARK: - Syncronization
    func testSyncronization() {
        swish.session.storage.set(_kUUID, for: "SYNC")
        Shell().session(uuid: _kUUID) { (exists, session) in
            XCTAssertEqual(session.storage.get()["SYNC"], self.swish.session.storage.get()["SYNC"])
        }
    }
    
    // MARK: - Variables
    func testRandomVariable() {
        let rand1 = swish.session.storage.get()["RANDOM"]
        let rand2 = swish.session.storage.get()["RANDOM"]
        
        XCTAssertNotEqual(rand1, rand2)
    }
    func testSetGetVariables() {
        let set = "Testing"
        swish.session.storage.set(set, for: "XCTEST")
        
        let get = swish.session.storage.get()["XCTEST"]
        XCTAssertEqual(set, get)
    }
    func testRemoveVariables() {
        swish.session.storage.removeValue(forKey: "XCTEST")
        let get = swish.session.storage.get()["XCTEST"]
        XCTAssertEqual(get, nil)
    }
    func testRemoveAllVariables() {
        let storage = swish.session.storage.get()
        swish.session.storage.removeAll()
        XCTAssertLessThan(swish.session.storage.get().count, storage.count)
        
        swish.session.storage.set(from: storage)
        XCTAssertEqual(swish.session.storage.get().count, storage.count)
    }
    func testAppendListOfVariables() {
        let custom = [
            "XCTEST_APPEND": "Test1",
            "XCTEST_OBJECT": "Test2"
        ]
        swish.session.storage.set(from: custom)
        let get = swish.session.storage.get()
        
        XCTAssertEqual(get["XCTEST_APPEND"], "Test1")
        XCTAssertEqual(get["XCTEST_OBJECT"], "Test2")
    }

//    static var allTests = [
//        ("testFindFunction", testFindFunction),
//    ]
}
