import Foundation

struct JSONCitiesRepositoryBuilder: BuilderProtocol {
    
    let data: Data
    var makeKey: (City) -> String
    var index: TextIndex = TrieTextIndex()
    var decoder: JSONDecoder = JSONDecoder()
    
    func build() async throws -> CitiesRepositoryProtocol {
        try await withCheckedThrowingContinuation { [index] continuation in
            let cities: [City]
            do {
                cities = try decoder.decode([City].self, from: data)
            }
            catch {
                continuation.resume(with: .failure(error))
                return
            }
            var nameIndex = index
            cities.enumerated().forEach { index, city in
                nameIndex.insert(key: makeKey(city), value: index)
            }
            let repository = IndexedCitiesRepository(
                cities: cities,
                nameIndex: nameIndex
            )
            continuation.resume(with: .success(repository))
        }
    }
}
