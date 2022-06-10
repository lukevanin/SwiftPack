import UIKit
import Combine

final class SearchViewController: UICollectionViewController {

    private var query: String = ""
    private var cities: [City] = []

    private var citiesCancellable: AnyCancellable?
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, City>!
    
    private let model: CitySearchModelProtocol
    
    init(model: CitySearchModelProtocol) {
        self.model = model
        let layoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let layoutGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(300)
            ),
            subitems: [layoutItem]
        )
        let layoutSection = NSCollectionLayoutSection(
            group: layoutGroup
        )
        let layout = UICollectionViewCompositionalLayout(
            section: layoutSection
        )
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("This view controller cannot be used from a Storyboard")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemGreen
        
        cellRegistration = UICollectionView.CellRegistration { cell, indexPath, city in
            let configuration = SearchResultViewContentConfiguration(
                title: "",
                subtitle: ""
            )
            cell.contentConfiguration = configuration
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        invalidateQuery()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnectViewModel()
    }
    
    // MARK: Model
    
    ///
    /// Start observing changes from the model. Update the view when the model changes.
    ///
    private func connectViewModel() {
        citiesCancellable = model.citiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                self?.updateCities(cities)
            }
    }
    
    ///
    /// Stop observing changes from the model. Any further changes made by the model are ignored.
    ///
    private func disconnectViewModel() {
        citiesCancellable?.cancel()
        citiesCancellable = nil
    }
    
    ///
    /// Update the list of cities displayed.
    ///
    private func updateCities(_ cities: [City]) {
        #warning("TODO: use diffable data source update - size permitting")
        self.cities = cities
        collectionView.reloadData()
    }
    
    ///
    /// Perform a search using the current query
    ///
    private func invalidateQuery() {
        model.searchByName(prefix: query)
    }
    
    // MARK: : UICollectionViewDelegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cities.count
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: cities[indexPath.item]
        )
    }
}
