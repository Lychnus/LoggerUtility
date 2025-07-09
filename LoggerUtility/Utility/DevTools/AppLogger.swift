//
//  AppLogger.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

#if canImport(OSLog)
import OSLog

// MARK: - Note
/// Why only returning `Logger`?
///
/// Apple’s `Logger` API requires the use of string interpolation literals at the call site.
/// This enables:
/// - Compile-time validation
/// - Compiler-generated `OSLogMessage`
/// - Structured logging with privacy support
///
/// Here is the note from `OSLogMessage`:
/// Important - You don’t create instances of OSLogMessage directly. Instead, the system creates them for you when writing messages to the unified logging system using a Logger.
///
/// Because of this design, wrapping `.debug(message:...)`, `.info(message:...)`, etc. in a custom method
/// would prevent proper `OSLogMessage` generation, resulting in compile time errors.
///
/// Therefore, `AppLogger` simply returns a fully configured `Logger`,
/// and developers use Apple's native `.debug`, `.info`, `.notice`, `.error`, `.fault` calls directly on it.

// MARK: - Protocol
/// A protocol that defines a development-only system logger.
public protocol SystemLogger {
    
    /// Provides access to a `Logger` instance using the specified log context.
    ///
    /// - Parameters:
    ///   - context: The logging context, containing subsystem and category.
    /// - Returns: A configured optional `Logger` instance.
    ///
    /// - Note: The return value is optional to allow suppression of logging in certain environments.
    /// Developers should use optional chaining (e.g., `log(context: _)?.info(...)`) to avoid unintended output during testing.
    func logger(context: LogContext) -> Logger?
    
    /// Retrieves logs written by the current process, filtered by time range, severity, and log context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    ///   - context: Optional logging context to match subsystem and category.
    /// - Returns: An array of `OSLogEntryLog` entries matching the filter criteria.
    func retrieveLogs(
        range: LogTimeRange,
        severity: OSLogEntryLog.Level?,
        context: LogContext?
    ) throws -> [OSLogEntryLog]
    
    /// Exports logs as JSON `Data`, suitable for saving to file or uploading.
    ///
    /// - Parameters:
    ///   - range: Time range to include.
    ///   - severity: Optional filter for severity.
    ///   - context: Optional context to match subsystem/category.
    /// - Returns: JSON `Data` if export succeeded, otherwise `nil`.
    func exportJSON(
        range: LogTimeRange,
        severity: OSLogEntryLog.Level?,
        context: LogContext?
    ) -> Data?
}

// MARK: - Protocol Extension
extension SystemLogger {
    
    /// Provides access to a `Logger` instance with default context of the main bundle and automatic file / function category.
    ///
    /// - Returns: A configured optional `Logger` instance.
    ///
    /// - Note: The return value is optional to allow suppression of logging in certain environments.
    /// Developers should use optional chaining (e.g., `log(context: _)?.info(...)`) to avoid unintended output during testing.
    public func logger() -> Logger? {
        logger(context: .default())
    }

    /// Retrieves logs written by the current process using the default time range, without filtering by severity or context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Returns: An array of `OSLogEntryLog` entries from the last 15 minutes.
    public func retrieveLogs() throws -> [OSLogEntryLog] {
        try retrieveLogs(range: .lastMinutes(15), severity: nil, context: nil)
    }

