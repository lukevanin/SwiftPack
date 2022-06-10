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
    
    @MainActor func testSearch_shouldShowAllCities_givenNoSearchInput() async throws {
        launchApp()
        verifySearchResults(cells: [
            "Bangkok, TH",
            "Berlin, DE",
            "London, GB",
            "Madrid, ES",
            "New York, US",
            "Paris, FR",
        ])
    }
    
    @MainActor func testSearch_shouldShowNoCities_givenQueryMatchingNoCities() async throws {
        launchApp()
        enterSearch(text: "z")
        addScreenshot()
        verifySearchResults(cells: [])
    }

    @MainActor func testSearch_shouldShowNoCities_givenQueryMatchingOneCity() async throws {
        launchApp()
        enterSearch(text: "p")
        addScreenshot()
        verifySearchResults(cells: ["Paris, FR"])
    }

    @MainActor func testSearch_shouldShowNoCities_givenQueryMatchingSomeCities() async throws {
        launchApp()
        enterSearch(text: "b")
        addScreenshot()
        verifySearchResults(cells: ["Bangkok, TH", "Berlin, DE"])
    }
    
    // MARK: Helpers

    private func launchApp() {
        app.launchArguments = ["test"]
        app.launch()
    }
    
    private func enterSearch(text: String) {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText(text)
    }
    
    private func verifySearchResults(cells: [String], file: StaticString = #file, line: UInt = #line) {
        let collectionView = app
            .descendants(matching: .collectionView)
            .matching(identifier: "search-results")
        XCTAssertEqual(collectionView.cells.count, cells.count, file: file, line: line)
        cells.enumerated().forEach { index, cell in
            let titleLabel = collectionView
                .cells
                .element(boundBy: index)
                .descendants(matching: .staticText)
                .matching(identifier: "title")
                .firstMatch
                .label
            XCTAssertEqual(titleLabel, cell, file: file, line: line)
        }
    }
    
    func addScreenshot() {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Search Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
