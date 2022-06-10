import UIKit


struct SearchResultViewContentConfiguration: UIContentConfiguration {
    
    var title: String
    var subtitle: String
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
    func makeContentView() -> UIView & UIContentView {
        SearchResultView(configuration: self)
    }
}


final class SearchResultView: UIView, UIContentView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "title"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "subtitle"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    var configuration: UIContentConfiguration {
        didSet {
            invalidateConfiguration()
        }
    }
    
    init(configuration: SearchResultViewContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        initializeLayout()
        invalidateConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class cannot be used in a storyboard or nib")
    }
    
    private func initializeLayout() {
        
        let mapIconImageView: UIImageView = {
            let image = UIImage(
                systemName: "map.fill",
                withConfiguration: UIImage.SymbolConfiguration(
                    font: subtitleLabel.font
                )
            )
            let view = UIImageView(image: image)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tintColor = subtitleLabel.textColor
            return view
        }()

        let disclosureImageView: UIImageView = {
            let image = UIImage(systemName: "chevron.right")
            let view = UIImageView(image: image)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        let secondaryLayout: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.spacing = 8
            view.alignment = .leading
            view.distribution = .fill
            view.addArrangedSubview(mapIconImageView)
            view.addArrangedSubview(subtitleLabel)
            return view
        }()
        
        let textLayout: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.spacing = 8
            view.alignment = .leading
            view.distribution = .fillProportionally
            view.addArrangedSubview(titleLabel)
            view.addArrangedSubview(secondaryLayout)
            return view
        }()
        
        let contentLayout: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.alignment = .center
            view.distribution = .fill
            view.addArrangedSubview(textLayout)
            view.addArrangedSubview(disclosureImageView)
            return view
        }()

        addSubview(contentLayout)
        
        NSLayoutConstraint.activate([
            contentLayout.leftAnchor.constraint(
                equalTo: layoutMarginsGuide.leftAnchor
            ),
            contentLayout.rightAnchor.constraint(
                equalTo: layoutMarginsGuide.rightAnchor
            ),
            contentLayout.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            contentLayout.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
        ])
    }
    
    private func invalidateConfiguration() {
        guard let configuration = configuration as? SearchResultViewContentConfiguration else {
            return
        }
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
    }
}