    /// Retrieves logs written by the current process for the specified time range, without filtering by severity or context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    /// - Returns: An array of `OSLogEntryLog` entries matching the filter criteria.
    public func retrieveLogs(range: LogTimeRange) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: range, severity: nil, context: nil)
    }

    /// Retrieves logs written by the current process, filtered by severity only.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    /// - Returns: An array of `OSLogEntryLog` entries from the last 15 minutes matching the filter criteria.
    public func retrieveLogs(severity: OSLogEntryLog.Level?) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: .lastMinutes(15), severity: severity, context: nil)
    }

    /// Retrieves logs written by the current process, filtered by context only.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - context: Optional logging context to match subsystem and category.
    /// - Returns: An array of `OSLogEntryLog` entries from the last 15 minutes matching the filter criteria.
    public func retrieveLogs(context: LogContext?) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: .lastMinutes(15), severity: nil, context: context)
    }

    /// Retrieves logs written by the current process for a given time range and severity.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    /// - Returns: An array of `OSLogEntryLog` entries matching the filter criteria.
    public func retrieveLogs(range: LogTimeRange, severity: OSLogEntryLog.Level?) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: range, severity: severity, context: nil)
    }

    /// Retrieves logs written by the current process for a given time range and context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    ///   - context: Optional logging context to match subsystem and category.
    /// - Returns: An array of `OSLogEntryLog` entries matching the filter criteria.
    public func retrieveLogs(range: LogTimeRange, context: LogContext?) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: range, severity: nil, context: context)
    }

    /// Retrieves logs written by the current process, filtered by severity and context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    ///   - context: Optional logging context to match subsystem and category.
    /// - Returns: An array of `OSLogEntryLog` entries from the last 15 minutes matching the filter criteria.
    public func retrieveLogs(severity: OSLogEntryLog.Level?, context: LogContext?) throws -> [OSLogEntryLog] {
        try retrieveLogs(range: .lastMinutes(15), severity: severity, context: context)
    }
    
    /// Exports logs as JSON `Data`, suitable for saving to file or uploading.
    ///
    /// Uses the default time range with no severity or context filtering.
    ///
    /// - Returns: JSON `Data` from the last 1 hour if export succeeded, otherwise `nil`.
    public func exportJSON() -> Data? {
        exportJSON(range: .lastHours(1), severity: nil, context: nil)
    }
    
    /// Exports logs as JSON `Data` for a specific time range.
    ///
    /// - Parameter range: Time range to include.
    /// - Returns: JSON `Data`matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(range: LogTimeRange) -> Data? {
        exportJSON(range: range, severity: nil, context: nil)
    }

    /// Exports logs as JSON `Data`, filtered by severity only.
    ///
    /// - Parameter severity: Optional filter for severity (e.g. `.info`, `.error`).
    /// - Returns: JSON `Data` from the last 1 hour matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(severity: OSLogEntryLog.Level?) -> Data? {
        exportJSON(range: .lastHours(1), severity: severity, context: nil)
    }

    /// Exports logs as JSON `Data`, filtered by context only.
    ///
    /// - Parameter context: Optional context to match subsystem/category.
    /// - Returns: JSON `Data` from the last 1 hour matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(context: LogContext?) -> Data? {
        exportJSON(range: .lastHours(1), severity: nil, context: context)
    }

    /// Exports logs as JSON `Data` for a specific time range and severity filter.
    ///
    /// - Parameters:
    ///   - range: Time range to include.
    ///   - severity: Optional filter for severity.
    /// - Returns: JSON `Data` matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(range: LogTimeRange, severity: OSLogEntryLog.Level?) -> Data? {
        exportJSON(range: range, severity: severity, context: nil)
    }

    /// Exports logs as JSON `Data` for a specific time range and context.
    ///
    /// - Parameters:
    ///   - range: Time range to include.
    ///   - context: Optional context to match subsystem/category.
    /// - Returns: JSON `Data` matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(range: LogTimeRange, context: LogContext?) -> Data? {
        exportJSON(range: range, severity: nil, context: context)
    }

    /// Exports logs as JSON `Data`, filtered by severity and context.
    ///
    /// - Parameters:
    ///   - severity: Optional filter for severity.
    ///   - context: Optional context to match subsystem/category.
    /// - Returns: JSON `Data` from the last 1 hour matching the filter criteria if export succeeded, otherwise `nil`.
    public func exportJSON(severity: OSLogEntryLog.Level?, context: LogContext?) -> Data? {
        exportJSON(range: .lastHours(1), severity: severity, context: context)
    }
}

// MARK: - Helpers
/// This enum represents the source of the log bundle (used as the subsystem).
public enum LogBundle {
    case mainBundle
    case someBundle(String)

    /// Readable textual description for the Logger subsystem.
    internal var textualDescription: String {
        switch self {
            case .mainBundle:
                return Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier"
            case .someBundle(let identifier):
                return identifier
        }
    }
}

/// This enum represents the category of the log.
public enum LogCategory {
    case fileCategory(file: String = #file, function: String = #function)
    case someCategory(String)

    /// Readable textual description for the Logger category.
    internal var textualDescription: String {
        switch self {
            case .fileCategory(let file, let function):
                return "File: \((file as NSString).lastPathComponent), Function: \(function)"
            case .someCategory(let identifier):
                return identifier
        }
    }
}

/// A convenience enum used to define time-based log query ranges.
///
/// This enum abstracts common intervals like minutes, hours, or days,
/// and also supports a custom starting `Date`. It is used to determine
/// the lower bound (`startDate`) when querying the system log store.
public enum LogTimeRange {
    /// Retrieves logs from the last _N_ minutes.
    case lastMinutes(Int)
    
    /// Retrieves logs from the last _N_ hours.
    case lastHours(Int)
    
    /// Retrieves logs from the last _N_ days.
    case lastDays(Int)
    
    /// Retrieves logs since the provided date.
    case since(Date)
    
    /// Retrieves all logs.
    case allAvailable
    
