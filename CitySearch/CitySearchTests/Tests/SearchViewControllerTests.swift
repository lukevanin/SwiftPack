import XCTest
import Combine

@testable import CitySearch

final class SearchViewControllerTests: XCTestCase {
    
    private var mockModel: MockCitySearchModel!
    private var subject: SearchViewController!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        mockModel = MockCitySearchModel()
        subject = SearchViewController(
            model: mockModel,
            makeCellConfiguration: { cell in
                SearchResultViewContentConfiguration(
                    title: cell.name,
                    subtitle: ""
                )
            },
            selectCell: { city in
                
            }
        )
        cancellables = Set()
        loadView()
    }
    
    override func tearDown() {
        subject = nil
        mockModel = nil
        cancellables = nil
    }
    
    private func loadView() {
        let searchExpectation = expectation(description: "first search")
        mockModel.mockSearchByName = { query in
            searchExpectation.fulfill()
        }
        subject.loadView()
        subject.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        subject.viewDidLoad()
        wait(for: [searchExpectation], timeout: 0.1)
    }
    
    // MARK: View life cycle
    
    @MainActor func testCollectionView_shouldShowNothing_givenNoCities() async throws {
        subject.viewWillAppear(false)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 0)
    }

    @MainActor func testCollectionView_shouldShowCity_givenOneCity() async throws {
        let cities = [City.wellingtonZA()]
        mockModel.citiesSubject.send(cities)
        subject.viewWillAppear(false)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), cities.count)
    }

    @MainActor func testCollectionView_shouldShowCities_givenSomeCities() async throws {
        let cities = [
            City.wellingtonZA(),
            City.foovilleAA(),
            City.footopiaAA(),
        ]
        mockModel.citiesSubject.send(cities)
        subject.viewWillAppear(false)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), cities.count)
    }

    @MainActor func testCollectionView_shouldUpdate_whenModelPublishesChangesAfterViewWillAppear() async throws {
        let cities = [City.wellingtonZA()]
        subject.viewWillAppear(false)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 0)
        mockModel.citiesSubject.send(cities)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), cities.count)
    }

    @MainActor func testCollectionView_shouldNotUpdate_whenModelPublishesChangesAfterViewWillDisappear() async throws {
        let cities = [City.wellingtonZA()]
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        subject.viewWillDisappear(false)
        mockModel.citiesSubject.send(cities)
        try await Task.sleep(seconds: 0.1)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 0)
    }
    
    // MARK: Search

    func testSearchInput_shouldShowNothing_givenNoCities() {
        
    }

    func testSearchInput_shouldShowNothing_givenNoMatchingCities() {
        
    }

    func testSearchInput_shouldShowCities_givenMatchingCities() {
        
    }
    
    func testClearSearch_shouldShowAllCities_givenSomeCities() {
        
    }
}
