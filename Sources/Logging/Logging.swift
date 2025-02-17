//
//  Logging.swift
//
//  Created by Johan Bergsee on 2021-07-08.
//  Copyright © 2021 Bergsee Aviation. All rights reserved.
//
///https://developer.apple.com/forums/thread/683169


import UIKit
import OSLog


@objc public enum LogLevel: Int {
    case error, // Error thrown (that is not expected, captured and tolerated)
         fault, // Bug in program
         notify, // Notice about specific occurrence
         trace, // Follow program execution
         debug // Useful for debugging only
}

/*
 Remember that the iOS system will store messages logged with
 notice, warning, and critical functions up to a storage limit.
 It doesn’t store debug messages at all.
 https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code
 */
@objc public class Log: NSObject {
    
    static let subsystem = Bundle.main.bundleIdentifier!

    /// firebase must only be set once in code to avoid unknown shared mutable state.
    @objc nonisolated(unsafe) public static var firebase: FirebaseWrapping?

    @objc public class func log(message: String, level: LogLevel, category: String?) {
        Log.log(error: nil, message: message, level: level, category: category)
    }

    @objc public class func log(error: NSError? = nil, message: String, level: LogLevel, category: String?) {
        let cat = LogCategory(rawValue: category ?? "Category not set") ?? .unknown
        
        switch level {
        case .error:
            let localizedDescription: String = NSLocalizedString("Error in ObjC code", comment: "Refer to Objective C code")
            let objCError = Log.createError(localizedDescription, domain: "ObjC")
            Log.error(error ?? objCError, message: message, in: cat)
            break
        case .fault:
            Log.fault(message: message, in: cat)
            break
        case .notify:
            Log.notify(message: message, in: cat)
            break
        case .trace:
            Log.trace(message: message, in: cat)
            break
        case .debug:
            Log.debug(message: message, in: cat)
            break
        }
    }
    
    //MARK: - Logging
    
    ///Log errors, where an error object is thrown
    ///Optional message will be added to Crashlytics log.
    public class func error(_ error: Error, message: String?, in category: LogCategory) {
        if let message = message {
            
            //Internal logging (message)
            Logger(subsystem: subsystem, category: category.rawValue).error("Error: \(message, privacy: .public)")
            //Notify crashlytics (log message)
            firebase?.crashlyticsLog(message)
            
        }
        //Internal logging (error)
        Logger(subsystem: subsystem, category: category.rawValue).error("Description: \(error.localizedDescription)")
        //Notify crashlytics (record as error)
        firebase?.crashlyticsError(error)
    }
    
    ///Log faults (Errors in code, but where no error object is provided)
    ///Creates an error in Crashlytics with optional error code
    public class func fault(message: String, code: LogErrorCode? = .defaultErrorCode, in category: LogCategory) {
        //Internal logging
        Logger(subsystem: subsystem, category: category.rawValue).fault("Fault: \(message, privacy: .public)")
        //Create an error and Notify crashlytics
        firebase?.crashlyticsError(Log.createError(message, code: code?.rawValue ?? 0, domain: category.rawValue))
    }
    
    
    ///Log code passes and events that needs attention, but are not necessarily serious
    ///Notifies Crashlytics and Analytics
    public class func notify(message: String, in category: LogCategory) {
        Logger(subsystem: subsystem, category: category.rawValue).fault("Attention: \(message, privacy: .public)")
        //Notify crashlytics
        firebase?.crashlyticsLog("Attention: \(message)")
        //Notify Analytics as well
        firebase?.analyticsLog("Attention", parameters: [
            "message": message,
            "category": category.rawValue,
        ])
    }
    
    ///Logs app flow and user actions
    public class func trace(message: String, in category: LogCategory) {
        //Internal logging
        Logger(subsystem: subsystem, category: category.rawValue).notice("\(message, privacy: .public)")
        //Notify crashlytics
        firebase?.crashlyticsLog(message)
    }
    
    ///Log debug messages
    ///Internal logging only, and not persisted.
    ///Nothing sent to crashlytics
    public class func debug(message: String, in category: LogCategory) {
        //Internal logging only, and not persisted.
        Logger(subsystem: subsystem, category: category.rawValue).debug("\(message, privacy: .public)")
        //Don't notify crashlytics
    }
    
    
    ///Convenience function for creating errors
    public static func createError(_ message: String, code: Int = 0, domain: String = "DefaultErrorDomain", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"
        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])
        
        return error
    }
}
