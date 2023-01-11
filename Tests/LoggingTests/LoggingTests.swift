import XCTest
@testable import Logging
import OSLog

public extension LogCategory {
    ///Log messages during testing
    static let testing = LogCategory(rawValue: "Unit Testing")!
}

final class LoggingTests: XCTestCase {

    func testLogging() {
        
        var logs = [OSLogEntryLog]()
        
        measure {
            //Getting logs is pretty slow, preferably this should be on a background thread
            logs = try! Log.getLogEntries(since: 60*60*24)
        }
        XCTAssert(logs.count > 0, "No logs!")
        print("**************************** Log ****************************")
        logs.forEach { entry in
            print("\(entry.subsystem): \(entry.composedMessage)")
        }
        print("**************************** End log ************************")

    }
    
}
