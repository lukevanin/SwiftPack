import Foundation


///
/// ```
/// "coord":{
///     "lon":34.283333,
///     "lat":44.549999
/// }
/// ```
///
struct Coordinate: Equatable {
    // Longitude
    let lon: Double
    
    // Latitude
    let lat: Double
}


///
/// ```
/// {
///     "country":"UA",
///     "name":"Hurzuf",
///     "_id":707860,
///     "coord":{
///         "lon":34.283333,
///         "lat":44.549999
///     }
/// }
/// ```
///
struct City: Equatable {
    
    /// Unique identifier
    let _id: UInt64
    
    /// Country
    let country: String
    
    /// Name of the city
    let name: String
    
    /// Geographic location of the city
    let coord: Coordinate
}


///
/// A collection of cities.
///
struct CitiesRepository {
    
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
        AnySequence([])
    }
}
