import XCTest

@testable import CitySearch

final class CitySearchUITests: XCTestCase {
    
    private let allCities = [
        "Bangkok, TH",
        "Berlin, DE",
        "London, GB",
        "Madrid, ES",
        "New York, US",
        "Paris, FR",
    ]
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: Search
    
    @MainActor func testSearch_shouldShowPlaceholder_givenNoSearchInput() async throws {
        launchApp()
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: [])
        verifyPlaceholder(visible: true)
    }
    
    @MainActor func testSearch_shouldShowNoCities_givenQueryMatchingNoCities() async throws {
        launchApp()
        enterSearch(text: "z")
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: [])
        verifyPlaceholder(visible: true)
    }

    @MainActor func testSearch_shouldShowOneCity_givenQueryMatchingOneCity() async throws {
        launchApp()
        enterSearch(text: "P")
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: ["Paris, FR"])
        verifyPlaceholder(visible: false)
    }

    @MainActor func testSearch_shouldShowMatchingCities_givenQueryMatchingSomeCities() async throws {
        launchApp()
        enterSearch(text: "B")
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: ["Bangkok, TH", "Berlin, DE"])
        verifyPlaceholder(visible: false)
    }

    @MainActor func testSearch_shouldShowPlaceholder_givenSearchCancelled() async throws {
        launchApp()
        enterSearch(text: "P")
        verifySearchResults(cells: ["Paris, FR"])
        verifyPlaceholder(visible: false)
        clearSearch()
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: [])
        verifyPlaceholder(visible: true)
    }

    @MainActor func testSearch_shouldShowOneCity_givenFinalQueryMatchingOneCity() async throws {
        launchApp()
        enterSearch(text: "P")
        clearSearch()
        enterSearch(text: "M")
        addScreenshot(name: "Search Screen")
        verifySearchResults(cells: ["Madrid, ES"])
        verifyPlaceholder(visible: false)
    }
    
    // MARK: Map
    
    @MainActor func testSearch_shouldShowMap_whenCellIsTapped() {
        launchApp()
        enterSearch(text: "P")
        addScreenshot(name: "Search Screen")
        tapSearchResult(at: 0)
        let mapView = app
            .descendants(matching: .map)
            .firstMatch
        let mapExists = mapView.waitForExistence(timeout: 0.5)
        XCTAssertTrue(mapExists, "Expected map not visible")
        addScreenshot(name: "Map Screen")
    }

    // MARK: Helpers

    private func launchApp() {
        app.launchArguments = ["test"]
        app.launch()
        addScreenshot(name: "Launch Screen")
    }
    
    private func enterSearch(text: String) {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText(text)
    }
    
    private func clearSearch() {
        let searchField = app.searchFields.firstMatch
        let clearButton = searchField.buttons.element(boundBy: 0)
        clearButton.tap()
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
    
    private func verifyPlaceholder(visible: Bool, file: StaticString = #file, line: UInt = #line) {
        let placeholderLabel = app
            .descendants(matching: .staticText)
            .matching(identifier: "placeholder")
            .firstMatch
        let exists = placeholderLabel.waitForExistence(timeout: 0.1)
        XCTAssertEqual(exists, visible, file: file, line: line)
    }
    
    private func tapSearchResult(at index: Int) {
        let cell = app
            .descendants(matching: .collectionView)
            .matching(identifier: "search-results")
            .cells
            .element(boundBy: 0)
        cell.tap()
    }
    
    func addScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
