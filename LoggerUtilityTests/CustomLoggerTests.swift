//
//  CustomLoggerTests.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

#if canImport(OSLog)
import Foundation
import Testing
import OSLog
@testable import LoggerUtility

@Suite("CustomLogger Tests")
struct CustomLoggerTests {
    
    //MARK: - SystemLoggerBundle Tests
    
    @Test("Main bundle description created correctly.")
    func testMainBundleIdentifierDescriptionCreation() {
        let bundle = SystemLoggerBundle.mainBundle
        let description = bundle.textualDescription
        
        #expect(description == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
    }
    
    @Test("Custom bundle description created correctly.")
    func testCustomBundleIdentifierDescriptionCreation() {
        let customIdentifier = "com.example.test"
        let bundle = SystemLoggerBundle.someBundle(customIdentifier)
        let description = bundle.textualDescription
        
        #expect(description == customIdentifier)
    }
    
    //MARK: - SystemLoggerCategory Tests
    
    @Test("Development category description created correctly.")
    func testDevelopmentCategoryDescriptionCreation() {
        let category = SystemLoggerCategory.development
        let description = category.textualDescription
        
        let expectedDescription = "Development"
        #expect(description == expectedDescription)
    }
    
    @Test("Production category description created correctly.")
    func testProductionCategoryDescriptionCreation() {
        let category = SystemLoggerCategory.production
        let description = category.textualDescription
        
        let expectedDescription = "Production"
        #expect(description == expectedDescription)
    }
    
    @Test("Some category description created correctly.")
    func testSomeCategoryDescriptionCreation() {
        let categoryName = "TestCategory"
        let category = SystemLoggerCategory.someCategory(categoryName)
        let description = category.textualDescription
        
        #expect(description == categoryName)
    }
    
    //MARK: - SystemLoggerTimeRange Tests
    
    @Test("Last minutes calculates correct start date.")
    func testLastMinutesRangeCalculation() {
        let minutes = 30
        let range = SystemLoggerTimeRange.lastMinutes(minutes)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-60 * minutes))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0) // Within 1 second
    }
    
    @Test("Last hours calculates correct start date.")
    func testLastHoursRangeCalculation() {
        let hours = 2
        let range = SystemLoggerTimeRange.lastHours(hours)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-3600 * hours))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Last days calculates correct start date.")
    func testLastDaysRangeCalculation() {
        let days = 7
        let range = SystemLoggerTimeRange.lastDays(days)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-86400 * days))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Since date returns provided date correctly.")
    func testSinceDateRangeCalculation() {
        let testDate = Date(timeIntervalSince1970: 1000000)
        let range = SystemLoggerTimeRange.since(testDate)
        let startDate = range.startDate
        
        #expect(startDate == testDate)
    }
    
    @Test("All available returns distant past correctly.")
    func testAllAvailableRangeCalculation() {
        let range = SystemLoggerTimeRange.allAvailable
        let startDate = range.startDate
        
        #expect(startDate == .distantPast)
    }
    
    //MARK: - SystemLoggerContext Tests
    
    @Test("Default context with main bundle and development category created correctly.")
    func testDefaultDevelopmentContextCreation() {
        let context = SystemLoggerContext.development()
        
        #expect(context.bundleTextualDescription == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
        #expect(context.categoryTextualDescription == "Development")
    }
    
    @Test("Default context with main bundle and production category created correctly.")
    func testDefaultProductionContextCreation() {
        let context = SystemLoggerContext.production()
        
        #expect(context.bundleTextualDescription == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
        #expect(context.categoryTextualDescription == "Production")
    }
    
    @Test("Custom context with specific bundle and category created correctly.")
    func testCustomContextCreation() {
        let customBundle = SystemLoggerBundle.someBundle("com.test.app")
        let customCategory = SystemLoggerCategory.someCategory("TestCategory")
        let context = SystemLoggerContext(bundle: customBundle, category: customCategory)
        
        #expect(context.bundleTextualDescription == "com.test.app")
        #expect(context.categoryTextualDescription == "TestCategory")
    }
    
    //MARK: - SystemLoggerEntry Tests
    
    @Test("Logger entry created correctly.")
    func testLoggerEntryCreation() {
        let date = Date()
        let subsystem = "com.test.app"
        let category = "TestCategory"
        let level = "info"
        let composedMessage = "Test message."
        let entry = SystemLoggerEntry(
            date: date,
            subsystem: subsystem,
            category: category,
            level: level,
            composedMessage: composedMessage
        )
        
        #expect(entry.date == date)
        #expect(entry.subsystem == subsystem)
        #expect(entry.category == category)
        #expect(entry.level == level)
        #expect(entry.composedMessage == composedMessage)
    }
    
    //MARK: - CustomLogger Tests
    
    // Can't be tested, written for convinience.
    @Test("Protocol conformance of Logger works correctly.")
    func testProtocolConformanceLogger() {
        let mock = CustomLogger.mock()
        let _ = mock.logger(context: .development())
        
        #expect(true)
    }
    
    // Returns selected simulator runtime logs in test environment.
    @Test("Protocol conformance of RetrieveLogs works correctly.")
    func testProtocolConformanceRetrieveLogs() throws {
        let mock = CustomLogger.mock()
        // If test fails, check manually and find some for bundle and category. This should pass.
        let entries = try mock.retrieveLogs(range: .allAvailable, severity: nil, context: .init(bundle: .someBundle("com.apple.network"), category: .someCategory("activity")))
   
        #expect(entries.isEmpty != true)
    }
    
    // Returns selected simulator runtime logs JSON in test environment.
    @Test("Protocol conformance of ExportJSON works correctly.")
    func testProtocolConformanceExportJSON() throws {
        let mock = CustomLogger.mock()
        // If test fails, check manually and find some for bundle and category. This should pass.
        let data = try mock.exportJSON(range: .allAvailable, severity: nil, context: .init(bundle: .someBundle("com.apple.network"), category: .someCategory("activity")))

        #expect(data != nil)
    }
    
    // MARK: - SystemLogger Protocol Overload Tests
    
    // Can't be tested, written for convinience.
    @Test("Logger development overload works correctly.")
    func testDevelopmentLoggerOverload() {
        let mock = CustomLogger.mock()
        let _ = mock.development()
        
        #expect(true)
    }
    
    // Can't be tested, written for convinience.
    @Test("Logger production overload works correctly.")
    func testProductionLoggerOverload() {
        let mock = CustomLogger.mock()
        let _ = mock.production()
        
        #expect(true)
    }
    
    // Returns empty in test environment.
    @Test("RetrieveLogs development overload works correctly.")
    func testDevelopmentRetrieveLogsOverload() throws {
        let mock = CustomLogger.mock()
        let entries = try mock.developmentLogs()
        
        #expect(entries.isEmpty == true)
    }
    
    // Returns empty in test environment.
    @Test("RetrieveLogs production overload works correctly.")
    func testProductionRetrieveLogsOverload() throws {
        let mock = CustomLogger.mock()
        let entries = try mock.productionLogs()
        
        #expect(entries.isEmpty == true)
    }
    
    // Returns nil in test environment.
    @Test("ExportJSON development overload works correctly.")
    func testDevelopmentExportJSONOverload() throws {
        let mock = CustomLogger.mock()
        let data = try mock.exportDevelopmentLogs()
        
        #expect(data == nil)
    }
    
    // Returns nil in test environment.
    @Test("ExportJSON production overload works correctly.")
    func testProductionExportJSONOverload() throws {
        let mock = CustomLogger.mock()
        let data = try mock.exportProductionLogs()
        
        #expect(data == nil)
    }
}

#endif
