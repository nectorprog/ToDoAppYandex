import CocoaLumberjackSwift

class LoggerSetup {
    static func configure() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        DDLogInfo("Logger configured successfully")
    }
}
