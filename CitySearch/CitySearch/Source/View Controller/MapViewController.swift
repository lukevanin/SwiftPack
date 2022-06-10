import UIKit
import MapKit

final class MapViewController: UIViewController {
    
    init(city: City) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MapViewController cannot be used in a storyboard or nib")
    }
}
