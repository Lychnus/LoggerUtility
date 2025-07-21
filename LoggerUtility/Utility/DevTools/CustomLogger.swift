//
//  CustomLogger.swift
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
/// Therefore, `SystemLogger` simply returns a fully configured `Logger`,
/// and developers can use Apple's native `.debug`, `.info`, `.notice`, `.error`, `.fault` calls directly on it.

// MARK: - Protocol
/// A protocol that defines a development-only system logger.
public protocol SystemLogger {
    
    /// Provides access to a `Logger` instance using the specified log context.
    ///
    /// - Parameters:
    ///   - context: The logging context, containing subsystem and category.
    /// - Returns: A configured optional `Logger` instance.
    func logger(context: SystemLoggerContext) -> Logger
    
    /// Retrieves logs written by the current process, filtered by time range, severity, and log context.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    ///   - context: Logging context to match subsystem and category.
    /// - Returns: An array of `SystemLoggerEntry` entries matching the filter criteria.
    func retrieveLogs(
        range: SystemLoggerTimeRange,
        severity: OSLogEntryLog.Level?,
        context: SystemLoggerContext
    ) throws -> [SystemLoggerEntry]
    
    /// Exports logs as JSON `Data`, suitable for saving to file or uploading.
    ///
    /// - Parameters:
    ///   - range: The time range from which to fetch logs.
    ///   - severity: Optional log severity filter (e.g. `.info`, `.error`).
    ///   - context: Logging context to match subsystem/category.
    /// - Returns: JSON `Data`composed from array of `SystemLoggerEntry`.
    func exportJSON(
        range: SystemLoggerTimeRange,
        severity: OSLogEntryLog.Level?,
        context: SystemLoggerContext
    ) throws -> Data?
}

// MARK: - Protocol Extension
extension SystemLogger {
    
    /// Provides access to a `Logger` instance with default context of the main bundle and `Development` category.
    ///
    /// - Returns: A configured `Logger` instance.
    public func development() -> Logger {
        logger(context: .development())
    }
    
    /// Provides access to a `Logger` instance with default context of the main bundle and `Production` category.
    ///
    /// - Returns: A configured `Logger` instance.
    public func production() -> Logger {
        logger(context: .production())
    }

    /// Retrieves all `Development` category logs from the last 15 minutes written by the current process.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Returns: An array of `SystemLoggerEntry`
    public func developmentLogs() throws -> [SystemLoggerEntry] {
        try retrieveLogs(range: .lastMinutes(15), severity: nil, context: .development())
    }
    
    /// Retrieves all `Production` category logs from the last 15 minutes written by the current process.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Returns: An array of `SystemLoggerEntry`
    public func productionLogs() throws -> [SystemLoggerEntry] {
        try retrieveLogs(range: .lastMinutes(15), severity: nil, context: .production())
    }

    /// Exports all `Development` category logs as JSON `Data`, suitable for saving to file or uploading.
    /// Consist of all `Development` category logs from the last 1 hour.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Returns: JSON `Data`composed from array of `SystemLoggerEntry`.
    public func exportDevelopmentLogs() throws -> Data? {
        try exportJSON(range: .lastHours(1), severity: nil, context: .development())
    }
    
    
    /// Exports all `Production` category logs as JSON `Data`, suitable for saving to file or uploading.
    /// Consist of all `Production` category logs from the last 1 hour.
    ///
    /// This only works during the current app session. Persistent log access is unavailable on iOS due to system restrictions.
    ///
    /// - Returns: JSON `Data`composed from array of `SystemLoggerEntry`.
    public func exportProductionLogs() throws -> Data? {
        try exportJSON(range: .lastHours(1), severity: nil, context: .production())
    }
}

// MARK: - Helpers
/// This enum represents the source of the log bundle (used as the subsystem).
public enum SystemLoggerBundle {
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
public enum SystemLoggerCategory {
    case development
    case production
    case someCategory(String)

