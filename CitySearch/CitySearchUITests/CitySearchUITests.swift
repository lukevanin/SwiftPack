//
//  CitySearchUITests.swift
//  CitySearchUITests
//
//  Created by Luke Van In on 2022/06/07.
//

import XCTest

@testable import CitySearch

final class CitySearchUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    @MainActor func testSearch_shouldShowAllCities_whenLoaded() async throws {
        launchApp()
        
        let cells = [
            "Bangkok, TH",
            "Berlin, DE",
            "London, GB",
            "Madrid, ES",
            "New York, US",
            "Paris, FR",
        ]
        
        let collectionView = app
            .descendants(matching: .collectionView)
            .matching(identifier: "search-results")
        XCTAssertEqual(collectionView.cells.count, 6)
        cells.enumerated().forEach { index, cell in
            let titleLabel = collectionView
                .cells
                .element(boundBy: index)
                .descendants(matching: .staticText)
                .matching(identifier: "title")
                .firstMatch
                .label
            XCTAssertEqual(titleLabel, cell)
        }
    }
    
    private func launchApp() {
        app.launchArguments = ["test"]
        app.launch()
    }
}
