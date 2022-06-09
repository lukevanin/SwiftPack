import UIKit

final class SearchViewController: UICollectionViewController {
    
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
    }


}