    /// Readable textual description for the Logger category.
    internal var textualDescription: String {
        switch self {
            case .development:
                return "Development"
            case .production:
                return "Production"
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
public enum SystemLoggerTimeRange {
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
public struct SystemLoggerContext {
    public let bundle: SystemLoggerBundle
    public let category: SystemLoggerCategory

    /// Resolved subsystem string for Logger.
    internal var bundleTextualDescription: String {
        return bundle.textualDescription
    }

    /// Resolved category string for Logger.
    internal var categoryTextualDescription: String {
        return category.textualDescription
    }

    /// Creates a default log context using the main bundle and `Development` category.
    ///
    /// - Parameters:
    ///   - bundle: The logging bundle source (defaults to main bundle).
    /// - Returns: An instance of `SystemLoggerContext` configured with defaults.
    public static func development(bundle: SystemLoggerBundle = .mainBundle) -> SystemLoggerContext {
        .init(bundle: bundle, category: .development)
    }
    
    /// Creates a default log context using the main bundle and `Production` category.
    ///
    /// - Parameters:
    ///   - bundle: The logging bundle source (defaults to main bundle).
    /// - Returns: An instance of `SystemLoggerContext` configured with defaults.
    public static func production(bundle: SystemLoggerBundle = .mainBundle) -> SystemLoggerContext {
        .init(bundle: bundle, category: .production)
    }
}

/// A codable representation of a single log entry retrieved from the unified logging system.
/// This model mirrors `OSLogEntryLog` fields relevant for external representation.
public struct SystemLoggerEntry: Codable {
    
    /// The timestamp at which the log entry was recorded.
    public let date: Date

    /// The log subsystem that emitted the log (typically the bundle identifier).
    public let subsystem: String

    /// The category associated with the log (e.g., component, layer, or module).
    public let category: String

    /// The severity level of the log (e.g., `info`, `error`, `fault`).
    public let level: String

    /// The composed and formatted message that was logged.
    public let composedMessage: String
}

// MARK: - Implementation
/// This class is responsible for logging action using Apple's unified logging system.
/// It provides structured, context-aware logging to support subsystem and category differentiation.
internal class CustomLogger: SystemLogger {
    
    /// Singleton instance.
    internal static let shared = CustomLogger()
    
    /// Secured initializer to enforce `.shared` usage.
    private init() { }
}

// MARK: - Protocol Conformance
extension CustomLogger {

    internal func logger(context: SystemLoggerContext) -> Logger {
        return Logger(subsystem: context.bundleTextualDescription, category: context.categoryTextualDescription)
    }
    
    internal func retrieveLogs(
        range: SystemLoggerTimeRange,
        severity: OSLogEntryLog.Level?,
        context: SystemLoggerContext
    ) throws -> [SystemLoggerEntry] {
        
        // Initialize store for current process.
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let startPosition = store.position(date: range.startDate)
        
        // Get all entries from the start date.
        let allEntries = (try store.getEntries(at: startPosition)).compactMap { $0 as? OSLogEntryLog }
        
        // Filter and convert log entries.
        let filteredEntries = allEntries
            .filter { entry in
                let matchesSeverity = severity.map { $0 == entry.level } ?? true
                let matchesSubsystem = context.bundleTextualDescription == entry.subsystem
                let matchesCategory = context.categoryTextualDescription == entry.category
                return matchesSeverity && matchesSubsystem && matchesCategory
            }
        
        let logEntries = filteredEntries
            .map { entry in
                SystemLoggerEntry(
                    date: entry.date,
                    subsystem: entry.subsystem,
                    category: entry.category,
                    level: entry.level.description,
                    composedMessage: entry.composedMessage
                )
            }
        
        return logEntries
    }
    
    internal func exportJSON(
        range: SystemLoggerTimeRange,
        severity: OSLogEntryLog.Level?,
        context: SystemLoggerContext
    ) throws -> Data? {
        
        // Get logs.
        let logs = try retrieveLogs(range: range, severity: severity, context: context)
        if logs.isEmpty { return nil }
        
        // Convert to DTOs.
        let exportable = logs.map { log in
            SystemLoggerEntry(
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
        let encoded = try encoder.encode(exportable)
        
        return encoded
    }
}

/// This extension is used on exporting Log severity level.
public extension OSLogEntryLog.Level {
    
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
extension CustomLogger {
    
    /// Returns a new, isolated instance of `CustomLogger` for testing purposes.
    ///
    /// - Returns: A fresh `CustomLogger` instance, separate from the shared singleton.
    ///
    /// Use this method in tests to access isolated instance.
    internal static func mock() -> CustomLogger {
        CustomLogger()
    }
}
#endif

#endif
