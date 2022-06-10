import UIKit

struct CitySearchResultCellContentBuilder: BuilderProtocol {
    
    var city: City
    var coordinateFormat: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(3))
    
    func build() -> UIContentConfiguration {
        #warning("TODO: Localize string composition")
        let lon = city.coord.lon.formatted(coordinateFormat)
        let lat = city.coord.lat.formatted(coordinateFormat)
        return SearchResultViewContentConfiguration(
            title: "\(city.name), \(city.country)",
            subtitle: "\(lon) \(lat)"
        )
    }
}
