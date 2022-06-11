import Foundation

struct JSONCitiesRepositoryBuilder: BuilderProtocol {
    
    let data: Data
    var makeKey: (City) -> String
    var index: TextIndex = TrieTextIndex()
    var decoder: JSONDecoder = JSONDecoder()
    
    func build() throws -> CitiesRepositoryProtocol {
        let cities = try decoder.decode([City].self, from: data)
        var nameIndex = index
        cities.enumerated().forEach { index, city in
            nameIndex.insert(key: makeKey(city), value: index)
        }
        let repository = IndexedCitiesRepository(
            cities: cities,
            nameIndex: nameIndex
        )
        return repository
    }
}