    /// Computes the `Date` representing the start of the log query range.
    internal var startDate: Date {
        switch self {
            case .lastMinutes(let minutes):
                return Date().addingTimeInterval(TimeInterval(-60 * minutes))
            case .lastHours(let hours):
                return Date().addingTimeInterval(TimeInterval(-3600 * hours))
            case .lastDays(let days):
                return Date().addingTimeInterval(TimeInterval(-86400 * days))
            case .since(let date):
                return date
            case .allAvailable:
                return .distantPast
        }
    }
}

/// This struct represents contextual information for the log, including subsystem and category.
public struct LogContext {
    let bundle: LogBundle
    let category: LogCategory

    /// Resolved subsystem string for Logger.
    internal var bundleTextualDescription: String {
        return bundle.textualDescription
    }

    /// Resolved category string for Logger.
    internal var categoryTextualDescription: String {
        return category.textualDescription
    }

    /// Creates a default log context using the main bundle and automatic file / function category.
    ///
    /// - Parameters:
    ///   - bundle: The logging bundle source (defaults to main bundle).
    ///   - file: File name for automatic category resolution.
    ///   - function: Function name for automatic category resolution.
    /// - Returns: An instance of `LogContext` configured with defaults.
    public static func `default`(bundle: LogBundle = .mainBundle, file: String = #file, function: String = #function) -> LogContext {
        .init(bundle: bundle, category: .fileCategory(file: file, function: function))
    }
}

// MARK: - Implementation
/// This class is responsible for logging action using Apple's unified logging system.
/// It provides structured, context-aware logging to support subsystem and category differentiation.
internal class AppLogger: SystemLogger {
    
    /// Singleton instance.
    internal static let shared = AppLogger()
    
    /// Secured initializer to enforce `.shared` usage.
    private init() { }
    
    /// Creates a new `Logger` instance using the given context.
    ///
    /// - Parameters:
    ///   - context: Log context describing subsystem and category.
    /// - Returns: An instance of `Logger` configured with the context.
    private func handle(context: LogContext) -> Logger {
        Logger(subsystem: context.bundleTextualDescription, category: context.categoryTextualDescription)
    }
}

// MARK: - Protocol Conformance
extension AppLogger {

    internal func logger(context: LogContext = .default()) -> Logger? {
        // Eliminate the log behavior in test environment.
        if DevTools.isTesting { return nil }
        
        return handle(context: context)
    }
    
    internal func retrieveLogs(
        range: LogTimeRange = .lastMinutes(15),
        severity: OSLogEntryLog.Level? = nil,
        context: LogContext? = nil
    ) throws -> [OSLogEntryLog] {
        
        // Initialize store for current process.
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let startPosition = store.position(date: range.startDate)
        
        // Get all entries from the start date.
        let allEntries = try store.getEntries(at: startPosition)
        
        // Filter only logs.
        let logEntries = allEntries
            .compactMap { $0 as? OSLogEntryLog }
            .filter { entry in
                let matchesSeverity = severity.map { $0 == entry.level } ?? true
                let matchesSubsystem = context.map { $0.bundleTextualDescription == entry.subsystem } ?? true
                let matchesCategory = context.map { $0.categoryTextualDescription == entry.category } ?? true
                return matchesSeverity && matchesSubsystem && matchesCategory
            }
        
        return logEntries
    }
    
    internal func exportJSON(
        range: LogTimeRange = .lastHours(1),
        severity: OSLogEntryLog.Level? = nil,
        context: LogContext? = nil
    ) -> Data? {
        
        /// DTO struct to use on encoding.
        struct ExportedLog: Codable {
            let date: Date
            let subsystem: String
            let category: String
            let level: String
            let composedMessage: String
        }
        
        do {
            // Get logs.
            let logs = try retrieveLogs(range: range, severity: severity, context: context)
            
            // Convert to DTOs.
            let exportable = logs.map { log in
                ExportedLog(
                    date: log.date,
                    subsystem: log.subsystem,
                    category: log.category,
                    level: log.level.description,
                    composedMessage: log.composedMessage
                )
            }
            
            // Convert to JSON.
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            return try encoder.encode(exportable)
        } catch {
            #if DEBUG
            print("[🔴 - Error] Log export failed: \(error)")
            #endif
            return nil
        }
    }
}

/// This extension will be used on exporting Log severity level.
fileprivate extension OSLogEntryLog.Level {
    
    /// Textual description of Log's severity level.
    var description: String {
        switch self {
            case .undefined: return "undefined"
            case .debug: return "debug"
            case .info: return "info"
            case .notice: return "notice"
            case .error: return "error"
            case .fault: return "fault"
            @unknown default: return "unknown"
        }
    }
}

// MARK: - Factory Initializer
#if DEBUG
extension AppLogger {
    
    /// Returns a new, isolated instance of `AppLogger` for testing purposes.
    ///
    /// - Returns: A fresh `AppLogger` instance, separate from the shared singleton.
    ///
    /// Use this method in tests to avoid side effects and ensure output isolation.
    internal static func mock() -> AppLogger {
        AppLogger()
    }
}
#endif

#endif
