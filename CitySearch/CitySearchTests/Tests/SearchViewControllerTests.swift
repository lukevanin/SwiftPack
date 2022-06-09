import XCTest

@testable import CitySearch

final class SearchViewControllerTests: XCTestCase {
    
    private var mockModel: MockCitySearchModel!
    private var subject: SearchViewController!
    
    override func setUp() {
        mockModel = MockCitySearchModel()
        subject = SearchViewController(model: mockModel)
    }
    
    override func tearDown() {
        subject = nil
    }
    
    func testCollectionView_shouldShowNothing_givenNoCities() {
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        XCTAssertEqual(subject.collectionView.numberOfSections, 0)
    }

    func testCollectionView_shouldShowCity_givenOneCity() {
        let cities = [City.wellingtonZA()]
        mockModel.citiesSubject.send(cities)
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 1)
    }

    func testCollectionView_shouldShowCities_givenSomeCities() {
        let cities = [
            City.wellingtonZA(),
            City.foovilleAA(),
            City.footopiaAA(),
        ]
        mockModel.citiesSubject.send(cities)
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 1)
    }

    func testCollectionView_shouldUpdate_whenModelPublishesChangesAfterViewWillAppear() {
        let cities = [City.wellingtonZA()]
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        XCTAssertEqual(subject.collectionView.numberOfSections, 0)
        mockModel.citiesSubject.send(cities)
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 1)
    }

    func testCollectionView_shouldNotUpdate_whenModelPublishesChangesAfterViewWillDisappear() {
        let cities = [City.wellingtonZA()]
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        subject.viewWillDisappear(false)
        mockModel.citiesSubject.send(cities)
        XCTAssertEqual(subject.collectionView.numberOfSections, 0)
    }

    func testSearchInput_shouldShowNothing_givenNoCities() {
        
    }

    func testSearchInput_shouldShowNothing_givenNoMatchingCities() {
        
    }

    func testSearchInput_shouldShowCities_givenMatchingCities() {
        
    }
    
    func testClearSearch_shouldShowAllCities_givenSomeCities() {
        
    }
}
