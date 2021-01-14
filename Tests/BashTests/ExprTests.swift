import XCTest
@testable import Bash

final class ExprTests: BashInit {
    
    func getStdOut() -> [StandardStream] {
        return self.bash.session.stdout
    }
    func getResult() -> String {
        return self.getStdOut().last?.stream.last ?? ""
    }
    
    func testCommandUsage() {
        bash.execute("expr 5#5") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("expr") { (exit) in
            XCTAssertEqual(1, exit)

            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "usage: expr") ?? false)
        }
    }
    
    func testSimpleMath() {
        // MARK: - Addition
        bash.execute("expr 1 + 2") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "3")
        }
        
        // MARK: - Subtraction
        bash.execute("expr 10 - 5") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "5")
        }
        
        // MARK: - Multiplication
        bash.execute("expr 4 * 3") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "12")
        }
        
        // MARK: - Division
        bash.execute("expr 20 / 5") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "4")
        }
    }
    
    // MARK: - Order of Operations
    func testOperationOrder() {
        bash.execute("expr (20 / 5) * 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "16")
        }
        bash.execute("expr (20 / 5) * (5 * 10)") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "200")
        }
        // MARK: - Should not follow PEMDAS
        bash.execute("expr 4 / (2 * 1) * 2") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "4")
        }
        bash.execute("expr 20 / 5 * 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "16")
        }
    }
    
    // MARK: - Variables
    func testVariables() {
        bash.execute("five=5") { (exit) in }
        bash.execute("expr $five + 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "9")
        }
    }

}
