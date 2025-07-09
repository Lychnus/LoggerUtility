//
//  AppLoggerTests.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

#if canImport(OSLog)
import Foundation
import Testing
import OSLog
@testable import LoggerUtility

// MARK: - Test Suite for LogBundle
@Suite("AppLogger-LogBundle Tests")
struct LogBundleTests {
    
    @Test("Main bundle returns correct identifier")
    func testMainBundleIdentifier() {
        let bundle = LogBundle.mainBundle
        let description = bundle.textualDescription
        
        #expect(description == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
    }
    
    @Test("Custom bundle returns provided identifier")
    func testCustomBundleIdentifier() {
        let customIdentifier = "com.example.test"
        let bundle = LogBundle.someBundle(customIdentifier)
        let description = bundle.textualDescription
        
        #expect(description == customIdentifier)
    }
}

// MARK: - Test Suite for LogCategory
@Suite("AppLogger-LogCategory Tests")
struct LogCategoryTests {
    
    @Test("Development category returns correct description")
    func testDevelopmentCategoryDescription() {
        let category = LogCategory.development
        let description = category.textualDescription
        
        let expectedDescription = "Development"
        #expect(description == expectedDescription)
    }
    
    @Test("Production category returns correct description")
    func testProductionCategoryDescription() {
        let category = LogCategory.production
        let description = category.textualDescription
        
        let expectedDescription = "Production"
        #expect(description == expectedDescription)
    }
    
    @Test("Some category returns provided string")
    func testSomeCategoryDescription() {
        let categoryName = "NetworkManager"
        let category = LogCategory.someCategory(categoryName)
        let description = category.textualDescription
        
        #expect(description == categoryName)
    }
}

// MARK: - Test Suite for LogTimeRange
@Suite("AppLogger-LogTimeRange Tests")
struct LogTimeRangeTests {
    
    @Test("Last minutes calculates correct start date")
    func testLastMinutesRange() {
        let minutes = 30
        let range = LogTimeRange.lastMinutes(minutes)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-60 * minutes))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0) // Within 1 second
    }
    
    @Test("Last hours calculates correct start date")
    func testLastHoursRange() {
        let hours = 2
        let range = LogTimeRange.lastHours(hours)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-3600 * hours))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Last days calculates correct start date")
    func testLastDaysRange() {
        let days = 7
        let range = LogTimeRange.lastDays(days)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-86400 * days))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Since date returns provided date")
    func testSinceDateRange() {
        let testDate = Date(timeIntervalSince1970: 1000000)
        let range = LogTimeRange.since(testDate)
        let startDate = range.startDate
        
        #expect(startDate == testDate)
    }
    
    @Test("All available returns distant past")
    func testAllAvailableRange() {
        let range = LogTimeRange.allAvailable
        let startDate = range.startDate
        
        #expect(startDate == .distantPast)
    }
}

// MARK: - Test Suite for LogContext
@Suite("AppLogger-LogContext Tests")
struct LogContextTests {
    
    @Test("Default context creates with main bundle and development category")
    func testDefaultContext() {
        let context = LogContext.development()
        
        #expect(context.bundleTextualDescription == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
        #expect(context.categoryTextualDescription == "Development")
    }
    
    @Test("Custom context with specific bundle and category")
    func testCustomContext() {
        let customBundle = LogBundle.someBundle("com.test.app")
        let customCategory = LogCategory.someCategory("TestCategory")
        let context = LogContext(bundle: customBundle, category: customCategory)
        
        #expect(context.bundleTextualDescription == "com.test.app")
        #expect(context.categoryTextualDescription == "TestCategory")
    }
}

// MARK: - Test Suite for AppLogger
@Suite("AppLogger Tests")
struct AppLoggerTests {
    
    @Test("Log call will not work while testing")
    func testLogCall() throws {
        let logger = AppLogger.mock().logger()
        
        #expect(logger == nil)
    }
}

#endif
