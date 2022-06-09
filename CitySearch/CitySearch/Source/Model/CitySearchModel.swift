import Foundation
import Combine

///
/// City search model
///
/// Provides capabilities for search for citities by name.
///
/// The search model maintains state about a search operation, including enqueing search requests, and
/// returning search results asynchronously through a publisher.
///
/// We use a publisher to provide results, so that users of our class not dependant on waiting for results from
/// the class. It also allows the model to modify search results after the original request is made, which would
/// not be possible if we use async/await for example. The reason we might want to be able to change the
/// search results is if we are loading results incrementally, and we want to update our users as changes
/// arrive, without requiring our users to use polling.
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
final class CitySearchModel {
    
    /// Cities from the last search request. We use a type-erased `AnyPublisher` here instead of
    /// exposing the underlying subject, so that users of our class cannot accidentally modify our queue
    /// and interfere with other users of this  class.
    lazy var citiesPublisher = citiesSubject.eraseToAnyPublisher()
    
    /// Internal subject used to publish results from search queries.
    private let citiesSubject = CurrentValueSubject<[City], Never>([])
    
    /// Repository providing cities in a synchronous manner
    private let citiesRepository: CitiesRepositoryProtocol
    
    init(citiesRepository: CitiesRepositoryProtocol) {
        self.citiesRepository = citiesRepository
    }

    ///
    /// Searches for cities whose name matches a given prefix.
    ///
    func searchByName(prefix: String) {
        
    }
}
