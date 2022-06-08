import XCTest

extension XCTestCase {
    
    func defaultMetrics() -> [XCTMetric] {
        [
            XCTCPUMetric(limitingToCurrentThread: true),
            XCTMemoryMetric(),
            XCTClockMetric(),
        ]
    }
}
