import Foundation

struct TestCitiesRepositoryBuilder: BuilderProtocol {
    
    var index: TextIndex = CaseInsensitiveTextIndex(index: TrieTextIndex())
    var makeKey: (City) -> String
    
    func build() -> CitiesRepositoryProtocol {
        let cities = [
            City(_id: 1609350, country: "TH", name: "Bangkok", coord: Coordinate(lon: 100.51667, lat: 13.75)),
            City(_id: 2950159, country: "DE", name: "Berlin", coord: Coordinate(lon: 13.41053, lat: 52.524368)),
            City(_id: 2643743, country: "GB", name: "London", coord: Coordinate(lon: -0.12574,lat: 51.50853)),
            City(_id: 5128638, country: "US", name: "New York", coord: Coordinate(lon: -74.005966, lat: 40.714272) ), 
            City(_id: 6359304, country: "ES", name: "Madrid", coord: Coordinate(lon: -3.68275, lat: 40.489349)),
            City(_id: 2968815, country: "FR", name: "Paris", coord: Coordinate(lon: 2.3486,lat: 48.853401)),
        ]
        var searchIndex = self.index
        cities.enumerated().forEach { index, city in
            searchIndex.insert(key: makeKey(city), value: index)
        }
        let repository = IndexedCitiesRepository(
            cities: cities,
            nameIndex: searchIndex
        )
        return repository
    }
}
