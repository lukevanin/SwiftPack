import UIKit

struct MapModuleBuilder: BuilderProtocol {
    
    var city: City
    
    func build() -> UIViewController {
        MapViewController(city: city)
    }
}
