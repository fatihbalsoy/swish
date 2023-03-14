import XCTest
@testable import Swish

final class ExprTests: SwishInit {
    
    func getStdOut() -> [StandardStream] {
        return self.swish.session.stdout
    }
    func getResult() -> String {
        return self.getStdOut().last?.stream.last ?? ""
    }
    
    func testCommandUsage() {
        swish.execute("expr 5#5") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("expr") { (exit) in
            XCTAssertEqual(1, exit)

            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "usage: expr") ?? false)
        }
    }
    
    func testSimpleMath() {
        // MARK: - Addition
        swish.execute("expr 1 + 2") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "3")
        }
        
        // MARK: - Subtraction
        swish.execute("expr 10 - 5") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "5")
        }
        
        // MARK: - Multiplication
        swish.execute("expr 4 * 3") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "12")
        }
        
        // MARK: - Division
        swish.execute("expr 20 / 5") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "4")
        }
    }
    
    // MARK: - Order of Operations
    func testOperationOrder() {
        swish.execute("expr (20 / 5) * 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "16")
        }
        swish.execute("expr (20 / 5) * (5 * 10)") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "200")
        }
        // MARK: - Should not follow PEMDAS
        swish.execute("expr 4 / (2 * 1) * 2") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "4")
        }
        swish.execute("expr 20 / 5 * 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "16")
        }
    }
    
    // MARK: - Variables
    func testVariables() {
        swish.execute("five=5") { (exit) in }
        swish.execute("expr $five + 4") { (exit) in
            XCTAssertEqual(0, exit)
            XCTAssertEqual(self.getResult(), "9")
        }
    }

}
