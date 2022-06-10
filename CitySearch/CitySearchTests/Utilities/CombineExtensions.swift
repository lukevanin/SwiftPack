import Foundation
import Combine

extension Task where Success == Never, Failure == Never {
    ///
    /// Sleeps for an amount of time defined in seconds. Seconds are rounded to the nearest nanosecond.
    ///
    /// Equivalent to calling `sleep(nanoseconds: time>)` where time is the equivalent number
    /// of nanoseconds.
    ///
    static func sleep(seconds: TimeInterval) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1e9))
    }
}
