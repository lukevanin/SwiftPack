import Foundation
import Combine

///
/// City search model
///
/// Provides capabilities for search for citities by name. Uses a cities repository to retrieve information.`
///
/// ## Architecture
///
/// It may seem overkill to have the model and repository implemented as separate objects. For this demo
/// this may be a valid criticism. However in a real world application, and even for our toy example, this
/// separation can be beneficial.
///
/// In our case we can separate the code that manages the search queue and rresults, from the logic that
/// produces our data. The result is that we end up with two simpler pieces of code which are easier to
/// reason about and test.
///
final class CitySearchModel: CitySearchModelProtocol {
    
    /// Cities from the last search request. We use `compactMap` to filter out and remove the initial nil
    /// value from the current value subject. 
    lazy var citiesPublisher = citiesSubject.eraseToAnyPublisher()
    
    /// Internal subject used to publish results from search queries.
    private let citiesSubject = CurrentValueSubject<AnyCollection<City>?, Never>(nil)
    
    /// Repository providing cities in a synchronous manner
    private let citiesRepository: CitiesRepositoryProtocol
    
    init(citiesRepository: CitiesRepositoryProtocol) {
        self.citiesRepository = citiesRepository
    }

    ///
    /// Searches for cities whose name matches a given prefix. Search results are published to the
    /// `citiesPublisher` property.
    ///
    /// - Parameters prefix: Prefix of the cities to search for.
    ///
    func searchByName(prefix: String) {
        Task { [weak self, citiesRepository] in
            let cities: AnyCollection<City>?
            if prefix.isEmpty == true {
                // Publish nil when prefix is empty.
                cities = nil
            }
            else {
                // Search for cities.
                cities = await citiesRepository.searchByName(prefix: prefix)
            }
            self?.publishCities(cities)
        }
    }
    
    ///
    /// Updates the published cities with the results from a search.
    ///
    private func publishCities(_ cities: AnyCollection<City>?) {
        citiesSubject.send(cities)
    }
}
