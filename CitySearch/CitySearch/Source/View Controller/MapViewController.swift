import UIKit
import MapKit

final class MapViewController: UIViewController {
    
    private let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let city: City
    private let initialSpan: CLLocationDistance
    
    init(city: City, initialSpan: CLLocationDistance = CLLocationDistance(50_000)) {
        self.city = city
        self.initialSpan = initialSpan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MapViewController cannot be used in a storyboard or nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = city.name
        edgesForExtendedLayout = .all
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(
                equalTo: view.leftAnchor
            ),
            mapView.rightAnchor.constraint(
                equalTo: view.rightAnchor
            ),
            mapView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            mapView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: city.coord.lat,
                longitude: city.coord.lon
            ),
            latitudinalMeters: initialSpan,
            longitudinalMeters: initialSpan
        )
        mapView.setRegion(region, animated: true)
    }
}
