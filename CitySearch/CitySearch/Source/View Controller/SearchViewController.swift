import UIKit
import Combine

protocol SearchViewControllerDelegate: AnyObject {
    func selectItem(item: City)
}

final class SearchViewController: UICollectionViewController {
    
    typealias MakeCellConfiguration = (_ city: City) -> UIContentConfiguration
    
    weak var delegate: SearchViewControllerDelegate?
    
    private let queryPlaceholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.caption = "Enter a city to search for" // TODO: Localize
        view.iconImageName = "map.fill"
        return view
    }()

    private let resultsPlaceholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.caption = "No cities found" // TODO: Localize
        view.iconImageName = "map.circle"
        return view
    }()

    private var query: String = ""
    private var cities: AnyCollection<City> = AnyCollection([])

    private var citiesCancellable: AnyCancellable?
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, UIContentConfiguration>!
    
    private let searchViewController: UISearchController
    private let model: CitySearchModelProtocol
    private let makeCellConfiguration: MakeCellConfiguration
    
    init(
        model: CitySearchModelProtocol,
        makeCellConfiguration: @escaping MakeCellConfiguration
    ) {
        self.model = model
        self.makeCellConfiguration = makeCellConfiguration
        self.searchViewController = UISearchController()
        let layoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let layoutGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)
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
        
        cellRegistration = UICollectionView.CellRegistration { cell, indexPath, configuration in
            cell.contentConfiguration = configuration
        }
        
        collectionView.backgroundView = {
            let view = UIView()
            view.addSubview(queryPlaceholderView)
            view.addSubview(resultsPlaceholderView)
            NSLayoutConstraint.activate([
                queryPlaceholderView.widthAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.widthAnchor,
                    constant: -64
                ),
                queryPlaceholderView.centerXAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.centerXAnchor
                ),
                queryPlaceholderView.centerYAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.centerYAnchor
                ),
                
                resultsPlaceholderView.widthAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.widthAnchor,
                    constant: -64
                ),
                resultsPlaceholderView.centerXAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.centerXAnchor
                ),
                resultsPlaceholderView.centerYAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.centerYAnchor
                ),
            ])
            return view
        }()
        
        collectionView.accessibilityIdentifier = "search-results"
        collectionView.keyboardDismissMode = .interactive
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
        
        setVisible(queryPlaceholder: false, resultsPlaceholder: false)
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
            .receive(on: RunLoop.main)
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
    private func updateCities(_ cities: AnyCollection<City>?) {
        #warning("TODO: use animated diffable data source update - size permitting")
        self.cities = cities ?? AnyCollection([])
        if let cities = cities {
            if cities.count > 0 {
                // Cities are visible. Hide the placeholders.
                setVisible(
                    queryPlaceholder: false,
                    resultsPlaceholder: false
                )
            }
            else {
                // No cities match the query. Show the results placeholder.
                setVisible(
                    queryPlaceholder: false,
                    resultsPlaceholder: true
                )
            }
        }
        else {
            // No query. Show query placeholder.
            setVisible(
                queryPlaceholder: true,
                resultsPlaceholder: false
            )
        }
        collectionView.reloadData()
    }
    
    ///
    /// Sets visibility of view elements.
    ///
    private func setVisible(queryPlaceholder: Bool, resultsPlaceholder: Bool) {
        queryPlaceholderView.isHidden = !queryPlaceholder
        resultsPlaceholderView.isHidden = !resultsPlaceholder
    }
    
    ///
    /// Perform a search using the current query
    ///
    private func invalidateQuery() {
        model.searchByName(prefix: query)
    }
    
    ///
    /// Returns the city for the given index path
    ///
    func getCity(at indexPath: IndexPath) -> City {
        cities[cities.index(cities.startIndex, offsetBy: indexPath.item)]
    }
    
    
    // MARK: : UICollectionViewDelegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectItem(item: getCity(at: indexPath))
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: makeCellConfiguration(getCity(at: indexPath))
        )
    }
}

extension SearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        invalidateQuery()
    }
}
