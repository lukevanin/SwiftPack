import UIKit

struct CitySearchResultCellContentBuilder: BuilderProtocol {
    
    var city: City
    var coordinateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    func build() -> UIContentConfiguration {
        #warning("TODO: Localize string composition")
        let lon = coordinateFormatter.string(from: NSNumber(value: city.coord.lon)) ?? "-"
        let lat = coordinateFormatter.string(from: NSNumber(value: city.coord.lat)) ?? "-"
        return SearchResultViewContentConfiguration(
            title: "\(city.name), \(city.country)",
            subtitle: "\(lon) \(lat)"
        )
    }
}
