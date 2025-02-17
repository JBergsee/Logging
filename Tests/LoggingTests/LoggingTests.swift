import Testing
import XCTest
@testable import JBLogging
import OSLog

public extension LogCategory {
    /// Log messages during testing
    static let testing = LogCategory(rawValue: "Unit Testing")!
}

struct LogTests {

    @Test func retrieveLogs() {

        var logs = [OSLogEntryLog]()

        //measure {
            // Fetching logs can be slow; ideally, this should run on a background thread.
            #expect(throws: Never.self) {
                logs = try Log.getLogEntries(since: 60 * 60 * 24)
                // getLogEntries writes one entry in the log first...
            }
        //}

        #expect(!logs.isEmpty, "No logs found!")

        print("**************************** Log ****************************")
        logs.forEach { entry in
            print("\(entry.subsystem): \(entry.composedMessage)")
        }
        print("**************************** End log ************************")
    }

    @Test func logging() {
        let testError = Log.createError("This error is just a test")
        Log.error(testError, message: "Testing error", in: .testing)
        Log.fault(message: "Testing fault", code: .defaultErrorCode, in: .testing)
        Log.notify(message: "Testing notification", in: .testing)
        Log.trace(message: "Testing trace", in: .testing)
        Log.debug(message: "Testing debug", in: .testing)
    }
}
