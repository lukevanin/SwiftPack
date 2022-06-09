import Foundation

///
/// A collection of cities.
///
struct CitiesRepository: CitiesRepositoryProtocol {
    
    /// List of all cities.
    let cities: [City]
    
    /// Index where the key is the name of a city, and value is the index of the city in the `cities` array.
    let nameIndex: TextIndex
    
    ///
    /// Searches for cities whose name starts with the given prefix.
    ///
    /// - Parameter prefix: Start of the name of the cities to search for.
    /// - Returns: Sequence containing cities.
    ///
    func searchByName(prefix: String) -> AnySequence<City> {
        // Look up the cities matching the given prefix.
        let indices = AnySequence(nameIndex.search(prefix: prefix))
        // Create an iterator that returns the cities for the indices from our
        // search results.
        let matchingCities = indices.lazy.map { index in
            cities[index]
        }
        return AnySequence(matchingCities)
    }
}
