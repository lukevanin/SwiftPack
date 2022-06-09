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
    }

    func testCollectionView_shouldShowAllCities_givenSomeCities() {
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
    }

    func testCollectionView_shouldUpdate_whenModelPublishesChangesAfterViewWillAppear() {
        subject.viewDidLoad()
        subject.viewWillAppear(false)
    }

    func testCollectionView_shouldNotUpdate_whenModelPublishesChangesAfterViewWillDisappear() {
        subject.viewDidLoad()
        subject.viewWillAppear(false)
        subject.viewDidAppear(false)
        subject.viewWillDisappear(false)
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
