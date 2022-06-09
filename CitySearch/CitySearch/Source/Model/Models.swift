import Foundation
import Combine

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
protocol CitySearchModelProtocol {
    
    /// Cities from the last search request. This should be an `CurrentValueSubject` or other subject
    /// type that offers persistent behaviour. We use a type-erased `AnyPublisher` here instead of
    /// exposing the underlying subject, so that users of our class cannot accidentally modify
    /// search results.
    var citiesPublisher: AnyPublisher<[City], Never> { get }
    
    
    func searchByName(prefix: String)
}
